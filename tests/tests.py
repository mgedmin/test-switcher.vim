import re

import pytest

from test_switcher import pattern2regex, prepare_replacement, try_match


# PEP-8 frowns upon column alignment.  PEP-8 is wrong.
@pytest.mark.parametrize('pattern, replacement, expected', [
    ('__init__.py', 'tests.py',          r'(^|/)__init__\.py$'),
    ('%.py',        'test_%.py',         r'(^|/)([^/]+)\.py$'),
    ('code/%.py',   'tests/test_%.py',   r'(^|/)code/([^/]+)\.py$'),
    ('%/%.py',      'tests/test_%.py',   r'(^|/)([^/]+)/\1\.py$'),
    ('%/%.py',      'tests/%/test_%.py', r'(^|/)([^/]+)/([^/]+)\.py$'),
])
def test_pattern2regex(pattern, replacement, expected):
    assert pattern2regex(pattern, replacement) == re.compile(expected)


@pytest.mark.parametrize('pattern, replacement, expected', [
    ('__init__.py',   'tests.py',          r'\1tests.py'),
    ('%.py',          'test_%.py',         r'\1test_\2.py'),
    ('%/__init__.py', 'tests/%/test_%.py', r'\1tests/\2/test_\2.py'),
    ('%/%.py',        'tests/%/test_%.py', r'\1tests/\2/test_\3.py'),
    # this is an incorrect case, but we don't want to crash
    ('__init__.py',   'test_%.py',         r'\1test_\2.py'),
])
def test_prepare_replacement(pattern, replacement, expected):
    assert prepare_replacement(pattern, replacement) == expected


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
    # case: one wildcard used twice in the replacements
    ('/project/src/pkg/__init__.py', '%/__init__.py', '%/tests/test_%.py',
     '/project/src/pkg/tests/test_pkg.py'),
    # case: matches but there's no wildcard to use in the replacement!
    ('/project/src/pkg/__init__.py', '__init__.py', '%/tests/test_%.py',
     None),
])
def test_try_match(filename, pattern, replacement, expected):
    assert try_match(filename, pattern, replacement) == expected
