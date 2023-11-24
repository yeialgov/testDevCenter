({
    getVenues : function(component, event, helper) {
        var Contact = component.get("v.Contact");
        if (Contact.AccountId != null) {
            var action = component.get("c.getMyObVenues");
            action.setParams({"AccountId": Contact.AccountId});
            action.setCallback(this, function(response){
                component.set("v.Venues", response.getReturnValue());
            });
            $A.enqueueAction(action);
        }
    }
})