#Include .\lib\BasicControls\Controls.ahk
#Include .\lib\BasicControls\Window.ahk

class DataExtractJobOptionsWindow extends Window {
	SetTitle() {
		this.WinTitle := "ahk_class WindowsForms10.Window.8.app.0.11ecf05"
		this.WinText := "Data Extract and Process jobs share the same default time-zone options, found on the Time Zone Options tab"
	}
	
	BindControls() {
		this.OkButton := this.BindButton("WindowsForms10.BUTTON.app.0.11ecf0512")
		this.TabControl := this.BindTabControl("WindowsForms10.SysTabControl32.app.0.11ecf051")
		this.TabControl.Add(0, "Data Extract Options")
		this.TabControl.Add(1, "Filtering")
		this.TabControl.Set(1)
		this.ManageFlexProcessorButton := this.BindButton("WindowsForms10.BUTTON.app.0.11ecf0513")
		this.TabControl.Set(0)
	}
}