" 引数なしでvimを開いたらNERDTreeを起動、
" 引数ありならNERDTreeは起動せず、引数で渡されたファイルを開く。
" 2020/10/02 vim-startifyと同時に開くのでコメントアウト
" autocmd vimenter * if !argc() | NERDTree | endif

" 他のバッファをすべて閉じた時にNERDTreeが開いていたらNERDTreeも一緒に閉じる。
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

" 隠しファイルを表示
let g:NERDTreeShowHidden=1

" 非表示ファイル
let g:NERDTreeIgnore=['\.git$']

nnoremap <Space>e :NERDTreeFind<CR>
