({
	getVenues : function(component, event, helper) {
        var AcctId = component.get("v.recordId");
        var action = component.get("c.getMyObVenues");
        action.setParams({"AccountId": AcctId});
        action.setCallback(this, function(response){
            component.set("v.Venues", response.getReturnValue());
        });
        $A.enqueueAction(action);
	}
})