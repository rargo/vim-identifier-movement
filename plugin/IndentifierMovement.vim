
nnoremap <silent> <C-l> :call JumpToNextIndentifier()<cr>
nnoremap <silent> <C-h> :call JumpToPrevIndentifier()<cr>

function! JumpToNextIndentifier()
	if !exists("b:IMovement_did_ftplugin")
		return
	endif

	let nextPos = GetNextIndentifierPos()
	if nextPos[0] != -1
		call setpos('.', nextPos)
	endif
endfunc

function! JumpToPrevIndentifier()
	if !exists("b:IMovement_did_ftplugin")
		return
	endif

	let prevPos = GetPrevIndentifierPos()
	if prevPos[0] != -1
		call setpos('.', prevPos)
	endif
endfunc

function! IsAComment(line, pos)
	let syn = synIDtrans(synID(a:line, a:pos, 1))
	return syn == hlID("Comment")
endfunction

"XXX should consider mutilbyte
function! GetNextIndentifierPos()
	let searchLine = line(".")
	let searchPos = col(".") - 1
	"echo "searchPos:" . searchPos
	let excludeKeyword = split(b:IMovementExcludeKeyword)
	let patternNotCheck = split(b:IMovementPatternNotCheck)
	"echo excludeKeyword
	"skip the keyword under cursor
	let pos = match(getline("."),b:IMovementPatternBasic,searchPos)
	if pos == searchPos
		let str = matchstr(getline("."),b:IMovementPatternBasic,searchPos)
		let searchPos += strchars(str)
	endif
	while 9
		if searchLine > line('$')
			return
		endif

		""echo "ReplacePattern in"
		let lineStr = ReplacePattern(getline(searchLine),' ', patternNotCheck)
		""echo "line:" . searchLine . " str:" . lineStr

		while 9
			let matchPos  = match(lineStr,b:IMovementPatternBasic,searchPos)
			""echo "matchPos:" . matchPos
			if matchPos == -1
				""echo "line search end"
				break
			endif
			let matchStr = matchstr(lineStr,b:IMovementPatternBasic,matchPos)
			""echo "matchStr:" . matchStr
			if matchStr == ""
				break
			endif

			let matchExclude = 0
			"check if matchStr is a exclude pattern
			for pattern in excludeKeyword
				"echo "pattern:" . pattern
				let str = matchstr(matchStr, pattern, 0)
				"echo "str:" . str
				if str != "" && strchars(str) == strchars(matchStr)
					""echo "patternNotCheck match, pattern:" . pattern . ",str:" . str
					let matchExclude = 1
					break
				endif
			endfor

			if matchExclude == 0
				let comment = IsAComment(searchLine,matchPos)
				"echo "comment:" . comment . "line:" . searchLine . "Pos:" . searchPos
				if comment == 0
					"XXX should consider visualedit col findpos[3]
					let newpos = [0, searchLine, matchPos + 1 , 0] 
					""echo "newpos:" . string(newpos)
					return newpos
				endif
			endif

			let searchPos = matchPos + strchars(matchStr)
			""echo "searchPos:" . searchPos
		endwhile

		let searchPos = 0
		let searchLine += 1
	endwhile

	let newpos = [-1, -1, -1, -1]
	return newpos
endfunc

function! GetPrevIndentifierPos()
	let searchLine = line(".")
	let searchPosStop = col(".") - 1
	"echo "searchPosStop:" . searchPosStop
	let excludeKeyword = split(b:IMovementExcludeKeyword)
	let patternNotCheck = split(b:IMovementPatternNotCheck)
	"echo excludeKeyword
	"skip the keyword under cursor
	while searchPosStop >= 0
		let pos = match(getline("."),b:IMovementPatternBasic,searchPosStop)
		if pos == searchPosStop
			let searchPosStop -= 1
			"echo "searchPosStop - 1:" . searchPosStop
		else
			break
		endif
	endwhile
	if searchPosStop < 0
		let searchLine -= 1
		let searchPosStop = len(getline(searchLine)) - 1
	endif
	"echo "searchPosStop:" . searchPosStop
	"echo "searchLine:" . searchLine
	while searchLine >= 1
		let lineStr = ReplacePattern(getline(searchLine),' ', patternNotCheck)
		"echo "line:" . searchLine . " str:" . lineStr

		let matchPosSave = -1
		let searchPosStart = 0
		while 9
			let matchPos  = match(lineStr,b:IMovementPatternBasic,searchPosStart)
			"echo "matchPos:" . matchPos
			if matchPos == -1
				"echo "line search end"
				break
			endif
			let matchStr = matchstr(lineStr,b:IMovementPatternBasic,matchPos)
			"echo "matchStr:" . matchStr
			if len(matchStr) + matchPos > (searchPosStop + 1)
				"echo "exceed matchStop"
				break
			endif

			let matchExclude = 0
			"check if matchStr is a exclude pattern
			for pattern in excludeKeyword
				"echo "pattern:" . pattern
				let str = matchstr(matchStr, pattern, 0)
				"echo "str:" . str
				if str != "" && len(str) == len(matchStr)
					"echo "matchExclude = 1"
					let matchExclude = 1
					break
				endif
			endfor

			if matchExclude == 0
				let comment = IsAComment(searchLine,matchPos)
				"echo "comment:" . comment . "line:" . searchLine . "Pos:" . searchPos
				if comment == 0
					let matchPosSave = matchPos
				endif
			endif

			let searchPosStart = matchPos + len(matchStr)
			"echo "searchPosStart:" . searchPosStart
		endwhile

		if matchPosSave != -1
			"XXX should consider visualedit col findpos[3]
			let newpos = [0, searchLine, matchPosSave + 1 , 0] 
			"echo "setpos:" . string(newpos)
			call setpos('.',newpos)
			return
		endif

		let searchLine -= 1
		let searchPosStop = len(getline(searchLine)) - 1
	endwhile
endfunc

function! ReplacePattern(lineStr, replaceChar, patternList)
	let lineStr = a:lineStr
	let patternCount = len(a:patternList)
	"echo "patternCount:" . patternCount

	"note, match startpos use byte index
	"if it's a mutilbyte string, like "我"(in utf8,it occupy 3 bytes)
	"it will be replace as 5 space
	while 9
		let matchPos = 99999999
		let patternWhich = -1
		let i = 0
		let startPos = 0

		"echo "startPos:" . startPos
		"find out which pattern is the first match
		for pattern in a:patternList
			let pos  = match(lineStr,pattern,startPos)
			if pos == -1
				let i = i + 1
				"echo "pattern:" . pattern . " not found"
				continue
			endif

			"echo "pattern:" . pattern " found"
			if pos <  matchPos
				let patternWhich = i
				"echo "patternWhich:" . patternWhich
				let matchPos = pos
				"echo "matchPos:" . matchPos
			endif
			let i = i + 1
			"echo "i:" . i
		endfor

		if patternWhich == -1
			"echo "patternWhich -1,break"
			break
		endif

		""echo "====>replace str "
		"make a new replace str,replace the pattern str
		let pattern = a:patternList[patternWhich]
		"echo "a:patternList[patternWhich]:" . a:patternList[patternWhich]
		let matchStr = matchstr(lineStr,pattern,matchPos)
		let matchStrByteLen = strlen(matchStr)
		let matchStrCharLen = strchars(matchStr)
		""echo "matchPos:" . matchPos . ",matchStr:" . matchStr . ",char length:" .  matchStrCharLen . "byte length:" . matchStrByteLen

		let replaceCharList = [a:replaceChar,]
		"echo "replaceCharList:" . string(replaceCharList)
		let replaceList = repeat(replaceCharList,matchStrByteLen)
		"echo "replace Str List:" . string(replaceList)

		"echo "replaceList:" . string(replaceList)
		"echo "new space replaceList:" . string(replaceList)
		let lineStrList = split(lineStr,'\zs')
		"echo "lineStrList old:" . string(lineStrList)
		let lineStrListNew = []
		if matchPos != 0
			call extend(lineStrListNew, lineStrList[0 : matchPos - 1])
		endif
		call extend(lineStrListNew, replaceList[:])
		call extend(lineStrListNew, lineStrList[matchPos + matchStrCharLen : ])
		""echo "lineStrList new:" . string(lineStrList)
		let lineStr = join(lineStrListNew,"")
		""echo "new replace str:" . lineStr
		""echo "<====replace str "

		"let startPos = matchPos + len(str)
	endwhile
	"echo lineStr
	return lineStr
endfunc
