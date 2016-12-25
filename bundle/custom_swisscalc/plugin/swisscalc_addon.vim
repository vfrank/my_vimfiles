
let g:SC_Window_Height = 10


function! <SID>OnBufEnter()

   "imap <C-q>  setenv("bin")<CR>_<CR>
   "imap <C-w>  setenv("dec")<CR>_<CR>
   "imap <C-e>  setenv("hex")<CR>_<CR>

   "nmap <C-q>  <S-S>setenv("bin")<CR>_<CR>
   "nmap <C-w>  <S-S>setenv("dec")<CR>_<CR>
   "nmap <C-e>  <S-S>setenv("hex")<CR>_<CR>

   imap <C-j> <Down>
   imap <C-k> <Up>

endfunction


function! <SID>OnBufLeave()
endfunction


function! <SID>SCalcOpenWindow()

   let bname = '__SwissCalc__'

   let winnum = bufwinnr(bname)
   if winnum != -1
      if winnr() != winnum
         " If not already in the window, jump to it
         exe winnum . 'wincmd w'
      endif
   else
      " Open a new window at the bottom

      " If the __SwissCalc__ buffer exists, then reuse it. Otherwise open
      " a new buffer
      let bufnum = bufnr(bname)
      if bufnum == -1
         let wcmd = bname
      else
         let wcmd = '+buffer' . bufnum
      endif

      exe 'silent! belowright ' . g:SC_Window_Height . 'split ' . wcmd
   endif

   :Scalc

endfunction


augroup SwissCalcAdd
   if !exists("g:SwissCalcAdded")
      let g:SwissCalcAdded = 1

      au BufEnter __SwissCalc__ call <SID>OnBufEnter()
      au BufLeave __SwissCalc__ call <SID>OnBufLeave()

   endif
augroup END


command! -nargs=? -complete=file Calc call <SID>SCalcOpenWindow()





