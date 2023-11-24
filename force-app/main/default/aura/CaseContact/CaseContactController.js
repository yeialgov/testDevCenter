({
    select : function(component, event, helper) {
        helper.doClick(component, true);
    },
    unselect : function(component, event, helper) {
        helper.doClick(component, false);
    }
})