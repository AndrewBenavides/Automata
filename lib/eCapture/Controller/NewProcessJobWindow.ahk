#Include .\lib\BasicControls\Controls.ahk

class NewProcessJobWindow {
	__New(windowId, processJobType) {
		this.WindowId := windowId
		
		if (processJobType = "DataExtractImport") {
			this.SwitchToDataExtractImport()
		}
	}
	
	SwitchToDataExtractImport() {
		this.Type := new RadioButtons()
		this.Type["DataExtractImport"] := new RadioButton(this.WindowId, "WindowsForms10.BUTTON.app.0.11ecf052")
		this.Type["DataExtractImport"].Set()
		this.Type["Standard"] := new RadioButton(this.WindowId, "WindowsForms10.BUTTON.app.0.11ecf0512")
		this.Type["DataExtractImport"].ControlClass := "WindowsForms10.BUTTON.app.0.11ecf0513"
		this.Name := new TextBox(this.WindowId, "WindowsForms10.EDIT.app.0.11ecf053")
		this.Description := new TextBox(this.WindowId, "WindowsForms10.EDIT.app.0.11ecf052")
		this.ItemIdFilePath := new TextBox(this.WindowId, "WindowsForms10.EDIT.app.0.11ecf051")
		this.SelectChildren := new CheckBox(this.WindowId, "WindowsForms10.BUTTON.app.0.11ecf0511")
		this.ChildItemHandling := new RadioButtons()
		this.ChildItemHandling["Item"] := new RadioButton(this.WindowId, "WindowsForms10.BUTTON.app.0.11ecf058")
		this.ChildItemHandling["ItemParent"] := new RadioButton(this.WindowId, "WindowsForms10.BUTTON.app.0.11ecf059")
		this.ChildItemHandling["ItemParentChild"] := new RadioButton(this.WindowId, "WindowsForms10.BUTTON.app.0.11ecf0510")
		this.ShowJobOptions := new CheckBox(this.WindowId, "WindowsForms10.BUTTON.app.0.11ecf0514")
		this.OkButton := new Button(this.WindowId, "WindowsForms10.BUTTON.app.0.11ecf0518")
	}
}