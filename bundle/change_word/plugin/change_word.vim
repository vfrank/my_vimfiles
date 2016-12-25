"=============================================================================
" File:        change_word.vim
" Author:      Dmitry Frank (dimon.frank@gmail.com)
" Version:     1.00
"=============================================================================
" You may use this code in whatever way you see fit.
" 
" I very hate that "cw" actually does "ce". I'd like to make
" "cw" do "cw".   
"
" You can read ":help cw", there's one solution:  ":map cw dwi". 
"
" But this is very stupid solution: 
"  1) "." repeats only "i", not "dwi".
"  2) when needed word is at the end of line, then "dwi" fails: cursor is
"     not on the end of line, one symbol missed. (test it)
"
"
"  well, first problem is solved by perfect plugin "repeat" :
"        http://www.vim.org/scripts/script.php?script_id=2136 
"
"  but i can't solve second problem. I need to do "append" instead of "insert"
"  so, this is it.
"
"


function! <SID>ChangeWord(word_letter)
   let l:dPos_before = getpos('.')

   exec 'normal! d'.a:word_letter

   startinsert

   "let l:dPos_after = getpos('.')
   "if (l:dPos_before[2] == l:dPos_after[2])
      "startinsert
   "else
      "startinsert!
   "endif

   call confirm("sdf")
   silent! call repeat#set("\<Plug>ChangeWord_w", -1)
endfunction


"nnoremap <silent> <Plug>ChangeWord_w  :call <SID>ChangeWord('w')<CR>
"nnoremap <silent> <Plug>ChangeWord_W  :call <SID>ChangeWord('W')<CR>

"nmap      cw   <Plug>ChangeWord_w
"nmap      cW   <Plug>ChangeWord_W


