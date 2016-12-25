
let s:def_shellslash = &shellslash

"   мапим клавиши для переключения буферов по Ctrl-Tab -----
noremap <silent> <C-Tab> :Bufferlistsw<CR>
noremap <silent> <C-S-Tab> :Bufferlistsw<CR>kk
if !has('gui_running')
   map <S-q> :Bufferlistsw<CR>
endif

function! <SID>OnBufEnter()
   "nunmap ds
   setlocal ft=mru
   let &shellslash = 1
endfunction


function! <SID>OnBufLeave()
   "nmap   ds <Plug>Dsurround
   let &shellslash = s:def_shellslash
endfunction



augroup MruAdd
   if !exists("g:MruAdded")
      let g:MruAdded = 1

      " disable "ds" mapping in the MruAdded window (to make "d" work fast)
      au BufEnter __MRU_Files__ call <SID>OnBufEnter()
      au BufLeave __MRU_Files__ call <SID>OnBufLeave()

   endif
augroup END







