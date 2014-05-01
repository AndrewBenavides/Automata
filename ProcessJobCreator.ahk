#Include %A_ScriptDir%
#Include .\lib\ProcessJobCreator.ahk

ProcessLog() {
	creator := new ProcessJobCreator()
}

^+t::
	ProcessLog()
