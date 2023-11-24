/**
 * @author keylight
 */
@isTest
public class SendQuoteControllerTest {
    static testMethod void test() {
        SendQuoteController SendQuoteController = new SendQuoteController();
    }
    /*
	@isTest
	static void testSendMail() 
	{
		zqu__Quote__c quote = init();
		ApexPages.StandardController standardController = new ApexPages.StandardController(quote);
		SendQuoteController controller = new SendQuoteController(standardController);
		controller.email.subject = 'Test';
		controller.email.content = 'test';
		controller.attach = true;
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new ZuoraFileCalloutMock());
		controller.sendEmail();
		Test.setMock(HttpCalloutMock.class, new ZuoraFileCalloutMock(true));
		controller.sendEmail();
		Test.stopTest();
	}

    @IsTest
    static void setQuoteLink_should_encryptAndSet_link_param() {
        zqu__Quote__c quote = init();
        ApexPages.StandardController standardController = new ApexPages.StandardController(quote);
        SendQuoteController controller = new SendQuoteController(standardController);
        System.assertEquals(null, quote.DecryptedQuoteLink__c);
        controller.setQuoteLink();
        zqu__Quote__c q = [SELECT DecryptedQuoteLink__c FROM zqu__Quote__c WHERE Id=:quote.Id LIMIT 1];
        System.assertNotEquals(null, q.DecryptedQuoteLink__c);
    }

    @IsTest
    static void copyText_should_copy() {
        zqu__Quote__c quote = init();
        ApexPages.StandardController standardController = new ApexPages.StandardController(quote);
        SendQuoteController controller = new SendQuoteController(standardController);
        Folder folder = [SELECT Id FROM Folder WHERE Name = 'Quotes'];
        EmailTemplate[] emailTemplates = [SELECT Id, Name, Subject, Body from EmailTemplate WHERE folderId =: folder.Id];
        controller.item = emailTemplates[0].Id;
        System.assertEquals(null, controller.email.content);
        System.assertEquals(null, controller.email.subject);
        controller.copyText();
        System.assertNotEquals(null, controller.email.content);
        System.assertEquals(emailTemplates[0].Subject, controller.email.subject);
    }

    @IsTest
    static void createTask_should_create_task() {
        zqu__Quote__c quote = init();
        ApexPages.StandardController standardController = new ApexPages.StandardController(quote);
        SendQuoteController controller = new SendQuoteController(standardController);
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.plainTextBody = 'BODY';
        email.setSubject('SUBJECT');
        Blob bl = Blob.valueOf('1');
        controller.createTask(email, controller.quote.Id, bl, '', false);
        Task task = [SELECT Id, Description, Subject FROM Task Where WhatId=:controller.quote.Id LIMIT 1];
        System.assertNotEquals(null, task);
        System.assertEquals('BODY', task.Description);
        System.assertEquals('SUBJECT', task.Subject);
    }

	static zqu__Quote__c init() {
		CheckoutAESKey__c aes256 =  new CheckoutAESKey__c();
		aes256.name = 'AES256';
		aes256.Key__c = '5G697w899d096Z4U3u2F34S5T5C6H7f6';
		insert aes256;

		Account acc = new Account();
		acc.Name = 'Test';
		acc.Phone = '+491701948378';
		insert acc;

		Contact contact = new Contact();
		contact.Email = 'test@test.de';
		contact.AccountId = acc.Id;
		contact.LastName = 'Test';
        contact.FirstName = 'Test2';
		contact.Phone = '+491701948378';
		insert contact;

		zqu__Quote_Template__c template = new zqu__Quote_Template__c();
		template.zqu__Template_Id__c = '1234';
		template.language__c = 'German';
		insert template;

		zqu__Quote__c quote = new zqu__Quote__c();
		quote.zqu__Account__c = acc.Id;
		quote.zqu__BillToContact__c = contact.Id;
		quote.zqu__SoldToContact__c = contact.Id;
		quote.zqu__QuoteTemplate__c = template.Id;
		insert quote;
		return quote;
	}
*/
}