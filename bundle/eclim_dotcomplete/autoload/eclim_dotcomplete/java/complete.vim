
" Check if the cursor is in comment or string
function! eclim_dotcomplete#java#complete#IsCursorInCommentOrString()
   return match(synIDattr(synID(line("."), col(".")-1, 1), "name"), '\v\Comment|String')>=0
endfunc

" Check if we can use omni completion in the current buffer
function! eclim_dotcomplete#java#complete#CanUseEclimCompletion()
   " For Java files and only if the omnifunc is eclim#java#complete#CodeComplete
   return (index(['java'], &filetype) >= 0 && &completefunc == 'eclim#java#complete#CodeComplete' && !eclim_dotcomplete#java#complete#IsCursorInCommentOrString())
endfunc

" Return the mapping of omni completion
function! eclim_dotcomplete#java#complete#Maycomplete()
   let szOmniMapping = "\<C-X>\<C-U>"

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

function! eclim_dotcomplete#java#complete#Maycomplete_Dot()
   if g:EclimJavaCompleteDotComplete && eclim_dotcomplete#java#complete#CanUseEclimCompletion()
      return '.'.eclim_dotcomplete#java#complete#Maycomplete()
   else
      return '.'
   endif
endfunc

function! eclim_dotcomplete#java#complete#Init()

   inoremap <buffer> <expr> .          eclim_dotcomplete#java#complete#Maycomplete_Dot()
   inoremap <buffer> <expr> <C-X><C-U> eclim_dotcomplete#java#complete#Maycomplete()

endfunc


