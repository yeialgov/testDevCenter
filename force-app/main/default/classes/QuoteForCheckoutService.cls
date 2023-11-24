/**
 * @author keylight
 */
//@RestResource(urlMapping='/QuoteForCheckout')
global with sharing class QuoteForCheckoutService  {/*

    global class QuoteResponse {
        public Boolean success;
        public QuoteCheckout data;

        public QuoteResponse() {
            this.success = false;
        }

        public QuoteResponse(QuoteCheckout data) {
            this.success = true;
            this.data = data;
        }
    }

    global class QuoteCheckout {
        public zqu__Quote__c quote {get; set;}
        Account account;
        Contact billToContact;
        Contact soldToContact;
        Zuora__PaymentMethod__c paymentMethod;
        List<zqu__QuoteRatePlanCharge__c> charges;
    }

    @HttpGet
    global static QuoteResponse getQuoteForCheckout() {
        String quoteId = RestContext.request.params.get('quoteId');
        List<zqu__Quote__c> quotes = [SELECT Name, zqu__Account__c, zqu__BillToContact__c, zqu__SoldToContact__c, zqu__PaymentMethod__c, zqu__Number__c, First_Payment_Manually__c, zqu__Status__c, zqu__ValidUntil__c, zqu__VAT_ID__c FROM zqu__Quote__c WHERE Id=:quoteId LIMIT 1];
        if (quotes.isEmpty()) return new QuoteResponse();
        zqu__Quote__c quote = quotes[0];
    
        QuoteCheckout quoteCheckout = new QuoteCheckout();
        quoteCheckout.quote = quote;
        quoteCheckout.account = [SELECT Name, LegalCompanyName__c FROM Account WHERE Id=:quote.zqu__Account__c LIMIT 1];
        
        Contact billToContact;
        Contact[] billToContacts = [SELECT FirstName, LastName, MailingStreet, MailingCity, MailingPostalCode, MailingCountry, Email FROM Contact WHERE Id=:quote.zqu__BillToContact__c LIMIT 1];
        if (!billToContacts.isEmpty()) billToContact = billToContacts[0];
        if (billToContact != null && !String.isEmpty(billToContact.MailingStreet)) {
            String[] addresses = billToContact.MailingStreet.split('\\n');
            if (addresses.size() > 1) {
                billToContact.MailingStreet = addresses[0];
                billToContact.OtherStreet = addresses[1];
            }
        }
        quoteCheckout.billToContact = billToContact;

        Contact soldToContact;
        Contact[] soldToContacts = [SELECT FirstName, LastName, MailingStreet, MailingCity, MailingPostalCode, MailingCountry FROM Contact WHERE Id=:quote.zqu__SoldToContact__c LIMIT 1];
        if (!soldToContacts.isEmpty() && soldToContacts[0].Id != billToContacts[0].Id) soldToContact = soldToContacts[0];
        if (soldToContact != null && !String.isEmpty(soldToContact.MailingStreet)) {
            String[] addresses = soldToContact.MailingStreet.split('\\n');
            if (addresses.size() > 1) {
                soldToContact.MailingStreet = addresses[0];
                soldToContact.OtherStreet = addresses[1];
            }
        }
        quoteCheckout.soldToContact = soldToContact;
        
        quoteCheckout.charges = [SELECT zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.zqu__Product__r.Name, zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.zqu__Product__r.ProductType__c, zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.zqu__Product__r.CheckoutCluster__c, zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.Name, Name, Charge_Name_DE__c, Charge_Name_ES__c, Charge_Name_FR__c, zqu__ChargeType__c, zqu__Model__c, zqu__Period__c, zqu__Currency__c, zqu__EffectivePrice__c, zqu__Quantity__c, zqu__TriggerDate__c, zqu__BillingTax__c, zqu__BillingSubtotal__c, zqu__Total__c FROM zqu__QuoteRatePlanCharge__c WHERE zqu__QuoteRatePlan__r.zqu__Quote__c=:quote.Id];
        return new QuoteResponse(quoteCheckout);
    }

    @HttpPut
    global static String updateQuote(String quoteId, String paymentMethodId, Contact billToContact, Contact soldToContact, String companyName, String vatId) {
        List<zqu__Quote__c> quotes = [SELECT Name, zqu__Account__c, zqu__BillToContact__c, zqu__SoldToContact__c, zqu__PaymentMethod__c, zqu__Status__c, zqu__ValidUntil__c, zqu__Number__c, First_Payment_Manually__c FROM zqu__Quote__c WHERE Id=:quoteId LIMIT 1];
        if (quotes.isEmpty()) return '{"success":false}';
        zqu__Quote__c quote = quotes[0];
        if (quote.zqu__ValidUntil__c < Date.today()) return '{"success":false, "code":3000}';
        if (quote.zqu__Status__c != 'New') return '{"success":false, "code":3001}';

        Boolean canBeTaxExempt = true;

        if (quote.zqu__BillToContact__c != null) {
            Contact contact = [SELECT Id FROM Contact WHERE Id =:quote.zqu__BillToContact__c LIMIT 1];
            contact.FirstName = billToContact.FirstName;
            contact.LastName = billToContact.LastName;
            contact.MailingStreet = billToContact.MailingStreet;
            contact.MailingCity = billToContact.MailingCity;
            contact.MailingPostalCode = billToContact.MailingPostalCode;
            contact.MailingCountry = billToContact.MailingCountry;
            contact.Email = billToContact.Email;
            if (!String.isEmpty(billToContact.OtherStreet)) contact.MailingStreet = contact.MailingStreet + '\n' + billToContact.OtherStreet;
            update contact;
        }

        if (quote.zqu__SoldToContact__c != null) {
            Contact contact = [SELECT Id, MailingCountry FROM Contact WHERE Id =:quote.zqu__SoldToContact__c LIMIT 1];
            if (contact.MailingCountry == 'Germany') canBeTaxExempt = false;
            if (quote.zqu__BillToContact__c != quote.zqu__SoldToContact__c) {
                contact.FirstName = soldToContact.FirstName;
                contact.LastName = soldToContact.LastName;
                contact.MailingStreet = soldToContact.MailingStreet;
                contact.MailingCity = soldToContact.MailingCity;
                contact.MailingPostalCode = soldToContact.MailingPostalCode;
                if (!String.isEmpty(soldToContact.OtherStreet)) contact.MailingStreet = contact.MailingStreet + '\n' + soldToContact.OtherStreet;
                update contact;
            }
        }

        Account account = [SELECT Id FROM Account WHERE Id =:quote.zqu__Account__c LIMIT 1];
        account.LegalCompanyName__c = companyName;
        if (vatId != null) {
            account.VATNumber__c = vatId;
            quote.zqu__VAT_ID__c = vatId;
            if (canBeTaxExempt) {
                account.taxExempted__c = true;
                quote.zqu__Tax_Exempt__c = 'Yes';
            }
        }
        update account;

        if (paymentMethodId != null && !quote.First_Payment_Manually__c) {
            quote.zqu__ElectronicPaymentMethodId__c = paymentMethodId;
        }
        quote.zqu__InvoiceDate__c = date.today();
        update quote;

        return '{"success":true}';
    }

    @HttpPost
    global static String checkoutQuote(String quoteId, String paymentMethodId) {
        List<zqu__Quote__c> quotes = [SELECT Name, zqu__Account__c, zqu__BillToContact__c, zqu__SoldToContact__c, zqu__PaymentMethod__c, zqu__Status__c, zqu__ValidUntil__c, zqu__Number__c, First_Payment_Manually__c FROM zqu__Quote__c WHERE Id=:quoteId LIMIT 1];
        if (quotes.isEmpty()) return '{"success":false}';
        zqu__Quote__c quote = quotes[0];
        if (quote.zqu__ValidUntil__c < Date.today()) return '{"success":false, "code":3000}';
        if (quote.zqu__Status__c != 'New') return '{"success":false, "code":3001}';

        List<zqu.zQuoteUtil.ZBillingQuoteCollection> quoteCollections = new List<zqu.zQuoteUtil.ZBillingQuoteCollection>();
        zqu.zQuoteUtil.ZBillingQuoteCollection quoteCollection = new zqu.zQuoteUtil.ZBillingQuoteCollection();
        quoteCollection.sfdcAccountId = quote.zqu__Account__c;
        quoteCollection.zAccountId = 'new'; // Zuora Billing Account ID
        quoteCollection.quoteRequests = new List<zqu.zQuoteUtil.ZBillingQuoteRequest>();
        zqu.zQuoteUtil.ZBillingQuoteRequest zBillingRequest = new zqu.zQuoteUtil.ZBillingQuoteRequest();
        zBillingRequest.sfdcQuoteId = quoteId;
        if (paymentMethodId != null) {
            zBillingRequest.paymentMethodId = paymentMethodId;
            zBillingRequest.setNewPaymentAsDefault = true;
        }
        zBillingRequest.enableAccountAutoPay = !quote.First_Payment_Manually__c;

        quoteCollection.quoteRequests.add(zBillingRequest);
        quoteCollections.add(quoteCollection);
 
        List<zqu.zQuoteUtil.zBillingResult> results = zqu.zQuoteUtil.sendToZBilling(quoteCollections);
        zqu.zQuoteUtil.zBillingResult billingResult = results[0];
        System.debug(results);
        return '{"success":' + billingResult.success + ', "message": "' + billingResult.message + '"}';
    }*/
}