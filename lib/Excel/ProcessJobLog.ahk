global col_JobName := 1
global col_DiscoveryJobID := 2
global col_CustodianOverride := 3
global col_Status := 4
global cell_Client := "$B$2"
global cell_Project := "$B$3"
global cell_JobType := "$B$4"
global cell_TaskTable := "$B$5"

class ProcessJobLog {
	__New() {
		this.Xl := ComObjActive("Excel.Application")
		this.Worksheet := this.Xl.ActiveSheet
		this.Client := this.GetValue(cell_Client)
		this.Project := this.GetValue(cell_Project)
		this.JobType := this.GetValue(cell_JobType)
		this.TaskTable := this.GetValue(cell_TaskTable)
	}
	
	GetValue(cell) {
		value := this.Worksheet.Range(cell).Value2
		return value
	}
	
	GetEntries() {
		entries := {}
		rowOffset := 7
		rowCount := this.Worksheet.UsedRange.Rows.Count - rowOffset
		
		loop % rowCount {
			row := A_Index + rowOffset
			entry := new ProcessJogLogEntry(this, row)
			
			if !entry.IsComplete() {
				entries[entry.JobName] := entry
			}
		}
		return entries
	}
}

class ProcessJogLogEntry {
	__New(jobLog, row) {
		this.RowNumber := row
		this.JobLog := jobLog
		this.Worksheet := this.JobLog.Worksheet
		this.JobName := this.GetValue(col_JobName)
		this.DiscoveryJobID := Floor(this.GetValue(col_DiscoveryJobID))
		this.CustodianOverride := this.GetValue(col_CustodianOverride)
		this.Custodian := this.ParseCustodian()
		this.Client := this.JobLog.Client
		this.Project := this.JobLog.Project
		
		this.StatusCell := this.Worksheet.Cells(row, col_Status)
	}
	
	GetValue(col) {
		value := this.Worksheet.Cells(this.RowNumber, col).Value2
		return value
	}
	
	IsComplete() {
		statusMessage := this.StatusCell.Value2
		if (statusMessage <> "") {
			return true
		} else {
			return false
		}
	}
	
	ParseCustodian() {
		name := ""
		if (this.CustodianOverride = "") {
			jobName := this.JobName
			StringSplit, parts, jobName, _
			name := parts2
		} else {
			name := this.CustodianOverride
		}
		return name
	}
	
	SetStatus(message, colorIndex) {
		this.StatusCell.Value2 := message
		this.StatusCell.Interior.ColorIndex := colorIndex
	}
}
