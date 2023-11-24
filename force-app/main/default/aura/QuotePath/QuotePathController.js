({
    review : function(component, event, helper) {
        component.set("v.ShowSpinner", true);
        var Quote = component.get("v.Quote");
        Quote.Status = 'In Review';
        component.set("v.Quote", Quote);
        component.find("recordHandler").saveRecord($A.getCallback(function(saveResult){}));
    },
    updated : function(component, event, helper) {
        component.find("recordHandler").reloadRecord(true);
    },
    reject : function(component, event, helper) {
        component.set("v.ShowSpinner", true);
        var Quote = component.get("v.Quote");
        Quote.Status = 'Rejected';
        component.set("v.Quote", Quote);
        component.find("recordHandler").saveRecord($A.getCallback(function(saveResult){}));
    },
    accept : function(component, event, helper) {
        component.set("v.ShowAccept", true);
    },
    HideAccept : function(component, event, helper) {
        component.set("v.ShowAccept", false);
    },
    edit : function(component, event, helper) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:EditQuote",
            componentAttributes: {
                "QuoteId" : component.get("v.recordId")
            }
        });
        evt.fire();
    },
    clone : function(component, event, helper) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:EditQuote",
            componentAttributes: {
                QuoteId : component.get("v.recordId"),
                CloneToOpportunity : true
            }
        });
        evt.fire();
    },
    reverify : function(component, event, helper) {
        component.set("v.ShowSpinner", true);
        var action = component.get("c.forecastInvoice");
        action.setParams({'QuoteId':component.get("v.recordId")});
        action.setCallback(this, function(response0){
            $A.get("e.force:refreshView").fire();
            component.find('recordHandler').reloadRecord(true) 
            component.set("v.ShowSpinner", false);
        });
        $A.enqueueAction(action);
    },
    HasObVenue : function(component) {
        component.set("v.HasObVenue", true);
    },
    NeedsBambora : function(component, event) {
        component.set("v.NeedsBambora", event.getParam("NeedsBamboraFields"));
        component.set("v.ShowSpinner", false);
    }
})