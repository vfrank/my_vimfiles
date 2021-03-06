
function! <SID>BufDelete(boolBang, sAddText)
   if (!a:boolBang)
      execute ":bd " . a:sAddText
   else
      execute ":bd! " . a:sAddText
   endif
endfunction

"here is a more exotic version of my original Kwbd script
"delete the buffer; keep windows; create a scratch buffer if no buffers left
function! <SID>Kwbd(kwbdStage, boolBang)
  if(a:kwbdStage == 1)

    " We should not to delete unsaved buffer.
    " We can do it if only "!" is provided.
    if (!a:boolBang && getbufvar("%", '&modified'))
      echoerr "Buffer is modified. Add '!' to ignore."
      return
    endif

    if(!buflisted(winbufnr(0)))
      call <SID>BufDelete(a:boolBang, "")
      return
    endif
    let s:kwbdBufNum = bufnr("%")
    let s:kwbdWinNum = winnr()
    windo call <SID>Kwbd(2, a:boolBang)
    execute s:kwbdWinNum . 'wincmd w'
    let s:buflistedLeft = 0
    let s:bufFinalJump = 0
    let l:nBufs = bufnr("$")
    let l:i = 1
    while(l:i <= l:nBufs)
      if(l:i != s:kwbdBufNum)
        if(buflisted(l:i))
          let s:buflistedLeft = s:buflistedLeft + 1
        else
          if(bufexists(l:i) && !strlen(bufname(l:i)) && !s:bufFinalJump)
            let s:bufFinalJump = l:i
          endif
        endif
      endif
      let l:i = l:i + 1
    endwhile
    if(!s:buflistedLeft)
      if(s:bufFinalJump)
        windo if(buflisted(winbufnr(0))) | execute "b! " . s:bufFinalJump | endif
      else
        enew
        let l:newBuf = bufnr("%")
        windo if(buflisted(winbufnr(0))) | execute "b! " . l:newBuf | endif
      endif
      execute s:kwbdWinNum . 'wincmd w'
    endif
    if(buflisted(s:kwbdBufNum) || s:kwbdBufNum == bufnr("%"))
      "execute "bd! " . s:kwbdBufNum
      call <SID>BufDelete(a:boolBang, s:kwbdBufNum)
    endif
    if(!s:buflistedLeft)
      set buflisted
      set bufhidden=delete
      set buftype=nofile
      setlocal noswapfile
    endif
  else
    if(bufnr("%") == s:kwbdBufNum)
      let prevbufvar = bufnr("#")
      if(prevbufvar > 0 && buflisted(prevbufvar) && prevbufvar != s:kwbdBufNum)
        b #
      else
        bn
      endif
    endif
  endif
endfunction

command! -bang Kwbd call <SID>Kwbd(1, <bang>0)
nnoremap <silent> <Plug>Kwbd :<C-u>Kwbd<CR>

" Create a mapping (e.g. in your .vimrc) like this:
"nmap <C-W>! <Plug>Kwbd

