({
	doInit : function(component, event, helper) {
     helper.preInit(component, event, helper);
	},

    handleEmailChange : function(component, event, helper){
        var Val =component.find("currentEmail").get("v.value");
        console.log(Val);
        if(Val !== undefined){ 
            component.set("v.newEmail",Val);
            helper.updateEmail(component, event, helper);
        }
    }
})