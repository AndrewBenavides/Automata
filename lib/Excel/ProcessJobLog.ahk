#Include .\lib\Excel\BaseJobLog.ahk

class ProcessJobLog extends BaseJobLog {
	HeaderRow := 6
	
	GetEntry(row) {
		entry := new ProcessJogLogEntry(this, row)
		return entry
	}
	
	GetProperties() {
		this.Properties.JobType := this.GetProperty("Job Type")
	}
}

class ProcessJogLogEntry extends BaseLogEntry {
	GetProperties() {
		this.DiscoveryJobID := floor(this.GetProperty("DiscoveryJobID"))
	}
}
