let b:syntastic_skip_checks=0
function s:syntastic_check_toggle()
    if !exists("b:syntastic_skip_checks")
        let b:syntastic_skip_checks=1
    else
        let b:syntastic_skip_checks=!b:syntastic_skip_checks
    endif
endfunction

command! -nargs=0 SyntasticCheckToggle call s:syntastic_check_toggle()
