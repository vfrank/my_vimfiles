" Prepare the snippet engine
function! snippets#dfrank_code_complete#init()
  "echo 'Initializing stuffs'

  inoremap <buffer> <silent> <C-Y> 
           \<c-r>=pumvisible() 
           \  ? "\<lt>C-P>\<lt>C-N>" 
           \  : "\<lt>C-Y>"<CR>
           \<c-r>=pumvisible() 
           \  ? "\<lt>C-Y>".snippets#dfrank_code_complete#switch_region()."" 
           \  : ""<CR>

  inoremap <buffer> <silent> <Enter> 
           \<c-r>=pumvisible() 
           \  ? "\<lt>C-P>\<lt>C-N>" 
           \  : "\<lt>Enter>"<CR>
           \<c-r>=pumvisible() 
           \  ? "\<lt>C-Y>".snippets#dfrank_code_complete#switch_region()."" 
           \  : ""<CR>

endfunction

function! snippets#dfrank_code_complete#switch_region()
   "return SwitchRegion()

   let s:lPos = getpos('.')
   let l:lList = searchpos('\V`', 'b')
   call setpos('.', s:lPos)
   if s:lPos[2] == l:lList[1] + 1

      "normal 0
      "call search('\V`<','c',line('.'))
      return SwitchRegion()

   endif
   return ""

endfunction

" Add a snippet to be triggered
" fullname: contain an unmangled name. ex: strcat(char *dest, const char *src)
" args_pos: contain the position of the argument in fullname. ex [ [8, 17], [20, 34] ]
" Returns: text to be inserted for when trigger() is called
function! snippets#dfrank_code_complete#add_snippet(fullname, args_pos)
   let l:res = ''
   let l:prev_idx = 0
   for elt in a:args_pos
      let l:res .= a:fullname[l:prev_idx : elt[0] - 1] . '`'.'<' . a:fullname[elt[0] : elt[1] - 1] . '>'.'`'
      let l:prev_idx = elt[1]
   endfor

   let l:res .= a:fullname[l:prev_idx : ]
   if len(a:args_pos) > 0
      if g:clang_trailing_placeholder == 1
         let l:res .= '`'.'<>'.'`'
      else
         " strip last closing bracket
         let l:res = strpart(l:res, 0, strlen(l:res) - 1)
      endif
   endif

   return l:res
endfunction

" Trigger the snippet
" Note: usually as simple as triggering the tab key
function! snippets#dfrank_code_complete#trigger()
   "if pumvisible() != 0
      "return
   "endif

   "" Do we need to launch UpdateSnippets()?
   "let l:line = getline('.'  )
   "let l:pattern = '`'.'<[^`]*>'.'`'
   "if match(l:line, l:pattern) == -1
      "return
   "endif
   "call feedkeys("\<tab>")
endfunction

" Remove all snippets
function! snippets#dfrank_code_complete#reset()
  "echo 'Resetting all snippets'
endfunction
