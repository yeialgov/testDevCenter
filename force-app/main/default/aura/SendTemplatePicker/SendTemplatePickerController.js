({
	deleteMe : function(component, event, helper) {
        var action = component.get("c.deleteTemplate");
        action.setParams({
            "TemplateId": component.get("v.Template").Id
        });
        action.setCallback(this, function(response){
            component.set("v.Display", false);
        });
        $A.enqueueAction(action);
	}
})