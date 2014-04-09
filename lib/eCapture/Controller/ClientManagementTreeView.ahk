global ecaptureHwnd := WinExist("eCapture Controller")
global eCapture := "ahk_id " . ecaptureHwnd
global tv := "WindowsForms10.SysTreeView32.app.0.11ecf051"


; Includes for RemoteTreeView
#Include .\lib\ex\RemoteTreeView\RemoteTreeViewClass.ahk

;Includes from lib
#Include .\lib\eCapture\Controller\NewProcessJobWindow.ahk
#Include .\lib\eCapture\Controller\ProcessingJobOptionsWindow.ahk
#Include .\lib\eCapture\Controller\FlexProcessorOptionsWindow.ahk
#Include .\lib\eCapture\Controller\ImportFromFileWindow.ahk
#Include .\lib\BasicControls\Controls.ahk

class LazilyLoadedTreeViewNode {
	__New(tree, item, typeName) {
		this.Items := []
		this.IsLoaded := false
		this.Tree := tree
		this.Item := item
		this.TypeName := typeName
	}
	
	__Get(key) {
		if !this.IsLoaded {
			this.Load()
		}
		if !this.Exists(key)
			throw "Key """ . key . """ does not exist in dictionary."
		return this.Items[key]
	}
	
	Collapse() {
		this.Tree.Expand(this.item, false)
		this.DestroyValues()
		this.IsLoaded := false
	}
	
	DestroyValues() {
		keys := {}
		for key, value in this.Items {
			keys.Add(key)
		}
		for key in keys {
			this.Items.Remove(key)
		}
	}
	
	Exists(key) {
		if !this.IsLoaded {
			this.Load()
		}
		exists := this.Items.HasKey(key)
		return exists
	}
	
	Expand() {
		this.Tree.Expand(this.item, true)
	}
	
	GetChildren() {
		item := this.Tree.GetChild(this.Item)
		while item <> 0 {
			if (this.TypeName = "Client") {
				child := new Client(this.Tree, item)
			}
			if (this.TypeName = "Project") {
				child := new Project(this.Tree, item)
			}
			if (this.TypeName = "Custodian") {
				child := new Custodian(this.Tree, item)
			}
			if (this.TypeName = "JobFolder") {
				child := new JobFolder(this.Tree, item)
			}
			if (this.TypeName = "Job") {
				child := new Job(this.Tree, item)
			}
			if child.IsValid() {
				this.Items[child.Name] := child
			}
			item := this.Tree.GetNext(item)
		}
	}
	
	Load() {
		this.Expand()
		this.GetChildren()
		this.IsLoaded := true
	}
}

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
		children := new LazilyLoadedTreeViewNode(this.Tree, this.Item, typeName)
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
	
	NewProcessingJob() {
		wdw := {}
		wdw.Exists := False
		tries := 0
		while (!wdw.Exists && tries < 5) {
			this.ProcessingJobNode.Select()
			WinActivate, % eCapture
			ControlFocus, % tv, % eCapture
			SendInput, {Escape}{Escape}{AppsKey}{AppsKey}
			Sleep (1 + (tries * 100))
			SendInput, {Up}{Enter}
			tries += 1
			Sleep (1 + (tries * 100))
			wdw := new NewProcessJobWindow()
		}
		return wdw
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