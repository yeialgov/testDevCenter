({
    ConfirmPermission : function() {
        var PermIds = ['0055J0000026xXeQAI', '0051t000004QoKAAA0', '0051t000003K4CFAA0', '00558000002BgHPAA0', '00558000002BgHFAA0', '00558000002KcvEAAS','0055J0000027VRLQA2','0055J0000026xXeQAI'];
        return PermIds.indexOf($A.get( "$SObjectType.CurrentUser.Id" )) > -1
    },
    doUploadFinished : function(component, event, helper, urlField) {
        var uploadedFiles = event.getParam("files");
        var docId = uploadedFiles[0].documentId;
        var Account = component.get("v.Account");
        Account[urlField] = '/' + docId;
        component.set("v.Account", Account);
        component.find("recordHandler2").saveRecord($A.getCallback(function(saveResult) {}));
    },
    setAuditField : function(component, auditField) {
        var Account = component.get("v.Account");
        Account[auditField] = $A.get( "$SObjectType.CurrentUser.Id" ) + " | " + new Date().toLocaleString();
        component.set("v.Account", Account);
        component.find("recordHandler2").saveRecord($A.getCallback(function(saveResult) {}));
    },
    doDelete : function(component, helper, urlField, auditField, label, isFinance) {
        if (helper.ConfirmPermission() || !isFinance) {
            if(confirm("Do you want to delete the " + label + "?")) {
                var Account = component.get("v.Account");
                var Quote = component.get("v.Quote");
                var CDId = Account[urlField].replace("/","");
                component.set("v.CDId", CDId);
                Account[urlField] = null;
                Account[auditField] = null;
                if (isFinance) {
                    var EmailAlert = prompt("Optional comments to email");
                    if (EmailAlert != null) {
                        if (EmailAlert.length > 1) {
                            Quote.Email_Alert__c = label + ": " + EmailAlert;
                        }
                    }
                    component.set("v.Quote", Quote);
                    component.find("recordHandlerQ").saveRecord($A.getCallback(function(saveResult) {
                        component.set("v.Account", Account);
                        component.find("recordHandler2").saveRecord($A.getCallback(function(saveResult) {
                            component.find("recordHandlerCD").reloadRecord(true, $A.getCallback(function() {
                                component.find("recordHandlerCD").deleteRecord($A.getCallback(function(deleteResult) {
                                    alert(label + " successfully deleted.");
                                }));                
                            }));
                        }));
                    }));
                } else {
                    component.set("v.Account", Account);
                    component.find("recordHandler2").saveRecord($A.getCallback(function(saveResult) {
                        component.find("recordHandlerCD").reloadRecord(true, $A.getCallback(function() {
                            component.find("recordHandlerCD").deleteRecord($A.getCallback(function(deleteResult) {
                                alert(label + " successfully deleted.");
                            }));                
                        }));
                    }));
                }
            }
        } else {
            alert("You don't have permission to delete this document.");
        }
    }
})