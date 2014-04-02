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
global cell_SelectChildren := "$B$4"
global cell_ChildItemHandling := "$B$5"

ConvertExcelBool(value) {
	if (value = -1) {
		return true
	}
	return false
}

class JobLog {
	__New() {
		this.Xl := ComObjActive("Excel.Application")
		this.Worksheet := xl.ActiveSheet
		this.Client := this.Worksheet.Range(cell_Client).Value2
		this.Project := this.Worksheet.Range(cell_Project).Value2
		this.TaglistDir := this.Worksheet.Range(cell_TaglistDir).Value2
		this.SelectChildren := ConvertExcelBool(this.Worksheet.Range(cell_SelectChildren).Value2)
		this.ChildItemHandling := this.Worksheet.Range(cell_ChildItemHandling).Value2
	}
	
	GetEntries() {
		entries := {}
		rowOffset := 7
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
		;processJobWdw.OkButton.Click()
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

class NewProcessJobWindow {
	__New(windowId, processJobType) {
		this.WindowId := windowId
		if (processJobType = "DataExtractImport") {
			this.SwitchToDataExtractImport()
		}
	}
	
	SwitchToDataExtractImport() {
		this.Type := new RadioButtons()
		this.Type["DataExtractImport"] := new RadioButton(this.WindowId, "WindowsForms10.BUTTON.app.0.11ecf052")
		this.Type["DataExtractImport"].Set()
		this.Type["Standard"] := new RadioButton(this.WindowId, "WindowsForms10.BUTTON.app.0.11ecf0512")
		this.Type["DataExtractImport"].ControlClass := "WindowsForms10.BUTTON.app.0.11ecf0513"
		this.Name := new TextBox(this.WindowId, "WindowsForms10.EDIT.app.0.11ecf053")
		this.Description := new TextBox(this.WindowId, "WindowsForms10.EDIT.app.0.11ecf052")
		this.ItemIdFilePath := new TextBox(this.WindowId, "WindowsForms10.EDIT.app.0.11ecf051")
		this.SelectChildren := new CheckBox(this.WindowId, "WindowsForms10.BUTTON.app.0.11ecf0511")
		this.ChildItemHandling := new RadioButtons()
		this.ChildItemHandling["Item"] := new RadioButton(this.WindowId, "WindowsForms10.BUTTON.app.0.11ecf058")
		this.ChildItemHandling["ItemParent"] := new RadioButton(this.WindowId, "WindowsForms10.BUTTON.app.0.11ecf059")
		this.ChildItemHandling["ItemParentChild"] := new RadioButton(this.WindowId, "WindowsForms10.BUTTON.app.0.11ecf0510")
		this.ShowJobOptions := new CheckBox(this.WindowId, "WindowsForms10.BUTTON.app.0.11ecf0514")
		this.OkButton := new Button(this.WindowId, "WindowsForms10.BUTTON.app.0.11ecf0518")
	}
}

class Control {
	__New(windowId, controlClass) {
		this.WindowId := windowId
		this.ControlClass := controlClass
	}
}

class CheckableControl extends Control {
	Get() {
		return this.IsChecked()
	}
	
	IsChecked() {
		ControlGet, state, Checked, , % this.ControlClass, % this.WindowId
		return state
	}
}

class Button extends Control {
	Click() {
		ControlClick, % this.ControlClass, % this.WindowId
	}
}

class CheckBox extends CheckableControl {
	Set(value) {
		if (value) { 
			Control, Check, , % this.ControlClass, % this.WindowId
		} else {
			Control, Uncheck, , % this.ControlClass, % this.WindowId
		}
	}
}

class RadioButtons {
	Get() {
		for key, value in this {
			if (value.IsChecked()) {
				return key
			}
		}
	}
	
	Set(value) {
		this[value].Set()
	}
}

class RadioButton extends CheckableControl {
	Set() {
		Control, Check, , % this.ControlClass, % this.WindowId
	}
}

class TextBox extends Control {
	Get() {
		tries := 0
		value := ""
		while (tries < 5 and value = "") {
			if (tries > 0 ) {
				Sleep 50
			}
			ControlGetText, value, % this.ControlClass, % this.WindowId
			tries := tries + 1
		}
		return value
	}
	
	Set(value) {
		tries := 0
		setValue := ""
		while (tries < 5 and setValue <> value) {
			if (tries > 0) {
				Sleep 100
			}
			ControlSetText, % this.ControlClass, % value, % this.WindowId
			setValue := this.Get()
			tries := tries + 1
		}
		if (setValue <> value) {
			throw "Error: value was not able to be set."
		}
	}
}

class ProcessingJobTaglistOptions {
	__New(name, filePath, selectChildren, childItemHandling) {
		this.Name := name
		this.FilePath := filePath
		this.SelectChildren := selectChildren
		this.ChildItemHandling := childItemHandling
	}
}

^+t::
