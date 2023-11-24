({
	runInit : function(component, helper) {
        var Opportunity = component.get("v.Opportunity");
        var componentName = "c:NewQuote";
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : componentName,
            componentAttributes: {
                PresetValue : "{\"mo\":0,\"yr\":0,\"thryr\":0,\"tenyr\":0,\"onb\":\"None\"}",
                OpportunityId : component.get("v.recordId")
            }
        });
        evt.fire();
	},
    errors : function(component, helper, messages) {
        component.set("v.ErrorMessages", messages);
        component.set("v.ShowSpinner", false);
    }
})