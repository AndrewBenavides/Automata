global xl := ComObjActive("Excel.Application")
global ecaptureHwnd := WinExist("eCapture Controller")
global eCapture := "ahk_id " . ecaptureHwnd
global tv := "WindowsForms10.SysTreeView32.app.0.11ecf051"

global col_JobName := 1
global col_Status := 2
global col_TaglistCount := 3
global col_AddedCount := 4
global col_ParentCount := 5
global col_ChildCount := 6
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
		this.ParentCountCell := this.Worksheet.Cells(row, col_ParentCount)
		this.ChildCountCell := this.Worksheet.Cells(row, col_ChildCount)
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

class ProcessingJobTaglistOptions {
	__New(name, filePath, selectChildren, childItemHandling) {
		this.Name := name
		this.FilePath := filePath
		this.SelectChildren := selectChildren
		this.ChildItemHandling := childItemHandling
	}
}
