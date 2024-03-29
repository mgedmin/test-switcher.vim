" File: test-switcher.vim
" Author: Marius Gedminas <marius@gedmin.as>
" Version: 2.0.1
" Last Modified: 2022-09-20
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
" I recommend a plugin manager like vim-plug.
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

if has('python') || has('python3')
  let s:python = has('python3') ? 'python3' : 'python'
  exec s:python "import test_switcher # see test_switcher.py"
endif

" Utility function: switch to buffer containing file or open a new buffer
function! SwitchToFile(name, bang)
  let tmp = bufnr(a:name)
  if tmp != -1 && fnamemodify(bufname(tmp), ":p") == fnamemodify(a:name, ":p")
    if &verbose >= 2
      echo 'edit #' . tmp
    endif
    exe 'edit #' . tmp
  elseif a:bang != "" || filereadable(a:name)
    if &verbose >= 2
      echo 'edit ' . a:name
    endif
    exe 'edit ' . a:name
  endif
endf


" If you're editing /path/to/foo.py, open /path/to/tests/test_foo.py
function! SwitchCodeAndTest(bang, count)
  if has('python') || has('python3')
    exec s:python "test_switcher.switch_code_and_test(verbose=int(vim.eval('&verbose')), new_file_allowed=bool(vim.eval('a:bang')), nth=int(vim.eval('a:count')))"
    return
  endif
  echo "Python not available, using hardcoded fallback logic"
  if count != 1
    echo "ignoring count"
  endif
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
command! -bang -bar -count=1 SwitchCodeAndTest      call SwitchCodeAndTest(<q-bang>, <count>)


function! OpenTestInOtherWindow(bang, count)
  let bn = bufnr('%')
  wincmd p
  exe "buffer" . bn
  call SwitchCodeAndTest(a:bang, a:count)
endf
command! -bang -bar -count=1 OpenTestInOtherWindow  call OpenTestInOtherWindow(<q-bang>, <count>)


function! TestForTheOtherWindow(bang, count)
  wincmd p
  let bn = bufnr('%')
  wincmd p
  exe "buffer" . bn
  call SwitchCodeAndTest(a:bang, a:count)
endf
command! -bang -bar -count=1 TestForTheOtherWindow  call TestForTheOtherWindow(<q-bang>, <count>)
