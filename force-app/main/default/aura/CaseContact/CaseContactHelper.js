({
    doClick : function(component, selected) {
        var action = component.get("c.setCaseContact");
        var CaseId = component.get("v.Case").Id;
        action.setParams({
            "CaseId": CaseId,
            "ContactId" : component.get("v.Contact").Id,
            "Selected" : selected
        });
        action.setCallback(this, function(response){
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId": CaseId,
                "isredirect": true
            });
            navEvt.fire();
        });
        $A.enqueueAction(action);
    }
})