#Include %A_ScriptDir%
#Include .\lib\ProcessTaglistJobCreator.ahk

ProcessLog() {
	creator := new ProcessTaglistJobCreator()
}

^+t::
	ProcessLog()
