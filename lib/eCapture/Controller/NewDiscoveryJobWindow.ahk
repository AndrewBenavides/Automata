#Include .\lib\BasicControls\Controls.ahk
#Include .\lib\BasicControls\Window.ahk

class NewDiscoveryJobWindow extends Window {
	SetTitle() {
		this.WinTitle := "New Discovery Job"
		this.WinText := "Create dtSearch Index during initial discovery"
	}
	
	BindControls() {
		this.JobName := this.BindTextBox("WindowsForms10.EDIT.app.0.11ecf055")
		this.BatchID := this.BindTextBox("WindowsForms10.EDIT.app.0.11ecf051")
		this.Description := this.BindTextBox("WindowsForms10.EDIT.app.0.11ecf054")
		this.Directory := this.BindTextBox("WindowsForms10.EDIT.app.0.11ecf052")
		this.DirectoriesToolStrip := this.BindToolStrip("WindowsForms10.ToolbarWindow32.app.0.11ecf051")
		this.CreateDtSearchIndex := this.BindCheckBox("WindowsForms10.BUTTON.app.0.11ecf0510")
		this.OcrImages := this.BindCheckBox("WindowsForms10.BUTTON.app.0.11ecf053")
		this.OcrPdfDocuments := this.BindCheckBox("WindowsForms10.BUTTON.app.0.11ecf052")
		this.IndexLocations := this.BindRadioButtons()
		this.IndexLocations.Add("Default", "WindowsForms10.BUTTON.app.0.11ecf056")
		this.IndexLocations.Add("Specified", "WindowsForms10.BUTTON.app.0.11ecf055")
		this.TaskTable := this.BindDropDownBox("WindowsForms10.COMBOBOX.app.0.11ecf051")
		this.ShowJobOptions := this.BindCheckBox("WindowsForms10.BUTTON.app.0.11ecf057")
		this.ExpediteJob := this.BindCheckBox("WindowsForms10.BUTTON.app.0.11ecf058")
		this.OkButton := this.BindButton("WindowsForms10.BUTTON.app.0.11ecf0511")
		this.CancelButton := this.BindButton("WindowsForms10.BUTTON.app.0.11ecf059")
	}
	
	AddDirectory(directory) {
		this.Directory.Set(directory)
		this.DirectoriesToolStrip.Click(10, 10)
	}
}
