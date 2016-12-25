
" ---------------------- dotcomplete

" Check if the cursor is in comment or string
function! phpcomplete_dfadd#complete#IsCursorInCommentOrString()
   return match(synIDattr(synID(line("."), col(".")-1, 1), "name"), '\v\Comment|String')>=0
endfunc

" Check if we can use omni completion in the current buffer
function! phpcomplete_dfadd#complete#CanUseEclimCompletion()
   " For Java files and only if the omnifunc is eclim#java#complete#CodeComplete
   "return (index(['php'], &filetype) >= 0 && &completefunc == 'eclim#java#complete#CodeComplete' && !phpcomplete_dfadd#complete#IsCursorInCommentOrString())

   let index = col('.') - 2
   if index >= 0
      let prev_char = getline('.')[index]
   else
      let prev_char = ''
   endif
   return (index(['php'], &filetype) >= 0  && !phpcomplete_dfadd#complete#IsCursorInCommentOrString() && index >= 0 && (prev_char == '-' || prev_char == ':'))

endfunc

" Return the mapping of omni completion
function! phpcomplete_dfadd#complete#Maycomplete()
   let szOmniMapping = "\<C-X>\<C-O>"

   " g:EclimJavaCompleteSelectFirstItem
   "     0 = don't select first item
   "     1 = select first item (inserting it to the text, default vim behaviour)
   "     2 = select first item (without inserting it to the text)
   if g:EclimJavaCompleteSelectFirstItem == 0
      " We have to force the menuone option to avoid confusion when there is
      " only one popup item
      set completeopt-=menu
      set completeopt+=menuone
      let szOmniMapping .= "\<C-P>"
   elseif g:EclimJavaCompleteSelectFirstItem == 2
      " We have to force the menuone option to avoid confusion when there is
      " only one popup item
      set completeopt-=menu
      set completeopt+=menuone
      let szOmniMapping .= "\<C-P>"
      let szOmniMapping .= "\<C-R>=pumvisible() ? \"\\<down>\" : \"\"\<cr>"
   endif
   return szOmniMapping
endfunc

function! phpcomplete_dfadd#complete#Maycomplete_Dot(char)
   if g:EclimJavaCompleteDotComplete && phpcomplete_dfadd#complete#CanUseEclimCompletion()
      return a:char.phpcomplete_dfadd#complete#Maycomplete()
   else
      return a:char
   endif
endfunc

function! phpcomplete_dfadd#complete#InitDotComplete()

   inoremap <buffer> <expr> >          phpcomplete_dfadd#complete#Maycomplete_Dot('>')
   inoremap <buffer> <expr> :          phpcomplete_dfadd#complete#Maycomplete_Dot(':')
   inoremap <buffer> <expr> <C-X><C-O> phpcomplete_dfadd#complete#Maycomplete()
   inoremap <buffer> <expr> <C-X><C-U> phpcomplete_dfadd#complete#Maycomplete()

endfunc




" func signatures


function! phpcomplete_dfadd#complete#InitSwitchRegion()

   if g:PHPCompleteFuncSignatures
      " NOTE: i can't use <expr> here like eclim_dfadd#java#complete#Maycomplete()
      "       because i need to perform first part of mapping separately,
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

function! phpcomplete_dfadd#complete#switchRegion()
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

