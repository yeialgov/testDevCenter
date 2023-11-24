({
    doInit: function(component, event, helper){
        var fields = ["Name", "LegalCompanyName__c"];
        var btFields = ["Name", "Addressee__c", "Attention__c"];
        var options = [];
        var ContactField = "SF_BillTo_Contact__r";
        var BuilderField = component.get("v.AddressType");
        if (BuilderField == "Shipping") ContactField = "SF_SoldTo_Contact__r";
        if (BuilderField == "Venue") ContactField = "SF_Venue_Contact__r";
        var Account = component.get("v.Account");
        try {
            component.set("v.MailingStreet", Account[ContactField].MailingStreet.replace("\r\n","<br/>"));
        }catch(err){}
        try {
            component.set("v.MailingStreet_raw", Account[ContactField].MailingStreet);
        }catch(err){}
        try {
            component.set("v.MailingPostalCode", Account[ContactField].MailingPostalCode);
        }catch(err){}
        try {
            component.set("v.MailingCity", Account[ContactField].MailingCity);
        }catch(err){}
        try {
            component.set("v.MailingCountry", Account[ContactField].MailingCountry);
        }catch(err){}
        try {
            component.set("v.MailingCountryCode", Account[ContactField].MailingCountryCode);
        }catch(err){}
        var action = component.get("c.getAddressBuilder");
        action.setParams({
            "AccountId": component.get("v.recordId"),
            "AddressType": BuilderField
        });
        action.setCallback(this, function(response){
            var AddressBuilderStr = action.getReturnValue();
            for (var x=0; x<fields.length; x++) {
                if (Account[fields[x]] != null) options.push({"Label":Account[fields[x]],"Text":fields[x]});
            }
            try {
                for (var x=0; x<btFields.length; x++) {
                    if (Account[ContactField][btFields[x]] != null) {
                        if (Account[ContactField][btFields[x]].indexOf("[not provided]") < 0) {
                            options.push({"Label":Account[ContactField][btFields[x]],"Text":ContactField+"."+btFields[x]});
                        }
                    }
                }
            }catch(error){}
            options.push({"Label":" ","Text":"empty"});
            var AddressBuilder = ["empty","empty","empty"];
            try{
                if (Account[ContactField] != null) {
                    if (AddressBuilderStr == null) {
                        if (Account[ContactField].FirstName == "[not provided]") {
                            AddressBuilder = [ContactField+".Addressee__c",ContactField+".Attention__c","empty"];
                        } else {
                            AddressBuilder = ["LegalCompanyName__c",ContactField+".Name","empty"];
                        }
                    } else {
                        AddressBuilder = JSON.parse(AddressBuilderStr);
                    }
                }
            }catch(error){}
            component.set("v.Options", options);
            component.set("v.Selections", AddressBuilder);
            component.set("v.ShowSpinner", false);
        });
        $A.enqueueAction(action);
    },
    changed: function(component, event, helper){
        component.set("v.ShowSpinner", true);
        var AddressType = component.get("v.AddressType");
        var Line1 = component.find("Line1").get("v.value");
        var Line2 = component.find("Line2").get("v.value");
        var Line3;
        try {Line3 = component.find("Line3").get("v.value");} catch(err){}
        console.log(Line1);
        console.log(Line2);
        console.log(Line3);
        if (AddressType != "Billing" || Line1 == "LegalCompanyName__c" || Line2 == "LegalCompanyName__c" || Line3 == "LegalCompanyName__c") {
        var action = component.get("c.updateAddressBuilder");
        action.setParams({
            "AccountId": component.get("v.recordId"),
            "AddressType": AddressType,
            "AddressBuilder": JSON.stringify([Line1, Line2, Line3])
        });
        action.setCallback(this, function(response){
            var appEvent = $A.get("e.c:AddressBuilderChange");
            appEvent.fire();
            component.set("v.ShowLCNError", false);
        });
        $A.enqueueAction(action);
        } else {
            component.set("v.ShowLCNError", true);
        }
        component.set("v.ShowSpinner", false);
    }
})