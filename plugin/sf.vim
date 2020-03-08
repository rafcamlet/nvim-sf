" Last Change:  ?
" Maintainer:   Rafał Camlet <raf.camlet@gmail.com>
" License:      GNU General Public License v3.0

if exists('g:loaded_nvim_sf') | finish | endif " prevent loading file twice

function! SuperFindReturnHighlightTerm(group, term)
   " from https://vi.stackexchange.com/questions/12293/read-values-from-a-highlight-group
   let output = execute('hi ' . a:group)
   return matchstr(output, a:term.'=\zs\S*')
endfunction

let s:save_cpo = &cpo
set cpo&vim

hi SuperFindRed ctermfg=9
hi SuperFindGreen ctermfg=10

try
  let s:background = SuperFindReturnHighlightTerm('CursorLine', 'ctermbg')
  exec 'hi SuperFindStGreen ctermfg=10 ctermbg=' . s:background
catch /.*/
  hi SuperFindStGreen ctermbg=10 ctermfg=0
endtry

command! -complete=dir -nargs=1 SF lua require'sf'.sf(<q-args>)

let &cpo = s:save_cpo
unlet s:save_cpo

let g:loaded_nvim_sf = 1
