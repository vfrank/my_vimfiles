autocmd BufReadPost  * call confirm('readpost #: '.bufnr('#').' '.expand('#')." %: ".bufnr('%').' '.expand('%')." <afile>: ".bufnr(expand('<afile>')).' '.expand('<afile>'))
autocmd BufNewFile   * call confirm('newfile #: '.bufnr('#').' '.expand('#')." %: ".bufnr('%').' '.expand('%')." <afile>: ".bufnr(expand('<afile>')).' '.expand('<afile>'))
"autocmd BufEnter     * call confirm('enter #: '.bufnr('#').' '.expand('#')." %: ".bufnr('%').' '.expand('%')." <afile>: ".bufnr(expand('<afile>')).' '.expand('<afile>'))
autocmd BufWritePost * call confirm('writepost #: '.bufnr('#').' '.expand('#')." %: ".bufnr('%').' '.expand('%')." <afile>: ".bufnr(expand('<afile>')).' '.expand('<afile>'))
autocmd BufWritePre  * call confirm('writepre #'.bufnr('#').' '.expand('#')." %: ".bufnr('%').' '.expand('%')." <afile>: ".bufnr(expand('<afile>')).' '.expand('<afile>'))

