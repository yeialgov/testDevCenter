({
    getData : function(component, event, helper) {
        var MyObVenueId = component.get("v.recordId");
        var action = component.get("c.matchContacts");
        action.setParams({"MyObVenueId": MyObVenueId});
        action.setCallback(this, function(response){
            component.set("v.Data", JSON.parse(response.getReturnValue()));
        });
        $A.enqueueAction(action);
    }
})