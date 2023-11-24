({
    handleRecordUpdated : function(component, event, helper) {
    },
    getSaveCallback : function(component, event, helper) {
    },
    ShowForm : function(component, event, helper) {
        component.set("v.Display", true);
    },
    FieldChange : function(component, event, helper) {
        component.find("reForm").submit();
    },
    refSuccess : function(component, event, helper) {
        component.find("recordHandler2").reloadRecord({"skipCache":"true"});
    },
    handleCDLoad : function(component, event, helper) {
        alert("loaded!");
    },
    // Registration_certificate__c
    // Registration_certificate_chk__c
    // Registration Certificate
    handleUploadFinished : function(component, event, helper) {
        helper.doUploadFinished(component, event, helper, 'Registration_certificate__c');
    },
    RegistrationCertificateClick : function(component, event, helper) {
        if (helper.ConfirmPermission()) {
            helper.setAuditField(component, 'Registration_certificate_chk__c');
        } else {
        	helper.doDelete(component, helper, 'Registration_certificate__c', 'Registration_certificate_chk__c', 'Registration Certificate', false);
        }
    },
    RegistrationCertificateDelete : function(component, event, helper) {
        helper.doDelete(component, helper, 'Registration_certificate__c', 'Registration_certificate_chk__c', 'Registration Certificate', true);
    },
    // Instalment_Contract__c
    // Instalment_Contract_chk__c
    // Instalment Contract
    handleInstalmentContractUploadFinished : function(component, event, helper) {
        helper.doUploadFinished(component, event, helper, 'Instalment_Contract__c');
    },
    InstalmentContractClick : function(component, event, helper) {
        if (helper.ConfirmPermission()) {
            helper.setAuditField(component, 'Instalment_Contract_chk__c');
        } else {
        	helper.doDelete(component, helper, 'Instalment_Contract__c', 'Instalment_Contract_chk__c', 'Instalment Contract', false);
        }
    },
    InstalmentContractDelete : function(component, event, helper) {
        helper.doDelete(component, helper, 'Instalment_Contract__c', 'Instalment_Contract_chk__c', 'Instalment Contract', true);
    },
    // Credit_Check__c
    // Credit_Check_chk__c
    // Credit Check
    handleCreditCheckUploadFinished : function(component, event, helper) {
        helper.doUploadFinished(component, event, helper, 'Credit_Check__c');
    },
    CreditCheckClick : function(component, event, helper) {
        if (helper.ConfirmPermission()) {
            helper.setAuditField(component, 'Credit_Check_chk__c');
        } else {
        	helper.doDelete(component, helper, 'Credit_Check__c', 'Credit_Check_chk__c', 'Credit Check', false);
        }
    },
    CreditCheckDelete : function(component, event, helper) {
        helper.doDelete(component, helper, 'Credit_Check__c', 'Credit_Check_chk__c', 'Credit Check', true);
    },
    // Id_Card__c
    // Id_Card_chk__c
    // Id Card
    handleIdCardUploadFinished : function(component, event, helper) {
        helper.doUploadFinished(component, event, helper, 'Id_Card__c');
    },
    IdCardClick : function(component, event, helper) {
        if (helper.ConfirmPermission()) {
            helper.setAuditField(component, 'Id_Card_chk__c');
        } else {
        	helper.doDelete(component, helper, 'Id_Card__c', 'Id_Card_chk__c', 'Id Card', false);
        }
    },
    IdCardDelete : function(component, event, helper) {
        helper.doDelete(component, helper, 'Id_Card__c', 'Id_Card_chk__c', 'Id Card', true);
    },
    // SEPA_Mandate__c
    // SEPA_Mandate_chk__c
    // SEPA Mandate
    handleSEPAMandateUploadFinished : function(component, event, helper) {
        helper.doUploadFinished(component, event, helper, 'SEPA_Mandate__c');
    },
    SEPAMandateClick : function(component, event, helper) {
        if (helper.ConfirmPermission()) {
            helper.setAuditField(component, 'SEPA_Mandate_chk__c');
        } else {
        	helper.doDelete(component, helper, 'SEPA_Mandate__c', 'SEPA_Mandate_chk__c', 'SEPA Mandate', false);
        }
    },
    setSEPAchk : function(component, event, helper) {
        if (helper.ConfirmPermission()) {
            if(confirm("Do you want to confirm the SEPA Mandate without a document?")) {
                var Account = component.get("v.Account");
            	Account.SEPA_Mandate_chk__c = $A.get( "$SObjectType.CurrentUser.Id" ) + " | " + new Date().toLocaleString();
                component.set("v.Account", Account);
                component.find("recordHandler2").saveRecord($A.getCallback(function(saveResult) {}));
            }
        }
    },
    SEPAMandateDelete : function(component, event, helper) {
        helper.doDelete(component, helper, 'SEPA_Mandate__c', 'SEPA_Mandate_chk__c', 'SEPA Mandate', true);
    }
})