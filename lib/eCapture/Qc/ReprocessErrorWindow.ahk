#Include .\lib\BasicControls\Controls.ahk

class ReprocessErrorWindow {
	__New(wait) {
		winTitle := "Reprocess Error" 
		winText := "Exception --->"
		WinWait, % winTitle, % winText, % wait
		this.WindowId := "ahk_id " . WinExist(winTitle, winText)
		
		this.Label := new Label(this.WindowId, "Static2")
		this.YesButton := new Button(this.WindowId, "Button1")
		this.NoButton := new Button(this.WindowId, "Button2")
	}
}