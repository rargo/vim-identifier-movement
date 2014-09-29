change log:
	2013.9.14: 
		1. Add lua support
		2. Modify default key maps to <c-l>,<c-h>
		3. Fix multibyte problem
	2014.07.10:
		1. add java support

vim plugin, one way to improve move using "w W b B",
smartly move between language indentifier, skip language keywords,comment,strings

default has no key mapping, please add keymap to your .vimrc, for example:
	nnoremap <silent> <c-l> :call JumpToNextIndentifier()<cr>
	nnoremap <silent> <c-h> :call JumpToPrevIndentifier()<cr>

current surpport language:
	c, c++, vim, python, lua, java

rargo.m@gmail.com
Distributed under the same terms as Vim itself.
