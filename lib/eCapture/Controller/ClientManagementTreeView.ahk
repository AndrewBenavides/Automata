; Includes for RemoteTreeView
#Include .\lib\RemoteTreeView\Const_TreeView.ahk
#Include .\lib\RemoteTreeView\Const_Process.ahk
#Include .\lib\RemoteTreeView\Const_Memory.ahk
#Include .\lib\RemoteTreeView\RemoteTreeViewClass.ahk

;Includes from lib
#Include .\lib\eCapture\Controller\NewProcessJobWindow.ahk
#Include .\lib\eCapture\Controller\ProcessingJobOptionsWindow.ahk
#Include .\lib\eCapture\Controller\FlexProcessorOptionsWindow.ahk
#Include .\lib\eCapture\Controller\ImportFromFileWindow.ahk

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
	
	Exists(item) {
		if !this.IsLoaded {
			this.Load()
		}
		items := this.Items
		for key, value in items {
			if (key = item) {
				return true
			}
		}
		return false
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
	
	NewProcessingJobTaglist(options) {
		this.ProcessingJobNode.Select()
		WinActivate, % eCapture
		ControlFocus, % tv, % eCapture
		SendInput {AppsKey}
		SendInput {Up}
		SendInput {Enter}
		WinWait, % "Processing Job", % "Task Table", 10
		handle := "ahk_id " . WinExist("Processing Job")
		processJobWdw := new NewProcessJobWindow(handle, "DataExtractImport")
		
		processJobWdw.Name.Set(options.Name)
		processJobWdw.ItemIdFilePath.Set(options.FilePath)
		processJobWdw.SelectChildren.Set(options.SelectChildren)
		processJobWdw.ChildItemHandling[options.ChildItemHandling].Set()
		processJobWdw.OkButton.Click()

		countWdw := new ImportFromFileWindow()
		addedCount := countWdw.GetCount()
		
		WinWait, % "Options for Processing Job", % "General Options", 10
		handle := "ahk_id " . WinExist("Options for Processing Job")
		settingsWdw := new ProcessingJobOptionsWindow(handle)
		settingsWdw.TabControl.Set(4)
		settingsWdw.ManageFlexProcessorButton.Click()
		
		Sleep 250
		settingsWdw.OkButton.Click()
		return addedCount
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