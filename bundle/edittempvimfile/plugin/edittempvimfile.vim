
function! <SID>EditTempFile(ft)
   exe 'e '.tempname()
   exe 'set ft='.a:ft
   "normal i
   "normal iendfunction

   append "sdf"

function! TmpFunc()
   
endfunction

.

   normal ggjjS
   :w

endfunction



command! -nargs=? -complete=file ET    call <SID>EditTempFile('vim')
command! -nargs=? -complete=file Tmp   call <SID>EditTempFile('vim')
command! -nargs=? -complete=file T     call <SID>EditTempFile('vim')

if exists("loaded_cmdalias") && exists("*CmdAlias")
   call CmdAlias('et',  'ET')
   call CmdAlias('tmp', 'Tmp')
endif

