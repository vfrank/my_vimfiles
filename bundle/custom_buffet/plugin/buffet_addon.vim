
let s:def_shellslash = &shellslash

"   мапим клавиши для переключения буферов по Ctrl-Tab -----
noremap <silent> <C-Tab> :Bufferlistsw<CR>
noremap <silent> <C-S-Tab> :Bufferlistsw<CR>kk
if !has('gui_running')
   map <S-q> :Bufferlistsw<CR>
endif

function! <SID>OnBufEnter()
   nunmap ds
   setlocal ft=buffet
   let &shellslash = 1
endfunction


function! <SID>OnBufLeave()
   nmap   ds <Plug>Dsurround
   let &shellslash = s:def_shellslash
endfunction


function! MyBuffetSetStatusLine(lDetails)
   let sStatusLine = dfrank#util#BufName(a:lDetails[0])
   let &l:statusline = sStatusLine
endfunction


augroup BuffetAdd
   if !exists("g:BuffetAdded")
      let g:BuffetAdded = 1
      au BufWinEnter buflisttempbuffer* map <buffer> <Tab> <CR>
      au BufWinEnter buflisttempbuffer* map <buffer> <C-Tab>   j
      au BufWinEnter buflisttempbuffer* map <buffer> <C-S-Tab> k

      if !has('gui_running')
         au BufWinEnter buflisttempbuffer* map <buffer> <S-q> j
         au BufWinEnter buflisttempbuffer* map <buffer> q <CR>
      endif

      " disable "ds" mapping in the Buffet window (to make "d" work fast)
      au BufEnter buflisttempbuffer* call <SID>OnBufEnter()
      au BufLeave buflisttempbuffer* call <SID>OnBufLeave()

   endif
augroup END


function! <SID>GetRelativePath(bufno)
   if exists('g:vimprj#dFiles[ a:bufno ]')

      let l:sFullPath = dfrank#util#BufName(a:bufno)

      let l:sVimprjKey = g:vimprj#dFiles[ a:bufno ]['sVimprjKey']
      let l:sVimprjProjRoot = g:vimprj#dRoots[ l:sVimprjKey ]['proj_root']

      let l:sUsedProjRoot = ''
      if !empty(l:sVimprjProjRoot)
         " use .vimprj root
         let l:sUsedProjRoot = l:sVimprjProjRoot
      else
         " use indexer paths root

         if exists("g:vimprj#dFiles[ a:bufno ]['projects'][0]")
            let l:sIndexerProjFile = g:vimprj#dFiles[ a:bufno ]['projects'][0]['file']
            let l:sIndexerProjName = g:vimprj#dFiles[ a:bufno ]['projects'][0]['name']

            let l:sIndexerProjRoot = ''
            let l:lPathsRoot =  g:indexer_dProjFilesParsed[l:sIndexerProjFile]['projects'][l:sIndexerProjName]['pathsRoot']
            for l:iPathNum in range(len(l:lPathsRoot))
               if dfrank#util#IsFileInSubdirSimple( l:sFullPath, l:lPathsRoot[ l:iPathNum ] )
                  let l:sIndexerProjRoot = l:lPathsRoot[ l:iPathNum ]
                  break
               endif
            endfor
            let l:sUsedProjRoot = l:sIndexerProjRoot

         else
            return ''
         endif
      endif

      "let l:sIndexerProjFile = '['.g:vimprj#dFiles[ a:bufno ]["projects"][0]["name"].']'

      "return l:sVimprjProjRoot
      let sUsedProjRoot = substitute(sUsedProjRoot, '\\', '\\\\', 'g')
      return fnamemodify(substitute(l:sFullPath, '\V'.l:sUsedProjRoot.'/', '', ''), ':h')
   else
      /_
      return ''
   endif
endfunction


"   define my own callback function to echo each buffer info in the list
function! MyBuffetCallback(bufno,tabno,windowno,srctab,srcwindow,isparent)
   if(getbufvar(a:bufno,'&modified'))
      let l:modifiedflag = " (+) "
   else
      let l:modifiedflag = "     "
   endif

   if((a:windowno == a:srcwindow ) && (a:tabno == a:srctab))
      let l:sSelected1 = '>'
      let l:sSelected2 = ' <'
   else 
      let l:sSelected1 = ''
      let l:sSelected2 = ' '
   endif

   let l:sBufpath = ''
   
   if !empty(getbufvar(a:bufno, "&buftype"))
      return []

      "let l:sIndexerProj = '*'.getbufvar(a:bufno, "&buftype").'*'
   elseif exists('g:vimprj#dFiles[ a:bufno ]["projects"][0]')
      let l:sIndexerProj = '[ '.g:vimprj#dFiles[ a:bufno ]["projects"][0]["name"].' ]'
      let l:sBufpath = <SID>GetRelativePath(a:bufno)
   else
      let l:sIndexerProj = '-'
   endif

   if empty(l:sBufpath)
      let l:sBufpath = fnamemodify(dfrank#util#BufName(a:bufno), ":h")
   endif

   let l:sBufname = fnamemodify(bufname(a:bufno), ":t")
   if empty(l:sBufname)
      let l:sBufname = '[No name]'
   endif

   let l:sBufpath = '   '.l:sBufpath

   if(a:isparent == 1)
      return [l:sSelected1,a:bufno.' ',l:sBufname,l:modifiedflag, l:sIndexerProj, l:sBufpath, l:sSelected2]
   else
      "return [l:sSelected1,'','','', l:sIndexerProj, l:sBufpath, l:sSelected2]
      return []
   endif
endfunction

let g:Buffetbufferformatfunction = "MyBuffetCallback"
let g:Buffetstatuslineupdatefunction = "MyBuffetSetStatusLine"




