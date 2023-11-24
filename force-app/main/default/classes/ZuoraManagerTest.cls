/**
 * @author keylight
 */
@IsTest
private class ZuoraManagerTest {
    
    static TestMethod void test() {
        Test.setMock(HttpCalloutMock.class, new ZuoraHttpCalloutMock(true));
        Test.startTest();
        Blob response = ZuoraManager.getPDF('test');
        String s = ZuoraManager.callZuoraAPI('route', 'method', '{}');
        Test.stopTest();
    }
    
    /*@IsTest
    static void ZuoraContact_toJson_should_return_correct_schema() {
        Map<String, String> zuoraContactData = new Map<String, String>();
        zuoraContactData.put('Attention__c', 'Attention');
        zuoraContactData.put('Addressee__c', 'Addressee');
        zuoraContactData.put('Description', 'Addressee\nAttention');
        zuoraContactData.put('FirstName', 'FirstName');
        zuoraContactData.put('LastName', 'LastName');
        zuoraContactData.put('Address1', 'MailingStreet1');
        zuoraContactData.put('Address2', 'Mailingstreet2');
        zuoraContactData.put('PostalCode', 'MailingPostalCode');
        zuoraContactData.put('City', 'MailingCity');
        zuoraContactData.put('Country', 'Germany');
        zuoraContactData.put('WorkEmail', 'test@test.de');
        Contact contact = loadContact();
        ZuoraManager.ZuoraContact zContact = new ZuoraManager.ZuoraContact(contact, false);
        String jsonSt = zContact.toJson();
        Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(jsonSt);
        for (String fieldName: zuoraContactData.keySet()) {
            System.assertEquals(zuoraContactData.get(fieldName), result.get(fieldName));
        }

        // Contact embedded in Account
        Map<String, String> zuoraAccountContactData = new Map<String, String>();
        zuoraAccountContactData.put('Attention__c', 'Attention');
        zuoraAccountContactData.put('Addressee__c', 'Addressee');
        zuoraAccountContactData.put('firstName', 'FirstName');
        zuoraAccountContactData.put('lastName', 'LastName');
        zuoraAccountContactData.put('address1', 'MailingStreet1');
        zuoraAccountContactData.put('address2', 'Mailingstreet2');
        zuoraAccountContactData.put('zipCode', 'MailingPostalCode');
        zuoraAccountContactData.put('city', 'MailingCity');
        zuoraAccountContactData.put('country', 'Germany');
        zuoraAccountContactData.put('workEmail', 'test@test.de');
        Contact contact2 = loadContact();
        ZuoraManager.ZuoraContact zContact2 = new ZuoraManager.ZuoraContact(contact2, true);
        String jsonSt2 = zContact2.toJson();
        Map<String, Object> result2 = (Map<String, Object>) JSON.deserializeUntyped(jsonSt2);
        for (String fieldName: zuoraAccountContactData.keySet()) {
            System.assertEquals(zuoraAccountContactData.get(fieldName), result2.get(fieldName));
        }
    }

    @IsTest
    static void ZuoraAccountUpdate_toJson_should_return_correct_schema() {
        Account acc = loadAccount();
        Contact billToContact = loadContact();
        Contact soldToContact = loadContact();

        ZuoraManager.ZuoraAccountUpdate accUp = new ZuoraManager.ZuoraAccountUpdate(acc, billToContact, soldToContact);
        String jsonSt = accUp.toJson();
        Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(jsonSt);
        System.assertEquals('TestCompany', result.get('LegalCompanyName__c'));
        System.assertEquals('12345', result.get('NetSuiteId__c'));
        System.assertNotEquals(null, result.get('billToContact'));
        System.assertNotEquals(null, result.get('soldToContact'));

        accUp = new ZuoraManager.ZuoraAccountUpdate(acc, null, null);
        jsonSt = accUp.toJson();
        result = (Map<String, Object>) JSON.deserializeUntyped(jsonSt);
        System.assertEquals('TestCompany', result.get('LegalCompanyName__c'));
        System.assertEquals('12345', result.get('NetSuiteId__c'));
        System.assertEquals(null, result.get('billToContact'));
        System.assertEquals(null, result.get('soldToContact'));
    }

    @IsTest
    static void contact_should_be_marked() {
        Test.setMock(HttpCalloutMock.class, new ZuoraHttpCalloutMock(true));
        Account account = loadAccount();
        insert account;
        Zuora__CustomerAccount__c customerAccount = new Zuora__CustomerAccount__c();
        customerAccount.Zuora__Account__c = account.Id;
        insert customerAccount;
        Contact contact = loadContact();
        contact.AccountId = account.Id;
        insert contact;
        Contact contact2 = loadContact();
        contact2.AccountId = account.Id;
        insert contact2;
        account.SF_BillTo_Contact__c = contact.Id;
        account.SF_SoldTo_Contact__c = contact2.Id;
        update account;

        Test.startTest();
        ZuoraManager.updateBillToContact(contact.Id);
        ZuoraManager.updateSoldToContact(contact2.Id);
        Test.stopTest();

        Contact con = [SELECT ZuoraSyncFailed__c FROM Contact WHERE Id = :contact.Id];
        System.assertEquals(true, con.ZuoraSyncFailed__c);
        Contact con2 = [SELECT ZuoraSyncFailed__c FROM Contact WHERE Id = :contact2.Id];
        System.assertEquals(true, con.ZuoraSyncFailed__c);
    }

    @IsTest
    static void account_should_be_marked() {
        Test.setMock(HttpCalloutMock.class, new ZuoraHttpCalloutMock(true));
        Account account = loadAccount();
        insert account;
        Zuora__CustomerAccount__c customerAccount = new Zuora__CustomerAccount__c();
        customerAccount.Zuora__Account__c = account.Id;
        insert customerAccount;
        Contact contact = loadContact();
        contact.AccountId = account.Id;
        insert contact;
        account.SF_BillTo_Contact__c = contact.Id;
        account.SF_SoldTo_Contact__c = contact.Id;
        update account;

        Test.startTest();
        ZuoraManager.updateAccount(account.Id, true, true);
        Test.stopTest();

        Account acc = [SELECT ZuoraSyncFailed__c FROM Account WHERE Id = :account.Id];
        System.assertEquals(true, acc.ZuoraSyncFailed__c);
    }



    @IsTest
    static void accountNeedsUpdate() {
        Account account = loadAccount();
        Account account2 = loadAccount();

        Boolean needsUpdate = ZuoraManager.accountNeedsUpdate(account, account2);
        System.debug(needsUpdate);
        System.assertEquals(needsUpdate, false);

        account2.LegalCompanyName__c = 'TestCompany2';
        needsUpdate = ZuoraManager.accountNeedsUpdate(account, account2);
        System.assertEquals(needsUpdate, true);

    }

    @IsTest
    static void contactNeedsUpdate() {
        Contact contact = loadContact();
        Contact contact2 = loadContact();

        Boolean needsUpdate = ZuoraManager.contactNeedsUpdate(contact, contact2);
        System.assertEquals(needsUpdate, false);

        contact2.LastName = 'LastName2';
        needsUpdate = ZuoraManager.contactNeedsUpdate(contact, contact2);
        System.assertEquals(needsUpdate, true);
    }

    @IsTest
    static void getQuotePdf() {
        Test.setMock(HttpCalloutMock.class, new ZuoraFileCalloutMock());
        zqu__Quote_Template__c quoteTemplate = new zqu__Quote_Template__c();
        quoteTemplate.Language__c = 'german';
        quoteTemplate.zqu__Template_Id__c = '1234';
        insert quoteTemplate;

        zqu__Quote__c quote = new zqu__Quote__c();
        quote.zqu__QuoteTemplate__c = quoteTemplate.Id;
        insert quote;

        Test.startTest();
        Blob response = ZuoraManager.getQuotePDF(quote.Id);
        System.assertEquals(response.toString(), 'Test');
        Test.stopTest();
    }

    private static Contact loadContact() {
        Contact contact = new Contact();
        contact.Addressee__c = 'Addressee';
        contact.Attention__c = 'Attention';
        contact.FirstName = 'FirstName';
        contact.LastName = 'LastName';
        contact.MailingStreet = 'MailingStreet1\nMailingstreet2';
        contact.MailingPostalCode = 'MailingPostalCode';
        contact.MailingCity = 'MailingCity';
        contact.MailingCountry = 'Germany';
        contact.Email = 'test@test.de';
        return contact;
    }

    private static Account loadAccount() {
        Account account = new Account();
        account.name = 'TestAccount';
        account.LegalCompanyName__c = 'TestCompany';
        account.NS_Customer_Internal_ID__c = '12345';
        return account;
    }*/
}