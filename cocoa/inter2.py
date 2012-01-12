from objp.util import pyref, dontwrap

class GUIObjectView:
    def refresh(self): pass

class PyGUIObject:
    def __init__(self, model: pyref, callback: pyref):
        self.model = model
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
        # if you want to release the cocoa side (self.cocoa is holding a refcount)
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