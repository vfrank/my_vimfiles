" This script provides :Source command, a drop-in replacement for
" built-in :source command, but this one also can take range and execute just
" a part of the buffer.
"


" Sources given range of the buffer
function! <SID>SourcePart(line1, line2)
   let tmp = @z
   silent exec a:line1.",".a:line2."yank z"
   let @z = substitute(@z, '\n\s*\\', '', 'g')
   @z
   let @z = tmp
endfunction



" if some argument is given, this command calls built-in command :source with
" given arguments; otherwise calls function <SID>SourcePart() which sources
" visually selected lines of the buffer.
command! -nargs=? -bar -range Source if empty("<args>") | call <SID>SourcePart(<line1>, <line2>) | else | exec "so <args>" | endif



" in order to achieve _real_ drop-in replacement, I like to abbreviate
" existing :so[urce] command to the new one.
"
" So, we can call :so %  just as before, and we are also call  '<,'>so

cnoreabbr so     Source
cnoreabbr sou    Source
cnoreabbr sour   Source
cnoreabbr sourc  Source
cnoreabbr source Source


