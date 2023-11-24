({
    doInit : function(component, event, helper) {
        var action = component.get("c.getBamboraEligibility");
        action.setParams({
            "QuoteId": component.get("v.recordId"),
        });
        action.setCallback(this, function(response){
            component.set("v.CardVisibility", response.getReturnValue());
            var appEvent = $A.get("e.c:NeedsBambora");
            appEvent.setParams({ "NeedsBamboraFields" : response.getReturnValue() });
            appEvent.fire();
        });
        $A.enqueueAction(action);
    }
})