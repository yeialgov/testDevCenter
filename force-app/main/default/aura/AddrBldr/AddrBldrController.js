({
	AddrBldrInit : function(component, event, helper) {
        var PrefixMap = {"BILL" : "Billing", "SHIP" : "Shipping", "VENUE" : "Venue"};
        var SuffixMap = {"BILL" : "", "SHIP" : "", "VENUE" : "__c"};
        var Account = component.get("v.Account");
        console.log(JSON.stringify(Account));
        var Type = component.get("v.Type");
        var Prefix = PrefixMap[Type];
        var Suffix = SuffixMap[Type];
        try {
            component.set("v.MailingStreet", Account[Prefix + "Street" + Suffix].replace("\r\n","<br/>"));
        }catch(err){}
        try {
            component.set("v.MailingStreet_raw", Account[Prefix + "Street" + Suffix]);
        }catch(err){}
        try {
            component.set("v.MailingPostalCode", Account[Prefix + "PostalCode" + Suffix]);
        }catch(err){}
        try {
            component.set("v.MailingCity", Account[Prefix + "City" + Suffix]);
        }catch(err){}
        try {
            component.set("v.MailingCountry", Account[Prefix + "Country" + Suffix]);
        }catch(err){}
        try {
            component.set("v.MailingCountryCode", Account[Prefix + "CountryCode" + Suffix]);
        }catch(err){}
        if (Type == "VENUE") {
            component.set("v.BuilderLine1", Account.Name);
        } else {
            var MetadataFields = [
                "Name", "LegalCompanyName__c", "empty", null,
                "SF_BillTo_Contact__r.Name", "SF_BillTo_Contact__r.FirstName", "SF_BillTo_Contact__r.Addressee__c", "SF_BillTo_Contact__r.Attention__c",
                "SF_SoldTo_Contact__r.Name", "SF_SoldTo_Contact__r.FirstName", "SF_SoldTo_Contact__r.Addressee__c", "SF_SoldTo_Contact__r.Attention__c"
            ];
            var AddrBldrMeta;
            var AddrBldrFld = Account.AddressBuilder__c;
            if (Type == "SHIP") AddrBldrFld = Account.AddressBuilder_Shipping__c;
            if (AddrBldrFld == null) {
                AddrBldrFld = "[\"LegalCompanyName__c\",\"SF_BillTo_Contact__r.Name\",\"empty\"]";
                if (Type == "SHIP") AddrBldrFld.replace("BillTo","SoldTo");
            }
            try {
                AddrBldrMeta = JSON.parse(AddrBldrFld);
                for (var x=1; x<=3; x++) {
                    if (MetadataFields.indexOf(AddrBldrMeta[x-1]) >= 0) {
                        if (AddrBldrMeta[x-1] != null) {
                            var FieldParts = AddrBldrMeta[x-1].split(".");
                            if (FieldParts.length == 1) {
                                component.set("v.BuilderLine" + x, Account[FieldParts[0]]); 
                            } else {
                                component.set("v.BuilderLine" + x, Account[FieldParts[0]][FieldParts[1]]); 
                            }
                        } else {
                            component.set("v.BuilderLine" + x, null); 
                        }
                    } else {
                        component.set("v.BuilderLine" + x, AddrBldrMeta[x-1]); 
                    }
                }
            } catch(err) { console.log(err); }
        }
	},
    EditAddr : function(component, event, helper) {
        component.set("v.ShowModal", true);
    },
    Cancel : function(component) {
        component.set("v.ShowModal", false);
    }
})