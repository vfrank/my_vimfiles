" Vim plugin file
" Maintainer: kAtremer <katremer@yandex.ru>
" Last changed: 2007 Oct 16
"
" maximize.vim
" maximize gVim's window on startup on Win32
"
" to install, put the script and maximize.dll
" in $VIM\vimfiles\plugin

" Execute only once {{{
if exists("g:loaded_maximize") || !has('win32') || !has('win64')
	finish
endif

let g:loaded_maximize=1

" check if gvim is started from Eclipse.
" (Eclipse defines servername just a digit, like 1, 2, 3, etc.)
" so, if servername is a digit, then we should not call Maximize.
if v:servername =~ '\v^\d+$'
   finish
endif

" }}}
" Set the default compatibility options {{{
" (don't know if they do any difference, in such a small script...)
let s:save_cpoptions=&cpoptions
set cpoptions&vim
" }}}
let s:dllfile=expand('<sfile>:p:h').'/maximize.dll'
autocmd GUIEnter * call libcallnr(s:dllfile, 'Maximize', 1)
" Restore the saved compatibility options {{{
let &cpoptions=s:save_cpoptions
" }}}

" vim:fdm=marker:fmr={{{,}}}
