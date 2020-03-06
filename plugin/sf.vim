" Last Change:  ?
" Maintainer:   Rafał Camlet <raf.camlet@gmail.com>
" License:      GNU General Public License v3.0

if exists('g:loaded_nvim_sf') | finish | endif " prevent loading file twice

let s:save_cpo = &cpo
set cpo&vim

hi SuperFindRed ctermfg=9
hi SuperFindGreen ctermfg=10

command! -complete=dir -nargs=1 SF lua require'sf'.sf(<q-args>)

let &cpo = s:save_cpo
unlet s:save_cpo

let g:loaded_nvim_sf = 1
