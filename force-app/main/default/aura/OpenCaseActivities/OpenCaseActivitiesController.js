({
	doInit : function(component, event, helper) {
        var action = component.get("c.getOpenTasks");
        action.setParams({"CaseId": component.get("v.recordId")});
        action.setCallback(this, function(response){
            console.log(response.getReturnValue());
            component.set("v.Tasks", response.getReturnValue());
        });
        $A.enqueueAction(action);
	}
})