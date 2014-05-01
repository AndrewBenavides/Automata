#Include %A_ScriptDir%
#Include .\lib\DiscoveryJobCreator.ahk

ProcessLog() {
	creator := new DiscoveryJobCreator()
}

^+t::
	ProcessLog()
