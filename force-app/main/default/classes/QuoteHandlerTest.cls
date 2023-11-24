/**
 * @author keylight
 */
@isTest(SeeAllData=false)
private class QuoteHandlerTest {/*
	@isTest static void should_update_zuora_contacts() {
		QuoteFieldUpdateTest.setUpTemplates();
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
		quote.zqu__SoldToContact__c = contact.Id;
		quote.zqu__Account__c = account.Id;	
      	insert quote;

       	Account updatedAccount = [SELECT Id, SF_BillTo_Contact__c, SF_SoldTo_Contact__c FROM Account WHERE Id = :account.Id];
        System.assertEquals(updatedAccount.SF_BillTo_Contact__c, contact.Id);
        System.assertEquals(updatedAccount.SF_SoldTo_Contact__c, contact.Id);
    }

    @isTest static void should_set_bill_cycle_day() {
		QuoteFieldUpdateTest.setUpTemplates();
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
		quote.zqu__SoldToContact__c = contact.Id;
		quote.zqu__Account__c = account.Id;	
      	insert quote;

      	quote.zqu__Service_Activation_Date__c = Date.newInstance(2017,01,01);
      	update quote;
      	zqu__Quote__c updatedQuote = [Select Id, zqu__BillCycleDay__c FROM zqu__Quote__c WHERE Id =: quote.id];
      	System.assertEquals('1', updatedQuote.zqu__BillCycleDay__c);

    }

    @isTest static void should_delete_quote() {
		zqu__Quote__c quote = new zqu__Quote__c();
		insert quote;

		delete quote;
	}*/
}