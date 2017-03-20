" ecto.vim - for working with Elixir apps that use Ecto
" Author:       Josh Branchaud (joshbranchaud.com)
" GetLatestVimScripts:

" Install this file as plugin/ecto.vim.

if exists('g:loaded_ecto')
  finish
endif
let g:loaded_ecto = 1

if !exists('g:did_load_ftplugin')
  filetype plugin on
endif
if !exists('g:loaded_projectionist')
  runtime! plugin/projectionist.vim
endif

" adaptation of vim-rails project detection
function! EctoDetect(...) abort
  if exists('b:ecto_root')
    return 1
  endif
  let fn = fnamemodify(a:0 ? a:1 : expand('%'), ':p')
  if !isdirectory(fn)
    let fn = fnamemodify(fn, ':h')
  endif
  let file = findfile('mix.exs', escape(fn, ', ').';')
  if !empty(file) && isdirectory(fnamemodify(file, ':p:h') . '/priv')
    let b:ecto_root = fnamemodify(file, ':p:h')
    return 1
  endif
endfunction

function! s:ProjectName() abort
  return fnamemodify(b:ecto_root, ':t')
endfunction

" Section: Utility

function! s:Capitalize(str) abort
  return join([toupper(strpart(a:str, 0, 1)), strpart(a:str, 1)], '')
endfunction

function! s:CamelCase(str) abort
  let parts = split(a:str, '_')
  let result = parts[0]
  for part in parts[1:]
    let result = result.s:Capitalize(part)
  endfor
  return result
endfunction

function! s:Modulize(str) abort
  return s:Capitalize(s:CamelCase(a:str))
endfunction

let s:ecto_projections = {}

function! SetupEctoProjections(projections) abort
  if exists('b:ecto_root')
    call projectionist#append(b:ecto_root, a:projections)
  endif
endfunction

function! SetupEcto() abort
  if !exists('b:ecto_root')
    return 0
  else
    command! Eecto :exe s:OpenLatestMigration()
  endif
endfunction

function! s:MigrationsPath() abort
  return b:ecto_root."/priv/repo/migrations/"
endfunction

function! s:OpenLatestMigration() abort
  let migrations = split(globpath(s:MigrationsPath(), '*'), "\n")
  let latest_migration = migrations[-1]
  execute ":e ".latest_migration
endfunction


augroup ecto_project
  autocmd!
  autocmd BufNewFile,BufReadPost *
        \ if EctoDetect(expand("<afile>:p")) && empty(&filetype) |
        \   call SetupEcto() |
        \ endif
  autocmd VimEnter *
        \ if empty(expand("<amatch>")) && EctoDetect(getcwd()) |
        \   call SetupEcto() |
        \ endif
  autocmd FileType netrw EctoDetect()
  autocmd FileType * if EctoDetect() | call SetupEcto() | endif

  autocmd User ProjectionistDetect
        \ if EctoDetect() |
        \   call SetupEctoProjections(s:ecto_projections) |
        \ endif

  autocmd BufNewFile,BufReadPost *.ex,*.exs set filetype=elixir
  " autocmd BufNewFile,BufReadPost * echom '<amatch>'
augroup END

function! EctoSayHello()
  echo "Hello, World!"
endfunction

nnoremap <leader>z :call EctoSayHello()<CR>

command! EctoHello :exe EctoSayHello()

" vim:set sw=2 sts=2:
