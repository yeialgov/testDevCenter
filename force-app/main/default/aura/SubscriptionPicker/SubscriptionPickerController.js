({
    acctChange : function(component, event) {
        var action = component.get("c.getSubscriptionsFromCase");
        action.setParams({
            "AccountId": component.get("v.AccountId")
        });
        action.setCallback(this, function(response){
            component.set("v.Subscriptions", JSON.parse(action.getReturnValue()));
        });
        $A.enqueueAction(action);
    }
})