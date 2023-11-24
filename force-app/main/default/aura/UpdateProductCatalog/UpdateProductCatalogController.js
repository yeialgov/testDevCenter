({
    UpdateCatalog : function(component, event, helper) {
        component.set("v.ShowSpinner", true);
        var action = component.get("c.syncCatalog");
        action.setCallback(this, function(response){
	        component.set("v.ShowSpinner", false);
            if(response.getReturnValue()) {
                alert("Product Catalog sync has been started.");                
            } else {
                alert("Product Catalog is already being synced.");
            }
        });
        $A.enqueueAction(action);
    }
})