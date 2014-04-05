#Include .\lib\BasicControls\Controls.ahk

class OkDonePrintingWindow {
	__New() {
		winTitle := "ahk_class #32770" 
		winText := "Press OK when you are done printing"
		WinWait, % winTitle, % winText, 30
		this.WindowId := "ahk_id " . WinExist(winTitle, winText)
		
		this.OkButton := new Button(this.WindowId, "Button1")
	}
}