({
	doClick : function(component, selected) {
		component.set("v.Selected", selected);
        var appEvent = $A.get("e.c:QuoteEmailContactClick");
        appEvent.setParams({
            "Add": selected,
            "Id": component.get("v.Contact").Id,
            "Sec": false
        });
        appEvent.fire();
	},
	doClickSec : function(component, selected) {
		component.set("v.SelectedSec", selected);
        var appEvent = $A.get("e.c:QuoteEmailContactClick");
        appEvent.setParams({
            "Add": component.get("v.Selected", selected),
            "Id": component.get("v.Contact").Id,
            "Sec": selected
        });
        appEvent.fire();
	}
})