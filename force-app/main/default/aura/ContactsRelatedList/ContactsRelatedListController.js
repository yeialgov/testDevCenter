({
    doInit : function(component, event, helper) {
        var recordId = component.get("v.recordId");
        console.log("!!! " + recordId);
        if (recordId != null) {
            var action = component.get("c.getAccountContacts");
            action.setParams({
                "AccountId": component.get("v.recordId")
            });
            action.setCallback(this, function(response){
                component.set("v.Contacts", JSON.parse(action.getReturnValue()));
            });
            $A.enqueueAction(action);
        }
    },
    refresher : function(component) {
        component.find("recordLoader").reloadRecord(true) 
    },
    newContact : function(component, event, helper) {
        var editRecordEvent = $A.get("e.force:createRecord");
        editRecordEvent.setParams({
            "entityApiName": "Contact",
            "defaultFieldValues": {
                'AccountId' : component.get("v.recordId")
            }
        });
        editRecordEvent.fire();
    }
})