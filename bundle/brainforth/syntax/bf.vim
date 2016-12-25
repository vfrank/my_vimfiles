syn case match

syn match  bf_func            "\v^\s*\:\s*\S+"
syn match  bf_cfunc           "\v\<[^>]+\>"
syn match  bf_comment         "\v\/\/.*"
syn match  bf_comment_parens  "\v\(.*\)"
syn match  bf_include         "^\s*\(%:\|#\)\s*include\>\s*["<].*"

command -nargs=+ HiLink hi def link <args>

HiLink bf_func             Identifier
HiLink bf_cfunc            Special
HiLink bf_comment          Comment
HiLink bf_comment_parens   Comment
HiLink bf_include          Include

delcommand HiLink

" vim:ts=2:sw=2
