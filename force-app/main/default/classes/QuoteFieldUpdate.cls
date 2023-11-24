/**
 * @author Keylight / refactored by Joern
 *
 * @group Quote
 *
 * @description should update defined fields on zqu__Quote__c object with values taken from Account or Contacts.
 * Used in QuoteHandler Before Insert / Update trigger and in QuotePopulatePlugin.
 */
public with sharing class QuoteFieldUpdate {

/*
    private zqu__Quote__c quote;
	private Map<Id, Account> accounts;
    private Map<Id, Contact> contacts;

    /**
     * Zuora quote templates key:=LANGUAGE_COUNTRY (from billToContact)
     *
    public Map<String, SObject> quoteTemplates;

    /**
     * Zuora invoice templates key:=LANGUAGE_COUNTRY (from billToContact)
     *
    public Map<String, SObject> invoiceTemplates;

    /**
     * Zuora communication profiles key:=LANGUAGE (from billToContact)
     *
    public Map<String, SObject> communicationProfiles;

    public QuoteFieldUpdate(Map<Id,Account> acc) {
        this.accounts = acc;
        init();
    }

    public QuoteFieldUpdate(Account acc) {
        this.accounts = new Map<Id, Account>();
        this.accounts.put(acc.Id, acc);
        init();
    }

    /**
    * Retrieve and set all related and needed objects
    *
    private void init() {
        this.contacts = this.getContacts();
        this.quoteTemplates = this.getQuoteTemplates();
        this.invoiceTemplates = this.getInvoiceTemplates();
        this.communicationProfiles = this.getCommunicationProfileTemplates();
    }

	public void updateFields(zqu__Quote__c quote) {
        this.quote = quote;
        this.setQuoteDates();
        if (this.accounts.get(this.quote.zqu__Account__c) != null) {
            this.setTaxRelatedFields(this.accounts.get(this.quote.zqu__Account__c));
            this.setZuoraTemplateIds(this.accounts.get(this.quote.zqu__Account__c));
        }
	}

    public Map<Id, Contact> getContacts() {
        if(this.contacts != null) {
            return this.contacts;
        } else {
            Map<Id, Contact> contacts = new Map<Id, Contact>();
            List<Id> contactIds = new List<Id>();
            for (Account acc : this.accounts.values()) {
                if(acc.SF_BillTo_Contact__c != null) {
                    contactIds.add(acc.SF_BillTo_Contact__c);
                }
                if(acc.SF_SoldTo_Contact__c != null) {
                    contactIds.add(acc.SF_SoldTo_Contact__c);
                }
            }
            return new Map<Id, Contact>([
                    SELECT Id, Name, MailingCountry, PrimaryLanguage__c FROM Contact
                    WHERE Id IN :contactIds
            ]);
        }
    }

    private void setQuoteDates() {
        this.quote.zqu__TermStartDate__c = this.quote.zqu__Service_Activation_Date__c;
        this.quote.zqu__InvoiceDate__c = this.quote.zqu__StartDate__c;

        if (this.quote.Invoice_Recurring_at_Start_Date__c) {
            this.quote.zqu__InvoiceTargetDate__c = this.quote.zqu__Service_Activation_Date__c;
        } else {
            this.quote.zqu__InvoiceTargetDate__c = this.quote.zqu__StartDate__c;
        }

        if (this.quote.Months_to_pay_in_advance__c != null && this.quote.Months_to_pay_in_advance__c > 0) {
            this.quote.zqu__InvoiceTargetDate__c = this.quote.zqu__StartDate__c.addMonths((Integer) this.quote.Months_to_pay_in_advance__c);
        }

        if (this.quote.zqu__Service_Activation_Date__c != null) {
            this.quote.zqu__BillCycleDay__c = String.valueOf(this.quote.zqu__Service_Activation_Date__c.day());
        }
        
        if (this.quote.zqu__InvoiceDate__c != null) {
            if (this.quote.zqu__InvoiceDate__c < Date.today()) this.quote.zqu__InvoiceDate__c = Date.today();
        }
        if (this.quote.zqu__InvoiceTargetDate__c != null) {
            if (this.quote.zqu__InvoiceTargetDate__c < Date.today()) this.quote.zqu__InvoiceTargetDate__c = Date.today();
        }

    }

    private void setTaxRelatedFields(Account acc) {
        this.quote.zqu__Currency__c = acc.CurrencyIsoCode;
        this.quote.zqu__VAT_ID__c = acc.VATNumber__c;
        if(acc.taxExempted__c) {
            this.quote.zqu__Tax_Exempt__c = 'Yes';
        } else {
            this.quote.zqu__Tax_Exempt__c = 'No';
        }
    }

    private void setZuoraTemplateIds(Account acc) {
        Id billtoId = acc.SF_BillTo_Contact__c;
        Contact contact = this.contacts.get(billtoId);
        if(contact != null) {
            if(this.quoteTemplates.get(this.getTplKey(contact)) != null)
                this.quote.put('zqu__QuoteTemplate__c',
                    this.quoteTemplates.get(this.getTplKey(contact)).Id);
            if(this.invoiceTemplates.get(this.getTplKey(contact)) != null)
                this.quote.put('zqu__InvoiceTemplate__c',
                    this.invoiceTemplates.get(this.getTplKey(contact)).Id);
            String language = this.getTplKey(contact).split('_').get(0);
            if (this.communicationProfiles.get(language) != null)
                this.quote.put('zqu__CommunicationProfile__c',
                    this.communicationProfiles.get(language).Id);
        }
    }

    /**
     * @description Get template key and return default template if LANGUAGE_COUNTRY combination does not exists
     *
     * @param contact
     *
     * @return
     *
    public String getTplKey(Contact contact) {

        String key = 'German_Germany';

        if (contact != null) {
            key = contact.PrimaryLanguage__c + '_' + contact.MailingCountry;
            if (this.quoteTemplates.get(key) == null) {
                if (contact.MailingCountry == 'Germany') {
                    key = 'German_Germany';
                } else if (contact.MailingCountry == 'Switzerland') {
                    key = 'German_Switzerland';
                } else if (contact.MailingCountry == 'Austria') {
                    key = 'German_Austria';
                } else if (contact.MailingCountry == 'France') {
                    key = 'French_France';
                } else if (contact.MailingCountry == 'United Kingdom') {
                    key = 'English_United Kingdom';
                }
            }
        }
        return key;
    }

    private Map<String, SObject> getQuoteTemplates() {
        List<zqu__Quote_Template__c> qTpls = [
                SELECT Id, Name, Country__c, Language__c
                FROM zqu__Quote_Template__c
                WHERE zqu__Quote_Type__c = 'New Subscription'
        ];
        Map<String, SObject> qMap = new Map<String, SObject>();
        for (zqu__Quote_Template__c tpl : qTpls) {
            qMap.put(tpl.Language__c + '_' + tpl.Country__c, tpl);
        }
        return qMap;
    }

    private Map<String, SObject> getInvoiceTemplates() {
        List<zqu__InvoiceTemplate__c> qTpls = [
                SELECT Id, Name, Country__c, Language__c
                FROM zqu__InvoiceTemplate__c
        ];
        Map<String, SObject> qMap = new Map<String, SObject>();
        for (zqu__InvoiceTemplate__c tpl : qTpls) {
            qMap.put(tpl.Language__c + '_' + tpl.Country__c, tpl);
        }
        return qMap;
    }

    private Map<String, SObject> getCommunicationProfileTemplates() {
        List<zqu__CommunicationProfile__c> qTpls = [
                SELECT Id, Name
                FROM zqu__CommunicationProfile__c
        ];
        Map<String, SObject> qMap = new Map<String, SObject>();
        for (zqu__CommunicationProfile__c tpl : qTpls) {
            qMap.put(tpl.Name, tpl);
        }
        return qMap;
    }*/
}