({
	doInit : function(component, event, helper) {
        helper.initialize(component);
	},
    AddNew : function(component, event, helper) {
        var action = component.get("c.addTemplate");
        action.setParams({
            "sObjectName": component.get("v.sObjectName"),
            "Name": component.get("v.Name"),
            "Message": component.get("v.EmailText")
        });
        action.setCallback(this, function(response){
            helper.initialize(component);
        });
        $A.enqueueAction(action);
    },
    exit : function(component, event, helper) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({ "recordId": component.get("v.sObjectId") });
        navEvt.fire();
    }
})