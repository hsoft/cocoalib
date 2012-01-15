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

proxy = CocoaProxy()

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

def report_crash(type, value, tb):
    app_identifier = proxy.bundleIdentifier()
    app_version = proxy.appVersion()
    osx_version = proxy.osxVersion()
    s = "Application Identifier: {}\n".format(app_identifier)
    s += "Application Version: {}\n".format(app_version)
    s += "Mac OS X Version: {}\n\n".format(osx_version)
    s += ''.join(traceback.format_exception(type, value, tb))
    if app_identifier:
        s += '\nRelevant Console logs:\n\n'
        p = subprocess.Popen(['grep', app_identifier, '/var/log/system.log'], stdout=subprocess.PIPE)
        try:
            s += str(p.communicate()[0], encoding='utf-8')
        except IndexError:
            # This can happen if something went wrong with the grep (permission errors?)
            pass
    proxy.reportCrash_(s)

def install_exception_hook():
    sys.excepthook = report_crash
