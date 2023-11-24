({
    doInit : function(component, event, helper) {
        var Account = component.get("v.Account");
        var Cockpit = {};
        var Lines = [];
        Cockpit["Name"] = Account.Name.toLowerCase();
        if (Account.Subscription_Count__c == 0) {
            Cockpit["Status"] = Account.RecordType.Name + " Prospect";    
        } else {
            Cockpit["Status"] = "Active Customer";
        }
        Cockpit["Lines"] = Lines;
        component.set("v.Cockpit", Cockpit);
    },
    HealthClick : function(component, event, helper) {
		component.set("v.closeModalOpen", !component.get("v.closeModalOpen"));
	},
    reloadRL3 : function(component, event, helper) {
        component.find('recordLoader3').reloadRecord(true) 
    }
})