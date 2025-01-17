'''
Created on Feb 19, 2013

@author: undesa
'''


from org.apache.log4j import Logger

LOG = Logger.getLogger("glue")



class COLOR(object):
    """
    Color definitions used for color-coding significant runtime events 
    or raised exceptions as applied on python print() function
    """
    
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'

    def disable(self):
        self.HEADER = ''
        self.OKBLUE = ''
        self.OKGREEN = ''
        self.WARNING = ''
        self.FAIL = ''
        self.ENDC = ''


class ParliamentCacheInfo:
    
    def __init__(self, no_of_parls = 1, p_info = []):
        self.no_of_parliaments = no_of_parls
        self.parl_info = p_info
    
    def is_cache_satisfied(self):
        print "XXXX is_cache_satisfied ", self.parl_info
        if self.parl_info is None:
            return False
        else:
            return self.no_of_parliaments == len(self.parl_info)

def close_quietly(handle):
    """
    Always use this close to close any File, Stream or Response Handles
    This closes all handles in a exception safe manner
    """
    try:
        if (handle is not None):
            handle.close()
    except Exception, ex:
        LOG.error("Error while closing handle", ex)
        

def get_module_dir():
    import os
    return os.path.dirname(os.path.realpath(__file__))

def get_module_file(file_name):
    import os
    return os.path.join(get_module_dir(),file_name)
    