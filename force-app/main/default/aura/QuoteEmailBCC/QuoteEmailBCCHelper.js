({
	doClick : function(component, selected) {
		component.set("v.Selected", selected);
        var appEvent = $A.get("e.c:QuoteEmailBCCClick");
        appEvent.setParams({ "BCCMe": selected });
        appEvent.fire();
	}
})