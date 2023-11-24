({
	doIt : function(component, event, helper) {
		component.set("v.Spinning", true);
        var ZuoraId = component.get("v.Account").ZuoraId__c;
        if (ZuoraId == null) {
            alert("This Account is not connected to Zuora.");
            component.set("v.Spinning", false);
        } else {
            var action = component.get("c.syncAccount");
            action.setParams({
                "AccountZId": ZuoraId,
                "RunFuture": true
            });
            action.setCallback(this, function(response){
                $A.get('e.force:refreshView').fire();
                component.set("v.Spinning", false);
            });
            $A.enqueueAction(action);
        }
    }
})