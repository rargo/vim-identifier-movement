
nnoremap <C-n> :call JumpToNextIndentifier()<cr>
nnoremap <C-p> :call JumpToPrevIndentifier()<cr>

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
		let searchPos += len(str)
	endif
	while 9
		if searchLine > line('$')
			return
		endif

		let lineStr = ReplacePattern(getline(searchLine),' ', patternNotCheck)
		"echo "line:" . searchLine . " str:" . lineStr

		while 9
			let matchPos  = match(lineStr,b:IMovementPatternBasic,searchPos)
			"echo "matchPos:" . matchPos
			if matchPos == -1
				"echo "line search end"
				break
			endif
			let matchStr = matchstr(lineStr,b:IMovementPatternBasic,matchPos)
			"echo "matchStr:" . matchStr
			if matchStr == ""
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
				"XXX should consider visualedit col findpos[3]
				let newpos = [0, searchLine, matchPos + 1 , 0] 
				"echo "newpos:" . string(newpos)
				return newpos
			endif

			let searchPos = matchPos + len(matchStr)
			"echo "searchPos:" . searchPos
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
				""echo "pattern:" . pattern
				let str = matchstr(matchStr, pattern, 0)
				""echo "str:" . str
				if str != "" && len(str) == len(matchStr)
					"echo "matchExclude = 1"
					let matchExclude = 1
					break
				endif
			endfor

			if matchExclude == 0
				let matchPosSave = matchPos
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

	while 9
		let matchPos = 99999999
		let patternWhich = -1
		let i = 0
		let startPos = 0
		"echo "startPos:" . startPos
		"find out which pattern if the first match
		for pattern in a:patternList
			""echo "pattern:" . pattern
			let pos  = match(lineStr,pattern,startPos)
			if pos == -1
				let i = i + 1
				continue
			endif
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

		"make a new replace str,replace the pattern str
		let pattern = a:patternList[patternWhich]
		"echo "a:patternList[patternWhich]:" . a:patternList[patternWhich]

		"echo "patternWhich:" . patternWhich
		"echo "pattern:" . pattern
		"echo "matchPos:" . matchPos
		"echo "lineStr:" . lineStr
		let str = matchstr(lineStr, pattern, matchPos)
		"echo "str:" . str
		let matchPosEnd = matchPos+ len(str) - 1

		"echo "patternNotCheck str:" . str
		let replaceCharList = [a:replaceChar,]
		"echo "replaceCharList:" . string(replaceCharList)
		let replaceList = repeat(replaceCharList,len(str))

		"echo "replaceList:" . string(replaceList)
		"echo "new space replaceList:" . string(replaceList)
		let lineStrList = split(lineStr,'\zs')
		let lineStrList[matchPos : matchPosEnd] = replaceList[:]
		"echo "lineStrList:" . string(lineStrList)
		"the new string
		let lineStr = join(lineStrList,"")
		"echo "lineStr:" . lineStr

		"let startPos = matchPos + len(str)
	endwhile
	""echo lineStr
	return lineStr
endfunc
