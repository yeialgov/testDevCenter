({
    doInit : function(component, event, helper) {
        var Account = component.get("v.Account");
        var Cockpit = {};
        var Lines = [];
        Cockpit["Name"] = Account.Name.toLowerCase();
        if (Account.Subscription_Count__c == 0) {
            Cockpit["Status"] = Account.RecordType.Name + " Prospect";    
            Lines.push(Account.Age__c + '-day old Account');
            Lines.push('Comes from ' + Account.LeadSource__c);
        } else {
            Cockpit["Status"] = "Active Customer";
            Lines.push('What info would be useful here?');
            Lines.push('Invoicing? Subscription? Support? Other?');
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