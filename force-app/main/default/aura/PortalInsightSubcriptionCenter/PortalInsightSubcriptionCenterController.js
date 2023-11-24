({
    initHelper : function(component, event, helper) {
        helper.start(component, event, helper);
       },

       handleConfirmDialog : function(component, event, helper) {
        component.set('v.showConfirmDialog', true);
    },

    handleConfirmDialogYes : function(component, event, helper) {
        helper.handleConfirm(component,event,helper);
    },

    handleConfirmDialogNo : function(component, event, helper) {
        component.set('v.showConfirmDialog', false);
    },

    back : function(component, event, helper) {
        var pgN ='options';
        helper.back(component, event, helper,pgN);
      }
})