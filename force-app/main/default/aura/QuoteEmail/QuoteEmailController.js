({
    doInit : function(component, event, helper) {
        helper.initialize(component);
    },
    toggleOBRecip: function(component, event, helper) {
        var CantSend = component.get("v.CantSend");
        component.set("v.CantSend", !CantSend);
    },
    checkAllBoxes : function(component, event, helper) {
        var CheckStatus = event.getSource().get("v.value");
        var Invoices = component.get("v.Invoices");
        for (var x=0; x<Invoices.length; x++) {
            Invoices[x].Checked = CheckStatus;
        }
        component.set("v.Invoices", Invoices);
    },
    checkAllQuoteBoxes : function(component, event, helper) {
        var CheckStatus = event.getSource().get("v.value");
        var Quotes = component.get("v.Quotes");
        for (var x=0; x<Quotes.length; x++) {
            Quotes[x].Checked = CheckStatus;
        }
        component.set("v.Quotes", Quotes);
    },
    toggleNotify : function(component) {
      	component.set("v.Notify", !component.get("v.Notify"));  
    },
    ContactClick : function(component, event, helper) {
        var Contacts = component.get("v.Contacts");
        var NothingSelected = true;
        for (var x=0; x<Contacts.length; x++) {
            if (Contacts[x].Id == event.getParams().Id) {
                Contacts[x]["Selected"] = event.getParams().Add;
                Contacts[x]["SelectedSec"] = event.getParams().Sec;
            }
            if (Contacts[x].Selected == true) NothingSelected = false;
        }
        component.set("v.Contacts", Contacts);
        component.set("v.CantSend", NothingSelected);
    },
    BCCClick : function(component, event, helper) {
        component.set("v.BCCMe", event.getParams().BCCMe);
    },
    ChooseInvoices : function(component, event, helper) {
        component.set("v.EmailSubject", "");
        component.set("v.EmailText", "");
        if (component.get("v.Language") == "German") {
            component.set("v.EmailSubject", "orderbird AG – Deine Rechnungen liegen bereit");
            component.set("v.EmailText", "<p>Hallo %%@FirstName%%,</p><p>schön, dass Du Dich meldest!</p><p>Wie gewünscht übersende ich Dir Deine Rechnungen für die von Dir gewünschten Zeiträume.</p><p>Falls Du noch Fragen oder Anregungen hast, freue ich mich, von Dir zu hören. Ich würde mich außerdem sehr über eine positive Bewertung von Dir freuen. Dafür bekommst Du im Laufe des Tages eine Bewertungsmail in Dein Postfach.</p><p>Vielen Dank und liebe Grüße aus Berlin</p><p>%%#FirstName%% von orderbird</p>");
        }
        component.set("v.ShowInvoices", true);
    },
    ChooseQuotes : function(component, event, helper) {
        component.set("v.ShowQuotes", true);
    },
    SendMultiEmail : function(component, event, helper) {
        component.set("v.ShowSpinner", true);
        var Invoices = component.get("v.Invoices");
        var Quotes = component.get("v.Quotes");
        var CheckedInvoiceIds = [];
        for (var x=0; x<Invoices.length; x++) {
            if (Invoices[x].Checked) CheckedInvoiceIds.push(Invoices[x].Id);
        }
        for (var x=0; x<Quotes.length; x++) {
            if (Quotes[x].Checked) CheckedInvoiceIds.push(Quotes[x].Id);
        }
        if (CheckedInvoiceIds.length==0) {
            alert('Please select at least one ' + component.get("v.ObjectName"));
            component.set("v.ShowSpinner", false);
        } else {
            var Contacts = component.get("v.Contacts");
            var Selected = [];
            var CCs = [];
            for (var x=0; x<Contacts.length; x++) {
                if (Contacts[x]["Selected"] == true) {
                    Selected.push(Contacts[x].Id);
                    if (Contacts[x]["SelectedSec"] == true) CCs.push(Contacts[x].Secondary_Email__c);
                }
            }
            var action = component.get("c.sendEmail");
            action.setParams({
                "RelatedToId": JSON.stringify(CheckedInvoiceIds),
                "WhoIdsString": JSON.stringify(Selected),
                "CCsString": JSON.stringify(CCs),
                "EmailSubject": component.get("v.EmailSubject"),
                "EmailText": component.get("v.EmailText"),
                "Attachments": "[]",
                "OWEAId": component.get("v.OWEA").Id,
                "Language": component.get("v.Language"),
                "OpenNotify": false,
                "BCCMe": component.get("v.BCCMe")
            });
            action.setCallback(this, function(response){
                $A.get('e.force:refreshView').fire();
		        component.set("v.ShowInvoices", false);
		        component.set("v.ShowQuotes", false);
                helper.initialize(component);
                component.set("v.ShowSpinner", false);
            });
            $A.enqueueAction(action);
        }
    },
    SendEmail : function(component, event, helper) {
        component.set("v.ShowSpinner", true);
        var Attachments = component.get("v.Attachments");
        var Contacts = component.get("v.Contacts");
        console.log(JSON.stringify(Contacts));
        var AttachmentList = [];
        var Selected = [];
        var CCs = [];
        for (var x=0; x<Contacts.length; x++) {
            if (Contacts[x]["Selected"] == true) {
                Selected.push(Contacts[x].Id);
                if (Contacts[x]["SelectedSec"] == true) CCs.push({"ContactId":Contacts[x].Id,"CCEmail":Contacts[x].Secondary_Email__c});
            }
        }
        for (var x=0; x<Attachments.length; x++) {
            AttachmentList.push(Attachments[x].ContentDocumentId);
        }
        var EmailText = component.get("v.EmailText");
        if (component.get("v.Unwrapped")) EmailText = component.get("v.UnwrappedEmailText").replace("<!--%%REPLACE%%-->",EmailText) + "<!--%%UNWRAPPED%%-->";
        var action = component.get("c.sendEmail");
        if (component.get("v.sObjectName") == "OBInvoice__c") { 
            CCs.push({"ContactId":null,"CCEmail":component.get("v.OBInvoice").Email__c});
            Selected.push(null);
        }
        action.setParams({
            "RelatedToId": component.get("v.recordId"),
            "WhoIdsString": JSON.stringify(Selected),
            "CCsString": JSON.stringify(CCs),
            "EmailSubject": component.get("v.EmailSubject"),
            "EmailText": EmailText,
            "Attachments": JSON.stringify(AttachmentList),
            "OWEAId": component.get("v.OWEA").Id,
            "Language": component.get("v.Language"),
            "OpenNotify": component.get("v.Notify"),
            "BCCMe": component.get("v.BCCMe")
        });
        console.log(component.get("v.OWEA").Id);
        action.setCallback(this, function(response){
            console.log(action.getReturnValue());
            $A.get('e.force:refreshView').fire();
            helper.initialize(component);
            component.set("v.ShowSpinner", false);
        });
        $A.enqueueAction(action);
    },
    Settings : function(component, event, helper) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:SendTemplatePickerPage",
            componentAttributes: {
                sObjectName : component.get("v.ObjectName"),
                sObjectId : component.get("v.recordId")
            }
        });
        evt.fire();
    },
    handleMenuSelect : function(component, event, helper) {
        component.set("v.EmailText",event.getParam("value").Message__c);
        component.set("v.UnwrappedEmailText",event.getParam("value").Unwrapped_Message__c);
        component.set("v.EmailSubject",event.getParam("value").Subject__c);
        component.set("v.Unwrapped",event.getParam("value").Unwrapped_Div__c);
    },
    handleAttachSelect : function(component, event, helper) {
        var NewAttach = event.getParam("value");
        var Attachments = component.get("v.Attachments");
        var Files = component.get("v.Files");
        for (var x=Files.length-1; x>-1; x--) {
            if (NewAttach.ContentDocumentId == Files[x].ContentDocumentId) {
                Files.splice(x,1);
            }
        }
        Attachments.push(NewAttach);
        component.set("v.Attachments", Attachments);
        component.set("v.Files", Files);
    },
    RemoveAttachment : function(component, event, helper) {
        var AttachIndex = event.getSource().get("v.class");
        var Attachments = component.get("v.Attachments");
        var Files = component.get("v.Files");
        Files.push(Attachments[AttachIndex]);
        Attachments.splice(AttachIndex,1);
        component.set("v.Attachments", Attachments);
        component.set("v.Files", Files);
    }
})