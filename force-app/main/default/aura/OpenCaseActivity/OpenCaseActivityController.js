({
    gotoTask : function(component, event, helper) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({ "recordId": component.get("v.Task").Id });
        navEvt.fire();
    },
    closeTask : function(component, event, helper) {
        component.set("v.Spinner", true);
        var action = component.get("c.closeOpenTask");
        action.setParams({ "TaskId": component.get("v.Task").Id });
        action.setCallback(this, function(response){
            component.set("v.Show", false);
            //$A.get('e.force:refreshView').fire();
        });
        $A.enqueueAction(action);
    }
})