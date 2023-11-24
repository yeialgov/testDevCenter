({
    doInit : function(component, event, helper) {
        var action = component.get("c.getRelatedDocuments");
        action.setParams({
            "AccountId": component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            console.log(action.getReturnValue());
            var Data = JSON.parse(action.getReturnValue());
            component.set("v.Data", Data);
            component.set("v.Size", Data.QuoteDocs.length + Data.InvoiceDocs.length);
        });
        $A.enqueueAction(action);
    }
})