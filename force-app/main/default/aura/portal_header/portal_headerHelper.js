({
	Initialize : function(component) {
        console.log('toke here '+component.get("v.token"));
        var action = component.get("c.getAccountInfo");
        action.setParams({'token':component.get("v.token")});
        action.setCallback(this, function(response){
            var returnVal = action.getReturnValue();
            if (returnVal == null) {
                component.set("v.HasError", true);
            } else {
                component.set("v.Data", JSON.parse(action.getReturnValue()));
            }
            component.set("v.ShowSpinner", false);
        });
        $A.enqueueAction(action);
	}
})