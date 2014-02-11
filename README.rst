Overview
--------

Vim script for easily switching between code and unit tests for that code.

It expects a certain file naming convention that you can customize in
``~/.vim/test-switcher.cfg``.  See test-switcher.example.cfg for an
example.

The default convention is that tests for a Python module named foo.py
should reside in test_foo.py, in the tests subpackage:

    foo.py <-> tests/test_foo.py

At the moment there are no defaults for languages other than Python,
since I'm not familiar with the conventions of those languages.

Needs Vim 7.0, built with Python support.


Installation
------------

I recommend `Vundle <https://github.com/gmarik/vundle>`_, `pathogen
<https://github.com/tpope/vim-pathogen>`_ or `Vim Addon Manager
<https://github.com/MarcWeber/vim-addon-manager>`_.  E.g. with Vundle do ::

  :BundleInstall "mgedmin/test-switcher.vim"

Manual installation: copy ``plugin/test-switcher.vim`` and
``plugin/test_switcher.py`` to ``~/.vim/plugin/``.


Usage
-----

The following commands are defined:

:SwitchCodeAndTest
    switch the current buffer between the code file and the test file
    (or vice versa)

:TestForTheOtherWindow
    open the test file for the code file visible in the other window
    (or vice versa: the code file for the test file)

:OpenTestInOtherWindow
    change the buffer in the other window to show the test for the code
    file in the current window (or vice versa)


Configuration
-------------

Copy test-switcher.example.cfg to ``~/.vim/test-switcher.cfg`` and edit
it to specify custom filename patterns to match your projects.

You may want to add a mapping in your ``~/.vimrc``.  I like ::

    map <C-F6> :SwitchCodeAndTest<CR>


Copyright
---------

``test-switcher.vim`` was written by Marius Gedminas <marius@gedmin.as>.
Licence: MIT.
