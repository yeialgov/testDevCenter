/**
 * @author keylight
 */
@isTest
private class QuotePopulatePluginTest {/*

	@isTest static void testQuotePopulatePlugin() {
		Account account = new Account();
		account.Name = 'AccountName';
		account.LegalCompanyName__c = 'TestCompany';
		account.Phone = '+491701948378';
		insert account;

		Contact contact = new Contact();
		contact.FirstName = 'FirstName';
		contact.LastName = 'LastName';
		contact.MailingStreet = 'MailingStreet';
		contact.MailingPostalCode = 'MailingPostalCode';
		contact.MailingCity = 'MailingCity';
		contact.MailingCountry = 'Germany';
		contact.Email = 'Email@email.de';
		contact.Phone = '+491701948378';
		contact.BillingAddress__c = true;
        contact.PrimaryLanguage__c = 'German';
		contact.accountId = account.Id;
		insert contact;

		zqu__CommunicationProfile__c communicationProfile = new zqu__CommunicationProfile__c();
		communicationProfile.Name = contact.PrimaryLanguage__c;
		communicationProfile.zqu__ZuoraId__c = '1234561121';
		insert communicationProfile;

		zqu__InvoiceTemplate__c invoiceTemplate = new zqu__InvoiceTemplate__c();
		invoiceTemplate.language__c = contact.PrimaryLanguage__c;
        invoiceTemplate.Country__c = contact.MailingCountry;
		invoiceTemplate.Name = 'TestInvoiceTemplate';
		invoiceTemplate.zqu__ZuoraId__c = '123451111';
		insert invoiceTemplate;

        zqu__Quote_Template__c quoteTemplate = new zqu__Quote_Template__c();
        quoteTemplate.zqu__Quote_Type__c = 'New Subscription';
        quoteTemplate.language__c = contact.PrimaryLanguage__c;
        quoteTemplate.Country__c = contact.MailingCountry;
        quoteTemplate.zqu__Template_Id__c = '12345111111121';
        insert quoteTemplate;

		// erster Test
		account.SF_BillTo_Contact__c = contact.Id;
		account.SF_SoldTo_Contact__c = contact.Id;
		account.TaxExempted__c = true;
		account.VATNumber__c = '123';
		update account;

		zqu__Quote__c quote = new zqu__Quote__c();
		quote.zqu__Account__c = account.Id;
		QuotePopulatePlugin  quotePopulatePlugin = new QuotePopulatePlugin();
		quotePopulatePlugin.populateDefaultFieldValue(quote, null);

        System.assertEquals('Yes', quote.zqu__Tax_Exempt__c);
        System.assertEquals(contact.Id, quote.zqu__BillToContact__c);
        System.assertEquals(contact.Id, quote.zqu__SoldToContact__c);
		System.assertEquals(date.today().addMonths(1), quote.zqu__ValidUntil__c);
		System.assertEquals(date.today(), quote.zqu__StartDate__c);
		System.assertEquals(12, quote.zqu__InitialTerm__c);
		System.assertEquals(12, quote.zqu__RenewalTerm__c);
		System.assertEquals('123', quote.zqu__VAT_ID__c);
        System.assertEquals(quoteTemplate.Id, quote.zqu__QuoteTemplate__c);
        System.assertEquals(invoiceTemplate.Id, quote.zqu__InvoiceTemplate__c);
        System.assertEquals(communicationProfile.Id, quote.zqu__CommunicationProfile__c);
	}

	@isTest static void populateQuoteTemplate_should_set_quote_template() {
		zqu__Quote_Template__c template = new zqu__Quote_Template__c();
		template.name = 'TestTemplate';
		zqu.LookupComponentOptions quoteTemplateOption = new zqu.LookupComponentOptions();
		QuotePopulatePlugin quotePopulatePlugin = new QuotePopulatePlugin();
		quotePopulatePlugin.populateQuoteTemplate(quoteTemplateOption, template);
		System.assertEquals(quoteTemplateOption.targetName, template.name);
	}

	@isTest static void populateCommunicationProfile_should_set_communication_profile() {
		zqu__CommunicationProfile__c communicationProfile = new zqu__CommunicationProfile__c();
		communicationProfile.name = 'TestProfile';
		zqu.LookupComponentOptions communicationProfileOption = new zqu.LookupComponentOptions();
		QuotePopulatePlugin quotePopulatePlugin = new QuotePopulatePlugin();
		quotePopulatePlugin.populateCommunicationProfile(communicationProfileOption, communicationProfile);
		System.assertEquals(communicationProfileOption.targetName, communicationProfile.name);
	}

	@isTest static void populateInvoiceTemplate_should_set_invoiceTemplate() {
		zqu__InvoiceTemplate__c invoiceTemplate = new zqu__InvoiceTemplate__c();
		invoiceTemplate.name = 'TestInvoice';
		zqu.LookupComponentOptions invoiceTemplateOption = new zqu.LookupComponentOptions();
		QuotePopulatePlugin quotePopulatePlugin = new QuotePopulatePlugin();
		quotePopulatePlugin.populateInvoiceTemplate(invoiceTemplateOption, invoiceTemplate);
		System.assertEquals(invoiceTemplateOption.targetName, invoiceTemplate.name);
	}*/
}