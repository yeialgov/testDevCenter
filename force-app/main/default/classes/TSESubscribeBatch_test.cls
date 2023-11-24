@isTest(seeAllData=true) public class TSESubscribeBatch_test {

    static TestMethod void test() {
        Account a = new Account(name='test', currencyisocode='EUR');
        insert a;
        Contact c = new Contact(lastname='test', accountid=a.id, email='test@test.com');
        insert c;
        insert new MyObVenue__c(Contact__c = c.Id, Wizard_Complete__c = DateTime.now());
        TSESubscribeBatch tsb = new TSESubscribeBatch();
        Boolean b = TSESubscribeBatch.IsRenewalDateTooSoon(Date.today().addDays(1), date.today());
        test.startTest();
 		TSESubscribeBatch dbs = new TSESubscribeBatch();
        String sch = '0 0 23 * * ?';
        system.schedule('Test check', sch, dbs);
        test.stopTest();
    }
    
    static TestMethod void test2() {
        Account a = new Account(name='test', currencyisocode='EUR');
        insert a;
        Contact c = new Contact(lastname='test', accountid=a.id, email='test@test.com');
        insert c;
        insert new MyObVenue__c(Contact__c = c.Id, Wizard_Complete__c = DateTime.now());
        Subscription__c sub = new Subscription__c(Account__c = a.Id, ZuoraId__c = 'test');
        insert sub;
        SubscriptionLineItem__c sli = new SubscriptionLineItem__c(Subscription__c = sub.Id, ZuoraId__c = 'test', EffectiveStartDate__c = Date.newInstance(2018, 3, 4));
        insert sli;
        SubscriptionLineItem__c sliQ = [SELECT Id, ESD_Matches_SubTSD__c, EffectiveStartDate__c, Subscription__r.Account__c, Subscription__r.Account__r.CurrencyIsoCode, Subscription__r.InvoiceOwner__c,
                                        Subscription__r.TermType__c, Subscription__r.Status__c, Subscription__r.ZuoraId__c, Subscription__r.Account__r.ZuoraId__c
                                        FROM SubscriptionLineItem__c WHERE Id = :sli.Id LIMIT 1
                                       ];
        TSESubscribeBatch tsb = new TSESubscribeBatch();
        String s = TSESubscribeBatch.SimpleProrate(sliQ, date.today());
        s = TSESubscribeBatch.ComplexProrate(sliQ, date.today());
        Boolean b = TSESubscribeBatch.EvalSub(sliQ);
        s = TSESubscribeBatch.PerformSP(sliQ, date.today());
        s = TSESubscribeBatch.ExecSP(sliQ, date.today());
    }
}