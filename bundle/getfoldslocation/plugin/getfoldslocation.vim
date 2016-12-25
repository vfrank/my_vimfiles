
" TODO:
"  * make customizable the following:
"     * "Folds: " starting text
"     * " -> " separator
"     * echohl for starting text, separators and folds names (i.e. three items)
"     * make items completely customizable: 2 types of items: 
"        - enclosed like {{{ }}}
"        - only start-defined, like sections ********
"        NOTE: maybe some enclosed items can have inner start-defined items,
"        for example, class MyClass { ... } can have its own 
"        *** PUBLIC METHODS *** .
"        
"       each item type should have two regexps
"        - regexp for search
"        - pattern for displaying


function! <SID>AddItem(lTgtList, iLineNum)
   call        add(
            \     a:lTgtList, 
            \     substitute(
            \        getline(a:iLineNum),
            \        '\v\s*(\/\/){0,1}\s*\*{0,}\s*(.{-})\s*(\{\{\{){-}',
            \        '\2',
            \        ''
            \     )
            \  )
endfunction

function! <SID>GetPrevFoldEdge()

   let dRet = {
            \     "edgeType" : "",
            \     "lineNum"  : 0
            \  }


   let iFoldStartLineNum       = search('{'.'{{$', 'nbW')
   let iFoldEndLineNum         = search('}'.'}}$', 'nbW')
   let iSectionAsteriskLineNum = search('\v\/\*\s{0,5}\*{10,}\n.+\n\s*\*\s{0,5}\*{10,}\/', 'nbW')




   if (iSectionAsteriskLineNum + 1 >= iFoldStartLineNum && iSectionAsteriskLineNum > iFoldEndLineNum)
      let dRet['edgeType'] = 'section_asterisk'
      let dRet['lineNum'] = iSectionAsteriskLineNum
   else
      if (iFoldStartLineNum > iFoldEndLineNum)
         let dRet['edgeType'] = 'start'
         let dRet['lineNum'] = iFoldStartLineNum
      elseif (iFoldEndLineNum > 0)
         let dRet['edgeType'] = 'end'
         let dRet['lineNum'] = iFoldEndLineNum
      else
         let dRet['edgeType'] = 'none'
      endif
   endif

   return dRet

endfunction

function! <SID>GetFoldsLocationList()

   let lSrcPos = getpos('.')

   let iCurDeep = 0
   let dPrevEdge = {}

   let lFoldNames = []
   let boolWasSectionAsterisk = 0

   while (1)

      let dPrevEdge = <SID>GetPrevFoldEdge()
      "echo dPrevEdge
      "echo getline(dPrevEdge['lineNum'])

      if (dPrevEdge['edgeType'] == 'none')
         break
      else

         if dPrevEdge['edgeType'] == 'start'
            if iCurDeep == 0

               "call <SID>AddItem(lFoldNames, dPrevEdge['lineNum'])
               call        add(
                        \     lFoldNames, 
                        \     substitute(
                        \        getline(dPrevEdge['lineNum']),
                        \        '\v\s*(\/\/){0,1}\s*\*{0,}\s*(.{-})\s*\{\{\{',
                        \        '\2',
                        \        ''
                        \     )
                        \  )
               "echo lFoldNames


            else
               let iCurDeep = iCurDeep - 1
               "echo iCurDeep
            endif
         elseif dPrevEdge['edgeType'] == 'section_asterisk'

            if !boolWasSectionAsterisk
               call        add(
                        \     lFoldNames, 
                        \     '[ '.substitute(
                        \        getline(dPrevEdge['lineNum'] + 1),
                        \        '\v\s*(\/\/){0,1}\s*\*{0,}\s*(.{-})\s*(\{\{\{){0,1}\*{0,1}\s*$',
                        \        '\2',
                        \        ''
                        \     ).' ]'
                        \  )
               let boolWasSectionAsterisk = 1
            endif

         else " end
            let iCurDeep = iCurDeep + 1
            "echo iCurDeep
         endif

         let lTmpPos = deepcopy(lSrcPos)
         let lTmpPos[1] = dPrevEdge['lineNum'] " lnum
         let lTmpPos[2] = 0                    " col
         call setpos('.', lTmpPos)

      endif
   endwhile

   call setpos('.', lSrcPos)
   return lFoldNames

endfunction


function! EchoFoldsLocation()

   let lFoldNames = reverse( <SID>GetFoldsLocationList() )
   let boolFirst = 1

   if len(lFoldNames) > 0
      echohl ModeMsg
      echo   "Folds: "
      echohl None

      for sName in lFoldNames
         
         if !boolFirst
            echohl ModeMsg
            echon  ' -> '
         endif

         echohl None
         echon  sName
         echohl None

         let boolFirst = 0
      endfor
   else
      echohl ModeMsg
      echo   "[No folds]"
      echohl None
   endif

   "return join( reverse( <SID>GetFoldsLocationList() ), ' / ' )
endfunction




nnoremap ,gl :call EchoFoldsLocation()<CR>

