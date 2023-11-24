({
    initialize : function(component) {
        var ObjectName = component.get("v.sObjectName").replace("__c","");
        var Case = component.get("v.Case");
        if (Case.AccountId != null) {
            var WhereCondition = [ObjectName, Case.Account.PrimaryLanguage__c];
            component.set("v.WhereCondition", WhereCondition);
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
                for (var x=0; x<Wrapper.Contacts.length; x++) {
                    //Wrapper.Contacts[x].Selected = Case.ContactId == Wrapper.Contacts[x].Id;
                    if (Wrapper.Contacts[x].Id == Case.Account.Primary_Contact__c) Wrapper.Contacts[x].Name += ' [P]';
                    if (Wrapper.Contacts[x].Id == Case.Account.SF_BillTo_Contact__c) Wrapper.Contacts[x].Name += ' [B]';
                    if (Wrapper.Contacts[x].Id == Case.Account.SF_SoldTo_Contact__c) Wrapper.Contacts[x].Name += ' [S]';
                }
                component.set("v.Contacts", Wrapper.Contacts);
                component.set("v.Templates", Wrapper.Templates);
                component.set("v.TemplateFolders", Wrapper.TemplateFolders);
                component.set("v.Invoices", Wrapper.Invoices);
                component.set("v.Files", Wrapper.Files);
                component.set("v.OWEA", Wrapper.OWEA);
                component.set("v.ReplyThread", Wrapper.EmailMessage)
                /*if (Wrapper.EmailMessage.length > 0) {
                    component.set("v.EmailText", "<br/><br/><br/>----Original Message----<br/>"+Wrapper.EmailMessage[0].HtmlBody);
                    component.set("v.EmailSubject", "re: " + Wrapper.EmailMessage[0].Subject);
                }*/
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
                /*} else if (ObjectName == "Opportunity") {
                    Perm = true;
                    AccountName = component.get("v.Opportunity").Account.Name;
                    var Language = component.get("v.Opportunity").Account.PrimaryLanguage__c;
                    if (Language == "French" || Language == "English") component.set("v.Language", Language);
                */} else if (ObjectName == "Case" || ObjectName == "Opportunity") {
                    Perm = true;
                    AccountName = component.get("v.Case").Account.Name;
                    var Language = component.get("v.Case").Account.PrimaryLanguage__c;
                    if (Language == "French" || Language == "English") component.set("v.Language", Language);
                } else {
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
    },
    chooseTemplate : function(component, TemplateId) {
        var Template;
        var Templates = component.get("v.Templates");
        var x=0;
        while (Template == null && x < Templates.length) {
            if (Templates[x].Id == TemplateId) Template = Templates[x];
            x++;
        }
        var Message = Template.Message__c;
        var ReplyThread = component.get("v.ReplyThread");
        if (component.get("v.InclReplyThread") && ReplyThread.length > 0) Message = Message + "<br/><br/><br/>----Original Message----<br/>" + ReplyThread[0].HtmlBody;
        component.set("v.EmailText",Message);
        component.set("v.UnwrappedEmailText",Template.Unwrapped_Message__c);
        component.set("v.EmailSubject",Template.Subject__c);
        component.set("v.Unwrapped",Template.Unwrapped_Div__c);
        component.set("v.TemplateName",Template.Name);
        component.set("v.ShowTemplates",false);
    }
})