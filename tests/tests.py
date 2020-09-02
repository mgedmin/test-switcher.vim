import re
import pytest

from test_switcher import pattern2regex, try_match


# PEP-8 frowns upon column alignment.  PEP-8 is wrong.
@pytest.mark.parametrize('pattern, expected', [
    ('__init__.py', r'(^|/)__init__\.py$'),
    ('%.py',        r'(^|/)([^/]+)\.py$'),
    ('code/%.py',   r'(^|/)code/([^/]+)\.py$'),
    ('%/%.py',      r'(^|/)([^/]+)/\1\.py$'),
])
def test_pattern2regex(pattern, expected):
    assert pattern2regex(pattern) == re.compile(expected)


@pytest.mark.parametrize('filename, pattern, replacement, expected', [
    ('/home/user/src/project/src/module.py', '%.py', 'tests/test_%.py',
     '/home/user/src/project/src/tests/test_module.py'),
    ('/home/user/src/project/src/module.py', '%.py', 'tests.py',
     '/home/user/src/project/src/tests.py'),
    ('/home/user/src/project/src/tests.py', '%.py', 'tests.py',
     None),
    ('/project/src/module.py', '%/__init__.py', 'tests/test_%.py',
     None),
    ('/project/src/module.py', '%/__init__.py', 'tests/test_%.py',
     None),
    ('/project/src/module.py', '__init__.py', 'tests/test_%.py',
     None),
])
def test_try_match(filename, pattern, replacement, expected):
    assert try_match(filename, pattern, replacement) == expected
