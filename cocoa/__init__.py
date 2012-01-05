# Created By: Virgil Dupras
# Created On: 2007-10-06
# Copyright 2011 Hardcoded Software (http://www.hardcoded.net)

# This software is licensed under the "BSD" License as described in the "LICENSE" file, 
# which should be included with this package. The terms are also available at 
# http://www.hardcoded.net/licenses/bsd_license

import logging
import time
import traceback
import subprocess
import sys

from .CocoaProxy import CocoaProxy
from .inter import signature
from .objcmin import NSBundle, NSExceptionHandler, NSLogAndHandleEveryExceptionMask, NSObject

proxy = CocoaProxy()

# About crash reporting: Normally, we want to get rid of the need for pyobjc and replace it with
# objp. But until we stop using it in our interfaces, we can't get rid of it because we need to use
# NSExceptionHandler's delegate because pyobjc intercepts exception (which means we can't just
# override sys.excepthook).

def report_crash(type, value, tb):
    mainBundle = NSBundle.mainBundle()
    app_identifier = mainBundle.bundleIdentifier()
    app_version = mainBundle.infoDictionary().get('CFBundleVersion', 'Unknown')
    s = "Application Identifier: {0}".format(app_identifier)
    s += "\nApplication Version: {0}\n\n".format(app_version)
    s += ''.join(traceback.format_exception(type, value, tb))
    HSErrorReportWindow = mainBundle.classNamed_('HSErrorReportWindow')
    if HSErrorReportWindow is None:
        logging.error(s)
        return
    if app_identifier:
        s += '\nRelevant Console logs:\n\n'
        p = subprocess.Popen(['grep', app_identifier, '/var/log/system.log'], stdout=subprocess.PIPE)
        try:
            s += str(p.communicate()[0], encoding='utf-8')
        except IndexError:
            # This can happen if something went wrong with the grep (permission errors?)
            pass
    HSErrorReportWindow.showErrorReportWithContent_(s)

try:
    from jobprogress.job import JobCancelled
    from jobprogress.performer import ThreadedJobPerformer as ThreadedJobPerformerBase
    class ThreadedJobPerformer(ThreadedJobPerformerBase):
        def _async_run(self, *args):
            proxy.createPool()
            target = args[0]
            args = tuple(args[1:])
            self._job_running = True
            self._last_error = None
            try:
                target(*args)
            except JobCancelled:
                pass
            except Exception:
                self._last_error = sys.exc_info()
                report_crash(*self._last_error)
            finally:
                self._job_running = False
                self.last_progress = None
                proxy.destroyPool()
except ImportError:
    # jobprogress isn't used in all HS apps
    pass


def as_fetch(as_list, as_type, step_size=1000):
    """When fetching items from a very big list through applescript, the connection with the app
    will timeout. This function is to circumvent that. 'as_type' is the type of the items in the 
    list (found in appscript.k). If we don't pass it to the 'each' arg of 'count()', it doesn't work.
    applescript is rather stupid..."""
    result = []
    # no timeout. default timeout is 60 secs, and it is reached for libs > 30k songs
    item_count = as_list.count(each=as_type, timeout=0)
    steps = item_count // step_size
    if item_count % step_size:
        steps += 1
    logging.info('Fetching %d items in %d steps' % (item_count, steps))
    # Don't forget that the indexes are 1-based and that the upper limit is included
    for step in range(steps):
        begin = step * step_size + 1
        end = min(item_count, begin + step_size - 1)
        if end > begin:
            result += as_list[begin:end](timeout=0)
        else: # When there is only one item, the stupid fuck gives it directly instead of putting it in a list.
            result.append(as_list[begin:end](timeout=0))
        time.sleep(.1)
    logging.info('%d items fetched' % len(result))
    return result

_exceptionHandlerDelegate = None
def install_exception_hook():
    # we need to retain this, cause the handler doesn't
    global _exceptionHandlerDelegate
    if _exceptionHandlerDelegate is not None:
        # already installed
        return
    def isPythonException(exception):
        return (exception.userInfo() or {}).get('__pyobjc_exc_type__') is not None

    class PyObjCExceptionDelegate(NSObject):
        @signature('c@:@@I')
        def exceptionHandler_shouldLogException_mask_(self, sender, exception, aMask):
            try:
                if exception.name() == 'NSAccessibilityException':
                    # These kind of exception are really weird and happen all the time with
                    # VoiceOver on.
                    return False
                if isPythonException(exception):
                    userInfo = exception.userInfo()
                    type = userInfo['__pyobjc_exc_type__']
                    value = userInfo['__pyobjc_exc_value__']
                    tb = userInfo.get('__pyobjc_exc_traceback__', [])
                    report_crash(type, value, tb)
                return True
            except Exception:
                # We can't allow the possibility of an exception coming out of this method or else
                # we get an infinite loop. Forget about trying to report the error and just let it
                # log to the console.
                return True
        
        @signature('c@:@@I')
        def exceptionHandler_shouldHandleException_mask_(self, sender, exception, aMask):
            return False
    
    delegate = PyObjCExceptionDelegate.alloc().init()
    NSExceptionHandler.defaultExceptionHandler().setExceptionHandlingMask_(NSLogAndHandleEveryExceptionMask)
    NSExceptionHandler.defaultExceptionHandler().setDelegate_(delegate)
    _exceptionHandlerDelegate = delegate
