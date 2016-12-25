
if did_filetype()	" filetype already set..
	  finish		" ..don't do these checks
endif

autocmd BufRead,BufNewFile *.rl set filetype=ragel

