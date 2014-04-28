#Include .\lib\Excel\Range.ahk

class BaseJobLog {
	__New() {
		this.Xl := ComObjActive("Excel.Application")
		this.Worksheet := this.Xl.ActiveSheet
		this.Header := this.GetHeader(this.HeaderRow . ":" . this.HeaderRow)
		this.PropertiesRange := this.GetRange("A1:B" . (this.HeaderRow - 2))
		this.Extend()
		this.GetProperties()
	}
	
	ConvertExcelBool(value) {
		if (value = -1) {
			return true
		}
		return false
	}
	
	GetEntry(row) {
		throw "This method must be overridden"
	}
	
	GetEntries() {
		entries := []
		rowCount := this.Worksheet.UsedRange.Rows.Count - this.HeaderRow
		
		loop % rowCount {
			row := A_Index + this.HeaderRow
			entry := this.GetEntry(row)
			
			if !entries.HasKey(entry.JobName) {
				if !entry.IsComplete() {
					entries[entry.JobName] := entry
				}
			} else {
				message := "JobName is already in list."
				entry.SetStatus(message, 46)
			}
		}
		return entries
	}
	
	GetProperty(name) {
		range := this.PropertiesRange.Find(name)
		if (range <> "") {
			row := range.GetRow()
			value := this.Worksheet.Range("B" . row).Value2
		} else {
			value = ""
		}
		return value
	}
	
	GetProperties() {
		throw "This method must be overridden"
	}
	
	GetHeader(address) {
		columns := new ColumnCollection(this.Worksheet, address)
		return columns
	}
	
	GetRange(address) {
		range := new Range(this.Worksheet, address)
		return range
	}
}

class BaseLogEntry {
	__New(jobLog, row) {
		this.Row := row
		this.Log := jobLog
		
		this.JobName := this.GetProperty("Job Name")
		this.CustodianOverride := this.GetProperty("Custodian Override")
		this.Custodian := this.ParseCustodian()
		this.StatusCell := this.GetCell("Status")
		
		this.GetProperties()
	}
	
	GetCell(name) {
		column := this.Log.Header.ColumnFor[name]
		cell := this.Log.Worksheet.Cells(this.Row, column)
		range := new Range(this.Log.Worksheet, cell.Address)
		return range
	}
	
	GetProperty(name) {
		value := this.GetCell(name).Get()
		return value
	}
	
	GetProperties() {
		throw "This method must be overridden"
	}
	
	IsComplete() {
		statusMessage := this.StatusCell.Get()
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
}
