({
	doInit : function(component, event, helper) {
        if (component.get("v.FirstRun")) {
            component.set("v.FirstRun", false);
            component.set("v.ShowSpinner", true);
            var ErrorMessages = [];
            console.log("debug");
            console.log(component.get("v.recordId"));
            var Opportunity = component.get("v.Opportunity");
            console.log(JSON.stringify(Opportunity));
            // if (Opportunity.OppCategory__c == 'MINI by orderbird') ErrorMessages.push("Cannot quote a MINI opportunity.");
            if (Opportunity.Account.SF_BillTo_Contact__c == null) ErrorMessages.push("Billing Contact is required on the Account.");
            //if (Opportunity.Account.BillingStreet == null) ErrorMessages.push("Billing Street is required on the Account.");
            if (Opportunity.Account.BillingPostalCode == null) ErrorMessages.push("Billing Postal Code is required on the Account.");
            if (Opportunity.Account.BillingCity == null) ErrorMessages.push("Billing City is required on the Account.");
            if (Opportunity.Account.BillingCountry == null) ErrorMessages.push("Billing Country is required on the Account.");
            if (Opportunity.Account.SF_BillTo_Contact__r.Email == null) ErrorMessages.push("Email Address is required on the Billing Contact.");
            if (Opportunity.Account.SF_BillTo_Contact__r.PrimaryLanguage__c == null) ErrorMessages.push("Primary Language is required on the Billing Contact.");
            if (Opportunity.Account.SF_BillTo_Contact__r.FirstName == null) ErrorMessages.push("First Name is required on the Billing Contact.");
            if (Opportunity.Account.SF_BillTo_Contact__r.LastName == null) ErrorMessages.push("Last Name is required on the Billing Contact.");
            if (Opportunity.Account.SF_SoldTo_Contact__c == null) ErrorMessages.push("Shipping Contact is required on the Account.");
            //if (Opportunity.Account.ShippingStreet == null) ErrorMessages.push("Shipping Street is required on the Account.");
            if (Opportunity.Account.ShippingPostalCode == null) ErrorMessages.push("Shipping Postal Code is required on the Account.");
            if (Opportunity.Account.ShippingCity == null) ErrorMessages.push("Shipping City is required on the Account.");
            if (Opportunity.Account.ShippingCountry == null) ErrorMessages.push("Shipping Country is required on the Account.");
            //if (Opportunity.Account.LegalCompanyName__c == null) ErrorMessages.push("Legal Company Name is required on the Account.");
            if (Opportunity.Account.PrimaryLanguage__c == null) ErrorMessages.push("Primary Language is required on the Account.");
            if (Opportunity.Account.Tax_Exempt_Reason__c == null) ErrorMessages.push("Tax Exempt Reason is required on the Account.");
            if (
                Opportunity.Account.Tax_Exempt_Reason__c == "Non Tax Exempt"
                && Opportunity.Account.TaxExemptStatus__c == "Yes"
            ) {
                ErrorMessages.push("Tax Exempt Reason cannot be \"Non Tax Exempt\" for Tax Exempt Account.");
            }
            if (
                Opportunity.Account.Tax_Exempt_Reason__c != "Non Tax Exempt"
                && Opportunity.Account.TaxExemptStatus__c == "No"
            ) {
                ErrorMessages.push("Tax Exempt Reason must be \"Non Tax Exempt\" for Non Tax Exempt Account.");
            }
            if (
                Opportunity.Account.Tax_Exempt_Reason__c == "EU reverse charge mechanism"
                && Opportunity.Account.TaxExemptStatus__c == "Yes"
                && Opportunity.Account.VATNumber__c == null
            ) {
                console.log(JSON.stringify(Opportunity));
                ErrorMessages.push("VAT Number is required when Tax Exempt Reason is \"EU reverse charge mechanism\" for Tax Exempt Account.");
            }
            if (ErrorMessages.length > 0) {
                helper.errors(component, helper, ErrorMessages);
            } else {
                helper.runInit(component, helper);
            }
        }
	},
    EditAccount : function(component) {
        var Opportunity = component.get("v.Opportunity");
    	var EditEvent = $A.get("e.force:editRecord");
        EditEvent.setParams({"recordId" : Opportunity.AccountId});
        EditEvent.fire();
    	$A.get("e.force:closeQuickAction").fire();
    },
    EditBillTo : function(component, helper) {
        var Opportunity = component.get("v.Opportunity");
        var EditEvent = $A.get("e.force:editRecord");
        EditEvent.setParams({"recordId" : Opportunity.Account.SF_BillTo_Contact__c});
        EditEvent.fire();
    	$A.get("e.force:closeQuickAction").fire();
    },
    EditSoldTo : function(component, helper) {
        var Opportunity = component.get("v.Opportunity");
    	var EditEvent = $A.get("e.force:editRecord");
        EditEvent.setParams({"recordId" : Opportunity.Account.SF_SoldTo_Contact__c});
        EditEvent.fire();
    	$A.get("e.force:closeQuickAction").fire();
    }
})