({
	doIt : function(component, event, helper) {
		component.set("v.Spinning", true);
        var ZuoraId = component.get("v.Invoice").ZuoraId__c;
        if (ZuoraId == null) {
            alert("This Invoice is not connected to Zuora.");
            component.set("v.Spinning", false);
        } else {
            var action = component.get("c.syncInvoiceItems");
            action.setParams({
                "InvoiceZId": ZuoraId
            });
            action.setCallback(this, function(response){
                $A.get('e.force:refreshView').fire();
                component.set("v.Spinning", false);
            });
            $A.enqueueAction(action);
        }
    }
})