" Only do this when not done yet for this buffer
if exists("b:IMovement_did_ftplugin")
  finish
endif

" Don't load another plugin for this buffer
let b:IMovement_did_ftplugin = 1

"basic language indentifier pattern
let b:IMovementPatternBasic = '\w\+'
"like comment,string, exclude them
let b:IMovementPatternNotCheck = "\"[^\"]*\" '[^']*' #.*$ "
"language keyword, exclude them
let b:IMovementExcludeKeyword = "\\d.* "
let b:IMovementExcludeKeyword .= "False class finally is return None continue for lambda try True def from nonlocal while and del global not with as elif if or yield assert else import pass break except in raise "
