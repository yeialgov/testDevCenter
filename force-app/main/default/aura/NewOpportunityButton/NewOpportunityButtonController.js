({
	doIt : function(component, event, helper) {
        var action = component.get("c.createNewOpportunity");
        action.setParams({ 
            "AccountId": component.get("v.AccountId"),
            "AccountName": component.get("v.Account").Name
        });
        action.setCallback(this, function(response){
    		var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({ "recordId": action.getReturnValue() });
            navEvt.fire();
        });
        $A.enqueueAction(action);
	}
})