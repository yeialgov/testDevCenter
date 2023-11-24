({
    doInit : function(component, event, helper) {
        helper.initialize(component);
    },
    AllLanguages : function(component) {
        component.set("v.ShowSpinner", true);
        var action = component.get("c.getAllTemplates");
        action.setParams({
            "ObjectName": component.get("v.sObjectName")
        });
        action.setCallback(this, function(response){
            console.log(action.getReturnValue());
            component.set("v.Templates", JSON.parse(action.getReturnValue()));
            component.set("v.AllTemplateLanguages", true);
            component.set("v.WhereCondition", [component.get("v.sObjectName"), '7434']);
            component.set("v.ShowSpinner", false);
        });
        $A.enqueueAction(action);
    },
    ToggleTemplate : function(component) {
        var stVar = component.get("v.ShowTemplates");
        component.set("v.ShowTemplates", !stVar);
    },
    lookupSearch : function(component, event) {
        const serverSearchAction = component.get('c.templateSearch');
        component.find('lookup').search(serverSearchAction);
    },
    selTemplate : function(component, event, helper) {
        var TemplateId = component.get("v.selection")[0].id;
        helper.chooseTemplate(component, TemplateId);
    },
    remTemplate : function(component, event) {
        component.set("v.EmailText","");
        component.set("v.UnwrappedEmailText","");
        component.set("v.EmailSubject","");
        component.set("v.Unwrapped",false);
        component.set("v.TemplateName","");
    },
    chooser : function(component, event, helper) {
        var TemplateId = event.currentTarget.id;
        var Templates = component.get("v.Templates");
        var x=0;
        var continuer = true;
        var returnObj = {};
        while (continuer && x < Templates.length) {
            if (Templates[x].Id == TemplateId) {
                continuer = false;
                component.set("v.selection", {"id":TemplateId,"title":Templates[x].Name, "icon":"standard:text_template"});
            }
            x++;
        }
        helper.chooseTemplate(component, TemplateId);
    },
    chooseFolder : function(component, event) {
        component.set("v.TemplateFolder", event.currentTarget.id);
        var TemplateFolders = component.get("v.TemplateFolders");
        var TemplateFolderName;
        var x=0;
        while (TemplateFolderName == null && x < TemplateFolders.length) {
            if (TemplateFolders[x].Id == event.currentTarget.id) TemplateFolderName = TemplateFolders[x].Name;
            x++;
        }
        component.set("v.TemplateFolderName",TemplateFolderName);
    },
    removeFolder : function(component, event) {
        component.set("v.TemplateFolder", null);
    },
    removeRecipient : function(component, event) {
        var Contacts = component.get("v.Contacts");
        for (var x=0; x<Contacts.length; x++) {
            if (Contacts[x].Id == event.getSource().get("v.class")) Contacts[x].Selected = false;
        }
        component.set("v.Contacts", Contacts);
    },
    removeBCC : function(component, event) {
        component.set("v.BCCMe", false);
    },
    removeCC : function(component, event) {
        var CCAddress = event.getSource().get("v.label");
        var CCs = component.get("v.CCs");
        for (var x=CCs.length-1; x>=0; x--) {
            if (CCs[x].Address == CCAddress) CCs.splice(x,1);
        }
        component.set("v.CCs", CCs);
        console.log(JSON.stringify(CCs));
    },
    ShowCC : function(component) {
        component.set("v.ShowCC", true);
        var ToContainer = component.find("ToContainer");
        $A.util.removeClass(ToContainer,"slds-size_5-of-6");
        $A.util.addClass(ToContainer,"slds-size_1-of-1");
    },
    CCBlur : function(component, event) {
        var regExpEmailformat = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
        var input = event.getSource();
        var raw = input.get("v.value");
        raw = raw.replace(" ","");
        raw = raw.replace(",",";");
        var rawList = raw.split(";");
        var CCs = component.get("v.CCs");
        rawList.forEach(function (item, index) {
            var CC = {};
            CC.Address = item;
            CC.Verified = regExpEmailformat.test(item);
            if (item != "" && item != null) CCs.push(CC);
        });
        input.set("v.value", "");
        component.set("v.CCs", CCs);
        console.log(JSON.stringify(CCs));
    },
    CCChange : function(component, event) {
        var regExpEmailformat = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
        var input = event.getSource();
        var raw = input.get("v.value");
        raw = raw.replace(" ","");
        raw = raw.replace(",",";");
        if (raw.indexOf(";") > -1) {
            var rawList = raw.split(";");
            var CCs = component.get("v.CCs");
            for (var x=0; x<rawList.length-1; x++){
                var CC = {};
                CC.Address = rawList[x];
                CC.Verified = regExpEmailformat.test(rawList[x]);
                CCs.push(CC);
            };
            input.set("v.value", "");
            component.set("v.CCs", CCs);
        }
    },
    onChange : function(component) {
        var ContactSelect = component.find("ContactSelect");
        var Contacts = component.get("v.Contacts");
        var IR = false;
        var BM = false;
        if (ContactSelect.get("v.value") == "Internal") IR = true;
        if (ContactSelect.get("v.value") == "BCCMe") BM = true;
        for (var x=0; x<Contacts.length; x++) {
            if (Contacts[x].Id == ContactSelect.get("v.value")) Contacts[x].Selected = true;
            if (IR || BM) Contacts[x].Selected = false;
        }
        if (IR) {
            component.set("v.CCs", []);
            component.set("v.ShowInternalRecipient", true);
        }
        if (BM) {
            component.set("v.BCCMe", true);
        }
        component.set("v.Contacts", Contacts);
        ContactSelect.set("v.value", null);
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
    IRClose : function(component, event, helper) {
        component.set("v.ShowInternalRecipient", false);
        component.set("v.CCs", []);
    },
    ChooseInvoices : function(component, event, helper) {
        component.set("v.EmailSubject", "");
        component.set("v.EmailText", "");
        component.set("v.ShowInvoices", true);
    },
    SendMultiEmail : function(component, event, helper) {
        component.set("v.ShowSpinner", true);
        var Invoices = component.get("v.Invoices");
        var CheckedInvoiceIds = [];
        for (var x=0; x<Invoices.length; x++) {
            if (Invoices[x].Checked) CheckedInvoiceIds.push(Invoices[x].Id);
        }
        if (CheckedInvoiceIds.length==0) {
            alert('Please select at least one Invoice');
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
                helper.initialize(component);
                component.set("v.ShowSpinner", false);
            });
            $A.enqueueAction(action);
        }
    },
    Preview : function(component, event, helper) {
        var Contacts = component.get("v.Contacts");
        var Selected = [];
        for (var x=0; x<Contacts.length; x++) {
            if (Contacts[x]["Selected"] == true) {
                Selected.push(Contacts[x].Id);
            }
        }
        var EmailText = component.get("v.EmailText");
        if (component.get("v.Unwrapped")) EmailText = component.get("v.UnwrappedEmailText").replace("<!--%%REPLACE%%-->",EmailText) + "<!--%%UNWRAPPED%%-->";
        var action = component.get("c.previewEmail");
        action.setParams({
            "RelatedToId": component.get("v.recordId"),
            "WhoIdsString": JSON.stringify(Selected),
            "EmailSubject": component.get("v.EmailSubject"),
            "EmailText": EmailText,
            "Language": component.get("v.Language")
        });
        action.setCallback(this, function(response){
            component.set("v.Preview", JSON.parse(action.getReturnValue()));
            component.set("v.ShowPreview", true);
        });
        $A.enqueueAction(action);
    },
    SendEmail : function(component, event, helper) {
        component.set("v.ShowSpinner", true);
        var Attachments = component.get("v.Attachments");
        var Contacts = component.get("v.Contacts");
        var ShowIR = component.get("v.ShowInternalRecipient");
        var cmpCCs = component.get("v.CCs");
        console.log(JSON.stringify(cmpCCs));
        var AttachmentList = [];
        var Selected = [];
        var CCs = [];
        for (var x=0; x<Contacts.length; x++) {
            if (Contacts[x]["Selected"] == true) {
                Selected.push(Contacts[x].Id);
                for (var y=0; y<cmpCCs.length; y++) {
                    CCs.push({"ContactId":Contacts[x].Id,"CCEmail":cmpCCs[y].Address});
                }
            }
            if (ShowIR) {
                for (var y=0; y<cmpCCs.length; y++) {
                    CCs.push({"ContactId":null,"CCEmail":cmpCCs[y].Address});
                }
            }
        }
        if (Selected.length > 0 || ShowIR) {
            for (var x=0; x<Attachments.length; x++) {
                AttachmentList.push(Attachments[x].ContentDocumentId);
            }
            var EmailText = component.get("v.EmailText");
            if (component.get("v.Unwrapped")) EmailText = component.get("v.UnwrappedEmailText").replace("<!--%%REPLACE%%-->",EmailText) + "<!--%%UNWRAPPED%%-->";
            EmailText = EmailText.replace(/<img/g,"<img style=\"margin:auto;display:block;max-width:100%;\"");
            var action = component.get("c.sendEmail");
            action.setParams({
                "RelatedToId": component.get("v.recordId"),
                "WhoIdsString": ShowIR ? "[null]" : JSON.stringify(Selected),
                "CCsString": JSON.stringify(CCs),
                "EmailSubject": component.get("v.EmailSubject"),
                "EmailText": EmailText,
                "Attachments": JSON.stringify(AttachmentList),
                "OWEA": null,
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
        } else {
            alert("No recipient is selected.");
        	component.set("v.ShowSpinner", false);
        }
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
    ToggleReplyThread : function(component, event, helper) {
        var InclReplyThread = component.get("v.InclReplyThread");
        var ReplyThread = component.get("v.ReplyThread");
        var EmailText = component.get("v.EmailText");
        var EmailSubject = component.get("v.EmailSubject");
        if (InclReplyThread && ReplyThread.length > 0) {
            if (EmailSubject == "") EmailSubject = ReplyThread[0].Subject;
            EmailText = EmailText + "<br/><br/><br/>----Original Message----<br/>" + ReplyThread[0].HtmlBody;
        } else {
            EmailText = EmailText.split("----Original Message----")[0];
            if (EmailSubject.slice(0,3) == "re:") EmailSubject = "";
        }
        component.set("v.EmailSubject", EmailSubject);
        component.set("v.EmailText", EmailText);
    },
    uploadAttachment : function(component, event, helper) {
        var uploadedFiles = event.getParam("files");
        var Attach = {
            ContentDocumentId : uploadedFiles[0].documentId,
            ContentDocument : { Title : uploadedFiles[0].name }
        };
        var Attachments = component.get("v.Attachments");
        Attachments.push(Attach);
        component.set("v.Attachments", Attachments);
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