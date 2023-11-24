({
    save : function(component, event, helper) {
        component.set("v.ShowSpinner", true);
        var SaveEvent = $A.get("e.c:QuoteButtonSave");
        SaveEvent.setParams({"saveAction": component.get("v.Type")})
        SaveEvent.fire();
        component.set("v.ShowSpinner", false);
    },
    cancel : function(component, event, helper) {
        component.set("v.ShowSpinner", true);
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.RedirectId")
        });
        navEvt.fire();
    }    
})