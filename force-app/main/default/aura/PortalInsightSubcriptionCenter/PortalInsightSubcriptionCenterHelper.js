({
    start: function (component, event, helper) {
		console.log('here '+component.get("v.token"));
		var hasToken = component.get("v.token");
		if(hasToken !== undefined){
			component.set("v.showOption",true);
        var action2 = component.get("c.getInsightSubscription");
		action2.setParams({
			"token": component.get("v.token")
		});
		action2.setCallback(this, function (response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				var recordId = JSON.parse(action2.getReturnValue()).RecordId;
				var subStatus = JSON.parse(action2.getReturnValue()).BooleanValue;
				component.set("v.currentSub",subStatus);
				var reSub = JSON.parse(action2.getReturnValue()).IsResub;
				component.set("v.isResub",reSub);
				component.set("v.recordId",recordId);
				console.log('response is '+component.get("v.recordId"));
				if(subStatus === false){
					var status = $A.get("$Label.c.STATUS_SUBSCRIBED");
					component.set("v.subscriptionStatus",status);
				}
				if(subStatus === true){
					var status = $A.get("$Label.c.STATUS_UNSUBSCRIBED");
					component.set("v.subscriptionStatus",status);
				}
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
		$A.enqueueAction(action2);	
	}
    },

	handleConfirm : function(component, event, helper){
		component.set('v.showConfirmDialog', false);
		component.set("v.showLoad", true);
		var action = component.get("c.updateSubscription");
		action.setParams({
			"venueId": component.get("v.recordId"),
			"status": component.get("v.currentSub")
		});
		action.setCallback(this, function (response) {
			var state = response.getState();			
			if (state === "SUCCESS"){
				var returned = response.getReturnValue();
				if(returned === true){
					component.set("v.showLoad", false);
					var toastType ='success';
					var title = $A.get("$Label.c.UPDATE_SUCCESS");
		            var customMsg = $A.get("$Label.c.REQ_PROCESSED_SUCCESS");
					component.set("v.showLoad", false);
					helper.showToast(component, event, helper,title, customMsg,toastType);
				}
			}
			if (state === "ERROR"){
				var toastType ='error';
					var title = $A.get("$Label.c.UPDATE_IVALID_ERROR");
		            var customMsg = $A.get("$Label.c.REQ_PROCESSED_FAILED");
					component.set("v.showLoad", false);
					helper.showToast(component, event, helper,title, customMsg,toastType);
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
		var pgName ='insights';
		helper.back(component, event, helper, pgName);
	},

	back : function(component, event, helper, pgName) {
        var object = {
            "type": "comm__namedPage",
            "attributes": {
                "pageName": pgName
            },    
            "state": {
                "token": component.get("v.token")  
            }
        };        
        component.find("navService").navigate(object);
	}
})