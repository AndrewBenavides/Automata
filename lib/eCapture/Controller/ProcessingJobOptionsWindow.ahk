#Include .\lib\BasicControls\Controls.ahk
#Include .\lib\BasicControls\Window.ahk

class ProcessingJobOptionsWindow extends Window {
	SetTitle() {
		this.WinTitle := "ahk_class WindowsForms10.Window.8.app.0.11ecf05"
		this.WinText := "Data Extract and Process jobs share the same default time-zone options, found on the Time Zone Options tab"
	}
	
	BindControls() {
		this.OkButton := this.BindButton("WindowsForms10.BUTTON.app.0.11ecf0513")
		this.TabControl := this.BindTabControl("WindowsForms10.SysTabControl32.app.0.11ecf051")
		this.TabControl.Add(0, "General")
		this.TabControl.Add(1, "Excel")
		this.TabControl.Add(2, "Word")
		this.TabControl.Add(3, "Powerpoint")
		this.TabControl.Add(4, "Filtering")
		this.TabControl.Set(4)
		this.ManageFlexProcessorButton := this.BindButton("WindowsForms10.BUTTON.app.0.11ecf0514")
		this.TabControl.Set(0)
	}
}