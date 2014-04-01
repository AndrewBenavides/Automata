; Includes for RemoteTreeView
#Include C:\Temp\TaglistJobCreator\Const_TreeView.ahk
#Include C:\Temp\TaglistJobCreator\Const_Process.ahk
#Include C:\Temp\TaglistJobCreator\Const_Memory.ahk
#Include C:\Temp\TaglistJobCreator\RemoteTreeViewClass.ahk

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Recommended for catching common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

DetectHiddenText On
DetectHiddenWindows On
SetTitleMatchMode 2
SetTitleMatchMode Slow
SetKeyDelay 75, 75

global xl := ComObjActive("Excel.Application")
global ecaptureHwnd := WinExist("eCapture Controller")
global eCapture := "ahk_id " . ecaptureHwnd
global tv := "WindowsForms10.SysTreeView32.app.0.11ecf051"

GetClients() {
	ControlGet TVId, Hwnd, , % tv, % ecapture
	tree := new RemoteTreeView(TVId)
	item := tree.GetRoot()
	clients := Object()
	while item <> 0 {
		client := Object()
		client.Name := tree.GetText(item)
		client.Item := item
		clients[client.Name] := client
		
		item := tree.GetNext(item)
	}
	
}

^+t::
	GetClients()
