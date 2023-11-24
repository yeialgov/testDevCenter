({
    doInit : function(component, event, helper) {
        helper.Initialize(component);
    },
    ConfirmCustomerId : function(component, event, helper) {
        component.set("v.ShowSpinner", true);
        var action = component.get("c.verifyConnection");
        action.setParams({
            "Token": component.get("v.token"),
            "VerificationString": component.find("custId").get("v.value")
        });
        action.setCallback(this, function(response){
            var Token = JSON.parse(action.getReturnValue()).Token;
            component.set("v.token", Token);
            component.find("custId").set("v.value", null);
            component.set("v.FailCount", component.get("v.FailCount")+1);
            helper.Initialize(component);
        });
        $A.enqueueAction(action);
    }
})