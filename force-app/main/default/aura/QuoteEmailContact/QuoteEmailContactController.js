({
    select : function(component, event, helper) {
        helper.doClick(component, true);
    },
    unselect : function(component, event, helper) {
        helper.doClick(component, false);
        component.set("v.SelectedSec", false);
    },
    selectSec : function(component, event, helper) {
        helper.doClickSec(component, true);
    },
    unselectSec : function(component, event, helper) {
        helper.doClickSec(component, false);
    }
})