function! <SID>StripTrailingWhitespaces()
    let l = line(".")
    let c = col(".")
    %s/\s\+$//e
    call cursor(l, c)
endfun

autocmd BufWritePre *.h,*.c,*.py,*.S,*.s,*.asm :call <SID>StripTrailingWhitespaces()
