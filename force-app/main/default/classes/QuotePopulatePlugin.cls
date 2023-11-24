/**
 * @author Keylight / refactored by Joern
 */
global class QuotePopulatePlugin {// extends zqu.CreateQuoteController.PopulateDefaultFieldValuePlugin {
/*
    global override void populateDefaultFieldValue(SObject record, zqu.PropertyComponentController.ParentController pcc) {
        if (pcc != null) super.populateDefaultFieldValue(record, pcc);

        Account account = this.getAccount((Id) record.get('zqu__Account__c'));

        this.populateFields(account, record);

        QuoteFieldUpdate quoteFieldUpdate = new QuoteFieldUpdate(account);
        quoteFieldUpdate.updateFields((zqu__Quote__c) record);

        Map<Id, Contact> contacts = quoteFieldUpdate.getContacts();
        Contact billToContact = contacts.get(account.SF_BillTo_Contact__c);
        Contact soldToContact = contacts.get(account.SF_SoldTo_Contact__c);

        String templateKey = quoteFieldUpdate.getTplKey(billToContact);

        zqu__Quote_Template__c quoteTemplate =
                (zqu__Quote_Template__c) quoteFieldUpdate.quoteTemplates.get(templateKey);
        zqu__InvoiceTemplate__c invoiceTemplate =
                (zqu__InvoiceTemplate__c) quoteFieldUpdate.invoiceTemplates.get(templateKey);
        zqu__CommunicationProfile__c communicationProfile =
                (zqu__CommunicationProfile__c) quoteFieldUpdate.communicationProfiles.get(templateKey.split('_').get(0));

        populateBillToContact(super.getLookupOption('zqu__BillToContact__c'), billToContact);
        populateSoldToContact(super.getLookupOption('zqu__SoldToContact__c'), soldToContact);
        populateQuoteTemplate(super.getLookupOption('zqu__QuoteTemplate__c'), quoteTemplate);
        populateCommunicationProfile(super.getLookupOption('zqu__CommunicationProfile__c'), communicationProfile);
        populateInvoiceTemplate(super.getLookupOption('zqu__InvoiceTemplate__c'), invoiceTemplate);

        if (pcc != null) super.setLookupOptions(pcc);
    }

    private Account getAccount(Id accountId) {
        return [
                SELECT Id, SF_BillTo_Contact__c, SF_SoldTo_Contact__c,
                        VATNumber__c, taxExempted__c, PrimaryLanguage__c,
                        CurrencyIsoCode
                FROM Account WHERE Id = :accountId LIMIT 1
        ];
    }

    private void populateFields(Account account, SObject record) {
        record.put('zqu__BillToContact__c', account.SF_BillTo_Contact__c);
        record.put('zqu__SoldToContact__c', account.SF_SoldTo_Contact__c);
        record.put('zqu__ValidUntil__c', date.today().addMonths(1));
        record.put('zqu__StartDate__c', date.today());
        Decimal initialTerm = (Decimal)record.get('zqu__InitialTerm__c');
        Decimal renewalTerm = (Decimal)record.get('zqu__RenewalTerm__c');
        if (initialTerm == null) {
            record.put('zqu__InitialTerm__c', 12);
        }
        if (renewalTerm == null) {
            record.put('zqu__RenewalTerm__c', 12);
        }
    }

    @TestVisible
    private void populateBillToContact(zqu.LookupComponentOptions billToOptions, Contact billToContact) {
        if (billToContact != null && billToContact.Id != null) {
            if (billToOptions == null) {
                billToOptions = new zqu.LookupComponentOptions();
            }
            billToOptions.targetId = billToContact.Id;
            billToOptions.targetName = billToContact.Name;
        }
    }

    @TestVisible
    private void populateSoldToContact(zqu.LookupComponentOptions soldToOptions, Contact soldToContact) {
        if (soldToContact != null && soldToContact.Id != null) {
            if (soldToOptions == null) {
                soldToOptions = new zqu.LookupComponentOptions();
            }
            soldToOptions.targetId = soldToContact.Id;
            soldToOptions.targetName = soldToContact.Name;
        }
    }

    @TestVisible
    private void populateQuoteTemplate(zqu.LookupComponentOptions quoteTemplate, zqu__Quote_Template__c quoteTpl) {
        if (quoteTpl != null) {
            if (quoteTemplate == null) {
                quoteTemplate = new zqu.LookupComponentOptions();
            }
            quoteTemplate.targetId = quoteTpl.Id;
            quoteTemplate.targetName = quoteTpl.Name;

        }
    }

    @TestVisible
    private void populateCommunicationProfile(zqu.LookupComponentOptions communicationProfile, zqu__CommunicationProfile__c comProfile) {
        if (comProfile != null) {
            if (communicationProfile == null) {
                communicationProfile = new zqu.LookupComponentOptions();
            }
            communicationProfile.targetId = comProfile.Id;
            communicationProfile.targetName = comProfile.Name;
        }
    }

    @TestVisible
    private void populateInvoiceTemplate(zqu.LookupComponentOptions invoiceTemplate, zqu__InvoiceTemplate__c invoiceTpl) {
        if (invoiceTpl != null) {
            if (invoiceTemplate == null) {
                invoiceTemplate = new zqu.LookupComponentOptions();
            }
            invoiceTemplate.targetId = invoiceTpl.Id;
            invoiceTemplate.targetName = invoiceTpl.Name;
        }
    }*/
}