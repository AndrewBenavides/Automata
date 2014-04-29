#Include .\lib\Excel\BaseJobLog.ahk

class DiscoveryJobLog extends BaseJobLog {
	HeaderRow := 6
	
	GetEntry(row) {
		entry := new DiscoveryJobLogEntry(this, row)
		return entry
	}
	
	GetProperties() {
		this.Properties.CreateCustodians := this.GetProperty("Create Custodians")
	}
}

class DiscoveryJobLogEntry extends BaseLogEntry {
	GetProperties() {
		this.Path := this.GetProperty("Path")
		this.Description := this.GetProperty("Description")
	}
}
