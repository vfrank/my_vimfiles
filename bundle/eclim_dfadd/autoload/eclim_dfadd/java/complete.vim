

function! eclim_dfadd#java#complete#Init()

   if g:EclimJavaCompleteFuncSignature
      " NOTE: i can't use <expr> here like eclim_dfadd#java#complete#Maycomplete()
      "       because of i need to perform first part of mapping separately,
      "       to make text inserted in buffer before 
      "       eclim_dfadd#java#complete#switchRegion() is called

      inoremap <buffer> <silent> <C-Y> 
               \<c-r>=pumvisible() 
               \  ? "\<lt>C-P>\<lt>C-N>" 
               \  : "\<lt>C-Y>"<CR>
               \<c-r>=pumvisible() 
               \  ? "\<lt>C-Y>".eclim_dfadd#java#complete#switchRegion()."" 
               \  : ""<CR>

      inoremap <buffer> <silent> <Enter> 
               \<c-r>=pumvisible() 
               \  ? "\<lt>C-P>\<lt>C-N>" 
               \  : "\<lt>Enter>"<CR>
               \<c-r>=pumvisible() 
               \  ? "\<lt>C-Y>".eclim_dfadd#java#complete#switchRegion()."" 
               \  : ""<CR>

   endif
endfunc

function! eclim_dfadd#java#complete#switchRegion()
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

