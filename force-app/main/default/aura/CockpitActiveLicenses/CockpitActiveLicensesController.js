({
    getAcctId : function(component, event, helper) {
        var AcctId = component.get("v.AccountId");
        console.log("==> "+AcctId);
        if (AcctId != null) {
            var action = component.get("c.getActiveDevices");
            action.setParams({"AccountId": AcctId});
            action.setCallback(this, function(response){
                console.log(JSON.stringify(response.getReturnValue()));
                component.set("v.Licenses", response.getReturnValue());
            });
            $A.enqueueAction(action);
        }
    }
})