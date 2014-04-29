#Include .\lib\BasicControls\Controls.ahk
#Include .\lib\BasicControls\Window.ahk
#Include .\lib\eCapture\Controller\DiscoveryJobListView.ahk

class NewProcessJobWindow extends Window {
	SetTitle() {
		this.WinTitle := "ahk_class WindowsForms10.Window.8.app.0.11ecf05"
		this.WinText := "Select the Discovery Jobs you wish to use in this Processing Job"
	}
	
	BindControls() {
		this.BindStandardControls()
		this.BindDataExtractImportControls()
		this.BindDatabaseTableImportControls()
		this.ImportFrom["SelectedFile"].Set()
		this.Type["Standard"].Set()
	}
		
	BindStandardControls() {
		this.Name := this.BindTextBox("WindowsForms10.EDIT.app.0.11ecf052")
		this.Description := this.BindTextBox("WindowsForms10.EDIT.app.0.11ecf051")
		this.Type := this.BindRadioButtons()
		this.Type.Add("Standard", "WindowsForms10.BUTTON.app.0.11ecf051")
		this.Type.Add("DataExtractImport", "WindowsForms10.BUTTON.app.0.11ecf052")
		this.DiscoveryJobs := new DiscoveryJobListView(this.WindowId, "WindowsForms10.SysListView32.app.0.11ecf051")
		this.ShowJobOptions := this.BindCheckBox("WindowsForms10.BUTTON.app.0.11ecf053")
		this.ExpediteJob := this.BindCheckBox("WindowsForms10.BUTTON.app.0.11ecf054")
		this.OkButton := this.BindButton("WindowsForms10.BUTTON.app.0.11ecf057")
		this.CancelButton := this.BindButton("WindowsForms10.BUTTON.app.0.11ecf058")
		this.TaskTable := this.BindDropDownBox("WindowsForms10.COMBOBOX.app.0.11ecf051")
	}
	
	BindDataExtractImportControls() {
		this.Type["DataExtractImport"].Set()
		this.ImportFrom := this.BindRadioButtons()
		this.ImportFrom.Add("SelectedFile", "WindowsForms10.BUTTON.app.0.11ecf052")
		this.ImportFrom.Add("DatabaseTable", "WindowsForms10.BUTTON.app.0.11ecf053")
		this.ContentType := this.BindRadioButtons()
		this.ContentType.Add("ItemIDs", "WindowsForms10.BUTTON.app.0.11ecf055")
		this.ContentType.Add("ItemGUIDs", "WindowsForms10.BUTTON.app.0.11ecf054")
		this.ItemIdFilePath := this.BindTextBox("WindowsForms10.EDIT.app.0.11ecf051")
		this.SelectChildren := this.BindCheckBox("WindowsForms10.BUTTON.app.0.11ecf0511")
		this.ChildItemHandling := this.BindRadioButtons()
		this.ChildItemHandling.Add("Item", "WindowsForms10.BUTTON.app.0.11ecf058")
		this.ChildItemHandling.Add("ItemParent", "WindowsForms10.BUTTON.app.0.11ecf059")
		this.ChildItemHandling.Add("ItemParentChild", "WindowsForms10.BUTTON.app.0.11ecf0510")
	}
	
	BindDatabaseTableImportControls() {
		this.Type["DataExtractImport"].Set()
		this.ImportFrom["DatabaseTable"].Set()
		this.DatabaseTableName := this.BindTextBox("WindowsForms10.EDIT.app.0.11ecf051")
		this.ValidateItemIds := this.BindCheckBox("WindowsForms10.BUTTON.app.0.11ecf054")
	}
}