﻿; Includes for RemoteTreeView
#Include .\lib\RemoteTreeView\Const_TreeView.ahk
#Include .\lib\RemoteTreeView\Const_Process.ahk
#Include .\lib\RemoteTreeView\Const_Memory.ahk
#Include .\lib\RemoteTreeView\RemoteTreeViewClass.ahk

;Includes from lib
#Include .\lib\eCapture\Controller\NewProcessJobWindow.ahk

class BaseClass {
	__New(tree, item) {
		this.Tree := tree
		this.Item := item
		this.NodeName := tree.GetText(item)
		this.Name := this.ParseName(this.NodeName)
		this.Construct()
	}

	__Delete() {
		DllCall("GlobalFree", "ptr", this.ptr)
	}
	
	IsValid() {
		valid := true
		if (this.NodeName = "Export Jobs") {
			valid := false
		}
		if (this.NodeName = "Dummy") {
			valid := false
		}
		return valid
	}
	
	GetChildren(typeName) {
		children := {}
		
		item := this.Tree.GetChild(this.Item)
		while item <> 0 {
			if (typeName = "Client") {
				child := new Client(this.Tree, item)
			}
			if (typeName = "Project") {
				child := new Project(this.Tree, item)
			}
			if (typeName = "Custodian") {
				child := new Custodian(this.Tree, item)
			}
			if (typeName = "JobFolder") {
				child := new JobFolder(this.Tree, item)
			}
			if (typeName = "Job") {
				child := new Job(this.Tree, item)
			}
			if child.IsValid() {
				children[child.Name] := child
			}
			item := this.Tree.GetNext(item)
		}
		return children
	}
	
	ParseName(fullName) {
		if InStr(fullName, ": ") {
			StringSplit, parts, fullName, :
			name := SubStr(parts2, 2)
		} else {
			name := fullName
		}
		return name
	}

	Select() {
		tries := 0
		success := false
		while (!success and tries < 10) {
			success := this.Tree.SetSelection(this.Item)
			tries := tries + 1
		}
	}
}

class Controller extends BaseClass {
	__New() {
		ControlGet TVId, Hwnd, , % tv, % ecapture
		this.Tree := new RemoteTreeView(TVId)
		this.Clients := this.GetChildren("Client")
	}
	
	IsValid() {
		return true
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
		nodes := this.GetChildren("JobFolder")
		this.DiscoveryJobNode := nodes["Discovery Jobs"]
		this.DataExtractJobNode := nodes["Data Extract Jobs"]
		this.ProcessingJobNode := nodes["Processing Jobs"]
		this.DiscoveryJobs := this.DiscoveryJobNode.Jobs
		this.DataExtractJobs := this.DataExtractJobNode.Jobs
		this.ProcessingJobs := this.ProcessingJobNode.Jobs
	}
	
	NewProcessingJobTaglist(options) {
		this.ProcessingJobNode.Select()
		WinActivate, % eCapture
		ControlFocus, % tv, % eCapture
		SendInput {AppsKey}
		SendInput {Up}
		SendInput {Enter}
		WinWait, % "Processing Job", % "Task Table", 10
		handle := "ahk_id" . WinExist("Processing Job")
		processJobWdw := new NewProcessJobWindow(handle, "DataExtractImport")
		
		processJobWdw.Name.Set(options.Name)
		processJobWdw.ItemIdFilePath.Set(options.FilePath)
		processJobWdw.SelectChildren.Set(options.SelectChildren)
		processJobWdw.ChildItemHandling[options.ChildItemHandling].Set()
		Sleep 10
		processJobWdw.OkButton.Click()
	}
}

class JobFolder extends BaseClass {
	Construct() {
		this.Jobs := this.GetChildren("Job")
	}
}

class Job extends BaseClass {
	Construct() {
		
	}
}