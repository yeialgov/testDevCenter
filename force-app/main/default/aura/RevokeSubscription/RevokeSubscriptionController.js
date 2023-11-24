({
    revoke : function(component, event, helper) {
        if(confirm("Are you sure you want to revoke this subscription?")) {
            var Subscription = component.get("v.Subscription");
            if(Subscription.Status__c == "Active") {
                var action = component.get("c.RevokeSubscription");
                action.setParams({
                    "SubscriptionZId": Subscription.ZuoraId__c
                });
                action.setCallback(this, function(response){
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": response.getReturnValue(),
                        "isredirect": true
                    });
                    navEvt.fire();
                });
                $A.enqueueAction(action);
            } else {
                component.set("v.ShowSpinner", false);
            }
        } else {
            $A.get("e.force:closeQuickAction").fire();
        }
    }
})