({
    doInit : function(component, event, helper) {
        var NameMap = {"1": "Monthly", "12": "Annual", "36": "Three-Year", "120": "Lifetime", "None": "None"};
		component.set("v.IsMobile", helper.detectMob());
        helper.getLicenseInfo(component,event,helper);
        helper.getCashBookInfo(component,event,helper);
        helper.getTSEInfo(component,event,helper);
        helper.getCashBookInfo(component,event,helper);
        helper.getActiveDevices(component,event,helper);
        var action = component.get("c.getLicenses");
        action.setParams({
            "Token": component.get("v.token")
        });
        action.setCallback(this, function(response){
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
        $A.enqueueAction(action);
    },

    handleCashDialog : function(component, event, helper) {
        component.set('v.showCashBook', true);
    },

    handleGuestMgmhDialog : function(component, event, helper) {
        component.set('v.showGuestMgm', true);
    },

    handleCloseCashDialog : function(component, event, helper) {
        component.set('v.showCashBook', false);
    },

    handleGuestCloseMgmhDialog : function(component, event, helper) {
        component.set('v.showGuestMgm', false);
    },
    handleAddDev : function(component, event, helper){
        component.set('v.addLicense',true);
        

    },

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
    AddDevice : function(component, event, helper) {
        var key = event.getSource().get("v.value");
        var Data = component.get("v.Data");
        var CombinedChanges = component.get("v.CombinedChanges");
        Data.Device.Map[Data.Device.RevMap[key]].value.Add++;
        if (Data.Device.Map[Data.Device.RevMap[key]].value.Add > 0) {
            CombinedChanges++;
        } else {
            CombinedChanges--;
        }
        component.set("v.Data", Data);
        component.set("v.CombinedChanges", CombinedChanges);
    },

    remDev: function(component,event,helper){
        var index = event.getSource().get("v.tabindex");
        console.log('Index is ==> ' + index);
        var AllRowsList = component.get("v.activeLicense");
        console.log('AllRowsList '+JSON.stringify(AllRowsList));
        AllRowsList.splice(index, 1);
        // set the contactList after remove selected row element  
        component.set("v.activeLicense", AllRowsList);
    },

    RemoveDevice : function(component, event, helper) {
        var key = event.getSource().get("v.value");
        var Data = component.get("v.Data");
        var CombinedChanges = component.get("v.CombinedChanges");
        if (Data.Device.Map[Data.Device.RevMap[key]].value.Active + Data.Device.Map[Data.Device.RevMap[key]].value.Add > 0) {
            Data.Device.Map[Data.Device.RevMap[key]].value.Add--;
            if (Data.Device.Map[Data.Device.RevMap[key]].value.Add < 0) {
                CombinedChanges++;
            } else {
                CombinedChanges--;
            }
        }
        component.set("v.Data", Data);
        component.set("v.CombinedChanges", CombinedChanges);
    },
    ServiceChange : function(component, event, helper) {
        var CombinedChanges = component.get("v.CombinedChanges");
        var Data = component.get("v.Data");
        var WasMatch = Data.Service.Now == Data.Service.Current;
        Data.Service.Now = event.target.value;
        Data.Service.NowName = Data.Device.Map[Data.Device.RevMap[Data.Service.Now]].value.Name;
        var IsMatch = Data.Service.Now == Data.Service.Current;
        if (WasMatch) { CombinedChanges++; } else if (IsMatch) { CombinedChanges--; }
        component.set("v.CombinedChanges", CombinedChanges);
        component.set("v.Data", Data);
    },
    CashbookChange : function(component, event, helper) {
        var CombinedChanges = component.get("v.CombinedChanges");
        var Data = component.get("v.Data");
        var WasMatch = Data.Cashbook.Now == Data.Cashbook.Current;
        Data.Cashbook.Now = event.target.value;
        Data.Cashbook.NowName = Data.Device.Map[Data.Device.RevMap[Data.Cashbook.Now]].value.Name;
        var IsMatch = Data.Cashbook.Now == Data.Cashbook.Current;
        if (WasMatch) { CombinedChanges++; } else if (IsMatch) { CombinedChanges--; }
        component.set("v.CombinedChanges", CombinedChanges);
        component.set("v.Data", Data);
    },
    TSEChange : function(component, event, helper) {
        var CombinedChanges = component.get("v.CombinedChanges");
        var Data = component.get("v.Data");
        var WasMatch = Data.TSE.Now == Data.TSE.Current;
        Data.TSE.Now = event.target.value;
        Data.TSE.NowName = Data.Device.Map[Data.Device.RevMap[Data.TSE.Now]].value.Name;
        var IsMatch = Data.TSE.Now == Data.TSE.Current;
        if (WasMatch) { CombinedChanges++; } else if (IsMatch) { CombinedChanges--; }
        component.set("v.CombinedChanges", CombinedChanges);
        component.set("v.Data", Data);
    },
    ShowSummary : function(component, event, helper) {
        component.set("v.ShowModal", true);
    },
    CreateQuote : function(component, event, helper) {
        component.set("v.ShowSpinner", true);
        var Data = component.get("v.Data");
        var Changes = [];
        for (var key in Data.Device.Map) {
            if (Data.Device.Map[key].value.Add != 0) Changes.push({
                "Type": "Device",
                "Frequency": Data.Device.Map[key].key,
                "Quantity": Data.Device.Map[key].value.Add
            });
        }
        for (var key in Data) {
            if (key != "Device" && Data[key].Current != Data[key].Now) {
                if (Data[key].Current != "None") {
                    Changes.push({
                        "Type": key,
                        "Frequency": Data[key].Current,
                        "Num": -1
                    });
                }
                if (Data[key].Now != "None") {
                    Changes.push({
                        "Type": key,
                        "Frequency": Data[key].Now,
                        "Num": 1
                    });
                }
            }
        }
        console.log(Changes);
		helper.QuoteCreate(component, Changes);
    },
    HideModal : function(component, event, helper) {
        component.set("v.ShowModal", false);
    },
    IndexP8 : function(component, event, helper) {
        var Index = component.get("v.Index");
        Index += component.get("v.PageSize");
        component.set("v.Index", Index);
	},
    IndexM8 : function(component, event, helper) {
        var Index = component.get("v.Index");
        Index -= component.get("v.PageSize");
        component.set("v.Index", Index);
	},
    handleCancelLicenses : function(component, even, helper){
        console.log('Entered Cancel Licenses modal' + JSON.stringify(component.get("v.serviceData")));
        var serviceDate = component.get("v.serviceData");
        var endDate =serviceDate[0].efEndDate;

        component.set("v.endDate", endDate);
        console.log('End Date is ' + component.get("v.endDate"));
        component.set("v.showCancelLicenseModal", true);
    },
    handleCancelDevNo : function(component, even, helper){
        component.set("v.showCancelLicenseModal", false);
    },
    handleCancelDevYes : function(component, event, helper){
        helper.cancelDevices(component, event, helper);
    },
})