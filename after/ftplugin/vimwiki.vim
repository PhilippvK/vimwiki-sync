augroup vimwiki
  if !exists('g:zettel_synced')
    let g:zettel_synced = 0
  else
    finish
  endif

  " g:zettel_dir is defined by vim_zettel
  if !exists('g:zettel_dir')
    let g:zettel_dir = vimwiki#vars#get_wikilocal('path') "VimwikiGet('path',g:vimwiki_current_idx)
  endif

  " don't try to start synchronization if the opend file is not in vimwiki
  " path
  let current_dir = expand("%:p:h")
  if !current_dir ==# fnamemodify(g:zettel_dir, ":h")
    finish
  endif

  " don't sync temporary wiki
  if vimwiki#vars#get_wikilocal('is_temporary_wiki') == 1
    finish
  endif

  " execute vim function. because vimwiki can be started from any directory,
  " we must use pushd and popd commands to execute git commands in wiki root
  " dir. silent is used to disable necessity to press <enter> after each
  " command. the downside is that the command output is not displayed at all.
  " One idea: what about running git asynchronously?
  " NEW: Sync Taskwarrior if installed and configured
  function! s:git_action(action)
    execute ':silent !pushd ' . g:zettel_dir . "; ". a:action . "; popd"
    execute ':silent !test -f $HOME/.taskrc && task sync'
    "execute ':silent !eval PAPIS_DIR=$(papis config dir) && test -d $PAPIS_DIR/.git/ && papis git pull'
    "execute ':silent !eval PAPIS_DIR=$(papis config dir) && test -d $PAPIS_DIR/.git/ && papis git push'
    " TODO: introduce parameters like push_extra_cmd, pull_extra_cmd
    " prevent screen artifacts
    redraw!
  endfunction

  call <sid>git_action("git pull origin main")

  " Commented out because this breakes the search function
  " au! BufRead * call <sid>git_action("git pull origin main")
  " auto commit changes on each file change
  au! BufWritePost * call <sid>git_action("git add .;git commit -m \"Auto commit + push. `date`\"")
  " push changes only on at the end
  au! VimLeave * call <sid>git_action("git pull origin main && git push origin main")
augroup END
