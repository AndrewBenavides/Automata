#Include .\lib\ex\RemoteTreeView\RemoteTreeViewClass.ahk
#Include .\lib\eCapture\Controller\NewProcessJobWindow.ahk
#Include .\lib\BasicControls\Controls.ahk

class ClientManagementTreeView extends Control {
	Extend() {
		this.Controller := new ClientManagementTreeView.Controller(this.WindowId, this.ControlId)
	}
	
	__Get(key) {
		return this.Controller.Clients[key]
	}

	class LazyNode {
		__New(tree, item, typeName) {
			this.Items := []
			this.IsLoaded := false
			this.Tree := tree
			this.Item := item
			this.TypeName := typeName
		}
		
		__Get(key) {
			if !this.IsLoaded
				this.Load()
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
			if !this.IsLoaded 
				this.Load()
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
					child := new ClientManagementTreeView.Client(this.Tree, item)
				}
				if (this.TypeName = "Project") {
					child := new ClientManagementTreeView.Project(this.Tree, item)
				}
				if (this.TypeName = "Custodian") {
					child := new ClientManagementTreeView.Custodian(this.Tree, item)
				}
				if (this.TypeName = "JobFolder") {
					child := new ClientManagementTreeView.JobFolder(this.Tree, item)
				}
				if (this.TypeName = "Job") {
					child := new ClientManagementTreeView.Job(this.Tree, item)
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

	class TreeItem {
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
			children := new ClientManagementTreeView.LazyNode(this.Tree, this.Item, typeName)
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
			selected := this.Tree.GetText(this.Tree.GetSelection())
			target := this.Tree.GetText(this.Item)
			while (selected <> target && tries < 10) {
				if this.Tree.SetSelection(this.Item) {
					selected := this.Tree.GetText(this.Tree.GetSelection())
				}
				Sleep (1 + (tries * 100))
				tries += 1
			}
		}
	}

	class Controller extends ClientManagementTreeView.TreeItem {
		__New(windowId, controlId) {
			handle := SubStr(controlId, 8)
			this.Tree := new RemoteTreeView(handle)
			this.Tree.ControlHandle := handle
			this.Tree.ControlId := controlId
			this.Tree.WindowId := windowId
			this.Clients := this.GetChildren("Client")
		}
		
		IsValid() {
			return true
		}
	}

	class Client extends ClientManagementTreeView.TreeItem {
		Construct() {
			this.Projects := this.GetChildren("Project")
		}	
	}

	class Project extends ClientManagementTreeView.TreeItem {
		Construct() {
			if this.IsValid() {
				this.Custodians := this.GetChildren("Custodian")
			}
		}
	}

	class Custodian extends ClientManagementTreeView.TreeItem {
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
				WinActivate, % this.Tree.WindowId
				ControlFocus, , % this.Tree.ControlId
				SendInput, {Escape}{Escape}{AppsKey}{AppsKey}
				Sleep (1 + (tries * 100))
				SendInput, {Down}{Enter}
				tries += 1
				Sleep (1 + (tries * 100))
				wdw := new NewProcessJobWindow(2)
			}
			return wdw
		}
	}

	class JobFolder extends ClientManagementTreeView.TreeItem {
		Construct() {
			this.Jobs := this.GetChildren("Job")
		}
	}

	class Job extends ClientManagementTreeView.TreeItem {
	}
}