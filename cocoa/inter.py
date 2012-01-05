# Created By: Virgil Dupras
# Created On: 2010-02-06
# Copyright 2011 Hardcoded Software (http://www.hardcoded.net)
# 
# This software is licensed under the "BSD" License as described in the "LICENSE" file, 
# which should be included with this package. The terms are also available at 
# http://www.hardcoded.net/licenses/bsd_license

# Interfaces for proxies in cocoalib

import logging

import objc

from .objcmin import NSObject, NSUserDefaults, NSArray, NSDictionary, NSWorkspace, NSURL

def signature(signature):
    """Returns an objc.signature with 'i' and 'f' letters changed to correct NSInteger and
    CGFloat values.
    """
    signature = bytes(signature, encoding='ascii')
    signature = signature.replace(b'i', objc._C_NSInteger)
    signature = signature.replace(b'I', objc._C_NSUInteger)
    signature = signature.replace(b'f', objc._C_CGFloat)
    return objc.typedSelector(signature)

def pythonify(o):
    """Changes 'o' into a python class (pyobjc_unicode --> u'', NSDictionary --> {}, NSArray --> [])
    """
    if o is None:
        return None
    elif isinstance(o, objc.pyobjc_unicode):
        return str(o)
    elif isinstance(o, (objc._pythonify.OC_PythonLong)):
        return int(o)
    elif isinstance(o, NSArray):
        return [pythonify(item) for item in o]
    elif isinstance(o, NSDictionary):
        return dict((pythonify(k), pythonify(v)) for k, v in list(o.items()))
    elif isinstance(o, (bool, int, list, dict, str)):
        return o # already pythonified
    logging.warning('Could not pythonify {0} (of type {1}'.format(repr(o), type(o)))
    return o

def subproxy(name, target_name, class_):
    def result(self):
        holder_name = '_' + name
        if not hasattr(self, holder_name):
            target = getattr(self.py, target_name)
            setattr(self, holder_name, class_.alloc().initWithPy_(target))
        return getattr(self, holder_name)
    
    result.__name__ = name
    return result

class PyGUIObject(NSObject):
    def initWithCocoa_pyParent_(self, cocoa, pyparent):
        super(PyGUIObject, self).init()
        self.cocoa = cocoa
        self.py = self.py_class(self, pyparent.py)
        return self
    
    def initWithPy_(self, py):
        # Use this for 2-steps instantiation, for example if our py instance is driven by the core
        # instead of the GUI. However, make sure to call bindCocoa_() before actual usage.
        super(PyGUIObject, self).init()
        self.cocoa = None
        self.py = py
        return self
    
    def bindCocoa_(self, cocoa):
        self.cocoa = cocoa
        self.py.view = self
    
    def connect(self):
        if hasattr(self.py, 'connect'):
            self.py.connect()
    
    def disconnect(self):
        if hasattr(self.py, 'disconnect'):
            self.py.disconnect()
    
    def free(self):
        # call this method only when you don't need to use this proxy anymore. you need to call this
        # if you want to release the cocoa side (self.cocoa is holding a refcount)
        # We don't delete py, it might be called after the free. It will be garbage collected anyway.
        # The if is because there is something happening giving a new ref to cocoa right after
        # the free, and then the ref gets to 1 again, free is called again.
        self.disconnect()
        if hasattr(self, 'cocoa'):
            del self.cocoa
    
    #--- Python -> Cocoa
    def refresh(self):
        self.cocoa.refresh()
    

class PyColumns(PyGUIObject):
    def columnNamesInOrder(self):
        return self.py.colnames
    
    def columnDisplay_(self, colname):
        return self.py.column_display(colname)
    
    @signature('i@:@')
    def columnIsVisible_(self, colname):
        return self.py.column_is_visible(colname)
    
    @signature('i@:@')
    def columnWidth_(self, colname):
        return self.py.column_width(colname)
    
    @signature('v@:@i')
    def moveColumn_toIndex_(self, colname, index):
        self.py.move_column(colname, index)
    
    @signature('v@:@i')
    def resizeColumn_toWidth_(self, colname, newwidth):
        self.py.resize_column(colname, newwidth)
    
    @signature('v@:@i')
    def setColumn_defaultWidth_(self, colname, width):
        self.py.set_default_width(colname, width)
    
    def menuItems(self):
        return self.py.menu_items()
    
    @signature('c@:i')
    def toggleMenuItem_(self, index):
        return self.py.toggle_menu_item(index)
    
    def resetToDefaults(self):
        self.py.reset_to_defaults()
    
    #--- Python --> Cocoa
    def restore_columns(self):
        self.cocoa.restoreColumns()
    
    def set_column_visible(self, colname, visible):
        self.cocoa.setColumn_visible_(colname, visible)

class PyOutline(PyGUIObject):
    columns = subproxy('columns', 'columns', PyColumns)
    
    def cancelEdits(self):
        self.py.cancel_edits()
    
    @signature('c@:@@')
    def canEditProperty_atPath_(self, propname, path):
        node = self.py.get_node(path)
        assert node is self.py.selected_node
        return getattr(node, 'can_edit_' + propname, False)
    
    def saveEdits(self):
        self.py.save_edits()
    
    def selectedPath(self):
        return self.py.selected_path
    
    def setSelectedPath_(self, path):
        self.py.selected_path = path
    
    def selectedPaths(self):
        return self.py.selected_paths
    
    def setSelectedPaths_(self, paths):
        self.py.selected_paths = paths
    
    def property_valueAtPath_(self, property, path):
        try:
            return getattr(self.py.get_node(path), property)
        except IndexError:
            logging.warning("%r doesn't have a node at path %r", self.py, path)
            return ''
    
    def setProperty_value_atPath_(self, property, value, path):
        setattr(self.py.get_node(path), property, value)
    
    #--- Python -> Cocoa
    def start_editing(self):
        self.cocoa.startEditing()
    
    def stop_editing(self):
        self.cocoa.stopEditing()
    
    def update_selection(self):
        self.cocoa.updateSelection()
    

class PyTable(PyGUIObject):
    columns = subproxy('columns', 'columns', PyColumns)
    
    #--- Helpers
    def _getrow(self, row):
        try:
            return self.py[row]
        except IndexError:
            msg = "Trying to get an out of bounds row ({} / {}) on table {}"
            logging.warning(msg.format(row, len(self.py), self.py.__class__.__name__))
    
    #--- Cocoa --> Python
    def add(self):
        self.py.add()
    
    def cancelEdits(self):
        self.py.cancel_edits()
    
    @signature('c@:@i')
    def canEditColumn_atRow_(self, column, row):
        return self.py.can_edit_cell(column, row)
    
    def deleteSelectedRows(self):
        self.py.delete()
    
    @signature('i@:')
    def numberOfRows(self):
        return len(self.py)
    
    def saveEdits(self):
        self.py.save_edits()
    
    def selectRows_(self, rows):
        self.py.select(list(rows))
    
    def selectedRows(self):
        return self.py.selected_indexes
    
    def selectionAsCSV(self):
        return self.py.selection_as_csv()
    
    @signature('v@:@@i')
    def setValue_forColumn_row_(self, value, column, row):
        # this try except is important for the case while a row is in edition mode and the delete
        # button is clicked.
        try:
            self._getrow(row).set_cell_value(column, value)
        except AttributeError:
            msg = "Trying to set an attribute that can't: {} with value {} at row {} on table {}"
            logging.warning(msg.format(column, value, row, self.py.__class__.__name__))
            raise
    
    @signature('v@:@c')
    def sortByColumn_desc_(self, column, desc):
        self.py.sort_by(column, desc=desc)
    
    @signature('@@:@i')
    def valueForColumn_row_(self, column, row):
        return self._getrow(row).get_cell_value(column)
    
    #--- Python -> Cocoa
    def show_selected_row(self):
        self.cocoa.showSelectedRow()
    
    def start_editing(self):
        self.cocoa.startEditing()
    
    def stop_editing(self):
        self.cocoa.stopEditing()
    
    def update_selection(self):
        self.cocoa.updateSelection()
    

class PySelectableList(PyGUIObject):
    def items(self):
        # Should normally always return strings
        return self.py[:]
    
    @signature('v@:i')
    def selectIndex_(self, index):
        self.py.select(index)
    
    @signature('i@:')
    def selectedIndex(self):
        result = self.py.selected_index
        if result is None:
            result = -1
        return result
    
    def selectedIndexes(self):
        return self.py.selected_indexes
    
    def selectIndexes_(self, indexes):
        self.py.select(indexes)
    
    @signature('i@:@')
    def searchByPrefix_(self, prefix):
        return self.py.search_by_prefix(prefix)
    
    #--- model --> view
    def update_selection(self):
        self.cocoa.updateSelection()
    

class PyFairware(NSObject):
    def initialRegistrationSetup(self):
        self.py.initial_registration_setup()
    
    def appName(self):
        return self.py.PROMPT_NAME
    
    @signature('c@:')
    def isRegistered(self):
        return self.py.registered
    
    @signature('c@:@@c')
    def setRegisteredCode_andEmail_registerOS_(self, code, email, registerOS):
        return self.py.set_registration(code, email, registerOS)
    
    def unpaidHours(self):
        return self.py.unpaid_hours
    
    def contribute(self):
        self.py.contribute()
    
    def buy(self):
        self.py.buy()
    
    def aboutFairware(self):
        self.py.about_fairware()
    
    #--- Python --> Cocoa
    def get_default(self, key_name):
        raw = NSUserDefaults.standardUserDefaults().objectForKey_(key_name)
        result = pythonify(raw)
        return result
    
    def set_default(self, key_name, value):
        NSUserDefaults.standardUserDefaults().setObject_forKey_(value, key_name)
    
    def setup_as_registered(self):
        self.cocoa.setupAsRegistered()
    
    def show_fairware_nag(self, prompt):
        self.cocoa.showFairwareNagWithPrompt_(prompt)
    
    def show_demo_nag(self, prompt):
        self.cocoa.showDemoNagWithPrompt_(prompt)
    
    def open_url(self, url):
        NSWorkspace.sharedWorkspace().openURL_(NSURL.URLWithString_(url))
    
    def show_message(self, msg):
        self.cocoa.showMessage_(msg)
