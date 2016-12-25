" Name:			SmartHomeKey 
" Author:		Andrew Lyon <orthecreedence@gmail.com>
" Version:		0.1
" Description:	Used to make the <Home> key a bit more intelligent. If not at ^
" 				and <Home> is pressed, the cursor is moved to ^. If the cursor 
"				is already at ^ it will be moved to 0, and if at 0 and <Home>
"				is pressed, it will go back to ^. This makes it easy to jump
"				between different beginning of line positions.
"
" Usage:		In your .vimrc, you can set it up like this:
"				map <Home> :SmartHomeKey<CR>
"				imap <Home> <C-O>:SmartHomeKey<CR>


if !exists(':SmartHomeKey')
	command! SmartHomeKey call <SID>SmartHomeKey()
endif

if !exists(':SmartEndKey')
   command! SmartEndKey call <SID>SmartEndKey()
endif

function! <SID>SmartHomeKey()
   if (&wrap)
      let l:sAdd = 'g'
   else
      let l:sAdd = ''
   endif

	let l:lnum	=	line('.')
	let l:ccol	=	col('.')
	execute 'normal! '.l:sAdd.'^'
	let l:fcol	=	col('.')
	execute 'normal! '.l:sAdd.'0'
	let l:hcol	=	col('.')

	if l:ccol != l:fcol
		call cursor(l:lnum, l:fcol)
	else
		call cursor(l:lnum, l:hcol)
	endif
endfun


function! <SID>SmartEndKey()
   if (&wrap)
      let l:sAdd = 'g'
   else
      let l:sAdd = ''
   endif
   execute 'normal! '.l:sAdd.'$'
endfun
