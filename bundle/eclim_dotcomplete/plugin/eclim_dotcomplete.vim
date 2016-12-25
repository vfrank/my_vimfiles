
" Global Variables {{{

" g:EclimJavaCompleteDotComplete
"     autocomplete after dot
"     0 = don't complete after dot
"     1 =       complete after dot (default)
if !exists("g:EclimJavaCompleteDotComplete")
   let g:EclimJavaCompleteDotComplete = 1
endif

" g:EclimJavaCompleteSelectFirstItem
"     0 = don't select first item
"     1 = select first item (inserting it to the text, default vim behaviour)
"     2 = select first item (without inserting it to the text) (default)
if !exists("g:EclimJavaCompleteSelectFirstItem")
   let g:EclimJavaCompleteSelectFirstItem = 2
endif


" }}}

