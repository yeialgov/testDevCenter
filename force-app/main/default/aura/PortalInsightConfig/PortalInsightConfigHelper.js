({
	preInit: function (component, event, helper){
		var emailToken = component.get("v.emailToken");
		var tok = component.get("v.token");
		if(tok !== undefined || tok != null){
			helper.initHelper(component, event, helper);
		} 
		if(emailToken !== undefined || emailToken !=null){
			console.log('in here');
			helper.initEmailHelper(component, event, helper);
		}
	},

	initHelper: function (component, event, helper) {
		var action = component.get("c.getInsightEmail");
		action.setParams({
			"token": component.get("v.token")
		});
		action.setCallback(this, function (response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				var returned = response.getReturnValue();
				var myObj = JSON.parse(action.getReturnValue()).xObject;
				component.set("v.MyOrderbird", myObj);
				var label = cmp.get("v.MyOrderbird");
			}
			if (state === "ERROR") {
				var errors = response.getError();
				if (errors) {
					if (errors[0] && errors[0].message) {
						console.log("Error message: " +
							errors[0].message);
					}
				}
			}
		});
		$A.enqueueAction(action);
	},

	initEmailHelper :function (component, event, helper){
		console.log('callled ');
		var action = component.get("c.getInsightEmailfromEmail");
		action.setParams({
			"token": component.get("v.emailToken")
		});
		action.setCallback(this, function (response) {
			var state = response.getState();
			console.log('state issss '+state);
			if (state === "SUCCESS") {
				var returned = response.getReturnValue();
				var myObj = JSON.parse(action.getReturnValue()).xObject;
				component.set("v.MyOrderbird", myObj);
				var label = cmp.get("v.MyOrderbird");
			}
			if (state === "ERROR") {
				var errors = response.getError();
				if (errors) {
					if (errors[0] && errors[0].message) {
						console.log("Error message: " +
							errors[0].message);
					}
				}
			}
		});
		$A.enqueueAction(action);
	}, 

	updateEmail: function (component, event, helper) {
		component.set("v.showLoad", true);
		var action = component.get("c.updateEmail");
		action.setParams({
			"myObjId": component.get("v.MyOrderbird.Id"),
			"newEmail": component.get("v.newEmail")
		});
		action.setCallback(this, function (response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				var returned = response.getReturnValue();
				if (returned === true) {
					component.set("v.showLoad", false);
					var title = $A.get("$Label.c.UPDATE_SUCCESS");
		            var customMsg = $A.get("$Label.c.UPDATE_SUCCESS_MSG");
					var toastType ='success';
					helper.showToast(component, event, helper,title, customMsg,toastType);					
				}
				if(returned === false){
					var toastType ='error';
					var title = $A.get("$Label.c.UPDATE_IVALID_ERROR");
		            var customMsg = $A.get("$Label.c.UPDATE_IVALID_ERROR_MSG");
					component.set("v.showLoad", false);
					helper.showToast(component, event, helper,title, customMsg,toastType);	
				}
			}
			if (state === "ERROR") {
				var errors = response.getError();
				if (errors) {
					if (errors[0] && errors[0].message) {
						console.log("Error message: " +
							errors[0].message);
							var title = $A.get("$Label.c.UPDATE_ERROR");
		                    var customMsg = $A.get("$Label.c.UPDATE_ERROR_MSG");
							var toastType ='error'
							helper.showToast(component, event, helper,title, customMsg,toastType);
					}
				}
			}
		});
		$A.enqueueAction(action);
	},

	showToast : function(component, event, helper, title, customMsg,toastType) {	
		var toastEvent = $A.get("e.force:showToast");
		toastEvent.setParams({
			"type":toastType,
			"title": title,
			"message": customMsg
		});
		toastEvent.fire();
	},

	back : function(component, event, helper) {
        var object = {
            "type": "comm__namedPage",
            "attributes": {
                "pageName": "options"
            },    
            "state": {
                "token": component.get("v.token")  
            }
        };        
        component.find("navService").navigate(object);
	}
})