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
			rule := this.ParseRuleText(item)
			rules[rule.ID] := rule
			item := this.Tree.GetNext(item, "FULL")
		}
		return rules
	}
	
	ParseRuleText(ruleItem) {
		rule := {}
		pattern := "(?P<ID>[0-9]*): (?P<Action>.*?) (?:-- (?P<Description>.*) )?-> (?P<AutoDescription>.*)"
		rule.Item := ruleItem
		ruleText := this.Tree.GetText(rule.Item)
		found := RegExMatch(ruleText, pattern, match)
		rule.ID := matchID
		rule.Action := matchAction
		rule.Description := matchDescription
		rule.AutoDescription := matchAutoDescription
		return rule
	}
	
	SelectRule(index) {
		selectedRule := {}
		for key, rule in this.GetRules() {
			if (A_Index = index + 1) {
				tries := 0
				success := false
				while (!success and tries < 5) {
					success := this.Tree.SetSelection(rule.Item)
					Sleep (25 * tries)
					tries := tries + 1
				}
				if (!success) {
					throw "Could not set selection on TreeView"
				}
				selectedRule := rule
				continue
			}
		}
		return selectedRule
	}
}