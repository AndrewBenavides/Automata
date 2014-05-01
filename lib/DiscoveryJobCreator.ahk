#Include .\lib\BaseJobCreator.ahk
#Include .\lib\Excel\DiscoveryJobLog.ahk

class DiscoveryJobCreator extends BaseJobCreator {
	Log := new DiscoveryJobLog()
	
	CreateJob(custodian, entry) {
		if this.PathExists(entry.Path) {
			entry.JobType := "Discovery Jobs"
			window := this.GetNewJobWindow(custodian, entry)
			window.JobName.Set(entry.JobName)
			window.Description.Set(entry.Description)
			window.AddDirectory(entry.Path)
			window.CreateDtSearchIndex.Uncheck()
			window.ShowJobOptions.Uncheck()
			window.OkButton.Click()
			entry.StatusCell.SetAndColor("Discovery Job created.", xl_LightGreen)
		} else {
			entry.StatusCell.SetAndColor("Path does not exist.", xl_Orange)
		}
	}
	
	PathExists(path) {
		attrib := FileExist(path)
		exists := (InStr(attrib, "D")) ? true : false
		return exists
	}
}
