#Include .\lib\BasicControls\Controls.ahk
#Include .\lib\BasicControls\Window.ahk
#Include .\lib\eCapture\Controller\ClientManagementTreeView.ahk

class Controller extends Window {
	SetTitle() {
		this.WinTitle := "eCapture Controller"
		this.WinText := "Client Management"
	}
	
	BindControls() {
		this.TreeView := new ClientManagementTreeView(this.WindowId, "WindowsForms10.SysTreeView32.app.0.11ecf051", true)
		this.Clients := this.TreeView.Clients
	}
}