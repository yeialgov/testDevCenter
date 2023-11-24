({
    handleUploadFinished : function(component, event, helper) {
        var uploadedFiles = event.getParam("files");
        var docId = uploadedFiles[0].documentId;
        var Account = component.get("v.Account");
        Account.Registration_certificate__c = '/' + docId;
        component.set("v.Account", Account);
        component.find("recordHandler2").saveRecord();
    },
    ShowForm : function(component) {
        component.set("v.Display", true);
    },
    FieldChange : function(component) {
        component.find("reForm").submit();
    },
    refSuccess : function(component) {
        component.find("recordHandler2").reloadRecord({"skipCache":"true"});
    }
})