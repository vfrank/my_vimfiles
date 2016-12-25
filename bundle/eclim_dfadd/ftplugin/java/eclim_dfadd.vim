

if exists('b:eclim_dfadd_java_complete_initialized')
   finish
endif

let b:eclim_dfadd_java_complete_initialized = 1

call eclim_dfadd#java#complete#Init()


