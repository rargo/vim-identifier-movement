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
let b:IMovementExcludeKeyword .= "auto break case char const continue default do double else enum extern float for goto if inline int long register return short signed sizeof static struct switch typedef union unsigned void volatile while "
let b:IMovementExcludeKeyword .= "asm export private throw bool false protected true catch friend public try class mutable reinterpret_cast typeid const_cast namespace static_cast typename delete new template using dynamic_cast operator this virtual explicit wchar_t "
let b:IMovementExcludeKeyword .= "uchar ushort uint ulong u32 u16 u8 uint32 uint16 uint8 int32 int16 int8 "
let b:IMovementExcludeKeyword .= "include define ifdef ifndef endif defined "
