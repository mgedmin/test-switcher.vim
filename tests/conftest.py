import os
import sys


source_path = os.path.join(
    os.path.dirname(os.path.dirname(os.path.abspath(__file__))), 'pythonx')
sys.path.append(source_path)


class VimStub(object):
    pass


try:
    import vim
    del vim
except ImportError:
    sys.modules['vim'] = VimStub()
