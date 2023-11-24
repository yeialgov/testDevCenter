({
	initialize : function(component) {
		var ObjectName = component.get("v.sObjectName").replace("__c","");
        console.log(ObjectName);
        if (ObjectName == 'OBInvoice') { component.set("v.ShowSpinner", false); }
        component.set("v.ObjectName", ObjectName);
        component.set("v.CantSend", true);
        component.set("v.EmailText", null);
        component.set("v.EmailSubject", null);
        component.set("v.UnwrappedEmailText", null);
        component.set("v.Attachments", []);
        var action = component.get("c.getContacts");
        action.setParams({
            "RecordId": component.get("v.recordId"),
            "sObjectName": component.get("v.sObjectName")
        });
        action.setCallback(this, function(response){
            console.log("response");
            console.log(action.getReturnValue());
            var Wrapper = JSON.parse(action.getReturnValue());
            if (Wrapper.OWEA.Address == "noreply@orderbird.com") Wrapper.OWEA.Id = null;
            component.set("v.Contacts", Wrapper.Contacts);
            component.set("v.Templates", Wrapper.Templates);
            component.set("v.Invoices", Wrapper.Invoices);
            component.set("v.Quotes", Wrapper.Quotes);
            component.set("v.Files", Wrapper.Files);
            component.set("v.OWEA", Wrapper.OWEA);
            var Perm = Wrapper.InvoicePermission;
            var AccountName;
            var InvoiceNo;
            var InvoiceDate;
            var InvoiceAmount;
            var CurrencyCode;
            if (ObjectName == "Quote") {
                Perm = true;
                AccountName = component.get("v.Quote").Account.Name;
                var Language = component.get("v.Quote").Account.PrimaryLanguage__c;
                if (Language == "French" || Language == "English") component.set("v.Language", Language);
            } else if (ObjectName == "Opportunity") {
                Perm = true;
                AccountName = component.get("v.Opportunity").Account.Name;
                var Language = component.get("v.Opportunity").Account.PrimaryLanguage__c;
                if (Language == "French" || Language == "English") component.set("v.Language", Language);
            } else if (ObjectName != "OBInvoice") {
                var Inv = component.get("v.Invoice");
                AccountName = Inv.Account__r.Name;
                var Language = component.get("v.Invoice").Account__r.PrimaryLanguage__c;
                if (Language == "French" || Language == "English") component.set("v.Language", Language);
                InvoiceNo = Inv.Name;
                var td = new Date(Inv.InvoiceDate__c);
                console.log(td);
                var dd = td.getDate();
                console.log(dd);
                var mm = td.getMonth()+1;
                console.log(mm);
                var yyyy = td.getFullYear();
                console.log(yyyy);
                if(dd<10){
                    dd='0'+dd;
                } 
                if(mm<10){
                    mm='0'+mm;
                } 
                InvoiceDate = dd+'.'+mm+'.'+yyyy;
                console.log(InvoiceDate);
                InvoiceAmount = Inv.Amount__c.toFixed(2);
                CurrencyCode = Inv.CurrencyIsoCode;
            }
            component.set("v.Permission", Perm);
            for (var x=0; x<Wrapper.Templates.length; x++) {
                var Template = Wrapper.Templates[x];
                if (Template.Default__c != null) {
                    component.set("v.EmailText", Template.Message__c
                                  .replace("%%AccountName%%",AccountName)
                                  .replace("%%InvoiceNo%%",InvoiceNo)
                                  .replace("%%InvoiceDate%%",InvoiceDate)
                                  .replace("%%InvoiceAmount%%",InvoiceAmount)
                                  .replace("%%InvoiceCurrencyCode%%",CurrencyCode)
                                 );
                    component.set("v.EmailSubject", Template.Subject__c.replace("%%InvoiceNo%%",InvoiceNo));
                }
            }
            component.set("v.ShowSpinner", false);
        });
        $A.enqueueAction(action);
	}
})