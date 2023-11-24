/**
 * Created by keylight
 */
@isTest(SeeAllData=false)
private class QuoteAccountSyncTest {
	/*
	@isTest static void constructer_test() {
        List<zqu__Quote__c> quotes = new List<zqu__Quote__c>();
        quotes.add(new zqu__Quote__c());
        QuoteAccountSync sync = new QuoteAccountSync(quotes);
        System.assertEquals(quotes, sync.quotes);
    }

    @isTest static void updateAccounts_should_return_accounts() {
    	List<zqu__Quote__c> quotes = new List<zqu__Quote__c>();
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
		contact.Email = 'email@email.de';
		contact.Phone = '+491701948378';
		insert contact;

		zqu__Quote__c quote = new zqu__Quote__c();
		quote.zqu__BillToContact__c = contact.Id;
		quote.zqu__Account__c = account.Id;	
        quotes.add(quote);

        QuoteAccountSync sync = new QuoteAccountSync(quotes);

        Account[] accounts = sync.updateAccounts();
        System.assertEquals(1, accounts.size());
    }


    @isTest static void updateAccounts_should_not_return_accounts() {
    	List<zqu__Quote__c> quotes = new List<zqu__Quote__c>();
        quotes.add(new zqu__Quote__c());
        QuoteAccountSync sync = new QuoteAccountSync(quotes);
        Account[] accounts = sync.updateAccounts();
        System.assertEquals(0, accounts.size());
    }

    @isTest static void getAccounts_should_return_a_account_map() {
        Account account = new Account();
        account.Name = 'AccountName';
        account.LegalCompanyName__c = 'TestCompany';
        account.Phone = '+491701948378';
        insert account;

        List<zqu__Quote__c> quotes = new List<zqu__Quote__c>();
        zqu__Quote__c quote = new zqu__Quote__c();
        quote.zqu__Account__c = account.Id; 
        quotes.add(quote);

        QuoteAccountSync sync = new QuoteAccountSync(quotes);
        Map<ID, Account> accounts = sync.getAccounts();
        System.assertEquals(account.Id, accounts.get(quote.zqu__Account__c).Id);
    }*/
}