#Include .\lib\BasicControls\Controls.ahk

class ReprocessDocumentWindow {
	__New() {
		winTitle := "ahk_class WindowsForms10.Window.8.app.0.11ecf05"
		winText := "NoProgressBar1"
		WinWait, % winTitle, % winText, 30
		this.WindowId := "ahk_id " . WinExist(winTitle, winText)
		
		this.ItemPath := new Label(this.WindowId, "WindowsForms10.STATIC.app.0.11ecf051")
		this.CancelButton := new Button(this.WindowId, "WindowsForms10.BUTTON.app.0.11ecf051")
	}
}