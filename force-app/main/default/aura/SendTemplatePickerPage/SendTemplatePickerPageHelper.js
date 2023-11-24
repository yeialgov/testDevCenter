({
	initialize : function(component) {
        var action = component.get("c.getSendTemplates");
        action.setParams({
            "sObjectName": component.get("v.sObjectName")
        });
        action.setCallback(this, function(response){
            component.set("v.Templates", JSON.parse(action.getReturnValue()));
            component.set("v.Name", null);
            component.set("v.EmailText", null);
        });
        $A.enqueueAction(action);
	}
})