/**
 * @author keylight / joern
 *
 * @todo remove because is integrated in AccountHandler and deactivated via custom setting
 */
@isTest(SeeAllData=false)
private class AccountHandlerTest
{
    static testmethod void test() {
        AccountStatementExtension AccountStatementExtension = new AccountStatementExtension();
        ZuoraContactUpdateUtil ZuoraContactUpdateUtil = new ZuoraContactUpdateUtil();
    }
    
    static testmethod void test2() {
        insert new Account(Name='test',ZuoraId__c='test');
        try {delete [SELECT Id FROM Account]; } catch(exception e){}
    }
    
    /*@isTest
    static void should_sync_contact_address() {
        Account acc = new Account(Name='_RestCaf');
        insert acc;
        ID acctID = acc.Id;
        Contact conBilling = new Contact(
            FirstName='_Joe',
            LastName='_Smith',
            Email='h@aol.c.com',
            Phone='030 12001002001',
            MailingStreet='Leipzigerstr. 13',
            MailingCity='Berlin',
            MailingPostalCode='121212',
            MailingCountry='Germany',
            AccountId=acctID);
        Contact conShipping = new Contact(
            FirstName='Joe2',
            Email='h_qw223@aol.c.com',
            LastName='_Smith2',
            Phone='030 21200102020012121212',
            MailingStreet='TheStreet 14',
            MailingCity='Köln',
            MailingPostalCode='21213',
            MailingCountry='Germany',
            AccountId=acctID);
        insert conBilling;
        insert conShipping;
        acc.SF_SoldTo_Contact__c = conShipping.Id;
        acc.SF_BillTo_Contact__c = conBilling.Id;
        update acc;

        Account accT = [SELECT 
            BillingStreet, BillingCity, BillingCountry, BillingPostalCode, 
            ShippingStreet, ShippingCity, ShippingCountry,ShippingPostalCode
            FROM Account WHERE Id=:acc.Id
        ];
        /*System.assertEquals(conBilling.MailingStreet, accT.BillingStreet);
        System.assertEquals(conBilling.MailingCity, accT.BillingCity);
        System.assertEquals(conBilling.MailingCountry, accT.BillingCountry);
        System.assertEquals(conBilling.MailingPostalCode, accT.BillingPostalCode);
        System.assertEquals(conShipping.MailingStreet, accT.ShippingStreet);
        System.assertEquals(conShipping.MailingCity, accT.ShippingCity);
        System.assertEquals(conShipping.MailingCountry, accT.ShippingCountry);
        System.assertEquals(conShipping.MailingPostalCode, accT.ShippingPostalCode);*
    }


    @isTest
    static void should_rewrite_wrong_formated_phonenumbers() {
        Account acc = new Account(Name='_Burger_', Phone='+49 175 2955188', Fax='+49 992 92 92 ');
        insert acc;
        acc = [SELECT Phone, Fax FROM Account WHERE Name='_Burger_'];
        System.assertEquals('+491752955188', acc.Phone);
        System.assertEquals('+499929292', acc.Fax);
        
        acc.Phone = '+49 175 2955188';
        acc.Fax = '+49 992 92 92 ';
        update acc;
        acc = [SELECT Phone, Fax FROM Account WHERE Name='_Burger_'];
        System.assertEquals('+491752955188', acc.Phone);
        System.assertEquals('+499929292', acc.Fax);
    }

    @isTest static void run_sync_to_zuora() {
        Test.setMock(HttpCalloutMock.class, new ZuoraHttpCalloutMock());

        Contact contact = new Contact();
        contact.LastName = 'LastName';
        insert contact;

        Contact contact2 = new Contact();
        contact2.LastName = 'LastName2';
        insert contact2;

        Account account = new Account();
        account.Name = 'AccountName';
        account.LegalCompanyName__c = 'TestCompany';
        account.SF_BillTo_Contact__c = contact.Id;
        account.SF_SoldTo_Contact__c = contact.Id;
        insert account;

        Zuora__CustomerAccount__c billingAccount = new Zuora__CustomerAccount__c();
        billingAccount.Zuora__Account__c = account.Id;
        insert billingAccount;
        
        account.LegalCompanyName__c = 'TestCompany2';
        account.SF_SoldTo_Contact__c = contact2.Id;
        update account;
    }

    @isTest static void should_delete_account() {
        Account account = new Account();
        account.Name = 'AccountName';
        insert account;

        delete account;
    }*/
}