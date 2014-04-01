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
	__New(tree, item) {
		this.Tree := tree
		this.Item := item
		this.Name := tree.GetText(item)
		this.Construct()
	}

	__Delete() {
		DllCall("GlobalFree", "ptr", this.ptr)
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
	
	GetChildren(typeName) {
		children := {}
		
		item := this.Tree.GetChild(this.Item)
		while item <> 0 {
			if (typeName = "Project") {
				child := new Project(this.Tree, item)
			}
			if (typeName = "Custodian") {
				child := new Custodian(this.Tree, item)
			}
			if child.IsValid() {
				children[child.Name] := child
			}
			item := this.Tree.GetNext(item)
		}
		return children
	}
}

class Client extends BaseClass {
	Construct() {
		this.Projects := this.GetChildren("Project")
	}	
}

class Project extends BaseClass {
	Construct() {
		if this.IsValid() {
			this.Custodians := this.GetChildren("Custodian")
		}
	}
}

class Custodian extends BaseClass {
	Construct() {
	
	}
}

^+t::
	GetClients()
