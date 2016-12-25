" Rename.vim  -  Rename a buffer within Vim and on the disk
"
" Copyright June 2007 by Christian J. Robinson <infynity@onewest.net>
"
" Distributed under the terms of the Vim license.  See ":help license".
"
" Usage:
"
" :Rename[!] {newname}






" <SID>IsAbsolutePath(path) <<<
"   this function from project.vim is written by Aric Blumer.
"   Returns true if filename has an absolute path.
function! <SID>IsAbsolutePath(path)
   if a:path =~ '^ftp:' || a:path =~ '^rcp:' || a:path =~ '^scp:' || a:path =~ '^http:'
      return 2
   endif
   let path=expand(a:path) " Expand any environment variables that might be in the path
   if path[0] == '/' || path[0] == '~' || path[0] == '\\' || path[1] == ':'
      return 1
   endif
   return 0
endfunction " >>>


function! <SID>Rename(name, bang)
	let l:name = a:name

   " if relative path given, we should save new file
   " in the same path as source file.
   if (!<SID>IsAbsolutePath(l:name))
      let l:name = expand("%:p:h")."/".l:name
   endif

	let l:curfile = expand("%:p")
	let v:errmsg = ""
	silent! exe "saveas" . a:bang . " " . l:name
	if v:errmsg =~# '^$\|^E329'
		if expand("%:p") !=# l:curfile && filewritable(expand("%:p"))
			silent exe "bwipe! " . l:curfile
			if delete(l:curfile)
				echoerr "Could not delete " . l:curfile
			endif
		endif
	else
		echoerr v:errmsg
	endif
endfunction

command! -nargs=* -complete=file -bang Rename call <SID>Rename(<q-args>, '<bang>')

