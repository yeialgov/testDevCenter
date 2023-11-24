/**
 * @author keylight updated by joern
 */
@isTest(SeeAllData=false)
public class QuoteFieldUpdateTest {/*
	static testMethod void updateFields_should_use_start_date() {
        setUpTemplates();
		Account acc = setUpAccount();
		Map<Id,Account> accounts = new Map<Id,Account>();
		accounts.put(acc.Id, acc);
		
		zqu__Quote__c quote = new zqu__Quote__c(zqu__StartDate__c = Date.today(), zqu__Account__c = acc.Id);
		QuoteFieldUpdate quoteFieldUpdate = new QuoteFieldUpdate(accounts);
		quoteFieldUpdate.updateFields(quote);
        System.assertEquals(quote.zqu__InvoiceTargetDate__c, quote.zqu__StartDate__c);
    }

    static testMethod void updateFields_should_use_service_activation_date() {
        setUpTemplates();
        Account acc = setUpAccount();
		Map<Id,Account> accounts = new Map<Id,Account>();
		accounts.put(acc.Id, acc);

		zqu__Quote__c quote = new zqu__Quote__c(
                zqu__StartDate__c = Date.today(),
                zqu__Service_Activation_Date__c = Date.today().addDays(10),
			    Invoice_Recurring_at_Start_Date__c = true,
                zqu__Account__c = acc.Id
		);

		QuoteFieldUpdate quoteFieldUpdate = new QuoteFieldUpdate(accounts);
		quoteFieldUpdate.updateFields(quote);
        System.assertEquals(quote.zqu__InvoiceTargetDate__c, quote.zqu__Service_Activation_Date__c);
        System.assertNotEquals(quote.zqu__InvoiceTargetDate__c, quote.zqu__StartDate__c);
    }

    static testMethod void updateFields_should_add_months_to_date() {
        setUpTemplates();
        Account acc = setUpAccount();
		Map<Id,Account> accounts = new Map<Id,Account>();
		accounts.put(acc.Id, acc);

		zqu__Quote__c quote = new zqu__Quote__c(
                zqu__StartDate__c = Date.today(),
                zqu__Service_Activation_Date__c = Date.today().addDays(10),
                Invoice_Recurring_at_Start_Date__c = true,
                Months_to_pay_in_advance__c = 2,
                zqu__Account__c = acc.Id
		);
		QuoteFieldUpdate quoteFieldUpdate = new QuoteFieldUpdate(accounts);
		quoteFieldUpdate.updateFields(quote);
        System.assertNotEquals(quote.zqu__InvoiceTargetDate__c, quote.zqu__Service_Activation_Date__c);
        System.assertEquals(quote.zqu__InvoiceTargetDate__c, Date.today().addMonths(2));
    }

    static testMethod void updateFields_should_set_tax_related_fields() {
        setUpTemplates();
        Account acc = setUpAccount();
        Map<Id,Account> accounts = new Map<Id,Account>();
        accounts.put(acc.Id, acc);

        zqu__Quote__c quote = new zqu__Quote__c(zqu__StartDate__c = Date.today(), zqu__Account__c = acc.Id);
        QuoteFieldUpdate quoteFieldUpdate = new QuoteFieldUpdate(accounts);
        quoteFieldUpdate.updateFields(quote);
        System.assertEquals(quote.zqu__Tax_Exempt__c, 'Yes');
        System.assertEquals(quote.zqu__Currency__c, acc.CurrencyIsoCode);
        System.assertEquals(quote.zqu__VAT_ID__c, acc.VATNumber__c);
    }

    static testMethod void updateFields_should_set_templates_ids() {
        setUpTemplates();
        Account acc = setUpAccount();
        Map<Id,Account> accounts = new Map<Id,Account>();
        accounts.put(acc.Id, acc);

        zqu__Quote__c quote = new zqu__Quote__c(zqu__StartDate__c = Date.today(), zqu__Account__c = acc.Id);
        QuoteFieldUpdate quoteFieldUpdate = new QuoteFieldUpdate(accounts);
        quoteFieldUpdate.updateFields(quote);
        System.assertNotEquals(quote.zqu__QuoteTemplate__c, null);
        System.assertNotEquals(quote.zqu__InvoiceTemplate__c, null);
        System.assertNotEquals(quote.zqu__CommunicationProfile__c, null);
    }

    private static Account setUpAccount() {
        Account acc = new Account(name='TestAccount', taxExempted__c=true, CurrencyIsoCode='EUR', VATNumber__c='10pqpwo1');
        insert acc;
        Contact contact = new Contact(
                LastName = 'TestCon',
                MailingCountry = 'Germany',
                PrimaryLanguage__c = 'English'
        );
        insert contact;
        acc.SF_BillTo_Contact__c = contact.Id;
        acc.SF_SoldTo_Contact__c = contact.Id;
        update acc;
        return acc;
    }

	public static void setUpTemplates() {
        zqu__Quote_Template__c qtpl =  new zqu__Quote_Template__c(
				Name = 'de_EN',
				Country__c = 'Germany',
				Language__c = 'English',
                zqu__Template_Id__c = '121212',
				zqu__Quote_Type__c = 'New Subscription');

        zqu__Quote_Template__c qtpl2 =  new zqu__Quote_Template__c(
                Name = 'de_EN',
                Country__c = 'Germany',
                Language__c = 'German',
                zqu__Template_Id__c = '121212422',
                zqu__Quote_Type__c = 'New Subscription');

        zqu__InvoiceTemplate__c itpl =  new zqu__InvoiceTemplate__c(
				Name = 'de_EN',
				Country__c = 'Germany',
                zqu__ZuoraId__c = '121212',
				Language__c = 'English');

        zqu__InvoiceTemplate__c itpl2 =  new zqu__InvoiceTemplate__c(
                Name = 'de_EN',
                Country__c = 'Germany',
                zqu__ZuoraId__c = '1212412',
                Language__c = 'German');

        zqu__CommunicationProfile__c c =  new zqu__CommunicationProfile__c(
				Name = 'English',
                zqu__ZuoraId__c = '1234123');

        zqu__CommunicationProfile__c c2 =  new zqu__CommunicationProfile__c(
                Name = 'German',
                zqu__ZuoraId__c = '12344123');

        insert new List<SObject>{qtpl, qtpl2, itpl, itpl2, c, c2};
	}*/
}