" Vim syntax file

" For version 5.x: Clear all syntax items
" For version 6.x: Quit when a syntax file was already loaded
if version < 600
   syntax clear
elseif exists("b:current_syntax")
   finish
endif

" turn case on
syn case match

syn region buffet_project_name      start="\[" end="\]"
syn region buffet_buftype           start="\*" end="\*"
syn match  buffet_mark_curfile      ">"
syn match  buffet_mark_curfile      "<"
syn match  buffet_mark_modified     "\V(+)"
syn match  buffet_noname            "\[No name\]"

" Define the default highlighting.
" For version 5.7 and earlier: only when not done already
" For version 5.8 and later: only when an item doesn't have highlighting yet
if version >= 508 || !exists("did_buffet_syntax_inits")
   if version < 508
      let did_buffet_syntax_inits = 1
      command -nargs=+ HiLink hi link <args>
   else
      command -nargs=+ HiLink hi def link <args>
   endif

   HiLink buffet_project_name       Special
   HiLink buffet_mark_curfile       Identifier
   HiLink buffet_mark_modified      Identifier
   HiLink buffet_buftype            Comment
   HiLink buffet_noname             None

   delcommand HiLink
endif

" include filetypes highlighting stuff by dfrank
runtime! syntax/filetypes_highlight.vim

let b:current_syntax = "buffet"

" vim:ts=3:sw=3
