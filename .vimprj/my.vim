
" определяем путь к папке .vim
let s:sVimprjPath = expand('<sfile>:p:h')

let &tabstop = 3
let &shiftwidth = 3

let g:indexer_indexerListFilename = s:sVimprjPath.'/.indexer_files'
let g:indexer_ctagsCommandLineOptions = ''

call envcontrol#set_previous()

let s:sProjectPath = simplify(s:sVimprjPath.'/..')

let g:vimwiki_list[0] =
         \  {
         \     'maxhi': 0,
         \     'css_name': 'style.css',
         \     'auto_export': 0,
         \     'diary_index': 'diary',
         \     'template_default': '',
         \     'nested_syntaxes': {},
         \     'diary_sort': 'desc',
         \     'path': s:sProjectPath.'/stuff/vimwiki/',
         \     'diary_link_fmt': '%Y-%m-%d',
         \     'template_ext': '',
         \     'syntax': 'default',
         \     'custom_wiki2html': '',
         \     'index': 'index',
         \     'diary_header': 'Diary',
         \     'ext': '.wiki',
         \     'path_html': '',
         \     'temp': 0,
         \     'template_path': '',
         \     'list_margin': -1,
         \     'diary_rel_path': 'diary/'
         \  }

