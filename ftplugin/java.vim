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
let b:IMovementExcludeKeyword .= "private protected public abstract class extends final implements interface native new static strictfp synchronized transient volatile break continue return do while if else for instanceof switch case default assert catch finally throw throws try import package boolean byte char double float int long short null true false super this void goto"
