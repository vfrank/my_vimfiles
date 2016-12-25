" Vim syntax file
" Language: C, C++

syn keyword cType U08 U16 U32 U64 S08 S16 S32 S64
syn keyword cType U08_FAST U16_FAST U32_FAST U64_FAST S08_FAST S16_FAST S32_FAST S64_FAST
syn keyword cType WORD UWORD
syn match cType   "\v<_{0,1}T_[a-zA-Z0-9_]+"
"syn match cType   "\v(struct\s+)@<=[a-zA-Z0-9_]+"
"syn match cType   "\v(enum\s+)@<=[a-zA-Z0-9_]+"

syn match	cFormat		display "%\(\d\+\$\)\=[-+' #0*]*\(\d*\|\*\|\*\d\+\$\)\(\.\(\d*\|\*\|\*\d\+\$\)\)\=\(\,\(\d*\|\*\|\*\d\+\$\)\)\=\([hlLjzt]\|ll\|hh\)\=\([aAbdiuoxXDOUfFeEgGcCsSpn]\|\[\^\=.[^]]*\]\)" contained

if 0
   if !exists("c_ignore_javadoc")
      " match the special comment /**/
      syn match   javaComment		 "/\*\*/"

      syntax case ignore
      " syntax coloring for javadoc comments (HTML)

      "syntax include @javaHtml <sfile>:p:h/html.vim
      "unlet b:current_syntax

      " HTML enables spell checking for all text that is not in a syntax item. This
      " is wrong for Java (all identifiers would be spell-checked), so it's undone
      " here.
      syntax spell default

      syn region  javaDocComment	start="/\*\*"  end="\*/" keepend contains=javaCommentTitle,javaDocTags,javaDocSeeTag,javaTodo,@Spell
      syn region  javaCommentTitle	contained matchgroup=javaDocComment start="/\*\*"   matchgroup=javaCommentTitle keepend end="\.$" end="\.[ \t\r<&]"me=e-1 end="[^{]@"me=s-2,he=s-1 end="\*/"me=s-1,he=s-1 contains=@javaHtml,javaCommentStar,javaTodo,@Spell,javaDocTags,javaDocSeeTag

      syn region javaDocTags	 contained start="{@\(link\|linkplain\|inherit[Dd]oc\|doc[rR]oot\|value\)" end="}"
      syn match  javaDocTags	 contained "@\(param\|exception\|throws\|since\)\s\+\S\+" contains=javaDocParam
      syn match  javaDocParam	 contained "\s\S\+"
      syn match  javaDocTags	 contained "@\(version\|author\|return\|deprecated\|serial\|serialField\|serialData\)\>"
      syn region javaDocSeeTag	 contained matchgroup=javaDocTags start="@see\s\+" matchgroup=NONE end="\_."re=e-1 contains=javaDocSeeTagParam
      syn match  javaDocSeeTagParam  contained @"\_[^"]\+"\|<a\s\+\_.\{-}</a>\|\(\k\|\.\)*\(#\k\+\((\_[^)]\+)\)\=\)\=@ extend
      syntax case match
   endif

   hi def link javaComment		Comment
   hi def link javaCommentTitle		SpecialComment
   hi def link javaDocComment		Comment
   hi def link javaDocTags		Special
   hi def link javaDocParam		Function
   hi def link javaDocSeeTagParam		Function
endif
