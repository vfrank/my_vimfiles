
function! MaximizeInCurrentMonitor()

   if has('unix')
      if executable('wmctrl')
         call system('wmctrl -i -b add,maximized_vert,maximized_horz -r '.v:windowid)
      else
         echo "you probably want to install wmctrl to make gvim maximized"
         set lines=78
         set columns=237
      endif
   endif

endfunction

function! MaximizeInLeftMonitor()

   winpos 0 0

   call MaximizeInCurrentMonitor()

endfunction

autocmd GUIEnter * call MaximizeInLeftMonitor()

