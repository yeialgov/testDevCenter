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
                console.log('success ++++++' + JSON.stringify(component.get("v.serviceData")));
            }
        });
        $A.enqueueAction(action);
    },

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
                console.log('success tse' + JSON.stringify(component.get("v.tseData")));
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

    getActiveDevices : function(component, event, helper){
        var action = component.get("c.getDeviceLicense");
        action.setParams({
            "Token": component.get("v.token")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var serv = response.getReturnValue();
                if(serv.length >0){
                    console.log('serv '+serv.length);
                for(var i=0;i<serv.length;i++){
                  //  console.log('Enetered for');
                    if(serv[i].prdCat.includes("F") ){
                        
                        serv[i].prdCat = "F";
                    }
                    else if(serv[i].prdCat.includes("F")&&serv[i].prdCat.includes("E")){
                        serv[i].prdCat = "F";
                    }
                    else if(serv[i].prdCat.includes("E")){
                        serv[i].prdCat = "E";
                    }
                }
                component.set("v.activeLicense", serv);
                component.set("v.hasActiveLicense", true);
                console.log('active license are:' + JSON.stringify(component.get("v.activeLicense")));
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

    getPrices : function(component, event, helper){
        var action = component.get("c.getDeviceLicense");
        action.setParams({
            "Token": component.get("v.token")
        });

    },

    QuoteCreate: function (component, Changes) {
        var action = component.get("c.CreateLicenseQuote");
        action.setParams({
            "Token": component.get("v.token"),
            "Changes": JSON.stringify(Changes)
        });
        action.setCallback(this, function (response) {
            alert('For testing: find Quote at ' + action.getReturnValue());
        });
        $A.enqueueAction(action);
    },
    cancelDevices: function(component, event, helper){
        var prods =[];
        var activeLicense = component.get("v.activeLicense");
        for(var i=0; i<activeLicense.length;i++){
            prods.push(activeLicense[i].prdId);
        }
        console.log('products are ' + prods);
        let action = component.get("c.createNegativeQuote");
        action.setParams({
            "Token": component.get("v.token"),
            "products": JSON.stringify(prods)
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log('state is ' + state);
            alert('For testing: find Quote at ' + action.getReturnValue());
        });
        $A.enqueueAction(action);
    }
})