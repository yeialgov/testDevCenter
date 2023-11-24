@isTest(seeAllData=true)
public class PdfControllerTest {
	
    @isTest static void test1() {
        Pricebook2 pb = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1];
        Account a = new Account(name='test');
        insert a;
        Opportunity o = new Opportunity(lac_id__c = '1',Pricebook2Id = pb.Id, Name='test', StageName='New', CloseDate=Date.today(), AccountId=a.Id, CurrencyIsoCode='EUR');
        insert o;
        Quote q = new Quote(OpportunityId=o.Id,Name='test',CurrencyIsoCode='EUR', Pricebook2Id = pb.Id);
        insert q;
        PricebookEntry pbe = [SELECT Id, Product2Id FROM PricebookEntry WHERE Pricebook2Id = :pb.Id AND CurrencyIsoCode='EUR' LIMIT 1];
        //ProductBundle__c pbun = [SELECT Id FROM ProductBundle__c LIMIT 1];
        ProductBundle__c pbun = new ProductBundle__c();
        insert new QuoteLineItem(QuoteId = q.Id,PricebookEntryId=pbe.Id, Quantity=1, UnitPrice=10, Product2Id=pbe.Product2Id, ProductBundle__c = pbun.Id);
        insert new QuoteLineItem(QuoteId = q.Id,PricebookEntryId=pbe.Id, Quantity=2, UnitPrice=8.25, Product2Id=pbe.Product2Id);
        QuotePdfController qpdf = new QuotePdfController();
        qpdf.qId = q.Id;
        
    }
    
    @isTest static void test2() {
        Account a = new Account(name='test');
        insert a;
        Pricebook2 pb = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1];
        Invoice__c i = new Invoice__c(Account__c=a.Id,Name='test',CurrencyIsoCode='EUR');
        insert i;
        PricebookEntry pbe = [SELECT Id, Product2Id FROM PricebookEntry WHERE Pricebook2Id = :pb.Id  LIMIT 1];
        Subscription__c s = new Subscription__c(Account__c=a.Id, ZuoraId__c='test');
        insert s;
        SubscriptionLineItem__c sl = new SubscriptionLineItem__c(Subscription__c = s.Id, Product__c=pbe.Product2Id, ZuoraId__c='test_sli');
        insert sl;
        insert new InvoiceLineItem__c(Invoice__c = i.Id,SubscriptionLineItem__c=sl.Id, Quantity__c=1, ChargeAmount__c=0);
        insert new InvoiceLineItem__c(Invoice__c = i.Id,SubscriptionLineItem__c=sl.Id, Quantity__c=2, ChargeAmount__c=0);
        InvoicePdfController ipdf = new InvoicePdfController();
        ipdf.iId = i.Id;
        
    }
    
    @isTest static void test2vat() {
        Account a = new Account(name='test');
        insert a;
        Pricebook2 pb = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1];
        Invoice__c i = new Invoice__c(Account__c=a.Id,Name='test',CurrencyIsoCode='EUR', ZuoraId__c ='inv');
        insert i;
        PricebookEntry pbe = [SELECT Id, Product2Id FROM PricebookEntry WHERE Pricebook2Id = :pb.Id  LIMIT 1];
        Subscription__c s = new Subscription__c(Account__c=a.Id, ZuoraId__c='test');
        insert s;
        SubscriptionLineItem__c sl = new SubscriptionLineItem__c(Subscription__c = s.Id, Product__c=pbe.Product2Id, ZuoraId__c='test_sli');
        insert sl;
        insert new InvoiceLineItem__c(Invoice__c = i.Id,SubscriptionLineItem__c=sl.Id, Quantity__c=1, ChargeAmount__c=0, ZuoraId__c = 'ili1');
        insert new InvoiceLineItem__c(Invoice__c = i.Id,SubscriptionLineItem__c=sl.Id, Quantity__c=2, ChargeAmount__c=0, ZuoraId__c = 'ili2');
        Invoice__c i2 = new Invoice__c(Account__c=a.Id,Name='test',CurrencyIsoCode='EUR');
        insert i2;
        Subscription__c s2 = new Subscription__c(Account__c=a.Id, ZuoraId__c='test2');
        insert s2;
        SubscriptionLineItem__c sl2 = new SubscriptionLineItem__c(Subscription__c = s.Id, Product__c=pbe.Product2Id, ZuoraId__c='test_sli2', vat_ref__c = 'inv|ili1;ili2');
        insert sl2;
        insert new InvoiceLineItem__c(Invoice__c = i2.Id,SubscriptionLineItem__c=sl2.Id, Quantity__c=1, ChargeAmount__c=10);
        insert new InvoiceLineItem__c(Invoice__c = i2.Id,SubscriptionLineItem__c=sl2.Id, Quantity__c=2, ChargeAmount__c=-10);
        InvoicePdfController ipdf = new InvoicePdfController();
        ipdf.iId = i2.Id;
        
    }
    
    @isTest static void test2ob() {
        Account a = new Account(name='test', CurrencyIsoCode = 'EUR');
        insert a;
        Pricebook2 pb = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1];
        //OBInvoice__c i = new OBInvoice__c(Account__c=a.Id,Name='test',CurrencyIsoCode='EUR',ExternalId__c='123');
        //insert i;
        PricebookEntry pbe = [SELECT Id, Product2Id FROM PricebookEntry WHERE Pricebook2Id = :pb.Id  LIMIT 1];
        Subscription__c s = new Subscription__c(Account__c=a.Id, ZuoraId__c='test');
        insert s;
        SubscriptionLineItem__c sl = new SubscriptionLineItem__c(Subscription__c = s.Id, Product__c=pbe.Product2Id, ZuoraId__c='test_sli');
        insert sl;
        insert new OBInvoiceItem__c(InvoiceName__c = '123', SubscriptionLineItem__c=sl.Id, Quantity__c=1, ChargeAmount__c=0);
        insert new OBInvoiceItem__c(InvoiceName__c = '123', SubscriptionLineItem__c=sl.Id, Quantity__c=2, ChargeAmount__c=0);
        obInvoicePdfController ipdf = new obInvoicePdfController();
        ipdf.iId = [SELECT Id FROM ObInvoice__c LIMIT 1].Id;
        
    }
    
    @isTest static void test3() {
        Account a = new Account(name='test');
        insert a;
        AccountLightningController.updateAddressBuilder(a.Id, 'Shipping','test');
        AccountLightningController.updateAddressBuilder(a.Id, 'Billing','test');
        AccountLightningController.updateAddressBuilder(a.Id, 'Venue','test');
        String s = AccountLightningController.getAddressBuilder(a.Id, 'Shipping');
        s = AccountLightningController.getAddressBuilder(a.Id, 'Billing');
        s = AccountLightningController.getAddressBuilder(a.Id, 'Venue');
        s = AccountLightningController.getAccountContacts(a.Id);
        system.debug(json.serialize(AccountLightningController.getRelatedDocuments(a.Id)));
        AccountLightningController.RelatedDoc rd = new AccountLightningController.RelatedDoc('t','e','s','t',datetime.now());
    }
    
    @isTest static void test4() {
        AccountLightningController.getVATVerify('DE812639372');
        Account a = new Account(name='test');
        insert a;
        Contact c = new Contact(lastname='test',accountid=a.Id,email='test@test.com');
        insert c;
        a.SF_BillTo_Contact__c = c.id;
        update a;
        AccountLightningController.saveVAT(a.Id, true, '{"vatID":"test","name":"test","address":"at-3124 test"}');
        AccountLightningController.sendMyObRegistrationEmail(c.Id, 'German');
        MyObVenue__c v = new MyObVenue__c(Contact__c=c.Id);
        insert v;
        system.debug(AccountLightningController.matchContacts(v.Id));
        AccountLightningController.confirmObVenue(v.Id);
        system.debug(json.serialize(AccountLightningController.getObWarning(a.Id)));
        system.debug(AccountLightningController.matchContacts(v.Id));
    }
    
    @isTest static void test5() {
        system.debug(json.serialize(AccountLightningController.getMyObVenues('test')));
    }
}