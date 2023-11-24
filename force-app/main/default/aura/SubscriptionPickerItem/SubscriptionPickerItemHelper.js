({
	doClick : function(component, selected) {
		component.set("v.Selected", selected);
        var appEvent = $A.get("e.c:QuoteEmailContactClick");
        appEvent.setParams({
            "Add": selected,
            "Id": component.get("v.Subscription").ZuoraId__c
        });
        appEvent.fire();
	}
})