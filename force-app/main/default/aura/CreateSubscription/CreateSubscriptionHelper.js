({
    create : function(component, helper) {
        var Quote = component.get("v.Quote");
        var action;
        action = component.get("c.ProcessQuote");
        action.setParams({"QuoteId": component.get("v.recordId")});
        action.setCallback(this, function(response){
            var ErrorMessages = JSON.parse(action.getReturnValue());
            component.set("v.ErrorMessages", ErrorMessages);
            console.log(action.getReturnValue());
            component.set("v.ShowSpinner", false);
            component.set("v.ShowConfirmation", false);
            if (ErrorMessages.length == 0) {
                $A.get('e.force:refreshView').fire();
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({ 
                    "recordId" : component.get("v.Quote").AccountId,
                    "isredirect" : true
                });
                navEvt.fire();
            }
            //component.set("v.ShowSpinner", false);*/
        });
        $A.enqueueAction(action);
    },
    wfpChange : function(component, boolValue) {
        var Quote = component.get("v.Quote");
        Quote.WireFirstPayment__c = boolValue;
        component.set("v.Quote", Quote);
        component.find("recordLoader").saveRecord($A.getCallback(function(saveResult) {
            component.set("v.HasWFPSelection", true);
            component.set("v.ShowSpinner", false);
        }));
    },
    errors : function(component, helper, messages) {
        component.set("v.ErrorMessages", messages);
        component.set("v.ShowSpinner", false);
    }
})