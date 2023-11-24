({
    doInit : function(component, event, helper) {
        if (component.get("v.FirstRun")) {
            component.set("v.FirstRun", false);
            component.set("v.ShowSpinner", true);
            helper.create(component, helper);
        }
    }
})