({
    detectMob: function () {
        const toMatch = [
            /Android/i,
            /webOS/i,
            /iPhone/i,
            /iPad/i,
            /iPod/i,
            /BlackBerry/i,
            /Windows Phone/i
        ];

        return toMatch.some((toMatchItem) => {
            return navigator.userAgent.match(toMatchItem);
        });
    },

    //function calls the controller and gets the license info based on decrypting of the token
    getLicenseInfo: function (component, event, helper) {
        var action = component.get("c.getLicenseInfo");
        action.setParams({
            "Token": component.get("v.token")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var serv = response.getReturnValue();
                component.set("v.serviceData", serv);
            }
        });
        $A.enqueueAction(action);
    },

    //function that gets the CashBook Information
    getCashBookInfo: function (component, event, helper) {
        var action = component.get("c.getCashBookInfo");
        action.setParams({
            "Token": component.get("v.token")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var serv = response.getReturnValue();
                component.set("v.cashBookData", serv);
                if(serv.length >0){
                component.set("v.hasCashBook", true);
                console.log('success cashbook' + JSON.stringify(component.get("v.cashBookData")));
                }
                if(serv.length ==0){
                    component.set("v.hasCashBook", false);
                }
            }
            if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    component.set("v.hasCashBook", false);
                    console.log('fail cashbook' + JSON.stringify(component.get("v.cashBookData")));
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                            errors[0].message);
                    }
                }
            }
        });
        $A.enqueueAction(action);
    },

    //function that gets the TSE Information
    getTSEInfo: function (component, event, helper) {
        var action = component.get("c.getTseInfo");
        action.setParams({
            "Token": component.get("v.token")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var serv  = response.getReturnValue();
                if(serv.length >0){
                component.set("v.tseData", serv);
                component.set("v.hasTse", true);
                }
                if(serv.length ==0){
                    component.set("v.hasTse", false);
                }
            }
            if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    component.set("v.hasTse", false);
                    console.log('fail tse' + JSON.stringify(component.get("v.tseData")));
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                            errors[0].message);
                    }
                }
            }
        });
        $A.enqueueAction(action);
    },

    //gets individual Cashbook info
    getCashBookInfo : function (component, event, helper){
        var action = component.get("c.getGuestBookInfo");
        action.setParams({
            "Token": component.get("v.token")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var serv = response.getReturnValue();
                if(serv.length >0){
                component.set("v.tseGuestBook", serv);
                component.set("v.hasGuest", true);
                console.log('success guestb' + JSON.stringify(component.get("v.tseData")));
                }
                if(serv.length ==0){
                    component.set("v.hasGuest", false);
                }
            }
            if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    component.set("v.hasGuest", false);
                    console.log('fail guest' + JSON.stringify(component.get("v.tseGuestBook")));
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                            errors[0].message);
                    }
                }
            }
        });
        $A.enqueueAction(action);
    },

    //gets the active device list
    getActiveDevices : function(component, event, helper){
        var action = component.get("c.getDeviceLicense");
        action.setParams({
            "Token": component.get("v.token")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var serv = JSON.parse(response.getReturnValue());
                console.log('serv: ' + serv);
                if(serv.length >0){
                    console.log('serv '+serv.length);
                for(var i=0;i<serv.length;i++){

                    console.log('serv[i]: ' +  serv[i]);
                    console.log('serv[i]: ' +  serv[i].productGeneration);

                   // console.log('Enetered for: ' + JSON.stringify(serv[i]));
                   // var tempItemJSONString =  JSON.stringify(serv[i]);
                   // var tempItemJsonObject = JSON.parse(tempItemJSONString);
                    //console.log('tempItem.prdCat: ' + tempItemJsonObject.prdCat);

                    //var productGeneration = serv[i].Product__r.Product_Generation__c;
                    //console.log('productGeneration: ' + productGeneration);

                    
                    if(serv[i].productGeneration.includes("F") ){
                        serv[i].productGeneration = "F";
                        component.set('v.prodCat',serv[i].productGeneration );
                        break;     
                    }
                    else if(serv[i].productGeneration.includes("F")&&serv[i].productGeneration.includes("E")){
                        serv[i].productGeneration = "F";
                        component.set('v.prodCat',serv[i].productGeneration );
                        break;  
                    }
                    else if(serv[i].productGeneration.includes("E")){
                        serv[i].productGeneration = "E";
                        component.set('v.prodCat',serv[i].productGeneration );
                        break;  
                    }
                    else if(serv[i].productGeneration.includes("G")){
                        serv[i].productGeneration = "G";
                        component.set('v.prodCat',serv[i].productGeneration );
                        break;  
                    }
                    
                }
                console.log('serv '+serv.length);
                component.set("v.activeLicense", serv);
                component.set("v.hasActiveLicense", true);
                }
                if(serv.length ==0){
                    component.set("v.hasActiveLicense", false);
                }
            }
            if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    component.set("v.hasActiveLicense", false);
                    console.log('fail guest' + JSON.stringify(component.get("v.activeLicense")));
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                            errors[0].message);
                    }
                }
            }
        });
        $A.enqueueAction(action);
    },

    //function that gets the prices from the custom metadata type and sets the individual attributes
    getPrices : function(component, event, helper){
        console.log('price called');
        var action = component.get("c.getPrices");
        action.setParams({
            "Token": component.get("v.token"),
            "custCat": component.get("v.prodCat")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var serv = response.getReturnValue();
                console.log('succeeesss on price'+JSON.stringify(serv));
                if(serv.length >0){
                    for(var i=0; i<serv.length; i++){
                        if(serv[i].Billing_Period__c ==='Monthly'){
                        console.log('i ser '+serv[i].Price__c);
                        component.set("v.monthlyPrice",serv[i].Price__c);
                        }
                        if(serv[i].Billing_Period__c ==='Yearly'){
                        console.log('i ser '+serv[i].Price__c);
                        component.set("v.yearlyPrice",serv[i].Price__c);
                        }
                        if(serv[i].Billing_Period__c ==='3 Year'){
                            console.log('i ser '+serv[i].Price__c);
                            component.set("v.year3yPrice",serv[i].Price__c);
                            }
                    }
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
        $A.enqueueAction(action);

    },

    //created the workored that will be used in the batch job to create the necesarry objects
    createWorkOrder : function(component, event, helper, json, operation, token){
        console.log('oder to create '+operation);
        var jsonInput = JSON.stringify(json);
        var op =operation;
        var action = component.get("c.createWorkOrder");
        console.log('token - createWorkOrder: ' + token);
        action.setParams({
            "token": token,
            "jsonInput": jsonInput,
            "operation": op
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var serv = response.getReturnValue();
                console.log('succeeesss on eork item'+JSON.stringify(serv));
                var toastType = 'success';
					var title = $A.get("$Label.c.UPDATE_SUCCESS");
					var customMsg = $A.get("$Label.c.LICENSE_CONFIRM");
					component.set("v.ShowSpinner", false);
					helper.showToast(component, event, helper, title, customMsg, toastType);
                    var reasons =component.get("v.cancelReasons");
                    for(var j=0; j<reasons.length; j++){
                        if(reasons[j] =='Out of business' || reasons[j] =='Owner Change'){
                            component.set("v.showAdditional",true);
                        }
                    }
            }
            if (state === "ERROR") {
                var errors = response.getError();
                var toastType = 'error';
				var title = $A.get("$Label.c.UPDATE_IVALID_ERROR");
				var customMsg = $A.get("$Label.c.REQ_PROCESSED_FAILED");
				component.set("v.showLoad", false);
				helper.showToast(component, event, helper, title, customMsg, toastType);
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

    //function that sets the input parameters and calls the apex method to create workorder record
    addDevices: function(component, event, helper, token){
        var op ='Create'; 

        var payload = '';
        payload += 'Year3DeviceToAdd:' + component.get("v.changed3YearsAmount") + '/';
        payload += 'Year3Price:' + component.get("v.year3yPrice") + '/';
        payload += 'Year3StartDate:' + component.find('startDate3Years').get('v.value') + '/';
        payload += 'MonthlyPrice:' + component.get("v.monthlyPrice") + '/';
        payload += 'MonthlyDeviceToadd:' + component.get("v.changedAmount") + '/';
        payload += 'MonhtlyStartDate:' + component.find('startDateMonthly').get('v.value') + '/';
        payload += 'YearlyDeviceToAdd:' + component.get("v.changedYearlyAmount") + '/';
        payload += 'YearlyPrice:' + component.get("v.yearlyPrice") + '/';
        payload += 'YearlyStartDate:' + component.find('startDateYearly').get('v.value') + '';

        console.log('payload: ' + payload);

        const orderRequest = {
            Year3DeviceToAdd : component.get("v.changed3YearsAmount"),
            Year3Price : component.get("v.year3yPrice"),
            Year3StartDate : component.find('startDate3Years').get('v.value'),
            MonthlyPrice :  component.get("v.monthlyPrice"),
            MonthlyDeviceToadd : component.get("v.changedAmount"),
            MonhtlyStartDate : component.find('startDateMonthly').get('v.value'),
            YearlyDeviceToAdd : component.get("v.changedYearlyAmount"),
            YearlyPrice : component.get("v.yearlyPrice"),
            YearlyStartDate : component.find('startDateYearly').get('v.value')
        };

        /*
        var obj = new Object();
        obj.MonthlyDeviceToadd  = component.get("v.changedAmount");
        obj.MonthlyPrice = component.get("v.monthlyPrice");
        obj.MonhtlyStartDate = component.find('startDateMonthly').get('v.value');
        obj.YearlyDeviceToAdd = component.get("v.changedYearlyAmount");
        obj.YearlyPrice = component.get("v.yearlyPrice");
        obj.YearlyStartDate = component.find('startDateYearly').get('v.value');
        obj.Year3DeviceToAdd = component.get("v.changed3YearsAmount");
        obj.Year3Price = component.get("v.year3yPrice");
        obj.Year3StartDate = component.find('startDate3Years').get('v.value');
        */

        helper.createWorkOrder(component, event, helper, payload, op,token);
        component.set("v.addLicense",false);
    },

    //calls method to create the workorder to cancel devices
    cancelDevices: function(component, event, helper){
        console.log(' component.get("v.token") -- cancelDevices: ' +  component.get("v.token"));
        var prods =[];
        var activeLicense = component.get("v.activeLicense");
        var operation ='Remove';
        helper.createWorkOrder(component, event, helper, activeLicense, operation, component.get("v.token")); 
    },

    //function that shows various toast events
    showToast: function (component, event, helper, title, customMsg, toastType) {
		var toastEvent = $A.get("e.force:showToast");
		toastEvent.setParams({
			"type": toastType,
			"title": title,
			"message": customMsg
		});
		toastEvent.fire();
	},
})