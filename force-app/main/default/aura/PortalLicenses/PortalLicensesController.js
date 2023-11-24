({
    //init method to get the necessary data needed for the whole process
    doInit : function(component, event, helper) {
        var NameMap = {"1": "Monthly", "12": "Annual", "36": "Three-Year", "120": "Lifetime", "None": "None"};


        console.log('token: ' + component.get("v.token"));
		component.set("v.IsMobile", helper.detectMob());
        helper.getLicenseInfo(component,event,helper);
        helper.getCashBookInfo(component,event,helper);
        helper.getTSEInfo(component,event,helper);
        helper.getCashBookInfo(component,event,helper);
        helper.getActiveDevices(component,event,helper);
        var action = component.get("c.getLicenses");

        console.log('Going to get licenses');

        console.log('a');
       
        action.setParams({
            "Token": component.get("v.token")
        });

        console.log('b');

        action.setCallback(this, function(response){
            console.log('e');
            console.log('It has worked');
            console.log(action.getReturnValue());
            var Token = JSON.parse(action.getReturnValue()).Token;
            var Data = JSON.parse(action.getReturnValue()).LicenseData;
            var Map = [];
            var RevMap = {};
            var x = 0;
            for (var key in Data.Device) {
                Data.Device[key].Name = NameMap[key];
                Data.Device[key].Add = 0;
                Map.push({value:Data.Device[key], key:key});
                RevMap[key] = x;
                x++;
            }
            Map.push({value:{"Name":"None","Add":0}, key:"None"});
            RevMap["None"] = x;
            Data.Device.Map = Map;
            Data.Device.RevMap = RevMap;
            Data.Service.Now = Data.Service.Current;
            Data.Service.CurrentName = NameMap[Data.Service.Current];
            Data.Cashbook.Now = Data.Cashbook.Current;
            Data.Cashbook.CurrentName = NameMap[Data.Cashbook.Current];
            Data.TSE.Now = Data.TSE.Current;
            Data.TSE.CurrentName = NameMap[Data.TSE.Current];
            console.log(Data);
            component.set("v.token", Token);
            component.set("v.ShowSpinner", false);
            component.set("v.Data", Data);
        });
        console.log('c');
        $A.enqueueAction(action);

        console.log('d');
    },

    //opens the Cashbook dialog
    handleCashDialog : function(component, event, helper) {
        component.set('v.showCashBook', true);
    },

    //opens GuestManagement dialog
    handleGuestMgmhDialog : function(component, event, helper) {
        component.set('v.showGuestMgm', true);
    },

    //closes cashbook dialog
    handleCloseCashDialog : function(component, event, helper) {
        component.set('v.showCashBook', false);
    },
    
    //closes the guestmanagement dialog
    handleGuestCloseMgmhDialog : function(component, event, helper) {
        component.set('v.showGuestMgm', false);
    },

    //opens the Add Devices screen and gets the prices from the custom metadata type
    handleAddDev : function(component, event, helper){
        component.set('v.addLicense',true);
        helper.getPrices(component,event,helper);
    },

    //cancel button for the add device screen
    handleCancelAddDev :function(component, event, helper){
        component.set('v.addLicense',false);
    },

    //navigates back to the original page
    back : function(component, event, helper) {
        var object = {
            "type": "comm__namedPage",
            "attributes": {
                "pageName": "options"
            },    
            "state": {
                "token": component.get("v.token"),
                "beta": "true"
            }
        };
                
        component.find("navService").navigate(object);
	},

    //removes devices by Splice function and calls the helper passing a JSON with the license to be removed
    remDev: function(component,event,helper){
        console.log(' component.get("v.token") -- remdev: ' +  component.get("v.token"));
        var index = event.getSource().get("v.tabindex");
        console.log('Index is ==> ' + index);
        var AllRowsList = component.get("v.activeLicense"); 
        console.log('removed '+JSON.stringify(AllRowsList[index]));
        var remList = AllRowsList[index];
        component.set("v.removeList",remList);
        var licenseToRemove = component.get("v.removeList");
        var operation ='Remove';
        AllRowsList.splice(index, 1);
        // set the contactList after remove selected row element  
        component.set("v.activeLicense", AllRowsList);
        console.log('AllRowsList '+JSON.stringify(AllRowsList));
        component.set("v.ShowSpinner", true);
        helper.createWorkOrder(component,event,helper,licenseToRemove,operation,component.get("v.token"));
    },

    //opens the cancel license screen
    handleCancelLicenses : function(component, even, helper){
        console.log('Entered Cancel Licenses modal' + JSON.stringify(component.get("v.serviceData")));
        var serviceDate = component.get("v.serviceData");
        var endDate =serviceDate[0].efEndDate;
        component.set("v.endDate", endDate);
        console.log('End Date is ' + component.get("v.endDate"));
        component.set("v.showCancelLicenseModal", true);
    },
    
    //closes the cancel screen window
    handleCancelDevNo : function(component, even, helper){
        component.set("v.showCancelLicenseModal", false);
    },

    //opens the complete cancel window
    handleCancelDevYes : function(component, event, helper){
        component.set("v.completeCancelation",true);
        component.set("v.showCancelLicenseModal", false);
    },

    //handles the complete cancel of devices - calls the helper and passes the necessary parameters
    handleCompleteCancel : function(component, event, helper){
    component.set("v.completeCancelation",false);
    component.set("v.ShowSpinner", true);
     helper.cancelDevices(component, event, helper);
    },

    //handles addition of aditional devices and calls the helper method
    handleAddAdditionalDev: function(component, event, helper){
        console.log(' component.get("v.token") -- handleAddAdditionalDev: ' +  component.get("v.token"));
      helper.addDevices(component, event, helper,component.get("v.token"));
    },

    //closes the complete cancel window in case of button press
    handleCancelCompleteCancel : function(component,event,helper){
        component.set("v.completeCancelation",false);
    },

    //handles the change of the start date
    handleChangedStartDate : function(component, event){
        var changedStartDate = event.getParam("value");
        component.set("v.changedStartDate", changedStartDate);
        console.log('Start date is ==> ' + component.get("v.changedStartDate"));
    },

    //handles change of the monthly amount
    handleChangedAmount : function(component, event, helper){
        var monthAmmount = component.find('amountMonthly').get('v.value');
        var startMonth = component.find('startDateMonthly').get('v.value');
        var newAmount = monthAmmount+1
        console.log('amm '+newAmount+' '+startMonth);
        component.set('v.changedAmount',newAmount);
    },

    //handles change of the yearly amount
    handleChangedAmountYearly : function(component, event, helper){
        var yearAmmount = component.find('amountYearly').get('v.value');
        var startMonth = component.find('startDateYearly').get('v.value');
        var newAmount = yearAmmount+1
        console.log('amm '+newAmount+' '+startMonth);
        component.set('v.changedYearlyAmount',newAmount);

    },

    //handles change of the 3 yearly amount
    handleChangedAmount3Year : function(component, event, helper){
        var year3Ammount = component.find('amount3Years').get('v.value');
        var startMonth = component.find('startDate3Years').get('v.value');
        var newAmount = year3Ammount+1
        console.log('amm '+newAmount+' '+startMonth);
        component.set('v.changed3YearsAmount',newAmount);
    },
 
    handleYearlyChangedAmount : function(component, event){
        var changedYearlyAmount = event.getParam("value");
        component.set("v.changedYearlyAmount", changedYearlyAmount);
        console.log('Quantity Yearly is ==> ' + component.get("v.changedYearlyAmount"));
    },
   
     // This will contain an array of the "value" attribute of the selected options
    handleChangeReason : function(component, event, helper){
        var selectedOptionValue = event.getParam("value");
        component.set("v.cancelReasons",selectedOptionValue);
    },

    //sets the callback checkbox value
    handleCallBackChange : function(component, event, helper){
        var callback = event.getParam("value");
        component.set("v.callBackValue",callback);
    },

    //handles 3 year quatity change
    handle3YearsChangedAmount : function(component, event){
        var changed3YearsAmount = event.getParam("value");
        component.set("v.changed3YearsAmount", changed3YearsAmount);
        console.log('Quantity 3 Years is ==> ' + component.get("v.changed3YearsAmount"));
    },

    //closes the addional message window
    handleCloseAdditional : function(component, event){
        component.set("v.showAdditional",false);
    }
})