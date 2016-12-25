"=============================================================================
" File:        envcontrol.vim
" Author:      Dmitry Frank (dimon.frank@gmail.com)
" Version:     1.00
"=============================================================================
" See documentation in accompanying help file
" You may use this code in whatever way you see fit.



" TODO: 
" *) option: -o path
"
" *)
"     *) add command :MakeSmart
"     *) add alias if possible for :make
"     *) analyze makefile for suffixes (if there's no suffix for .c.o or .cpp.o,
"        then use following: 'gcc -c $^')
"     *) source can be defined as $< or $^
"
"
"
"
" Main function is: MakeprgGenerate
" @param sFilename    string, project filename
" @param sProjectType string, project type, one of the following:
"     'MPLAB_8_mcp'
"     'makefile'
" @param dParams      dictionary, special params for specified project type.
"                     (explained below)
"
" @return             string to put in &makeprg
"
"
" special params for each project_type:
"
" ------------------------ 'MPLAB_8_mcp' -----------------------
"
"  compiler_executable: (default: '')
"     *) '': will be autodetected   
"     *) non-empty: will be used. (should be executable!)
"
"  compiler_add_params: (default: '-x c -c')
"     *) will be just inserted in command directly after compiler_executable
"
"  compiler_mcpu: (default: '')
"     *) '': will be autodetected (just from [HEADER] section, param 'device')
"     *) 'none': no -mcpu param will be given to compiler
"     *) non-empty: will be used in -mcpu param
"
"  compiler_tool_settings_use: (default: '')
"     *) '': will be autodetected
"     *) 'none': no params from TOOL_SETTINGS will be given to compiler
"     *) string like 'TS{25AC22BD-2378-4FDB-BFB6-7345A15512D3}':
"           will be used item from TOOL_SETTINGS section with given name
"     *) number: will be used item from TOOL_SETTINGS section with given number
"     *) any other: will be used *second* item from TOOL_SETTINGS
"           section. (because of i have empirically figured out
"           that second element is what we need)
"
"  obj: (default: '')
"     will be given as -o argument
"     *) if empty, then will be retrieved from .mcp :
"           -o '<output_dir>/%:t:r.o'
"        where <output_dir> is a value from [PATH_INFO] section, param 'dir_tmp'
"     *) if not empty, will be used as is.
"
"  source (default: '%:p')
"     * source filename. Default settings works fine, i think you
"       will never need to change it.
"
"
"
" ------------------------ 'makefile' -----------------------
"
" TODO
"
" ------------------------ 'MPLAB_X' -----------------------
"   compiler_command_without_includes: (default: '')
"      *) should not be empty. Full command without includes (which will
"         be added automatically) and source filename to compile
"         (which is defined by another option, see below)
"   source' : '"%:p"',
"     * source filename. Default settings works fine, i think you
"       will never need to change it.
"      
" ************************************************************************************************
"                                   COMMON USEFUL FUNCTIONS
" ************************************************************************************************

if v:version < 700
   call confirm("indexer error: You need Vim 7.0 or higher")
   finish
endif

try
   call vimprj#init()
catch
   " no vimprj plugin installed
endtry

let s:iVimprj_min_version = 101

if !exists("g:vimprj#version")
   let s:boolVimprjCompatible = 0
else
   if g:vimprj#version < s:iVimprj_min_version
      call confirm("EnvControl error: you have plugin 'vimprj' installed, but version is not compatible: you need vimprj version ".s:iVimprj_min_version.", but current vimprj version is ".g:vimprj#version)
      let s:boolVimprjCompatible = 0
   else
      let s:boolVimprjCompatible = 1
   endif
endif

let g:iEnvcontrolVersion = 100
let g:loaded_envcontrol  = 1




" <SID>Trim(sString)
" trims spaces from begin and end of string
function! <SID>Trim(sString)
   return substitute(substitute(a:sString, '^\s\+', '', ''), '\s\+$', '', '')
endfunction



function! <SID>has_keys(dDict, lKeys)
   
   let l:boolHasKeys = 1

   for l:sKey in a:lKeys
      if (!has_key(a:dDict, l:sKey))
         let l:boolHasKeys = 0
         break
      endif
   endfor

   return l:boolHasKeys

endfunction

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

function! <SID>SetDefaultValues(dParams, dDefParams)
   let l:dParams = a:dParams

   for l:sKey in keys(a:dDefParams)
      if (!has_key(l:dParams, l:sKey))
         let l:dParams[ l:sKey ] = a:dDefParams[ l:sKey ]
      else
         if type(l:dParams[ l:sKey ]) == type({}) && type(a:dDefParams[ l:sKey ]) == type({})
            let l:dParams[ l:sKey ] = <SID>SetDefaultValues(l:dParams[ l:sKey ], a:dDefParams[ l:sKey ])
         endif
      endif
   endfor

   return l:dParams
endfunction




" ************************************************************************************************
"                                          SPECIAL UTILS
" ************************************************************************************************

function! <SID>GetFileInfo(sProjectFilename, sProjectType)
   let dRet = {}
   if (a:sProjectType == 'MPLAB_8_mcp')
      " ---------- MPLAB 8.x mcp ----------

      let dRet = <SID>GetFileInfo__MPLAB_8_mcp(a:sProjectFilename)


   elseif (a:sProjectType == 'MPLAB_X')
      " ---------- MPLAB X ----------

      let dRet = <SID>GetFileInfo__MPLAB_X(a:sProjectFilename)

   elseif (a:sProjectType == 'Keil')
      " ---------- Keil ----------

      let dRet = <SID>GetFileInfo__Keil(a:sProjectFilename)

   elseif (a:sProjectType == 'makefile')
      " ---------- makefile ----------

      let dRet = <SID>GetFileInfo__Makefile(a:sProjectFilename)

   elseif (a:sProjectType == 'none')
      " ---------- none ----------

      let dRet = <SID>GetFileInfo__None()

   endif

   return dRet
endfunction

function! <SID>GetIncludesCommand(lIncludepath)
   let sRet = ''

   "if len(a:lIncludepath) > 0
      "let sRet .= '-I'
   "endif

   for sCurPath in a:lIncludepath
      let sRet .= ' -I"'.sCurPath.'"'
   endfor

   "let sRet .= join(a:lIncludepath, ' -I')

   return sRet
   
endfunction

function! <SID>ErrorRegister(sCat, sErrorText)
   "let s:sErrorText .= a:sErrorText
   if !has_key(s:dErrors, a:sCat)
      echoerr "EnvControl error: there's no error category '".a:sCat."'"
   endif
   let s:dErrors[ a:sCat ] .= a:sErrorText
endfunction

function! <SID>ErrorsClear()
   for l:sKey in keys(s:dErrors)
      let s:dErrors[ l:sKey ] = ''
   endfor
endfunction

function! <SID>InlineVarInsert(sString, dVars)
   let l:sValues = a:sString
   let l:dResult = a:dVars

   let l:sPattern_inline_var = '\v\$\(([a-zA-Z0-9_]+)\)'


   while (match(l:sValues, l:sPattern_inline_var) >= 0)
      let l:sInlineVar_matchlist = matchlist(l:sValues, l:sPattern_inline_var)
      let l:sTmpValue = ""
      if (exists('l:dResult["'.l:sInlineVar_matchlist[1].'"]'))
         let l:sTmpValue = l:dResult[l:sInlineVar_matchlist[1]]
      endif
      let l:sValues = substitute(l:sValues, l:sPattern_inline_var, l:sTmpValue, '')
   endwhile

   return l:sValues
endfunction

" ************************************************************************************************
"                                            makefile
" ************************************************************************************************





function! <SID>GetFileInfo__Makefile(sProjectFilename)
   return {
            \     'modification_time' : getftime(a:sProjectFilename),
            \     'size'              : getfsize(a:sProjectFilename),
            \  }
endfunction

function! <SID>GetFileInfo__None()
   return {
            \     'modification_time' : 0,
            \     'size'              : 0,
            \  }
endfunction

" parses makefile, returns dictionary like this:
"  {
"     'CC' : 'gcc',
"     'CXX' : 'g++',
"     'DEFINES' : '-DUNICODE -DQT_LARGEFILE_SUPPORT -DQT_DLL',
"     'CXXFLAGS' : '-std=gnu++0x -g -frtti -fexceptions -mthreads -Wall -DUNICODE -DQT_LARGEFILE_SUPPORT -DQT_DLL'
"  }
function! <SID>ParseMakefile(sFilename)

   let l:lLines = readfile(a:sFilename)
   let l:dResult = {}

   " now look for variables

   let l:sPattern_qmakeVarName = '(%(%(\\ )|\S)+)'    " matches string like 'foo\ bar'
   let l:sPattern_operation    = '(\=)'     " matches one of three operations: =, +=, -=

   " this pattern matches string like 'MY_VARIABLE = blabla foo bar    foobar  any\ text'
   let l:sPattern_total = '\v^\s*'.l:sPattern_qmakeVarName.'\s*'.l:sPattern_operation.'\s*(.+)$'

   let l:iVarMatchIndex_varName   = 1
   let l:iVarMatchIndex_value     = 3


   let l:sPattern_inline_var = '\v\$\(([a-zA-Z0-9_]+)\)'

   for l:sLine in l:lLines
      let l:sVarAssign_matchlist = matchlist(l:sLine, l:sPattern_total)

      if (len(l:sVarAssign_matchlist) > 0)

         let l:sVarName = l:sVarAssign_matchlist[l:iVarMatchIndex_varName]
         let l:sValues = <SID>Trim(l:sVarAssign_matchlist[l:iVarMatchIndex_value])

         let l:sValues = <SID>InlineVarInsert(l:sValues, l:dResult)

         let l:dResult[l:sVarName] = l:sValues

      endif

      if (<SID>has_keys(l:dResult, ['CC', 'CXX', 'CFLAGS', 'CXXFLAGS', 'INCPATH']))
         break
      endif

   endfor

   return l:dResult

endfunction



function! <SID>ParseProject__Makefile(sFilename)

   let l:dResult = <SID>ParseMakefile(a:sFilename)

   let l:sPathToFile = substitute(a:sFilename, '^\(.*\)[\\/][^\\/]\+$', '\1', 'g')

   " parsing INCPATH
   


   let l:lIncludepath = []
   let l:sTmpINCPATH = l:dResult['INCPATH']


   " parse -I'/foo/bar'
   let l:sPattern_includeItem_squot = '\v\-I''([^'']+)'''

   while (match(l:sTmpINCPATH, l:sPattern_includeItem_squot) >= 0)
      let l:sIncItem_matchlist = matchlist(l:sTmpINCPATH, l:sPattern_includeItem_squot)
      let l:sCurPath = l:sIncItem_matchlist[1]

      if !<SID>IsAbsolutePath(l:sCurPath)
         let l:sCurPath = l:sPathToFile.'/'.l:sCurPath
      endif

      call add(l:lIncludepath, simplify(l:sCurPath))

      let l:sTmpINCPATH = substitute(l:sTmpINCPATH, l:sPattern_includeItem_squot, '', '')
   endwhile

   " parse -I"/foo/bar"
   let l:sPattern_includeItem_squot = '\v\-I"([^"]+)"'

   while (match(l:sTmpINCPATH, l:sPattern_includeItem_squot) >= 0)
      let l:sIncItem_matchlist = matchlist(l:sTmpINCPATH, l:sPattern_includeItem_squot)
      let l:sCurPath = l:sIncItem_matchlist[1]

      if !<SID>IsAbsolutePath(l:sCurPath)
         let l:sCurPath = l:sPathToFile.'/'.l:sCurPath
      endif

      call add(l:lIncludepath, simplify(l:sCurPath))

      let l:sTmpINCPATH = substitute(l:sTmpINCPATH, l:sPattern_includeItem_squot, '', '')
   endwhile



   " parse -I/foo/bar
   let l:sPattern_str = '(%(%(\\ )|\S)+)'    " matches string like 'foo\ bar'
   let l:sPattern_includeItem_noquot = '\v\-I'.l:sPattern_str

   while (match(l:sTmpINCPATH, l:sPattern_includeItem_noquot) >= 0)
      let l:sIncItem_matchlist = matchlist(l:sTmpINCPATH, l:sPattern_includeItem_noquot)

      let l:sCurPath = l:sIncItem_matchlist[1]

      " unescape spaces, because of we will provide path in quotes
      let l:sCurPath = substitute(l:sCurPath, '\\ ', ' ', 'g')

      if !<SID>IsAbsolutePath(l:sCurPath)
         let l:sCurPath = l:sPathToFile.'/'.l:sCurPath
      endif

      call add(l:lIncludepath, simplify(l:sCurPath))

      let l:sTmpINCPATH = substitute(l:sTmpINCPATH, l:sPattern_includeItem_noquot, '', '')
   endwhile


   " add includepath for build dir
   call add(l:lIncludepath, l:sPathToFile)

   let l:dResult['lIncludepath'] = l:lIncludepath
   
   return l:dResult

endfunction

function! <SID>GetData__Makefile(sProjectFilename, dParams)
   let l:lEnvData = [ deepcopy(s:dDefEnvData) ]

   let l:dParams = a:dParams
   let l:sProjectFilename = a:sProjectFilename

   let l:dDefParserParams = {
            \     '-o'     : '%:t:r.o',
            \     'source' : '"%:p"',
            \  }
   let l:dParams = <SID>SetDefaultValues(l:dParams, l:dDefParserParams)

   "let l:dParams['-o'] = '%:t:r.o'
   "let l:dParams['source'] = '%:p'





   let l:dParsedProject = <SID>ParseProject__Makefile(l:sProjectFilename)
   let l:lEnvData[0]['include_paths'] = l:dParsedProject['lIncludepath']
   let l:lEnvData[0]['filetypes']     = ['cpp']
   let l:sMakeprg = ''

   let l:sMakeprg .= l:dParsedProject['CXX'].' '
   let l:sMakeprg .= '-c '
   let l:sMakeprg .= l:dParsedProject['CXXFLAGS'].' '

   for l:sIncludePath in l:dParsedProject['lIncludepath']
      let l:sMakeprg .= '-I"'.l:sIncludePath.'" '
   endfor

   let l:sMakeprg .= '-o "'.l:dParams['-o'].'" '
   let l:sMakeprg .= '"'.l:dParams['source'].'" '

   let l:lEnvData[0]['makeprg']     = l:sMakeprg

   return l:lEnvData


endfunction

function! <SID>GetData__None()
   let l:lEnvData = [ deepcopy(s:dDefEnvData) ]
   return l:lEnvData
endfunction









" ************************************************************************************************
"                                            MPLAB X
" ************************************************************************************************




function! <SID>GetFileInfo__MPLAB_X(sProjectFilename)
   let sConfFilename = a:sProjectFilename.'/nbproject/configurations.xml'

   return {
            \     'modification_time' : getftime(sConfFilename),
            \     'size'              : getfsize(sConfFilename),
            \  }
endfunction


function! <SID>GetData__MPLAB_X(sProjectFilename, dParserParams)

   let l:dDefParserParams = {
            \     'compiler_command_without_includes'  : '',
            \     'source' : '"%:p"',
            \  }


   let l:dParserParams = a:dParserParams
   let l:sProjectFilename = a:sProjectFilename

   let l:dParserParams = <SID>SetDefaultValues(l:dParserParams, l:dDefParserParams)

   let l:sPathToProject = substitute(l:sProjectFilename, '^\(.*\)[\\\][^\\/]\+$', '\1', 'g')
   let l:sPathToProject = substitute(l:sPathToProject, '\\', '/', 'g')

   let l:sPathToProjConfXML = l:sPathToProject.'/nbproject/configurations.xml'

   let l:sFileContents = join(
            \     readfile(l:sPathToProjConfXML),
            \     '\n'
            \  )

   let l:lEnvData = [ deepcopy(s:dDefEnvData) ]
   let l:lEnvData[0]['filetypes']     = ['c', 'cpp']


   let lMatch = matchlist(l:sFileContents, '\v\"extra\-include\-directories\"(.|[\n]){-}value\=\"([^"]*)\"')
   if len(lMatch) == 0
      "call <SID>ErrorRegister('path', 'can''t get include dirs from configurations.xml')
      let lIncludepath = []
   else
      let sIncludes = lMatch[2]
      let lIncludepath = split(sIncludes, '\v\;')

      let l:i = 0
      for l:sCurPath in l:lIncludepath

         if !<SID>IsAbsolutePath(l:sCurPath)
            let l:sCurPath = l:sPathToProject.'/'.l:sCurPath
         endif
         let l:sCurPath = simplify(l:sCurPath)

         let l:lIncludepath[ l:i ] = l:sCurPath

         let l:i += 1

      endfor

      let l:lEnvData[0]['include_paths'] = l:lIncludepath
   endif

   if empty(dParserParams['compiler_command_without_includes'])
      call <SID>ErrorRegister('makeprg', 'you should provide all the compiler command without includes.')
   else
      let lEnvData[0]['makeprg'] = 
               \     dParserParams['compiler_command_without_includes']
               \     .' '.<SID>GetIncludesCommand(lIncludepath)
               \     .' '.dParserParams['source']
   endif

   return lEnvData

endfunction




" ************************************************************************************************
"                                            Keil
" ************************************************************************************************

function! <SID>GetFileInfo__Keil(sProjectFilename)
   let sConfFilename = a:sProjectFilename.'/nbproject/configurations.xml'

   return {
            \     'modification_time' : getftime(sConfFilename),
            \     'size'              : getfsize(sConfFilename),
            \  }
endfunction


function! <SID>GetData__Keil(sProjectFilename, dParserParams)

   let l:dDefParserParams = {
            \     'compiler_command_without_includes'  : '',
            \     'source' : '"%:p"',
            \  }


   let l:dParserParams = a:dParserParams
   let l:sProjectFilename = a:sProjectFilename

   let l:dParserParams = <SID>SetDefaultValues(l:dParserParams, l:dDefParserParams)

   let l:sPathToProject = substitute(l:sProjectFilename, '\v^(.*)[\\/][^\\/]+$', '\1', 'g')
   let l:sPathToProject = substitute(l:sPathToProject, '\\', '/', 'g')

   let l:sFileContents = join(
            \     readfile(l:sProjectFilename),
            \     '\n'
            \  )

   let l:lEnvData = [ deepcopy(s:dDefEnvData) ]
   let l:lEnvData[0]['filetypes']     = ['c', 'cpp']


   let lMatch = matchlist(l:sFileContents, '\v\<IncludePath\>([^<]+)\<\/IncludePath\>')
   if len(lMatch) == 0
      "call <SID>ErrorRegister('path', 'can''t get include dirs from configurations.xml')
      let lIncludepath = []
   else
      let sIncludes = lMatch[1]
      "call confirm(sIncludes)
      let lIncludepath = split(sIncludes, '\v\;')

      let l:i = 0
      for l:sCurPath in l:lIncludepath

         if !<SID>IsAbsolutePath(l:sCurPath)
            let l:sCurPath = l:sPathToProject.'/'.l:sCurPath
         endif
         let l:sCurPath = simplify(l:sCurPath)

         let l:lIncludepath[ l:i ] = l:sCurPath

         let l:i += 1

      endfor

      let l:lEnvData[0]['include_paths'] = l:lIncludepath
   endif

   if empty(dParserParams['compiler_command_without_includes'])
      call <SID>ErrorRegister('makeprg', 'you should provide all the compiler command without includes.')
   else
      let lEnvData[0]['makeprg'] = 
               \     dParserParams['compiler_command_without_includes']
               \     .' '.<SID>GetIncludesCommand(lIncludepath)
               \     .' '.dParserParams['source']
   endif

   return lEnvData

endfunction





" ************************************************************************************************
"                                            MPLAB 8.x
" ************************************************************************************************




function! <SID>GetFileInfo__MPLAB_8_mcp(sProjectFilename)
   return {
            \     'modification_time' : getftime(a:sProjectFilename),
            \     'size'              : getfsize(a:sProjectFilename),
            \  }
endfunction


" parse MPLAB project file .mcp
" 
" just parse and return dictionary like this:
"  {
"     'SECTION_1' : {
"        'param_1' : 'value_1',
"        'param_2' : 'value_2'
"     },
"     'SECTION_2' : {
"        'param_1' : 'value_1',
"        'param_2' : 'value_2'
"     }
"  }
"
"  @param sProjectFilename     string, project filename (*.mcp)
"  @param lNeededSections  list, needed sections to get.
"                          if an empty list given, then all sections will be
"                          retrieved, otherwise only sections that specified.
"                          example: ['SECTION_1', 'SECTION_2']
function! <SID>Parse_MPLAB_mcp(sProjectFilename, lNeededSections)
   
   let l:lLines = readfile(a:sProjectFilename)
   let l:dResult = {}

   let l:sPattern_section  = '\v^\s*\[([^\[\]]+)\]\s*$'        " matches string like '[MY_SECTION]'
   let l:sPattern_parValue = '\v^\s*([^=]+)\s*\=\s*(.*)\s*$'   " matches string like 'par=value'

   let l:boolInNeededSection    = 0    " we need to save params from current section
   let l:boolSaveParNames       = 0    " we need to save param name
   let l:boolSaveParNumbers     = 0    " we need to save param numbers

   let l:sCurSectionName        = ''

   for l:sLine in l:lLines
      " look if current line is a start of new section
      let l:sSection_matchlist = matchlist(l:sLine, l:sPattern_section)

      if (len(l:sSection_matchlist) > 0)
         " echo a:lNeededSections
         " echo l:sCurSectionName.'__num'
         let l:sCurSectionName = l:sSection_matchlist[1]

         if (len(a:lNeededSections) == 0)
            " needed section starts, because of we need ALL sections
            " (a:lNeededSections is empty)
            let l:boolInNeededSection    = 1
            let l:boolSaveParNumbers     = 0
            let l:dResult[ l:sCurSectionName ] = {}
         else
            let l:boolSaveParNumbers     = 0
            let l:boolSaveParNames       = 0
            let l:boolInNeededSection    = 0

            if (index(a:lNeededSections, l:sCurSectionName) >= 0)
               " needed section starts
               let l:boolInNeededSection          = 1
               let l:boolSaveParNames             = 1
               let l:dResult[ l:sCurSectionName ] = {}
            endif

            if (index(a:lNeededSections, l:sCurSectionName.'__num') >= 0)
               " needed section starts (save NUMBERS)
               let l:boolInNeededSection          = 1
               let l:boolSaveParNumbers           = 1
               let l:dResult[ l:sCurSectionName.'__num' ] = {}
            endif

            " check if we already got all needed sections
            if (!l:boolInNeededSection)
               if (len(a:lNeededSections) > 0 && len(l:dResult) == len(a:lNeededSections))
                  break
               endif
            endif

         endif


         continue
      endif


      " if we are in needed section, then
      " look if current line is par=value
      if (l:boolInNeededSection)
         let l:sParValue_matchlist = matchlist(l:sLine, l:sPattern_parValue)

         if (len(l:sParValue_matchlist) > 0)
            let l:sParam = l:sParValue_matchlist[1]
            let l:sValue = l:sParValue_matchlist[2]

            if (l:boolSaveParNames)
               let l:dResult[ l:sCurSectionName ][ l:sParam ] = l:sValue
            endif

            if (l:boolSaveParNumbers)
               let l:dResult[ l:sCurSectionName.'__num' ][ len(l:dResult[ l:sCurSectionName.'__num' ]) ] = l:sValue
            endif
         endif
      endif

   endfor

   return l:dResult

endfunction

" @param dParsedProject    result of function <SID>Parse_MPLAB_mcp()
" @param dParams           params, given to MakeprgGenerate()
"
" @return dictionary with two keys: 'compiler_executable', 'compiler_params'.
" for example:
"  {
"     'compiler_executable' : 'pic30-gcc.exe',
"     'compiler_params'     : '-g -Wall -mlarge-code -Os'
"  }
"  
function! <SID>MPLAB_8_CompilerParams_Get(dParsedProject, dParserParams, sPathToProject)
   let l:dResult = { 
            \     'compiler_executable' : '',
            \     'compiler_params'     : '',
            \  }

   let l:dDefParserParams = {
            \     'needed_tool_settings' : '',
            \     'compiler_executable'  : '',
            \     'compiler_params' : {
            \        'add'    : '',
            \        'mcpu'   : '',
            \        'obj'    : '',
            \        'source' : '"%:p"',
            \     },
            \  }

   let l:dDatabase = {
            \     'suite_guid' : {
            \        '{479DDE59-4D56-455E-855E-FFF59A3DB57E}' : {
            \           'needed_tool_settings' : 'TS{25AC22BD-2378-4FDB-BFB6-7345A15512D3}',
            \           'compiler_executable'  : 'pic30-gcc',
            \           'compiler_params' : {
            \              'mcpu'   : '-mcpu=$(MCPU)',
            \              'add'    : '-x c -c',
            \              'obj'    : '-o "$(OBJ_FILE)"',
            \              'source' : '"%:p"',
            \           },
            \        },
            \        '{6021FCB8-0CEB-40BB-8757-661CF38FC6F1}' : {
            \           'needed_tool_settings' : 'TS{49FF0217-4FF8-4C92-809A-52A18451954C}',
            \           'compiler_executable'  : 'picc18.exe',
            \           'compiler_params' : {
            \              'mcpu'   : '-$(MCPU)',
            \              'add'    : '-Q -C --ERRFORMAT="\%f:\%l:\%c: error: \%s (\#\%n)" --WARNFORMAT="\%f:\%l:\%c: warning: \%s (\#\%n)" ',
            \              'obj'    : '-O"$(OBJ_FILE)"',
            \              'source' : '"%:p"',
            \           },
            \        },
            \        '{5B7D72DD-9861-47BD-9F60-2BE967BF8416}' : {
            \           'needed_tool_settings' : 'TS{C2AF05E7-1416-4625-923D-E114DB6E2B96}',
            \           'compiler_executable'  : 'mcc18.exe',
            \           'compiler_params' : {
            \              'mcpu'   : '-p=$(MCPU)',
            \              'add'    : '',
            \              'obj'    : '-fo="$(OBJ_FILE)"',
            \              'source' : '"%:p"',
            \           },
            \        },
            \     },
            \  }


   let l:sPathToProject = a:sPathToProject

   " --- check if we know anything about suite_guid from project

   let l:dParserParams = a:dParserParams

   let l:sSuiteGuid = a:dParsedProject['SUITE_INFO']['suite_guid']
   if (has_key(l:dDatabase['suite_guid'], l:sSuiteGuid))
      " suite_guid from project is found in our database!
      let l:dSuiteGuid = l:dDatabase['suite_guid'][ l:sSuiteGuid ]
      let l:boolSuitGuidKnown = 1

      let l:dParserParams = <SID>SetDefaultValues(l:dParserParams, l:dSuiteGuid)

   else 
      let l:boolSuitGuidKnown = 0
   endif

   let l:dParserParams = <SID>SetDefaultValues(l:dParserParams, l:dDefParserParams)

   " --- retrieve compiler_executable

   let l:dResult['compiler_executable'] = l:dParserParams['compiler_executable']

   " --- retrieve needed mcpu

   let l:sCompilerMcpu = <SID>InlineVarInsert(l:dParserParams['compiler_params']['mcpu'], {
            \     'MCPU' : substitute(a:dParsedProject['HEADER']['device'], '\v^PIC', '', 'g'),
            \  })

   " --- retrieve compiler_params

   let l:sCompilerParamsFromToolSettings = ''

   let l:sToolSettingsName = l:dParserParams['needed_tool_settings']
   if (has_key(a:dParsedProject['TOOL_SETTINGS'], l:sToolSettingsName))
      " in project is found needed TOOL_SETTINGS. Good.
      let l:sCompilerParamsFromToolSettings = a:dParsedProject['TOOL_SETTINGS'][ l:sToolSettingsName ]
   endif

   " --- retrieve obj

   let l:sObj = a:dParsedProject['PATH_INFO']['dir_tmp']
   if !<SID>IsAbsolutePath(l:sObj)
      let l:sObj = l:sPathToProject.'/'.l:sObj
      let l:sObj = substitute(l:sPathToProject, '\/\/', '/', 'g')
   endif

   let l:sObj .= '/%:t:r.o'

   let l:sCompilerObj = <SID>InlineVarInsert(l:dParserParams['compiler_params']['obj'], {
            \     'OBJ_FILE' : l:sObj,
            \  })









   let l:dResult['compiler_params'] = 
            \  l:dParserParams['compiler_params']['add'].' '
            \ .l:sCompilerMcpu.' '
            \ .l:sCompilerParamsFromToolSettings.' '
            \ .l:sCompilerObj.' '
            \ .l:dParserParams['compiler_params']['source'].' '

   return l:dResult

endfunction



function! <SID>GetData__MPLAB_8_mcp(sProjectFilename, dParserParams)
   let l:dParserParams = a:dParserParams
   let l:sProjectFilename = a:sProjectFilename

   let l:sPathToProject = substitute(l:sProjectFilename, '^\(.*\)[\\/][^\\/]\+$', '\1', 'g')
   let l:sPathToProject = substitute(l:sPathToProject, '\\', '/', 'g')

   let l:lEnvData = [ deepcopy(s:dDefEnvData) ]

   " see comment in the header of this file

   "let l:dDefParams = {
            "\     'compiler_executable'          : '',
            "\     'compiler_add_params'          : '-x c -c',
            "\     'compiler_mcpu'                : '',
            "\     'compiler_tool_settings_use'   : '',
            "\     '-o'                           : '',
            "\     'source'                       : '%:p',
            "\  }

   " set default values for non-specified params
   "let l:dParserParams = <SID>SetDefaultValues(l:dParserParams, l:dDefParams)

   " parse .mcp project

   let l:lSections = [ 'HEADER', 'PATH_INFO', 'SUITE_INFO', 'TOOL_SETTINGS', 'TOOL_SETTINGS__num' ]
   let l:dParsedProject = <SID>Parse_MPLAB_mcp(l:sProjectFilename, l:lSections)


   let l:lEnvData[0]['filetypes']     = ['c', 'cpp']


   if !has_key(l:dParsedProject, 'PATH_INFO')
      call <SID>ErrorRegister('path', 'There''s no needed section ''PATH_INFO'' in your .mcp file')
   else
      " get includes
      let l:lIncludepath = split(l:dParsedProject['PATH_INFO']['dir_inc'], '\v\;')

      let l:i = 0
      for l:sCurPath in l:lIncludepath

         if !<SID>IsAbsolutePath(l:sCurPath)
            let l:sCurPath = l:sPathToProject.'/'.l:sCurPath
         endif
         let l:sCurPath = simplify(l:sCurPath)

         let l:lIncludepath[ l:i ] = l:sCurPath

         let l:i += 1

      endfor

      let l:lEnvData[0]['include_paths'] = l:lIncludepath

   endif


   if (!<SID>has_keys(l:dParsedProject, l:lSections))
      call <SID>ErrorRegister('makeprg', 'There''s not all needed sections in your .mcp file')
   else

      "try
         " get compiler_executable and compiler_params
         let l:dCompilerParams = <SID>MPLAB_8_CompilerParams_Get(l:dParsedProject, l:dParserParams, l:sPathToProject)

         let l:sIncludes = ''
         for l:sCurPath in l:lEnvData[0]['include_paths']
            let l:sIncludes .= '-I"'.l:sCurPath.'" '
         endfor

         let l:lEnvData[0]['makeprg'] = l:dCompilerParams['compiler_executable'].' '
                  \ .l:dCompilerParams['compiler_params'].' '
                  \ .l:sIncludes.' '

      "catch
         "if (empty(s:sErrorText))
            "call <SID>ErrorRegister('makeprg', 'unknown error')
         "endif
      "endtry

   endif




   return l:lEnvData
endfunction













" ************************************************************************************************
"                                         GENERAL. PUBLIC
" ************************************************************************************************

function! envcontrol#reparse()
   let lCurParsedFileInfo = s:lParsedFilesInfo[ s:iCurParsedFile ]
   let dParams = lCurParsedFileInfo['prop']['dParams']
   let dParams['bool_reparse'] = 1

   call envcontrol#set_project_file(
            \     lCurParsedFileInfo['prop']['filename'],
            \     lCurParsedFileInfo['prop']['project_type'],
            \     dParams
            \  )

   call envcontrol#set_path()
   call envcontrol#set_makeprg()
   call envcontrol#set_clang_params()

endfunction

" Main function of plugin.
" Generates &makeprg from project file.
"
" @param sProjectFilename    string, project filename
" @param sProjectType string, project type, one of the following:
"     'MPLAB_8_mcp'
"     'makefile'
" @param dParams      dictionary, special params for specified project type.
"
" @return             string to put in &makeprg
function! envcontrol#set_project_file(sProjectFilename, sProjectType, dParams)

   "let s:sErrorText = ''
   call <SID>ErrorsClear()

   " 'handle_path' : should envcontrol handle &path option or not
   " 'handle_makeprg' : should envcontrol handle &makeprg option or not
   " 'handle_clang' : should envcontrol handle clang options or not
   " 'add_paths' : NOTE!! these paths will NOT be added to the &makeprg as
   "               additional include paths, but they WILL be added to &path,
   "               and to clang include paths.
   "
   "               Typical use: set here some standard paths of your compiler:
   "
   "               &makeprg does not need them, since your compiler knows its
   "               standard paths; but &path will be extended by them (which
   "               is useful), and clang will include them (which is needed
   "               for code-completion)
   let l:dDefParams = {
            \     'handle_path'      : 1,
            \     'handle_makeprg'   : 1,
            \     'handle_clang'     : 1,
            \     'add_paths'        : [],
            \     'clang_add_params' : '',
            \     'parser_params'    : {},
            \     'bool_reparse'     : 0,
            \  }

   let l:dParams = a:dParams
   " set default values for non-specified params
   let l:dParams = <SID>SetDefaultValues(l:dParams, l:dDefParams)

   let bool_reparse = l:dParams['bool_reparse']

   " unlet bool_reparse in order to not remember it in s:lParsedFilesInfo
   unlet l:dParams['bool_reparse']

   "COMMENTED because for project type 'none' empty filename is allowed
   "if (a:sProjectFilename != '')
   if (1)
      let l:sProjectFilename = simplify(a:sProjectFilename)
      "\        'info'              : {
      "\           'size'              : getfsize(l:sProjectFilename),
      "\           'modification_time' : getftime(l:sProjectFilename),
      "\        },

      " get info about file
      let l:dFileInfo = {
               \     'prop' : {
               \        'filename'          : l:sProjectFilename,
               \        'project_type'      : a:sProjectType,
               \        'dParams'           : deepcopy(l:dParams),
               \        'info'              : <SID>GetFileInfo(l:sProjectFilename, a:sProjectType),
               \     },
               \
               \     'lEnvData'             : [],
               \  }

   endif


   " check if this file is already parsed
   let l:boolAlreadyParsed = 0

   let l:i = 0
   call <SID>SetCurParsedFile(-1)


   for l:dTmpParsedFile in s:lParsedFilesInfo

      if (l:dFileInfo['prop']['filename'] == l:dTmpParsedFile['prop']['filename'])
         " this file is parsed earlier, but maybe it has been changed..

         call <SID>SetCurParsedFile(l:i)

         if (!bool_reparse && l:dFileInfo['prop'] == l:dTmpParsedFile['prop'])
            " this file has NOT been changed. No need to parse it again!
            let l:boolAlreadyParsed = 1
            "call confirm('NOT changed cur='.dFileInfo['prop']['info']['modification_time'].' old='.dTmpParsedFile['prop']['info']['modification_time'])
         else
            " this file has been changed. We NEED to parse it again
            let s:lParsedFilesInfo[l:i] = l:dFileInfo
            "call confirm('changed!')
         endif

         break

      endif

      let l:i += 1
   endfor

   if s:iCurParsedFile == -1
      " this file has not been parsed. we need to add it to our database
      " and parse
      call <SID>SetCurParsedFile(len(s:lParsedFilesInfo))
      call add(s:lParsedFilesInfo, l:dFileInfo)
   endif


   if (l:boolAlreadyParsed)
      "echo "already"
      "call confirm("already")
      " let l:sRet = s:lParsedFilesInfo[l:sProjectFilename]['makeprg']
   else
      let l:lEnvData = [ deepcopy(s:dDefEnvData) ]
      "echo "parsing"
      "call confirm("parsing")
      " removing last part of path (removing all after last slash)
      if (a:sProjectType == '')
         call <SID>ErrorRegister('common', "project_type not defined")

         "COMMENTED because for project type 'none' any filename is allowed
      "elseif (a:sProjectFilename == '')
         "call <SID>ErrorRegister('common', "filename not defined")

      "elseif (!filereadable(a:sProjectFilename) && !isdirectory(a:sProjectFilename))
         "call <SID>ErrorRegister('common', "file '".a:sProjectFilename."' not found")
      else






         if (a:sProjectType == 'MPLAB_8_mcp')
            " ---------- MPLAB 8.x mcp ----------

            let l:lEnvData = <SID>GetData__MPLAB_8_mcp(l:sProjectFilename, l:dParams['parser_params'])


         elseif (a:sProjectType == 'MPLAB_X')
            " ---------- MPLAB X ----------

            let l:lEnvData = <SID>GetData__MPLAB_X(l:sProjectFilename, l:dParams['parser_params'])

         elseif (a:sProjectType == 'Keil')
            " ---------- Keil ----------

            let l:lEnvData = <SID>GetData__Keil(l:sProjectFilename, l:dParams['parser_params'])

         elseif (a:sProjectType == 'makefile')
            " ---------- makefile ----------

            let l:lEnvData = <SID>GetData__Makefile(l:sProjectFilename, l:dParams['parser_params'])

         elseif (a:sProjectType == 'none')
            " ---------- none ----------

            let l:lEnvData = <SID>GetData__None()

         else
            call <SID>ErrorRegister('common', "project_type '".a:sProjectType."' is not supported")
         endif

         call extend(l:lEnvData[0]['include_paths'], l:dParams['add_paths'])

         "let g:tmp = l:lEnvData
         "PP g:tmp
         "call confirm(1)


         " on Windows systems we should do the trick with quotes because of
         " cmd's behavior.
         "
         " if &makeprg is 'echo 123', then Vim does this:   cmd.exe /c echo 123.
         " so, if &makeprg is 
         " '"C:/Program Files/blablabla.exe" some_input_files', then Vim does
         " this:
         " cmd.exe /c "C:/Program Files/blablabla.exe" some_input_files
         "
         " but there's trouble: if after /c is quote, then cmd.exe thinks that
         " all command is quoted, not the part of command.
         " And it returns that "C:\Program" is not a file.
         "
         " To make it work, we should add quotes for a whole command:
         "
         " let &makeprg = '""C:/Program Files/blablabla.exe" some_input_files"'
         " then, command will be:
         "
         " cmd.exe /c ""C:/Program Files/blablabla.exe" some_input_files"
         "
         " and this will work.
         "
         " TODO: I found out that we can just use &shellxquote to make it automatically.
         "       So, maybe it's better to warn user to use shellxquote?
         if has('win32') || has('win64')
            if empty(&shellxquote)
               for l:dCurEnvData in l:lEnvData
                  if strpart(l:dCurEnvData['makeprg'], 0, 1) == '"'
                     let l:dCurEnvData['makeprg'] = '"'.l:dCurEnvData['makeprg'].'"'
                  endif
               endfor
            endif
         endif

         "echoerr 1
         "echo l:lEnvData[0]['include_paths']
         "call confirm (1)

         " simplify all include_paths
         let l:i = 0
         for l:dCurEnvData in l:lEnvData
            let l:j = 0
            for l:sCurPath in l:lEnvData[ l:i ]['include_paths']
               let l:lEnvData[ l:i ]['include_paths'][l:j] = simplify( l:lEnvData[ l:i ]['include_paths'][l:j] )
               "call confirm(l:lEnvData[ l:i ]['include_paths'][l:j])
               let l:j += 1
            endfor
            let l:i += 1
         endfor

      endif

      if (!empty(s:dErrors['common']))
         let l:lEnvData = [ deepcopy(s:dDefEnvData) ]
         let l:lEnvData[0]['makeprg'] = 'echo MakeprgGenerate error: '.s:dErrors['common']
      elseif (!empty(s:dErrors['makeprg']))
         let l:lEnvData[0]['makeprg'] = 'echo MakeprgGenerate error: '.s:dErrors['makeprg']
      endif
      " TODO: report path errors, not only makeprg

      let s:lParsedFilesInfo[ s:iCurParsedFile ]['lEnvData'] = l:lEnvData
   endif

   if !s:boolVimprjCompatible
      call envcontrol#set_path()
      call envcontrol#set_makeprg()
      call envcontrol#set_clang_params()
   endif

   "call confirm("set ".s:iCurParsedFile)
endfunction


function! envcontrol#set_previous()
   call <SID>SetCurParsedFile(s:iPrevParsedFile)
   "call confirm("previous ".s:iCurParsedFile)
endfunction


function! envcontrol#set_inactive()
   call <SID>SetCurParsedFile(-1)
   "call confirm("inactive ".s:iCurParsedFile)
endfunction

function! <SID>SetCurParsedFile(iParsedFileNum)
   if s:iCurParsedFile >= 0
      let s:iPrevParsedFile = s:iCurParsedFile
   endif

   if s:iPrevParsedFile == -1
      let s:iPrevParsedFile = a:iParsedFileNum
   endif

   let s:iCurParsedFile = a:iParsedFileNum
endfunction


function! envcontrol#set_path()

   " TODO: analyze &ft
   "call confirm(s:iCurParsedFile)

   if s:iCurParsedFile >= 0
      if s:lParsedFilesInfo[ s:iCurParsedFile ]['prop']['dParams']['handle_path']
         let l:lEnvData = s:lParsedFilesInfo[ s:iCurParsedFile ]['lEnvData']
         let l:iEnvDataNum = 0
         for l:sCurPath in l:lEnvData[ l:iEnvDataNum ]['include_paths']
            exec 'set path+='.escape(l:sCurPath, ' \')
         endfor
      endif
   endif
endfunction

function! envcontrol#set_makeprg()
   
   " TODO: analyze &ft
   if s:iCurParsedFile >= 0
      if s:lParsedFilesInfo[ s:iCurParsedFile ]['prop']['dParams']['handle_makeprg']
         let l:lEnvData = s:lParsedFilesInfo[ s:iCurParsedFile ]['lEnvData']
         let l:iEnvDataNum = 0
         let &makeprg = l:lEnvData[ l:iEnvDataNum ]['makeprg']
      endif
   endif

endfunction

function! envcontrol#set_clang_params()

   if s:iCurParsedFile >= 0
      if s:lParsedFilesInfo[ s:iCurParsedFile ]['prop']['dParams']['handle_clang']
         let l:lEnvData = s:lParsedFilesInfo[ s:iCurParsedFile ]['lEnvData']
         let l:iEnvDataNum = 0
         let sIncludes = '-I'.join(l:lEnvData[ l:iEnvDataNum ]['include_paths'], '  -I')
         let g:clang_user_options = ''
                  \     . '  '.s:lParsedFilesInfo[ s:iCurParsedFile ]['prop']['dParams']['clang_add_params']
                  \     . '  '.sIncludes


         "call ClangCompleteWarmupCache()
      endif
   endif

endfunction

"let s:sErrorText = ""

let s:dErrors = {
         \     'makeprg' : '',
         \     'path'    : '',
         \     'common'  : '',
         \  }

let s:lParsedFilesInfo = []

let s:iCurParsedFile = -1
let s:iPrevParsedFile = -1

let s:dDefEnvData = {
         \     'filetypes'     : [],
         \     'makeprg' : '',
         \     'include_paths' : [],
         \  }



if s:boolVimprjCompatible
   function! g:vimprj#dHooks['SetDefaultOptions']['envcontrol'](dParams)
      call envcontrol#set_inactive()
   endfunction

   function! g:vimprj#dHooks['OnAfterSourcingVimprj']['envcontrol'](dParams)
      "call confirm('envcontrol OnAfterSourcingVimprj, '.s:iCurParsedFile)
      call envcontrol#set_path()
      call envcontrol#set_makeprg()
      call envcontrol#set_clang_params()
   endfunction
else
   "augroup envcontrol_BufEnter
      "autocmd! envcontrol_BufEnter
      "autocmd envcontrol_BufEnter BufEnter * call envcontrol#set_makeprg()
      "autocmd envcontrol_BufEnter BufEnter * call envcontrol#set_path()
   "augroup END
endif



command! -nargs=? -complete=file EnvcontrolReparse call envcontrol#reparse()
command! -nargs=? -complete=file EnvcontrolReload  call envcontrol#reparse()
command! -nargs=? -complete=file EnvcontrolRefresh call envcontrol#reparse()




"command! -nargs=? -complete=file Make call envcontrol#make()
"" define lowercased aliases if possible
"if exists("loaded_cmdalias") && exists("*CmdAlias")
   "call CmdAlias('mak', 'Make')
   "call CmdAlias('make', 'Make')
"endif




"unlet g:test
"let g:test = <SID>Parse_MPLAB_mcp('D:\projects\bk100-series\iface\PIC24\appl\iface_PIC24_appl.mcp', [ 'PATH_INFO', 'SUITE_INFO', 'TOOL_SETTINGS', 'TOOL_SETTINGS__num' ])

"let g:test = <SID>ParseProject__Makefile('D:\projects\bk100-series\utils\iface_PIC24\bk90_loader-build-desktop\Makefile.Release')

"PrettyPrint g:test

"echo MakeprgGenerate('D:\projects\bk100-series\utils\iface_PIC24\bk90_loader-build-desktop\Makefile.Release', 'makefile', {})
"echo MakeprgGenerate('D:\projects\bk100-series\iface\PIC24\appl\iface_PIC24_appl.mcp', 'MPLAB_8_mcp', {})




