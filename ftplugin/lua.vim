" Only do this when not done yet for this buffer
if exists("b:IMovement_did_ftplugin")
  finish
endif

" Don't load another plugin for this buffer
let b:IMovement_did_ftplugin = 1

"basic language indentifier pattern
let b:IMovementPatternBasic = '\w\+'
"like comment,string, exclude them
let b:IMovementPatternNotCheck = "\"[^\"]*\" '[^']*' --.*$ "
"language keyword, exclude them
let b:IMovementExcludeKeyword = '\d.* '
let b:IMovementExcludeKeyword .= "and break do else elseif end false for function if in local nil not or repeat return then true until while"
