#Include .\lib\BasicControls\Controls.ahk
#Include .\lib\eCapture\Qc\DocumentList.ahk

class QcClient {
	__New() {
		winTitle := "ahk_class WindowsForms10.Window.8.app.0.11ecf05" 
		winText := "RasterImageViewer1"
		WinWait, % winTitle, % winText, 30
		this.WindowId := "ahk_id " . WinExist(winTitle, winText)

		this.DocumentList := new DocumentList(this.WindowId, "WindowsForms10.Window.8.app.0.11ecf0517")
	}
}