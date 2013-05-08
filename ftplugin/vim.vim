
" Only do this when not done yet for this buffer
if exists("b:did_ftplugin")
  finish
endif

" Don't load another plugin for this buffer
let b:did_ftplugin = 1

"basic language indentifier pattern
let b:IMovementPatternBasic = '\w\+'
"like comment,string,exclude them
let b:IMovementPatternNotCheck = '"[^"]*" "[^"]*$ '
let b:IMovementPatternNotCheck .= "'[^']*' "
"language keyword,exclude them"
let b:IMovementExcludeKeyword = "\\d.* for do while break continue if else return "
let b:IMovementExcludeKeyword .= "let endif endwhile endfunction endfunc endfor in call exec "
