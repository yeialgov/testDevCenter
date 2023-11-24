({
    mergeVenue : function(component, event, helper) {
        var MyObVenueId = component.get("v.MyObVenueId");
        var Contact = component.get("v.Contact");
        var action = component.get("c.ReparentMyObVenue");
        action.setParams({"MyObVenueId": MyObVenueId, "ContactId": Contact.Id});
        action.setCallback(this, function(response){
            var homeEvent = $A.get("e.force:navigateToObjectHome");
            homeEvent.setParams({
                "scope": "MyObVenue__c"
            });
            homeEvent.fire();
        });
        $A.enqueueAction(action);
    }
})