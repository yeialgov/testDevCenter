({
	doInitt : function(component, event, helper) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:EditQuote",
            componentAttributes: {
                QuoteId : component.get("v.recordId"),
                CloneToOpportunity : true
            }
        });
        evt.fire();
	}
})