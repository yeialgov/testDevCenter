({
    count : function(component, event, helper) {
        var action = component.get("c.CountInterwega");
        action.setCallback(this, function(response){
            alert(response.getReturnValue());
        });
        $A.enqueueAction(action);
    },
    clear : function(component, event, helper) {
        var action = component.get("c.ClearInterwega");
        action.setCallback(this, function(response){
            alert(response.getReturnValue());
        });
        $A.enqueueAction(action);
    },
    import : function(component, event, helper ) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/lightning/settings/personal/DataImporter/home"
        });
        urlEvent.fire();
    }
})