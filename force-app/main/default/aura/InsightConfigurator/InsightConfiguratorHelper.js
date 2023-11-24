({
	preInit: function (component, event, helper) {
		var emailToken = component.get("v.emailToken");
		var tok = component.get("v.token");
		if (tok !== undefined || tok != null) {
			helper.initHelper(component, event, helper);
		}
		if (emailToken !== undefined || emailToken != null) {
			helper.initEmailHelper(component, event, helper);
		}
		console.log('token isssss '+component.get("v.token"));
	},

	initHelper: function (component, event, helper) {
		var action = component.get("c.getInsightEmail");
		action.setParams({
			"token": component.get("v.token")
		});
		action.setCallback(this, function (response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				helper.getInsightHourlyOption(component, event, helper);
				helper.getAverageRevenue(component, event, helper);
				helper.getFoodDrinkRatio(component, event, helper);
				var returned = response.getReturnValue();
				var myObj = JSON.parse(action.getReturnValue()).xObject;
				component.set("v.MyOrderbird", myObj);
				var subStatus = myObj.InsightsUnsubbed__c;
				component.set("v.currentSub", subStatus);
				var reSub = myObj.InsightsResubbed__c;
				var recordId = myObj.Id;
				component.set("v.isResub", reSub);
				component.set("v.recordId", recordId);
				console.log('response is +++ ' + component.get("v.recordId"));
				if (subStatus === false) {
					var status = $A.get("$Label.c.STATUS_SUBSCRIBED");
					component.set("v.subscriptionStatus", status);
				}
				if (subStatus === true) {
					var status = $A.get("$Label.c.STATUS_UNSUBSCRIBED");
					component.set("v.subscriptionStatus", status);
				}
				var hourlyRev = myObj.Hourly_Revenue__c;
				component.set("v.hourlyRevenueCurrent",hourlyRev);
				var averageRev = myObj.Average_Revenue__c;
				component.set("v.averageRevenueCurrent",averageRev);
				var foodDrink = myObj.Food_Drinks_Ratio__c;
				component.set("v.foodDrinkRatioCurrent",foodDrink);
			}
			if (state === "ERROR") {
				var errors = response.getError();
				if (errors) {
					if (errors[0] && errors[0].message) {
						console.log("Error message:  hereee" +
							errors[0].message);
					}
				}
			}
		});
		$A.enqueueAction(action);
	},

	initEmailHelper: function (component, event, helper) {
		console.log('callled ');
		var action = component.get("c.getInsightEmailfromEmail");
		action.setParams({
			"token": component.get("v.emailToken")
		});
		action.setCallback(this, function (response) {
			var state = response.getState();
			console.log('state issss ' + state);
			if (state === "SUCCESS") {
				var returned = response.getReturnValue();
				var myObj = JSON.parse(action.getReturnValue()).xObject;
				component.set("v.MyOrderbird", myObj);
				var subStatus = myObj.InsightsUnsubbed__c;
				component.set("v.currentSub", subStatus);
				var reSub = myObj.InsightsResubbed__c;
				var recordId = myObj.Id;
				component.set("v.isResub", reSub);
				component.set("v.recordId", recordId);
				console.log('response is +++ ' + component.get("v.recordId"));
				if (subStatus === false) {
					var status = $A.get("$Label.c.STATUS_SUBSCRIBED");
					component.set("v.subscriptionStatus", status);
				}
				if (subStatus === true) {
					var status = $A.get("$Label.c.STATUS_UNSUBSCRIBED");
					component.set("v.subscriptionStatus", status);
				}
			}
			if (state === "ERROR") {
				var errors = response.getError();
				if (errors) {
					if (errors[0] && errors[0].message) {
						console.log("Error message: " +
							errors[0].message);
						var toastType = 'error';
						var title = $A.get("$Label.c.UPDATE_IVALID_ERROR");
						var customMsg = $A.get("$Label.c.UPDATE_IVALID_ERROR_MSG");
						component.set("v.showLoad", false);
						helper.showToast(component, event, helper, title, customMsg, toastType);

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
					var toastType = 'success';
					helper.showToast(component, event, helper, title, customMsg, toastType);
				}
				if (returned === false) {
					var toastType = 'error';
					var title = $A.get("$Label.c.UPDATE_IVALID_ERROR");
					var customMsg = $A.get("$Label.c.UPDATE_IVALID_ERROR_MSG");
					component.set("v.showLoad", false);
					helper.showToast(component, event, helper, title, customMsg, toastType);
				}
			}
			if (state === "ERROR") {
				var errors = response.getError();
				if (errors) {
					if (errors[0] && errors[0].message) {
						console.log("Error message: " +
							errors[0].message);
						var title = $A.get("$Label.c.UPDATE_ERROR");
						var customMsg = $A.get("$Label.c.INVALID_TOKEN");
						var toastType = 'error'
						helper.showToast(component, event, helper, title, customMsg, toastType);
					}
				}
			}
		});
		$A.enqueueAction(action);
	},

	handleConfirm: function (component, event, helper) {
		component.set('v.showConfirmDialog', false);
		component.set("v.showLoad", true);
		var action = component.get("c.updateSubscription");
		action.setParams({
			"venueId": component.get("v.recordId"),
			"status": component.get("v.currentSub")
		});
		action.setCallback(this, function (response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				var returned = response.getReturnValue();
				if (returned === true) {
					component.set("v.showLoad", false);
					var toastType = 'success';
					var title = $A.get("$Label.c.UPDATE_SUCCESS");
					var customMsg = $A.get("$Label.c.REQ_PROCESSED_SUCCESS");
					component.set("v.showLoad", false);
					helper.showToast(component, event, helper, title, customMsg, toastType);
				}
			}
			if (state === "ERROR") {
				var toastType = 'error';
				var title = $A.get("$Label.c.UPDATE_IVALID_ERROR");
				var customMsg = $A.get("$Label.c.REQ_PROCESSED_FAILED");
				component.set("v.showLoad", false);
				helper.showToast(component, event, helper, title, customMsg, toastType);
			}
		});
		$A.enqueueAction(action);
	},

	showToast: function (component, event, helper, title, customMsg, toastType) {
		var toastEvent = $A.get("e.force:showToast");
		toastEvent.setParams({
			"type": toastType,
			"title": title,
			"message": customMsg
		});
		toastEvent.fire();
		var tk = component.get("v.token");
		if (tk) {
			var pgName = 'insights';
			helper.back(component, event, helper, pgName);
		}
		if (!tk) {
			var ttt = component.get("v.emailToken");
			console.log('entere pg' + ttt);
			var pgName = 'insights' + ttt;
			helper.back(component, event, helper, pgName);
		}
	},

	back: function (component, event, helper, pgName) {
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
	},

	getInsightHourlyOption : function (component, event, helper){
		console.log('function called');
		var action = component.get("c.getInsightHourlyOption");
		action.setCallback(this, function (response) {
			var state = response.getState();
			var s = component.get("v.hourlyRevenueCurrent");
			console.log('s '+s);
			if (state === "SUCCESS") {
				var returned = response.getReturnValue();
				var hRev =[];
				for(var i=0; i<returned.length; i++){
					if(returned[i] != s ){
						console.log('i'+returned[i]);
						hRev.push(returned[i]);			
					}					
				}
				component.set("v.hourlyRevenue",hRev);							
			}
			if (state === "ERROR") {
				var errors = response.getError();
				if (errors) {
					if (errors[0] && errors[0].message) {
						console.log("Error message: " +
							errors[0].message);
						var toastType = 'error';
						var title = $A.get("$Label.c.ERROR");
						var customMsg = $A.get("$Label.c.GENERAL_ERROR");
						component.set("v.showLoad", false);
						helper.showToast(component, event, helper, title, customMsg, toastType);

					}
				}
			}
		});
		$A.enqueueAction(action);
	},

	getAverageRevenue: function (component, event, helper){
		console.log('function called Average Revenue');
		var action = component.get("c.getAverageRevenue");
		action.setCallback(this, function (response) {
			var state = response.getState();
			var avgR = component.get("v.averageRevenueCurrent");
			console.log('avg '+avgR);
			if (state === "SUCCESS") {
				var returned = response.getReturnValue();
				var avg =[];
				for(var i=0; i<returned.length; i++){
					if(returned[i] != avgR ){
						console.log('i'+returned[i]);
						avg.push(returned[i]);
					}					
				}
				component.set("v.averageRevenue",avg);							
			}
			if (state === "ERROR") {
				var errors = response.getError();
				if (errors) {
					if (errors[0] && errors[0].message) {
						console.log("Error message: " +
							errors[0].message);
						var toastType = 'error';
						var title = $A.get("$Label.c.ERROR");
						var customMsg = $A.get("$Label.c.GENERAL_ERROR");
						component.set("v.showLoad", false);
						helper.showToast(component, event, helper, title, customMsg, toastType);

					}
				}
			}
		});
		$A.enqueueAction(action);
	},

	getFoodDrinkRatio : function (component, event, helper){
		console.log('function called Food Drink Ratio');
		var action = component.get("c.getFoodDrinkRatio");
		action.setCallback(this, function (response) {
			var state = response.getState();
			var foodDrink = component.get("v.foodDrinkRatioCurrent");
			console.log('foodDrink '+foodDrink);
			if (state === "SUCCESS") {
				var returned = response.getReturnValue();
				var food =[];
				for(var i=0; i<returned.length; i++){
					if(returned[i] != foodDrink ){
						console.log('food'+returned[i]);
						food.push(returned[i]);
					}					
				}
				component.set("v.foodDrinkRatio",food);							
			}
			if (state === "ERROR") {
				var errors = response.getError();
				if (errors) {
					if (errors[0] && errors[0].message) {
						console.log("Error message: " +
							errors[0].message);
						var toastType = 'error';
						var title = $A.get("$Label.c.ERROR");
						var customMsg = $A.get("$Label.c.GENERAL_ERROR");
						component.set("v.showLoad", false);
						helper.showToast(component, event, helper, title, customMsg, toastType);
					}
				}
			}
		});
		$A.enqueueAction(action);
	},

	updateMetrics: function (component, event, helper){
		console.log('called');
		var hourlyRev = component.get("v.selectedHourlyValue");
		var avg = component.get("v.selectedAverageValue");
		var food = component.get("v.selectedfoodDrinkRatio");
		console.log('metrics '+hourlyRev+' '+avg+' '+food);
		var action = component.get("c.updateMetricOptions");
		action.setParams({
			"hourlyRev": component.get("v.selectedHourlyValue"),
			"avg": component.get("v.selectedAverageValue"),
			"food": component.get("v.selectedfoodDrinkRatio"),
			"recordId": component.get("v.recordId"),
		});
		action.setCallback(this, function (response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				var returned = response.getReturnValue();
				console.log('success ++++'+ returned);
				var toastType = 'success';
					var title = $A.get("$Label.c.UPDATE_SUCCESS");
					var customMsg = $A.get("$Label.c.REQ_PROCESSED_SUCCESS");
					component.set("v.showLoad", false);
					helper.showToast(component, event, helper, title, customMsg, toastType);
			}
			if (state === "ERROR") {
				if (errors) {
					if (errors[0] && errors[0].message) {
						console.log("Error message: " +
							errors[0].message);
						var toastType = 'error';
						var title = $A.get("$Label.c.ERROR");
						var customMsg = $A.get("$Label.c.GENERAL_ERROR");
						component.set("v.showLoad", false);
						helper.showToast(component, event, helper, title, customMsg, toastType);
					}
				}
			}
		});
		$A.enqueueAction(action);
	}
})