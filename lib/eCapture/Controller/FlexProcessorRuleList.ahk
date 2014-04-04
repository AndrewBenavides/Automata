; Includes for RemoteTreeView
#Include .\lib\RemoteTreeView\Const_TreeView.ahk
#Include .\lib\RemoteTreeView\Const_Process.ahk
#Include .\lib\RemoteTreeView\Const_Memory.ahk
#Include .\lib\RemoteTreeView\RemoteTreeViewClass.ahk


class FlexProcessorRuleList {
	__New(windowId, controlClass) {
		this.WindowId := windowId
		this.ControlClass := controlClass
		ControlGet, treeviewId, Hwnd, , % this.ControlClass, % this.WindowId
		this.ControlId := treeviewId
		this.Tree := new RemoteTreeView(this.ControlId)
	}
	
	Count() {
		i := 0
		for rule in this.GetRules() {
			i := i + 1
		}
		return i
	}
	
	GetRules() {
		rules := {}
		item := this.Tree.GetNext(0, "FULL")
		while item {
			rule := this.ParseRuleText(this.Tree.GetText(item))
			rules[rule.ID] := rule
			item := this.Tree.GetNext(item, "FULL")
		}
		return rules
	}
	
	ParseRuleText(ruleText) {
		rule := {}
		pattern := "(?P<ID>[0-9]*): (?P<Action>.*?) (?:-- (?P<Description>.*) )?-> (?P<AutoDescription>.*)"
		found := RegExMatch(ruleText, pattern, match)
		rule.ID := matchID
		rule.Action := matchAction
		rule.Description := matchDescription
		rule.AutoDescription := matchAutoDescription
		return rule
	}
}