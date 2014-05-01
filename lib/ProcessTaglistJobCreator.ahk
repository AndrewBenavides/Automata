#Include .\lib\BaseJobCreator.ahk
#Include .\lib\eCapture\Controller\DataExtractJobOptionsWindow.ahk
#Include .\lib\eCapture\Controller\FlexProcessorOptionsWindow.ahk
#Include .\lib\eCapture\Controller\ImportFromFileWindow.ahk
#Include .\lib\eCapture\Controller\ProcessingJobOptionsWindow.ahk
#Include .\lib\Excel\ProcessTaglistJobLog.ahk

class ProcessTaglistJobCreator extends BaseJobCreator {
	Log := new ProcessTaglistJobLog()

	ProcessEntry(entry) {
		processor := new ProcessTaglistJobEntryProcessor(this, entry)
		processor.Process()
	}
}

class ProcessTaglistJobEntryProcessor {
	__New(creator, entry) {
		this.Creator := creator
		this.Entry := entry
	}
	
	Process() {
		this.Counts := new ProcessTaglistJobEntryCounts()
		this.Counts.Add("File", this.Entry.GetTaglistCount())
		if (this.Counts.File > 0) {
			this.Custodian := this.Creator.TargetCustodian(this.Entry)
			if this.Custodian.Exists {
				this.CreateJob()
			} else {
				this.Entry.StatusCell.SetAndColor("Custodian not found.", xl_Orange)
			}
		} else {
			this.Entry.StatusCell.SetAndColor("Taglist file does not exist.", xl_Orange)
		}
	}
	
	ConfigureFilter() {
		window := this.GetFilterWindow()
		window.CreateNewRule()
		window.RuleTitle.Set("Remove Duplicates")
		window.Action.Set("Remove")
		window.ProcessJobDuplicates.Check()
		window.DataExtractJobDuplicates.Check()
		window.ProcessJobDuplicatesScope.Set("Project")
		window.DataExtractJobDuplicatesScope.Set("Project")
		window.SaveRule()
		counts := this.GetFilterCounts(window)
		window.Exit()
		return counts
	}
	
	ConfigureProcessingJob() {
		window := this.Creator.GetNewJobWindow(this.Custodian, this.Entry)
		window.Type["DataExtractImport"].Set()
		window.Name.Set(this.Entry.JobName)
		window.ItemIdFilePath.Set(this.Entry.TaglistFullName)
		window.SelectChildren.Set(this.Entry.SelectChildren)
		window.ChildItemHandling[this.Entry.ChildItemHandling].Set()
		window.OkButton.Click()
	}
	
	CreateJob() {
		this.ConfigureProcessingJob()
		this.Counts.Add("Added", this.GetAddedCount())
		filterCounts := this.ConfigureFilter()
		this.Counts.Add("Parent", filterCounts.Parent)
		this.Counts.Add("Child", filterCounts.Child)
	}

	GetAddedCount() {
		window := new ImportFromFileWindow()
		count := window.GetCount()
		return count
	}
	
	GetFilterCounts(window) {
		counts := {}
		counts.Parent := this.ValidateFilterParents(window)
		counts.Child := this.ValidateFilterChildren(window)
		return counts
	}
	
	GetFilterWindow() {
		if (this.Entry.JobType = "Processing Jobs") {
			window := new ProcessingJobOptionsWindow()
		} else if (this.Entry.JobType = "Data Extract Jobs") {
			window := new DataExtractJobOptionsWindow()
		} else {
			message := "Job Type """ . this.Entry.JobType . """ is not supported."
		}
		tries := 0
		filterWindow := {}
		filterWindow.Exists := False
		while (!filterWindow.Exists && tries < 5) {
			window.ManageFlexProcessorButton.Click()
			filterWindow := new FlexProcessorOptionsWindow()
			Sleep (1 + (tries * 100))
			tries += 1
		}
		window.OkButton.Click() 
		return filterWindow
	}
	
	LogCounts() {
		this.Entry.TaglistCountCell.Set(this.Counts.File)
		this.Entry.AddedCountCell.Set(this.Counts.Added)
		this.Entry.ParentCountCell.Set(this.Counts.Parent)
		this.Entry.ChildCountCell.Set(this.Counts.Child)
	}
	
	ValidateFilterParents(window) {
		count := window.GetItemIdListCount(0)
		return count
	}
	
	ValidateFilterChildren(window) {
		rule := window.RulesList.SelectRule(1)
		if  (rule.Action = "Remove") {
			return 0
		} else {
			count := window.GetItemIdListCount(1)
			return count
		}
	}
}

class ProcessTaglistJobEntryCounts {
	IsNumber(num) {
		if num is number
		{
			return true
		} else {
			return false
		}
	}
	
	Add(key, value) {
		if this.IsNumber(value) {
			this[key] := value
		} else {
			this[key] := -1
		}
	}
}
