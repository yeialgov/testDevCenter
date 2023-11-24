/**
 * @author martin
 */
@IsTest
public class QuoteAttachmentMandatoryTest {
/*
    private static User createUser() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Sales'];
        User u = new User(Alias = 'dUser', Email = 'deploymentuser@orderbird.com',
                EmailEncodingKey = 'UTF-8', LastName = 'Deploy', LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US', ProfileId = p.Id,
                TimeZoneSidKey = 'America/Los_Angeles', UserName = 'deploymentuser@orderbird.com');
        return u;
    }

    static testMethod void quote_insert_should_fail() {

        // Setup test data
        User u = createUser();
        // This code runs as the deploying user

        System.runAs(u) {
            // This runs as the created user u
            // Insert fail
            Contact c = new Contact(FirstName = 'Hi', LastName = 'krass', PrimaryLanguage__c = 'German', Email = 'bla@bla.de', MailingCity = 'lul', MailingStreet = 'lul', MailingPostalCode = '12345', MailingCountry = 'Germany');
            insert c;
            Account a = new Account(Name = 'LULACCOUNT', BillingCity = 'a', BillingCountry = 'Germany', LegalCompanyName__c = 'krasscompany', BillingStreet = 'e', BillingPostalCode = '12345', ShippingCity = 'a', ShippingCountry = 'Germany', ShippingStreet = 'e', ShippingPostalCode = '12345', SF_BillTo_Contact__c = c.Id, SF_SoldTo_Contact__c = c.Id, CurrencyISOCode = 'EUR', Tax_Exempt_Reason__c = 'Non Tax Exempt');
            insert a;
            Opportunity o = new Opportunity(Name = 'LULOPP', StageName = 'Potential', CloseDate = System.Today(), AccountId = a.Id, LAC_Shorthand__c = 'Walk-In');
            insert o;
            zqu__Quote__c q = new zqu__Quote__c(Name = 'Deployment Quote', zqu__BillToContact__c = c.Id, zqu__Account__c = a.Id, zqu__Opportunity__c = o.Id, Quote_is_ready__c = true, zqu__Currency__c = 'EUR');

            Test.startTest();
            try {
                insert q;
                System.assertEquals(true, false);
            } catch (Exception e) {
                System.Assert(e.getMessage().contains('Please attach the customers response to the Quote before marking it as ready!'));
            }
            Test.stopTest();
        }

    }

    static testMethod void quote_update_should_fail() {

        // Setup test data
        User u = createUser();
        // This code runs as the deploying user

        System.runAs(u) {
            // Update Fail
            Contact c2 = new Contact(FirstName = 'Hi', LastName = 'krass', PrimaryLanguage__c = 'German', Email = 'bla@bla.de', MailingCity = 'lul', MailingStreet = 'lul', MailingPostalCode = '12345', MailingCountry = 'Germany');
            insert c2;
            Account a2 = new Account(Name = 'LULACCOUNT', BillingCity = 'a', BillingCountry = 'Germany', LegalCompanyName__c = 'krasscompany', BillingStreet = 'e', BillingPostalCode = '12345', ShippingCity = 'a', ShippingCountry = 'Germany', ShippingStreet = 'e', ShippingPostalCode = '12345', SF_BillTo_Contact__c = c2.Id, SF_SoldTo_Contact__c = c2.Id, Tax_Exempt_Reason__c = 'Non Tax Exempt');
            insert a2;
            Opportunity o2 = new Opportunity(Name = 'LULOPP', StageName = 'Potential', CloseDate = System.Today(), AccountId = a2.Id, LAC_Shorthand__c = 'Walk-In');
            insert o2;
            zqu__Quote__c q2 = new zqu__Quote__c(Name = 'Deployment Quote', zqu__BillToContact__c = c2.Id, zqu__Account__c = a2.Id, zqu__Opportunity__c = o2.Id);
            insert q2;

            q2.Quote_is_ready__c = true;

            Test.startTest();
            try {
                update q2;
                System.assertEquals(true, false);
            } catch (Exception e) {
                System.Assert(e.getMessage().contains('Please attach the customers response to the Quote before marking it as ready!'));
            }
            Test.stopTest();
        }

    }

    static testMethod void quote_update_should_not_fail() {

        // Setup test data
        User u = createUser();
        // This code runs as the deploying user

        System.runAs(u) {

            // No Error

            Contact c3 = new Contact(FirstName = 'Hi', LastName = 'krass', PrimaryLanguage__c = 'German', Email = 'bla@bla.de', MailingCity = 'lul', MailingStreet = 'lul', MailingPostalCode = '12345', MailingCountry = 'Germany');
            insert c3;
            Account a3 = new Account(Name = 'LULACCOUNT', BillingCity = 'a', BillingCountry = 'Germany', LegalCompanyName__c = 'krasscompany', BillingStreet = 'e', BillingPostalCode = '12345', ShippingCity = 'a', ShippingCountry = 'Germany', ShippingStreet = 'e', ShippingPostalCode = '12345', SF_BillTo_Contact__c = c3.Id, SF_SoldTo_Contact__c = c3.Id, Tax_Exempt_Reason__c = 'Non Tax Exempt');
            insert a3;
            Opportunity o3 = new Opportunity(Name = 'LULOPP', StageName = 'Potential', CloseDate = System.Today(), AccountId = a3.Id, LAC_Shorthand__c = 'Walk-In');
            insert o3;
            zqu__Quote__c q3 = new zqu__Quote__c(Name = 'Deployment Quote', zqu__BillToContact__c = c3.Id, zqu__Account__c = a3.Id, zqu__Opportunity__c = o3.Id);
            insert q3;
            Attachment att = new Attachment(Name = 'Test attachment', body = Blob.valueOf('Testbody of bodyness'), ParentId = q3.Id);
            insert att;

            Test.startTest();
            q3.Quote_is_ready__c = true;
            update q3;
            Test.stopTest();
        }
    }*/
}