({
    getAcctId : function(component, event, helper) {
        var AcctId = component.get("v.AccountId");
        var action = component.get("c.getMRR");
        action.setParams({"AccountId": AcctId});
        action.setCallback(this, function(response){
            component.set("v.MRR", Math.round(response.getReturnValue()));
        });
        $A.enqueueAction(action);
    }
})