#Include .\lib\BaseJobCreator.ahk
#Include .\lib\Excel\ProcessJobLog.ahk

class ProcessJobCreator extends BaseJobCreator {
	Log := new ProcessJobLog()
	
	CreateJob(custodian, entry) {
		window := this.GetNewJobWindow(custodian, entry)
		if window.DiscoveryJobs.HasID(entry.DiscoveryJobID) {
			discoveryJob := window.DiscoveryJobs.GetByID(entry.DiscoveryJobID)
			if (discoveryJob.Name = entry.JobName) {
				window.Name.Set(entry.JobName)
				discoveryJob.Check()
				window.ShowJobOptions.Uncheck()
				window.OkButton.Click()
				jobType := SubStr(entry.JobType, 1, StrLen(entry.JobType) - 1)
				entry.StatusCell.SetAndColor(jobType . " Created.", xl_LightGreen)
			} else {
				entry.StatusCell.SetAndColor("Discovery Job Name does match Process Job Name.", xl_Orange)
				window.CancelButton.Click()
			}
		} else {
			entry.StatusCell.SetAndColor("Discovery Job ID not found.", xl_Orange)
			window.CancelButton.Click()
		}
	}
}
