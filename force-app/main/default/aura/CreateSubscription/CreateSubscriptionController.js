({
    doInit : function(component, event, helper) {
        if (component.get("v.FirstRun")) {
            component.set("v.FirstRun", false);
            component.set("v.ShowSpinner", true);
            var ErrorMessages = [];
            var Quote = component.get("v.Quote");
            console.log(JSON.stringify(Quote));
            if (Quote.Account.SF_BillTo_Contact__c == null) ErrorMessages.push("Billing Contact is required on the Account.");
            if (Quote.Account.BillingStreet == null) ErrorMessages.push("Billing Street is required on the Account.");
            if (Quote.Account.BillingPostalCode == null) ErrorMessages.push("Billing Postal Code is required on the Account.");
            if (Quote.Account.BillingCity == null) ErrorMessages.push("Billing City is required on the Account.");
            if (Quote.Account.BillingCountry == null) ErrorMessages.push("Billing Country is required on the Account.");
            if (Quote.Account.SF_BillTo_Contact__r.Email == null) ErrorMessages.push("Email Address is required on the Billing Contact.");
            //if (Quote.Account.SF_BillTo_Contact__r.PrimaryLanguage__c == null) ErrorMessages.push("Primary Language is required on the Billing Contact.");
            if (Quote.Account.SF_BillTo_Contact__r.FirstName == null) ErrorMessages.push("First Name is required on the Billing Contact.");
            if (Quote.Account.SF_BillTo_Contact__r.LastName == null) ErrorMessages.push("Last Name is required on the Billing Contact.");
            if (Quote.Account.SF_SoldTo_Contact__c == null) ErrorMessages.push("Shipping Contact is required on the Account.");
            if (Quote.Account.ShippingStreet == null) ErrorMessages.push("Shipping Street is required on the Account.");
            if (Quote.Account.ShippingPostalCode == null) ErrorMessages.push("Shipping Postal Code is required on the Account.");
            if (Quote.Account.ShippingCity == null) ErrorMessages.push("Shipping City is required on the Account.");
            if (Quote.Account.ShippingCountry == null) ErrorMessages.push("Shipping Country is required on the Account.");
            //if (Quote.Account.SF_Venue_Contact__c == null) ErrorMessages.push("Venue Contact is required on the Account.");
            if (Quote.Account.LegalCompanyName__c == null) ErrorMessages.push("Legal Company Name is required on the Account.");
            if (Quote.Account.PrimaryLanguage__c == null) ErrorMessages.push("Primary Language is required on the Account.");
            if (Quote.Account.Tax_Exempt_Reason__c == null) ErrorMessages.push("Tax Exempt Reason is required on the Account.");
            if (Quote.Account.Legal_Entity_Type__c == null && Quote.Account.ZuoraId__c == null && Quote.Account.BillingCountry != "France") ErrorMessages.push("Legal Entity Type is required on the Account.");
            if (
                Quote.Opportunity.ExistingCardTerminal__c == null 
                && Quote.Account.ZuoraId__c == null
            ) {
                ErrorMessages.push("Existing Card Terminal is required on the Opportunity.");
            }
            if (
                Quote.Opportunity.METROOpportunityID__c != null
                && Quote.Opportunity.MSOP__c == null
            ) {
                ErrorMessages.push("MSOP is required on the Opportunity.");
            }
            if (
                Quote.Opportunity.LAC_ID__c == null
                && Quote.Opportunity.LAC_Shorthand__c == null
                && Quote.Account.ZuoraId__c == null
            ) {
                ErrorMessages.push("LAC Id or Shorthand is required on the Opportunity.");
            }
            if (
                Quote.Opportunity.NewOpening__c == "Yes"
                && Quote.Opportunity.OpeningDateNewVenue__c == null
                && Quote.Account.ZuoraId__c == null
            ) {
                ErrorMessages.push("Opening Date New Venue is required on the Opportunity.");
            }
            if (
                Quote.Account.Tax_Exempt_Reason__c == "EU reverse charge mechanism"
                && Quote.Account.VATNumber__c == null
                && Quote.Account.ZuoraId__c == null
            ) {
                ErrorMessages.push("VAT Number is required when Tax Exempt Reason is \"EU reverse charge mechanism\" for Tax Exempt Account.");
            }
            if (
                Quote.Account.Tax_Exempt_Reason__c == "Non Tax Exempt"
                && !["Germany","France","Austria","Netherlands","Luxembourg","Spain"].includes(Quote.Account.BillingCountry)  
                && Quote.Account.ZuoraId__c == null
            ) {
                ErrorMessages.push("Coustomers from that Billing Country are not allowed to be \"Non Tax Exempt\" as value for Tax Exempt Reason.");
            }
            if (
                Quote.Opportunity.NewBusiness__c && Quote.Account.BillingCountry == "Germany" && !Quote.WireFirstPayment__c && Quote.PaymentMethod__c == "Bank Transfer" && (
                    Quote.Account.Registration_certificate__c == null || Quote.Account.SEPA_Mandate__c == null
                )
            ) {
                ErrorMessages.push("Required documents must be uploaded before quote acceptance for customers not wiring their first payment.");
            }
            if (
                component.get("v.NeedsBambora")
                && Quote.Account.ZuoraId__c == null
                && (
                    Quote.Account.Name_of_official_authorized_signatory__c == null
                    || Quote.Account.E_Mail_of_official_authorized_signatory__c == null
                    || Quote.Account.Phone_of_official_authorized_signatory__c == null
                    || Quote.Account.Payment_Provider__c == null
                    || (
                        Quote.Account.Registration_number__c == null
                        && Quote.Account.VAT_number_USt_ID__c == null
                        && Quote.Account.Registration_certificate__c == null
                    )
                )
            ) {
                ErrorMessages.push("Bambora field requirements are not met.");
            }
            if (ErrorMessages.length > 0) {
                helper.errors(component, helper, ErrorMessages);
            } else {
                //helper.create(component, helper);
                component.set("v.ShowSpinner", false);
                component.set("v.ShowConfirmation", true);
            }
        }
    },
    creator : function(component, event, helper) {
        component.set("v.ShowSpinner", true);
        helper.create(component, helper);
    },
    closeOut : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    wfpYes : function(component, event, helper) {
        component.set("v.ShowSpinner", true);
        helper.wfpChange(component, true);
    },
    wfpNo : function(component, event, helper) {
        component.set("v.ShowSpinner", true);
        helper.wfpChange(component, false);
    },
    EditAccount : function(component) {
        var Quote = component.get("v.Quote");
        var EditEvent = $A.get("e.force:editRecord");
        EditEvent.setParams({"recordId" : Quote.AccountId});
        EditEvent.fire();
        $A.get("e.force:closeQuickAction").fire();
    },
    EditOpportunity : function(component) {
        var Quote = component.get("v.Quote");
        var EditEvent = $A.get("e.force:editRecord");
        EditEvent.setParams({"recordId" : Quote.OpportunityId});
        EditEvent.fire();
        $A.get("e.force:closeQuickAction").fire();
    }
})