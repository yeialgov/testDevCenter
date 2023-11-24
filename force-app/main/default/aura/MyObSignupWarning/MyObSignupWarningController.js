({
    getWarning : function(component, event, helper) {
        var AcctId = component.get("v.AccountId");
        if (AcctId != null) {
            var action = component.get("c.getObWarning");
            action.setParams({"AccountId": AcctId});
            action.setCallback(this, function(response){
                var Warning = JSON.parse(response.getReturnValue());
                component.set("v.Warning", Warning);
                if (Warning.NoWarning) $A.get("e.c:HasObVenue").fire();
            });
            $A.enqueueAction(action);
        }
    },
    SendEmail : function(component, event, helper) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:MyObRegistrationEmail",
            componentAttributes: {
                recordId : component.get("v.Warning").PrimaryContactId,
                redirectId : component.get("v.redirectId")
            }
        });
        evt.fire();
    }
})