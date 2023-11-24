({
	initialize : function(component) {
        var action = component.get("c.getContacts");
        action.setParams({
            "AccountId": component.get("v.Case.AccountId"),
        });
        action.setCallback(this, function(response){
            component.set("v.Contacts", JSON.parse(action.getReturnValue()));
        });
        $A.enqueueAction(action);
	}
})