" Vim indent file
"
" Language:     TTCN-3
" Maintainer:   Stefan Karlsson <stefan.74@comhem.se>
" Last Change:  22 July 2004

if exists("b:did_indent")
    finish
endif
let b:did_indent = 1

" Basic strategy for calculating the indent:
"
" 1. Use cindent as far as possible
" 2. Correct the indent for those parts where cindent fails


setlocal indentexpr=Get_ttcn_indent(v:lnum)

setlocal indentkeys=0{,0},0),!^F,o,O,e
setlocal cinwords=
setlocal cinoptions=(1s

setlocal comments=sO:*\ -,mO:*\ \ ,exO:*/,s1:/*,mb:*,ex:*/,://


if exists("*Get_ttcn_indent")
    finish
endif


 " Returns the number of the closest previous line that contains code (i.e. it
 " skips blank lines and pure comment lines)
 function Get_previous_code_line(lnum)
     let i = a:lnum - 1
     while i > 0
         let i = prevnonblank(i)
         if getline(i) =~ '\*/\s*$'
             while getline(i) !~ '/\*' && i > 1
                 let i = i - 1
             endwhile
             if getline(i) =~ '^\s*/\*'
                 let i = i - 1
             else
                 break
             endif
         elseif getline(i) =~ '^\s*//'
             let i = i - 1
         else
             break
         endif
     endwhile
     return i
 endfunction

 " Returns true if the given line contains code
 function Is_code_line(lnum)
     return Get_previous_code_line(a:lnum + 1) == a:lnum
 endfunction

" Returns the value of a given component of the 'cindent' option
function Parse_cindent(ch)
    let pat = a:ch . '[0-9]\+s\?'
    let str = matchstr(&cinoptions, pat)
    if str == ""
        let n = &sw
    else
        let n = matchstr(str, '[0-9]\+')
        if str =~# 's'
            let n = n * &sw
        endif
    endif
    return n
endfunction

function Get_ttcn_indent(lnum)
    let m1 = Get_previous_code_line(a:lnum)
    let m2 = Get_previous_code_line(m1)

    let prevl1 = getline(m1)
    let prevl2 = getline(m2)

    let thisl = getline(a:lnum)

    " TODO: count the number of opening and closing braces and indent the diff on the next line

    if prevl1 =~ '\({\|(\)$'
        let ind = indent(m1) + &sw
    elseif thisl =~ '^\s*\(}\|)\)\(;\|,\)\?$'
        let ind = indent(m1) - &sw
    else
        let ind = indent(m1)
    endif

    return ind
endfunction
