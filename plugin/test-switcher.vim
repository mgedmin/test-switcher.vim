" File: test-switcher.vim
" Author: Marius Gedminas <marius@gedmin.as>
" Version: 1.1.0
" Last Modified: 2014-11-10
"
" Overview
" --------
" Vim script to help switch between code modules and unit test modules.
"
" Probably very specific to the way I work (Zope 3 style unit tests)
"
"
" Other more or less similar plugins for this:
"   vim-pyunit -- http://github.com/nvie/vim-pyunit
"   FSwitch -- http://www.vim.org/scripts/script.php?script_id=2590
"   a.vim -- http://www.vim.org/scripts/script.php?script_id=31
"
"
" Installation
" ------------
" Copy this file and test_switcher.py to $HOME/.vim/plugin directory.
"
" You need vim compiled with Python support.  There's some fallback code
" in pure VimL, but it isn't very smart, and it isn't configurable.
"
"
" Usage
" -----
"
" Map a key (e.g. Ctrl-F6) to :SwitchCodeAndTest.  Press it whenever you want
" to switch the current buffer between foo.py and the corresponding
" tests/test_foo.py.
"
" There are two other commands, :TestForTheOtherWindow, that opens the
" corresponding test file for the code currently visible in the next window
" (when you have a split view), and :OpenTestInOtherWindow which changes the
" buffer in the other window to the test module for the current buffer.
"
" If you want a new file to be created using one of the recognized test
" patterns, add a ! to the command, e.g. :SwitchCodeAndTest!

if has('python')
  python import sys, vim
  python if vim.eval('expand("<sfile>:p:h")') not in sys.path:
    \        sys.path.append(vim.eval('expand("<sfile>:p:h")'))
  python import test_switcher # see test_switcher.py
endif

" Utility function: switch to buffer containing file or open a new buffer
function! SwitchToFile(name, bang)
  let tmp = bufnr(a:name)
  if tmp != -1
    exe 'edit #'. tmp
  elseif a:bang != ""
    exe 'edit ' . a:name
  endif
endf


" If you're editing /path/to/foo.py, open /path/to/tests/test_foo.py
function! SwitchCodeAndTest(bang)
  if has('python')
    python test_switcher.switch_code_and_test(verbose=int(vim.eval('&verbose')), new_file_allowed=bool(vim.eval('a:bang')))
    return
  endif
  echo "Python not available, using hardcoded fallback logic"
  if expand('%:p:h:t') == 'tests'
    let filename = substitute(expand('%:p'), "tests/test_", "", "")
    let package = fnamemodify(filename, ':h:t')
    let name = fnamemodify(filename, ':t:r')
    if !filereadable(filename) && package == name
      let filename = fnamemodify(filename, ':h') . '/__init__.py'
    endif
    call SwitchToFile(filename, a:bang)
  elseif match(expand('%:t'), "^test_") == 0
    let filename = substitute(expand('%:p'), "test_", "", "")
    call SwitchToFile(filename, a:bang)
  else
    let filename = expand('%:t')
    if filename == '__init__.py'
      let filename = expand('%:p:h:t') . '.py'
    endif
    let dir = expand('%:h') 
    let dir = dir == "" ? "" : dir . "/"
    let proper_test_fn = dir . 'tests/test_' . filename
    if filereadable(dir . 'tests.py') && !filereadable(proper_test_fn)
      call SwitchToFile(dir . 'tests.py', a:bang)
    elseif filereadable(dir . 'test_' . filename) && !filereadable(proper_test_fn)
      call SwitchToFile(dir . 'test_' . filename, a:bang)
    else
      call SwitchToFile(proper_test_fn, a:bang)
    endif
  endif
endf
command! -bang -bar -count=1 SwitchCodeAndTest      call SwitchCodeAndTest(<q-bang>)


function! OpenTestInOtherWindow(bang)
  let bn = bufnr('%')
  wincmd p
  exe "buffer" . bn
  call SwitchCodeAndTest(a:bang)
endf
command! -bang -bar OpenTestInOtherWindow           call OpenTestInOtherWindow(<q-bang>)


function! TestForTheOtherWindow()
  wincmd p
  let bn = bufnr('%')
  wincmd p
  exe "buffer" . bn
  call SwitchCodeAndTest(a:bang)
endf
command! -bang -bar TestForTheOtherWindow          call TestForTheOtherWindow(<q-bang>)
