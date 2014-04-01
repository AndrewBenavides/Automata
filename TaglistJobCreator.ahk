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
	clients := {}
	
	ControlGet TVId, Hwnd, , % tv, % ecapture
	tree := new RemoteTreeView(TVId)
	item := tree.GetRoot()
	while item <> 0 {
		client := new Client(tree, item)
		clients[client.Name] := client
		
		item := tree.GetNext(item)
	}
	return clients
}

class BaseClass {
	__Delete() {
		DllCall("GlobalFree", "ptr", this.ptr)
	}
}

class Client extends BaseClass {
	__New(tree, item) {
		this.Tree := tree
		this.Name := tree.GetText(item)
		this.Item := item
		this.Projects := this.GetProjects()
	}
	
	GetProjects() {
		projects := {}

		item := this.Tree.GetChild(this.Item)
		while item <> 0 {
			project := new Project(this.Tree, item)
			if (project.IsValid() = true) {
				projects[project.Name] := project
			}
			
			item := this.Tree.GetNext(item)
		}
		return projects
	}
}

class Project extends BaseClass {
	__New(tree, item) {
		this.Tree := tree
		this.Name := tree.GetText(item)
		this.Item := item
		if this.IsValid() {
			this.Custodians := this.GetCustodians()
		}
	}
	
	IsValid() {
		valid := true
		if (this.Name = "Export Jobs") {
			valid := false
		}
		if (this.Name = "Dummy") {
			valid := false
		}
		return valid
	}
	
	GetCustodians() {
		custodians := {}
		
		item := this.Tree.GetChild(this.Item)
		while item <> 0 {
			custodian := new Custodian(this.Tree, item)
			if custodian.IsValid() {
				MsgBox % custodian.Name
			}
			
			item := this.Tree.GetNext(item)
		}
	}
}

class Custodian extends BaseClass {
	__New(tree, item) {
		this.Tree := tree
		this.Name := tree.GetText(item)
		this.Item := item
	}
	
	IsValid() {
		valid := true
		if (this.Name = "Dummy") {
			valid := false
		}
		return valid
	}
}

^+t::
	GetClients()
