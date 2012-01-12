import logging
from objp.util import pyref, dontwrap

class GUIObjectView:
    def refresh(self): pass

class PyGUIObject:
    def __init__(self, model: pyref):
        self.model = model
        self.callback = None
    
    # This *has* to be called right after initialization.
    def bindCallback_(self, callback: pyref):
        self.callback = callback
        self.model.view = self
    
    def connect(self):
        if hasattr(self.model, 'connect'):
            self.model.connect()
    
    def disconnect(self):
        if hasattr(self.model, 'disconnect'):
            self.model.disconnect()
    
    def free(self):
        # call this method only when you don't need to use this proxy anymore. you need to call this
        # if you want to release the cocoa side (self.callback is holding a refcount)
        # We don't delete py, it might be called after the free. It will be garbage collected anyway.
        # The if is because there is something happening giving a new ref to cocoa right after
        # the free, and then the ref gets to 1 again, free is called again.
        self.disconnect()
        if hasattr(self, 'callback'):
            del self.callback
    
    #--- Python -> Cocoa
    @dontwrap
    def refresh(self):
        self.callback.refresh()

class SelectableListView(GUIObjectView):
    def updateSelection(self): pass

class PySelectableList2(PyGUIObject):
    def items(self) -> list:
        # Should normally always return strings
        return self.model[:]
    
    def selectIndex_(self, index: int):
        self.model.select(index)
    
    def selectedIndex(self) -> int:
        result = self.model.selected_index
        if result is None:
            result = -1
        return result
    
    def selectedIndexes(self) -> list:
        return self.model.selected_indexes
    
    def selectIndexes_(self, indexes: list):
        self.model.select(indexes)
    
    def searchByPrefix_(self, prefix: str) -> int:
        return self.model.search_by_prefix(prefix)
    
    #--- model --> view
    @dontwrap
    def update_selection(self):
        self.callback.updateSelection()

class ColumnsView:
    def restoreColumns(self): pass
    def setColumn_visible_(self, colname: str, visible: bool): pass

class PyColumns2(PyGUIObject):
    def columnNamesInOrder(self) -> list:
        return self.model.colnames
    
    def columnDisplay_(self, colname: str) -> str:
        return self.model.column_display(colname)
    
    def columnIsVisible_(self, colname: str) -> bool:
        return self.model.column_is_visible(colname)
    
    def columnWidth_(self, colname: str) -> int:
        return self.model.column_width(colname)
    
    def moveColumn_toIndex_(self, colname: str, index: int):
        self.model.move_column(colname, index)
    
    def resizeColumn_toWidth_(self, colname: str, newwidth: int):
        self.model.resize_column(colname, newwidth)
    
    def setColumn_defaultWidth_(self, colname: str, width: int):
        self.model.set_default_width(colname, width)
    
    def menuItems(self) -> list:
        return self.model.menu_items()
    
    def toggleMenuItem_(self, index: int) -> bool:
        return self.model.toggle_menu_item(index)
    
    def resetToDefaults(self):
        self.model.reset_to_defaults()
    
    #--- Python --> Cocoa
    @dontwrap
    def restore_columns(self):
        self.callback.restoreColumns()
    
    @dontwrap
    def set_column_visible(self, colname: str, visible):
        self.callback.setColumn_visible_(colname, visible)

class OutlineView(GUIObjectView):
    def startEditing(self): pass
    def stopEditing(self): pass
    def updateSelection(self): pass

class PyOutline(PyGUIObject):
    def cancelEdits(self):
        self.model.cancel_edits()
    
    def canEditProperty_atPath_(self, property: str, path: list) -> bool:
        node = self.model.get_node(path)
        assert node is self.model.selected_node
        return getattr(node, 'can_edit_' + property, False)
    
    def saveEdits(self):
        self.model.save_edits()
    
    def selectedPath(self) -> list:
        return self.model.selected_path
    
    def setSelectedPath_(self, path: list):
        self.model.selected_path = path
    
    def selectedPaths(self) -> list:
        return self.model.selected_paths
    
    def setSelectedPaths_(self, paths: list):
        self.model.selected_paths = paths
    
    def property_valueAtPath_(self, property: str, path: list) -> object:
        try:
            return getattr(self.model.get_node(path), property)
        except IndexError:
            logging.warning("%r doesn't have a node at path %r", self.model, path)
            return ''
    
    def setProperty_value_atPath_(self, property: str, value: object, path: list):
        setattr(self.model.get_node(path), property, value)
    
    #--- Python -> Cocoa
    @dontwrap
    def start_editing(self):
        self.callback.startEditing()
    
    @dontwrap
    def stop_editing(self):
        self.callback.stopEditing()
    
    @dontwrap
    def update_selection(self):
        self.callback.updateSelection()