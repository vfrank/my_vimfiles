
if exists("g:vimprj#loaded")

   function! g:vimprj#dHooks['NeedSkipBuffer']['eclim_my_add'](dParams)
      let l:sFilename = bufname(a:dParams['iFileNum'])

      " skip standard .vimprojects file
      if l:sFilename =~ '__eclim_tmp_'
         return 1
      endif

      return 0
   endfunction

endif


" support *.aidl files: set filetype 'java'
au BufRead,BufNewFile *.aidl set filetype=java

" command to close project tree :ProjectTreeClose
command! -nargs=? -complete=file ProjectTreeClose call eclim#project#tree#ProjectTreeClose()

" Global Variables {{{

" g:EclimJavaCompleteFuncSignature
"     insert function arguments in autocomplete or not
"     0 = no
"     1 = yes (default)
if !exists("g:EclimJavaCompleteFuncSignature")
   let g:EclimJavaCompleteFuncSignature = 0
endif


" }}}

