
function! <SID>GetCommentExpr()

   if (&ft == 'vim')
      return '"'
   else
      return '//'
   endif

endfunction



function! MatchPrevComment()

   let sRet = ''
   let sCommentExpr = <SID>GetCommentExpr()

   let iCurLineNum = line('.')
   if (iCurLineNum > 1)
      let sPrevLine = getline(iCurLineNum - 1)

      let iCommentIndex = match(sPrevLine, '\V'.sCommentExpr, col('.') - 1)
      if iCommentIndex >= 0
         let iSpacesCnt = iCommentIndex + 1 - col('.')

         while iSpacesCnt > 0
            let sRet .= ' '
            let iSpacesCnt -= 1
         endwhile
         let sRet .= sCommentExpr

         let iNonSpaceIndex = match(sPrevLine, '\v[^ \t-]', iCommentIndex + strlen(sCommentExpr))
         if iNonSpaceIndex >= 0
            let iSpacesCntAfterComment = iNonSpaceIndex - iCommentIndex - strlen(sCommentExpr)

            while iSpacesCntAfterComment > 0
               let sRet .= ' '
               let iSpacesCntAfterComment -= 1
            endwhile

         endif

      endif

   endif


   return sRet
endfunction

inoremap <C-G>/ <C-R>=MatchPrevComment()<CR>

