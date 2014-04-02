#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Recommended for catching common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

; Includes for RemoteTreeView
#Include %A_ScriptDir%\Const_TreeView.ahk
#Include %A_ScriptDir%\Const_Process.ahk
#Include %A_ScriptDir%\Const_Memory.ahk
#Include %A_ScriptDir%\RemoteTreeViewClass.ahk


DetectHiddenText On
DetectHiddenWindows On
SetTitleMatchMode 2
SetTitleMatchMode Slow
SetKeyDelay 75, 75

global xl := ComObjActive("Excel.Application")
global ecaptureHwnd := WinExist("eCapture Controller")
global eCapture := "ahk_id " . ecaptureHwnd
global tv := "WindowsForms10.SysTreeView32.app.0.11ecf051"

global col_JobName := 1
global col_Status := 2
global col_TaglistCount := 3
global col_AddedCount := 4
global cell_Client := "$B$1"
global cell_Project := "$B$2"
global cell_TaglistDir := "$B$3"

class JobLog {
	__New() {
		this.Xl := ComObjActive("Excel.Application")
		this.Worksheet := xl.ActiveSheet
		this.TaglistDir := this.Worksheet.Range(cell_TaglistDir).Value2
	}
	
	GetEntries() {
		entries := {}
		rowOffset := 5
		rowCount := this.Worksheet.UsedRange.Rows.Count - rowOffset
		
		loop % rowCount {
			row := A_Index + rowOffset
			entry := new LogEntry(this, row)
			
			if !entry.IsComplete() {
				entries[entry.JobName] := entry
			}
		}
		return entries
	}
}

class LogEntry {
	__New(jobLog, row) {
		this.RowNumber := row
		this.JobLog := jobLog
		this.Worksheet := this.JobLog.Worksheet
		this.JobName := this.Worksheet.Cells(row, col_JobName).Value2
		this.Custodian := this.ParseCustodian(this.JobName)
		this.TaglistName := this.JobName . ".txt"
		this.TaglistFullName := this.JobLog.TaglistDir . "\" . this.TaglistName
		
		this.StatusCell := this.Worksheet.Cells(row, col_Status)
		this.TaglistCountCell := this.Worksheet.Cells(row, col_TaglistCount)
		this.AddedCountCell := this.Worksheet.Cells(row, col_AddedCount)
	}
	
	GetTaglistCount() {
		output := ""
		itemCount := 0
		if this.TaglistExists() {
			FileRead, contents, % this.TaglistFullName
			Loop, parse, contents, `n, `r 
			{
				if (A_LoopField <> "") {
					itemCount := itemCount + 1
				}
			}
			output := itemCount
		} else {
			output := "File does not exist."
		}
		return output
	}
	
	IsComplete() {
		statusMessage := this.StatusCell.Value2
		if (statusMessage <> "") {
			return true
		} else {
			return false
		}
	}
	
	ParseCustodian(jobName) {
		StringSplit, parts, jobName, _
		name := parts2
		return name
	}
	
	SetStatus(message, colorIndex) {
		this.StatusCell.Value2 := message
		this.StatusCell.Interior.ColorIndex := colorIndex
	}
	
	SetAddedCount(itemCount) {
		this.AddedCountCell.Value2 := itemCount
	}
	
	SetTaglistCount(itemCount) {
		this.TaglistCountCell.Value2 := itemCount
	}
	
	TaglistExists() {
		FileGetSize, size, % this.TaglistFullName
		if (size > 0) {
			return true
		} else {
			return false
		}
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

^+t::
