" Name:        qthelp
" Author:      xaizek (xaizek@gmail.com)
" Version:     1.1.1
"
" NOTE: to make it work, you should run Qt Assistant like that:
"
"   nc -lkU ~/.assistantfifo | assistant -enableRemoteControl
"
"
" Description: This plugin would allow you to open Qt help pages in browser
"              from your C++ source code. Currently it can show help if the word
"              underneath your cursor is a class name, a variable name or a
"              class-member name.
"
" Examples:    QStr|ing trackTitle, artistName;
"              QString track|Title, artistName("Unknown");
"              track|Title = "Unknown";
"              Running command :QHelpOnThis will open help on QString.
"
"              trackTitle.ri|ght(10);
"              Running command :QHelpOnThis will open help on QString::right.
"
"              Running command :QHelp QPixmap::QPixmap will open help on
"              QPixmap constructor.
"
" Configuring: g:qthelp_browser - command to run your browser
"              default: '' (so an error message will be printed if your try to
"                           use plugin)
"              Note: on Windows use something like (notice 'start' at the
"                    beginning)
"                    'start c:\Program files\Mozilla Firefox\firefox.exe'
"                    or Vim will be waiting until you close your browser.
"
" Using:       1. Make tags-file for your html-qthelp.
"                 Addition by DFrank: just go to %Qt-current-version-path%/doc
"                 (say, D:/Qt/4.8.4/doc) , and run   ctags -R . 
"              2. Add that tags-file into your 'tags' option (WARNING: doing
"                 this in your .vimrc file can slow down and pollute completion
"                 list for not Qt-projects).
"              3. Setup g:qthelp_browser variable with the command to run your
"                 browser.
"              4. Map command QHelpOnThis on some hotkey.
"              5. Use QHelp from command-line for faster navigating through
"                 help (to escape manual searching of needed section).
"
" Limitation:  I didn't found a way to determine inheritance hierarchy using
"              tags so trying
"              QStringList strlst;
"              strlst.in|sert("String");
"              will open reference for QString, not for QList::insert.
"
" Warning:     In some cases it can take a while for searching definition (for
"              example when it doesn't exist) if this happens hit Ctrl-C to
"              break searching.
"
" ToDo:        - Maybe it should look for declaration not only in one header
"                file ("companion"), but in all included from this?
"              - Is there a way to determine variable type without regexps?
"              - Use Vim documentation format.
"
" ChangeLog:   v1.0.0 (2010-12-07) - Initial version
"              v1.0.1 (2013-03-09) - Fixed multiple load guard
"              v1.1.1 (2013-03-09) - Added support for latest versions of Qt
"                                    (thanks to Dmitry Frank).

if exists("g:loaded_qthelp")
   "finish
endif

let g:loaded_qthelp = 1

if !exists('g:qthelp_browser')
   let g:qthelp_browser = ''
endif

" boolean for switching debug output
let s:debugging = 0

" regexps, as you can see
let s:idregex = '\%(\<const\>\)\?'.'[_a-zA-Z][_a-zA-Z0-9]*'.'\%(\<const\>\)\?'
let s:nsregex = '\%('.s:idregex.'::\)*'
let s:numregex = '[0-9]\+'
let s:varpfxregex = '\s*&\?\s*\%(\*\s*\)*'
let s:varsfxregex = '\s*\%('.
         \'\%(([^)]*)\)'.
         \'\|'.
         \'\%(\['.s:numregex.'\]\)'.
         \'\)\?'
let s:varregex = s:varpfxregex.s:idregex.s:varsfxregex
let s:varlstregex = '\%('.s:varregex.'\s*\%(,\s*\)\?\)*'
let s:typeregex = '^\s*\%(const\s\+\)\?'.s:nsregex.'\zs'.s:idregex.'\ze'
         \.'\%(<.*>\)\?'.s:varpfxregex.'\s\+'

" buffer variables
" b:membername
" b:foundinfile
" b:foundatline

" commands definition
command! -nargs=0 QHelpOnThis call QHHelp('')
command! -nargs=1 QHelp call QHHelp('<args>')

" the main function
" cword parameter is what we want to get help on or '' for analyzing word
" underneath the cursor
function! QHHelp(query)
   call s:QHDebug('QHDBG: QHHelp(cword="'.a:query.'")')

   let buf_tags = &tags
   if exists('g:qthelp_tags')
      let &tags = g:qthelp_tags
   endif

   if empty(a:query)
      let [l:class, l:membername] = QHGetVUCInfo()
   else
      let l:class = ''
      let l:membername = ''

      let lTmp = split(a:query, '::')
      if len(lTmp) >= 1
         let l:class = lTmp[0]
         if len(lTmp) >= 2
            let l:membername = lTmp[1]
         endif
      endif
   endif

   call s:QHDebug('class='.l:class.',membername='.l:membername)

   if empty(l:class)
      call s:QHTellUser("Nothing was found")
   else
      call s:QHOpenAssistant(l:class, l:membername)
   endif

   "if empty(a:query)
      "let l:lst = s:QHGetTagsListUC()
   "else
      "let l:lst = s:QHGetTagsList(a:query)
   "endif

   "if empty(l:lst)
      "call s:QHTellUser("Nothing was found")
   "else
      "call s:QHDebug('QHDBG: QHHelp, filename="'.l:lst[0]['filename'].'"')
      "call <SID>QHOpenBrowser(l:lst[0]['filename'])
   "endif

   let &tags = buf_tags
endfunction

function! s:QHOpenAssistant(classname, membername)

   "TODO: if we have membername like isSomething or setSomething, then
   "setSource '#something-prop'
   "
   "The trouble is that it won't work for, say, prop 'font': get prop method is
   "just "font()".

   call s:QHTellUser('Opening help for '.a:classname.'::'.a:membername)

   let sId = a:classname
   if !empty(a:membername)
      let sId .= "::".a:membername
   endif

   let sCommand = 'echo "activateIdentifier '.sId.'" | nc -U ~/.assistantfifo'
   call system(sCommand)
   "call confirm(sCommand)


   " --- OLD CODE --- {{{
   if (0)
      let sCommand = ''
      let sClassCommand = 'echo "activateKeyword '.a:classname.'" | nc -U ~/.assistantfifo'
      call system(sClassCommand)

      if !empty(a:membername)

         "let sMemberCommand = 'echo "setSource #sdf" | nc -U ~/.assistantfifo'
         "call system(sMemberCommand)
         "sleep 100 m

         let sMemberCommand = 'echo "setSource #'.a:membername.'" | nc -U ~/.assistantfifo'
         call system(sMemberCommand)
         call confirm(sMemberCommand)

      else
         "let sCommand = sClassCommand
      endif
   endif
   " }}}


endfunction

" determines if a class name, a variable name or a class member name is
" underneath the cursor and returns appropriate taglist
function! s:QHGetTagsListUC()
   let b:membername = ''

   " wuc is for Word Underneath the Cursor
   let l:wuc = expand('<cword>')

   let l:lst = s:QHTryFindClass(l:wuc)
   if empty(l:lst) " if WUC is not class name
      let [l:class, l:membername] = QHGetVUCInfo()
      if !empty(l:membername)
         let l:lst = s:QHGetTagsListOnMember(l:class, l:membername)
      endif
      if empty(l:lst)
         let l:lst = s:QHTryFindClass(l:class)
      endif
   endif

   return l:lst
endfunction

" tries to get a list of tags for the class
function! s:QHTryFindClass(class)
   let l:lst = taglist('//apple_ref/cpp/cl//'.a:class.'$')
   if empty(l:lst)
      let l:lst = s:QHGetTagsListOnMember(a:class, a:class)
   endif
   let b:membername = ''
   return l:lst
endfunction

" tries to get a gat for the member of the class
" sets b:membername
function! s:QHGetTagsListOnMember(class, member)
   let l:lst = []

   if empty(l:lst)
      let b:membername = a:member.'-typedef'
      let l:lst = s:QHGetWithoutAppleRef(b:membername, a:class)
   endif
   if empty(l:lst)
      let b:membername = a:member.'-enum'
      let l:lst = s:QHGetWithoutAppleRef(b:membername, a:class)
   endif

   if empty(l:lst)
      let b:membername = a:member
   endif

   if empty(l:lst)
      let l:lst = taglist('//apple_ref/cpp/clm/'.a:class.'/'.a:member.'$')
   endif
   if empty(l:lst)
      let l:lst = taglist('//apple_ref/cpp/instm/'.a:class.'/'.a:member.'$')
   endif
   if empty(l:lst)
      let l:lst = taglist('//apple_ref/cpp/econst/'.a:class.'/'.a:member.'$')
   endif
   if empty(l:lst)
      let l:lst = taglist('//apple_ref/cpp/tag/'.a:class.'/'.a:member.'$')
   endif

   if empty(l:lst)
      let l:lst = s:QHGetWithoutAppleRef(a:member, a:class)
   endif

   if empty(l:lst)
      let b:membername = ''
   endif

   return l:lst
endfunction

" tries to guess tag by its name and name of the class
function! s:QHGetWithoutAppleRef(tag, class)
   let l:lst = taglist('^'.a:tag.'$')
   call filter(l:lst, 'v:val["filename"] =~? "[/\\\\]'.a:class.'\\.html$"')
   return l:lst
endfunction

" analyses query for class name or class name and its member name
" sets b:membername
function! s:QHGetTagsList(query)
   call s:QHDebug('QHDBG: QHGetTagsList(query="'.a:query.'")')
   let l:lst = []

   let l:regex = '\('.s:idregex.'\)::\('.s:idregex.'\)'
   if empty(matchstr(a:query, l:regex))
      let l:lst = s:QHTryFindClass(a:query)
      let b:membername = ''
   else
      let l:class = substitute(a:query, l:regex, '\1', '')
      call s:QHDebug('QHDBG: QHGetTagsList, class="'.l:class.'"')
      let l:member = substitute(a:query, l:regex, '\2', '')
      call s:QHDebug('QHDBG: QHGetTagsList, member="'.l:member.'"')

      let l:lst = s:QHGetTagsListOnMember(l:class, l:member)

      let b:membername = l:member
   endif

   return l:lst
endfunction

" opens users browser
function! s:QHOpenBrowser(file)
   let buf_shellslash = &shellslash
   if has('win32') && &shellslash
      set noshellslash
   endif

   if s:debugging == 1
      return
   endif
   let l:browserargs = 'file://'.fnamemodify(a:file, ':p')
   if !empty(b:membername)
      let l:browserargs = l:browserargs.'\#'.b:membername
   endif
   let l:browsercmd = g:qthelp_browser
   let l:browserargs = shellescape(l:browserargs)
   if !has('win32') && !has('win64')
      let l:browserargs = l:browserargs.'&'
      let l:browsercmd = shellescape(l:browsercmd)
   endif
   try
      exe ":silent !".l:browsercmd." ".l:browserargs
   catch 'E484'
      call s:QHTellUser('An error occuried while running your browser. '
               \.'Maybe your g:qthelp_browser option is incorrect.')
   endtry

   let &shellslash = buf_shellslash
endfunction

" lets tell user about what we have found
function! s:QHInformUser(varname, class, membername)
   let l:msg = a:class
   if !empty(a:membername)
      let l:msg = l:msg.'::'
   endif
   if !empty(a:varname)
      let l:msg = a:varname.' ('.l:msg.')'
   endif
   if !empty(b:foundinfile)
      let l:msg = l:msg.'; was found in '.b:foundinfile
               \.' at line '.b:foundatline
   endif
   call s:QHTellUser(l:msg)
endfunction

" prints some message to a user to let him know what are we doing
function! s:QHTellUser(msg)
   execute 'echomsg("QtHelp: '.escape(a:msg, '"').'")'
endfunction

" prints debug message
function! s:QHDebug(msg)
   if s:debugging == 1
      execute 'echomsg("QtHelp: '.escape(a:msg, '"').'")'
   endif
endfunction

" ------------------------------------------------------------------------------
" stuff below is for analyzing code --------------------------------------------
" ------------------------------------------------------------------------------

" returns list with information about Variable Underneath the Cursor in form of
" [classname, membername]
function! QHGetVUCInfo()
   let l:wuc = expand('<cword>')
   let l:wuctype = s:QHGetWUCType(wuc)
   call s:QHDebug('type='.l:wuctype)
   if l:wuctype == 0 " we're assuming that this is varname
      let l:varname = s:QHGetVarType(l:wuc)
      call s:QHDebug('varname='.l:varname)
      let l:classname = empty(l:varname) ? l:wuc : l:varname
      return [l:classname, '']
   elseif l:wuctype == 1
      return [s:QHGetNSName(l:wuc), l:wuc]
   elseif l:wuctype == 2
      return [s:QHGetVarType(s:QHGetVarName(l:wuc)), l:wuc]
   elseif l:wuctype == 3
      return [l:wuc, '']
   endif
endfunction

" this function searches for variable definition in current file and header
" file if the current one is a source
function! s:QHGetVarType(varname)
   let b:foundatline = line('.')

   " firstly lets try to find declaration in current file
   " simple case
   let l:type = s:QHSearchSimpleVarDef(a:varname)
   if !empty(l:type)
      call s:QHDebug('QHDBG: Simple definition search succesed')
      return l:type
   endif
   " more complex
   let l:type = s:QHSearchComplexVarDef(a:varname)
   if !empty(l:type)
      call s:QHDebug('QHDBG: Complex definition search succesed')
      return l:type
   endif

   " try to find variable in function declaration
   let l:type = s:QHSearchVarDefInArgs(a:varname)
   if !empty(l:type)
      call s:QHDebug('QHDBG: Arg search succesed')
      return l:type
   endif

   " and now lets take a look at the header if it exists
   if expand('%:e') == 'cpp'
      if filereadable(expand('%:r').'.hpp')
         return s:QHSearchVarDefInFile(a:varname, expand('%:r').'.hpp')
      elseif filereadable(expand('%:r').'.h')
         return s:QHSearchVarDefInFile(a:varname, expand('%:r').'.h')
      else
         call s:QHDebug('QHDBG: QHGetVarType, cant find companion file')
         return ''
      endif
   endif

   return ''
endfunction

" searches for simple declaration of varname above cursor position
function! s:QHSearchSimpleVarDef(varname)
   let l:sdefregex = '\<'.s:nsregex.s:idregex.'\>'.'\%(<.*>\)\?'.'[^,()=]\+'
            \.'\<'.a:varname.'\>[^&]'
   let l:lnum = search(l:sdefregex, 'bcnW')
   if l:lnum > 0
      let l:type = matchstr(matchstr(getline(l:lnum), l:sdefregex)
               \, s:typeregex)
      if l:type != 'delete' && l:type != 'include' && l:type != 'new'
         let b:foundinfile = 'this file'
         let b:foundatline = l:lnum
         return l:type
      endif
   endif
endfunction

" searches for complex declaration of varname above cursor position
function! s:QHSearchComplexVarDef(varname)
   let l:defregex = '\s*'.s:nsregex.s:idregex.'\s\+'
            \.s:varlstregex.s:varpfxregex.a:varname.s:varsfxregex
            \.'\%(<.*>\)\?\s*\%(;\|,\|\%(=\)\)'
   let l:lnum = search(l:defregex, 'bcnW')
   if l:lnum > 0
      call s:QHDebug('QHDBG: QHGetVarType, lnum="'.l:lnum.'"')
      let l:type = matchstr(getline(l:lnum), s:typeregex)
      if l:type != 'delete'
         let b:foundinfile = 'this file'
         let b:foundatline = l:lnum
         return l:type
      else
         " continue the search but without search() to escape moving cursor
         for l:l in range(l:lnum - 1, 1, -1)
            let l:type = matchstr(getline(l:l), l:defregex)
            if !empty(l:type) && l:type != 'delete'
               let b:foundinfile = 'this file'
               let b:foundatline = l:l
               return l:type
            endif
         endfor
      endif
   endif
endfunction

" searches for declaration of varname in argument list of current function
function! s:QHSearchVarDefInArgs(varname)
   let l:argdefregex = '[(,]\s*\%(const\)\?'.s:nsregex.s:idregex.s:varpfxregex
            \.'\s\+'.a:varname.s:varsfxregex.'\s*[,)]\?'
   let l:stoplnum = search('^}', 'bcnW')
   let l:lnum = search(l:argdefregex, 'bcnW', l:stoplnum + 1)
   if l:lnum > 0
      let b:foundinfile = 'this file'
      let b:foundatline = l:lnum
      return matchstr(getline(l:lnum), l:argdefregex, 'bcnW')
   endif
   return ''
endfunction

" searches for declaration of varname in file filename
function! s:QHSearchVarDefInFile(varname, filename)
   let l:defregex = '^\s*'.s:nsregex.s:idregex.'\>[^()]*\<'.a:varname.'\>'
   let l:headerfile = readfile(a:filename)
   let l:lnum = 0
   for l:line in l:headerfile
      let l:definition = matchstr(l:line, l:defregex)
      if !empty(l:definition)
         let b:foundinfile = a:filename
         let b:foundatline = l:lnum
         return matchstr(l:line, s:typeregex)
      endif
      let l:lnum += 1
   endfor
   return ''
endfunction

" returns variable name that goes right before the cursor
function! s:QHGetVarName(funcname)
   let [l:line, l:col] = searchpos(expand('<cword>'), 'bcn')
   let l:varname = matchstr(getline('.'),
            \ s:idregex.'\ze\%(\.\|\(this\)\@<!->\)\%'.l:col.'c'.a:funcname)
   return l:varname
endfunction

" returns namespace name that goes right before the cursor
function! s:QHGetNSName(funcname)
   let [l:line, l:col] = searchpos(expand('<cword>'), 'bcn')
   let l:varname = matchstr(getline('.'),
            \ s:idregex.'\ze::\%'.l:col.'c'.a:funcname)
   return l:varname
endfunction

" analyses what is before the wuc and returns:
" - 0 for class_n|ame or va|r_name
" - 1 for class_name::mem|ber_name
" - 2 for var_name.mem|ber_name or var_name->me|mber_name
" - 3 for class_n|ame
function! s:QHGetWUCType(wuc)
   let [l:line, l:col] = searchpos(a:wuc, 'bcn')
   let l:line = getline('.')
   let l:pref = matchstr(l:line,
            \ s:idregex.'\zs\%(::\|\.\|\(this\)\@<!->\)\ze\%'.l:col.'c'
            \ .a:wuc)
   let l:suf = matchstr(l:line,
            \ '\%'.l:col.'c'
            \ .a:wuc.'\zs\%(::\|\.\|\(this\)\@<!->\)\ze'.s:idregex)
   call s:QHDebug('pref='.l:pref.', suf='.l:suf)
   if l:pref == '.' || l:pref == '->'
      return 2
   elseif l:pref == '::'
      return 1
   elseif l:suf == '::'
      return 3
   else
      return 0
   endif
endfunction

" vim: set foldmethod=syntax foldlevel=0 :miv "
