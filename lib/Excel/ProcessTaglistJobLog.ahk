#Include .\lib\Excel\BaseJobLog.ahk

class ProcessTaglistJobLog extends BaseJobLog {
	HeaderRow := 8
	
	GetEntry(row) {
		entry := new ProcessTaglistJobLogEntry(this, row)
		return entry
	}
	
	GetProperties() {
		this.Client := this.GetProperty("Client")
		this.Project := this.GetProperty("Project")
		this.TaglistDirectory := this.GetProperty("Taglist Directory")
		this.SelectChildren := this.ConvertExcelBool(this.GetProperty("Select Children"))
		this.ChildItemHandling := this.GetProperty("Child Item Handling")
	}
}

class ProcessTaglistJobLogEntry extends BaseLogEntry {
	GetProperties() {
		this.TaglistName := this.JobName . ".txt"
		this.TaglistFullName := this.Log.TaglistDirectory . "\" . this.TaglistName
		
		this.TaglistCountCell := this.GetCell("Taglist Count")
		this.AddedCountCell := this.GetCell("Added Count")
		this.ParentCountCell := this.GetCell("Parent Items")
		this.ChildCountCell := this.GetCell("Child Items")
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
			
	TaglistExists() {
		FileGetSize, size, % this.TaglistFullName
		if (size > 0) {
			return true
		} else {
			return false
		}
	}
}
