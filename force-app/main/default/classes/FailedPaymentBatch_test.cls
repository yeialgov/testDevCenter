@isTest(seeAllData=true) public class FailedPaymentBatch_test {

    static TestMethod void test1() {
        Account a = new Account(name='isRunning Test Account');
        insert a;
        Refund__c ref = new Refund__c(name='test',account__c=a.id,zuoraid__c='test');
        insert ref;
        database.executeBatch(new FailedPaymentBatch());
    }

	static TestMethod void test2() {
        Account a = new Account(name='isRunning Test Account', Target_Product__c='MINI');
        insert a;
        Refund__c ref = new Refund__c(name='test',account__c=a.id,zuoraid__c='test');
        insert ref;
        database.executeBatch(new FailedPaymentBatch());
    }

    static TestMethod void test3() {
        Account a = new Account(name='isRunning Test Account',currencyisocode='EUR');
        insert a;
        Contact c = new Contact(lastname='test', email='test@test.com', accountid=a.id);
        insert c;
        MyObVenue__c v = new MyObVenue__c(Contact__c=c.Id,LastOpenShiftTimestamp__c=datetime.now(),ChurnPrediction__c=0.9);
        insert v;
        Refund__c ref = new Refund__c(name='test',account__c=a.id,zuoraid__c='test');
        insert ref;
        Product2 p1 = new Product2(name='test1',ZuoraId__c='test1');
        insert p1;
        Product2 p = new Product2(name='test',downshiftsto__c=p1.id,ZuoraId__c='test');
        insert p;
        Id Pricebook2Id = [SELECT Id From Pricebook2 WHERE Key__c = 'Main' LIMIT 1].Id;
        PriceBookEntry pbe1 = new PriceBookEntry(Pricebook2Id=Pricebook2Id,Key__c='EUR:test1',UnitPrice=12.34,Product2Id=p1.Id,IsActive=true);
        insert pbe1;
        PriceBookEntry pbe = new PriceBookEntry(Pricebook2Id=Pricebook2Id,Key__c='EUR:test',UnitPrice=12.34,Product2Id=p.Id,IsActive=true);
        insert pbe;
        Subscription__c sub = new Subscription__c(Account__c=a.Id,ZuoraId__c='test',Status__c='Active');
        insert sub;
        SubscriptionLineItem__c sli = new SubscriptionLineItem__c(name='test',Subscription__c=sub.Id,Product__c=p.Id,ZuoraId__c='test');
        insert sli;
        Invoice__c inv = new Invoice__c(name='test',account__c=a.id,zuoraid__c='test',amount__c=12.34,balance__c=12.34);
        insert inv;
        InvoiceLineItem__c ili = new InvoiceLineItem__c(Invoice__c=inv.id, ServiceStartDate__c = date.today().addDays(-10),ZuoraId__c='test',subscriptionlineitem__c=sli.id);
        insert ili;
        database.executeBatch(new FailedPaymentBatch());
    }
    
    static TestMethod void test4() {
        system.schedule('jobName', '0 0 0 * * ?', new FailedPaymentBatch_Scheduler());
    }
}