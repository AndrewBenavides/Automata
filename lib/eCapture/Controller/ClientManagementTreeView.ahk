﻿#Include .\lib\BasicControls\Controls.ahk
#Include .\lib\eCapture\Controller\NewCustodianWindow.ahk
#Include .\lib\eCapture\Controller\NewDiscoveryJobWindow.ahk
#Include .\lib\eCapture\Controller\NewProcessJobWindow.ahk

class ClientManagementTreeView extends TreeView {
	AddChild(item) {
		child := this.GetNewChild(item)
		child.NodeName := child.GetText()
		child.Name := this.ParseName(child.NodeName)
		child.IsValid := this.IsValidNode(child.NodeName)
		if child.IsValid {
			this[this.ChildrenName][child.Name] := child
		}
	}
	
	GetChildrenName() {
		return "Clients"
	}
	
	GetNewChild(item) {
		child := new ClientManagementTreeView.Client(this, item)
		return child
	}

	IsValidNode(name) {
		valid := true
		valid := (name <> "Export Jobs") ? valid : false
		valid := (name <> "Dummy") ? valid : false
		return valid
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
	
	Refresh() {
		this.Unload()
		this.Load()
	}
		
	class Client extends ClientManagementTreeView {		
		GetNewChild(item) {
			child := new ClientManagementTreeView.Project(this, item)
			return child
		}
		
		GetChildrenName() {
			return "Projects"
		}
	}
	
	class Project extends ClientManagementTreeView {
		GetNewChild(item) {
			child := new ClientManagementTreeView.Custodian(this, item)
			return child
		}

		GetChildrenName() {
			return "Custodians"
		}
		
		NewCustodian() {
			window := {}
			window.Exists := false
			tries := 0
			while (!window.Exists && tries < 5) {
				WinActivate, % this.WindowId
				ControlFocus, , % this.ControlId
				this.Select()
				SendInput, {Escape}{Escape}{AppsKey}{AppsKey}
				Sleep (1 + (tries * 100))
				SendInput, {Down}{Enter}
				tries += 1
				Sleep (1 + (tries * 100))
				window := new NewCustodianWindow(2)
			}
			return window
		}
	}
	
	class Custodian extends ClientManagementTreeView {
		GetNewChild(item) {
			child := new ClientManagementTreeView.Folder(this, item)
			return child
		}

		GetChildrenName() {
			return "Folders"
		}
		
		NewDataExtractJob() {
			wdw := this.NewJob("Data Extract Jobs")
			return wdw
		}
		
		NewDiscoveryJob() {
			wdw := this.NewJob("Discovery Jobs")
			return wdw
		}
		
		NewProcessingJob() {
			wdw := this.NewJob("Processing Jobs")
			return wdw
		}
		
		NewJob(jobType) {
			wdw := {}
			wdw.Exists := False
			tries := 0
			while (!wdw.Exists && tries < 5) {
				WinActivate, % this.WindowId
				ControlFocus, , % this.ControlId
				this[this.ChildrenName][jobType].Select()
				SendInput, {Escape}{Escape}{AppsKey}{AppsKey}
				Sleep (1 + (tries * 100))
				SendInput, {Down}{Enter}
				tries += 1
				Sleep (1 + (tries * 100))
				if (jobType = "Discovery Jobs") {
					wdw := new NewDiscoveryJobWindow(2)
				} else {
					wdw := new NewProcessJobWindow(2)
				}
			}
			return wdw
		}
	}
	
	class Folder extends ClientManagementTreeView {
		GetNewChild(item) {
			child := new ClientManagementTreeView.Job(this, item)
			return child
		}

		GetChildrenName() {
			return "Jobs"
		}
	}
	
	class Job extends ClientManagementTreeView {
		GetNewChild(item) {
			child := new ClientManagementTreeView.Job(this, item)
			return child
		}

		GetChildrenName() {
			return "Children"
		}
	}
}
