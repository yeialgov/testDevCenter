({
    doInit : function(component, event, helper) {
        helper.preInit(component, event, helper);
       },
   
       handleEmailChange : function(component, event, helper){
           var Val =component.find("currentEmail").get("v.value");
           console.log(Val);
           if(!Val){
               console.log('blank');
               var toastType ='error';
					var title = $A.get("$Label.c.UPDATE_IVALID_ERROR");
		            var customMsg = $A.get("$Label.c.INSIGHT_NO_EMAIL");
					component.set("v.showLoad", false);
					helper.showToast(component, event, helper,title, customMsg,toastType);
           }
           if(Val){ 
               component.set("v.newEmail",Val);
               helper.updateEmail(component, event, helper);
           }
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

    handleUpdateMetrics : function(component, event, helper){
     helper.updateMetrics(component, event, helper);
    },

       back:  function(component, event, helper){
           var pg ='options';
           helper.back(component, event, helper,pg);
       }
})