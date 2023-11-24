({
    doInit : function(component, event, helper) {
        component.set("v.VATNumber", component.get("v.Account").VATNumber_disp__c);
    },
    editModeOn : function(component) {
        component.set("v.EditMode", true);
    },
    verifyMe : function(component) {
        component.set("v.ShowSpinner", true);
        var action = component.get("c.getVATVerify");
        action.setParams({
            "VATNumber": component.get("v.VATNumber")
        });
        action.setCallback(this, function(response){
            component.set("v.VIES", JSON.parse(response.getReturnValue()));
            component.set("v.ShowSpinner", false);
        });
        $A.enqueueAction(action);
    },
    saveMe : function(component) {
        component.set("v.ShowSpinner", true);
        var action = component.get("c.saveVAT");
        var AccountId = component.get("v.recordId");
        action.setParams({
            "AccountId": AccountId,
            "UpdateAddress": component.get("v.AddressOverride"),
            "VIES_json": JSON.stringify(component.get("v.VIES"))
        });
        action.setCallback(this, function(response){
            if (response.getReturnValue()) {
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": AccountId,
                    "isredirect": true
                });
                navEvt.fire();
            } else {
                component.set("v.ShowSpinner", false);
            }
        });
        $A.enqueueAction(action);
    }
})