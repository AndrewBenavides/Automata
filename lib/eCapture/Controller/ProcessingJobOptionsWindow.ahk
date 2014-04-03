#Include .\lib\BasicControls\Controls.ahk

class ProcessingJobOptionsWindow {
	__New(windowId) {
		this.WindowId := windowId
		this.TabControl := new TabControl(this.WindowId, "WindowsForms10.SysTabControl32.app.0.11ecf051")
		this.ManageFlexProcessorButton := new Button(this.WindowId, "WindowsForms10.BUTTON.app.0.11ecf0514")
		this.OkButton := new Button(this.WindowId, "WindowsForms10.BUTTON.app.0.11ecf0516")
	}
}