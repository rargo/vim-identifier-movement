" Only do this when not done yet for this buffer
if exists("b:IMovement_did_ftplugin")
  finish
endif

" Don't load another plugin for this buffer
let b:IMovement_did_ftplugin = 1

"basic language indentifier pattern
let b:IMovementPatternBasic = '\w\+'
"like comment,string, exclude them
let b:IMovementPatternNotCheck = '"[^"]*" /\*.*\*/ //.* '
let b:IMovementPatternNotCheck .= "'[^']' "
"language keyword, exclude them
let b:IMovementExcludeKeyword = "\\d.* "
let b:IMovementExcludeKeyword .= "auto _Bool break case char _Complex const continue default restrict do double else enum extern float for goto if _Imaginary inline int long register return short signed sizeof static struct switch typedef union unsigned void volatile while "
let b:IMovementExcludeKeyword .= "asm __asm "
let b:IMovementExcludeKeyword .= "uchar ushort uint ulong u32 u16 u8 uint32 uint16 uint8 int32 int16 int8 "
let b:IMovementExcludeKeyword .= "include define ifdef ifndef endif defined "
