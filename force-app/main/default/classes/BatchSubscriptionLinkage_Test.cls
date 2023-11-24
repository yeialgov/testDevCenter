@isTest public class BatchSubscriptionLinkage_Test {

    static TestMethod void test1() {
        Account a = new Account(name = 'Test');
        insert a;
        Subscription__c s1 = new Subscription__c(account__c = a.Id, zuoraid__c = 'test1', name='Test', version__c = 1);
        insert s1;
        SubscriptionLineItem__c sli1 = new SubscriptionLineItem__c(subscription__c = s1.Id, name='Test', zuoraid__c = 'test1');
        insert sli1;
        Subscription__c s2 = new Subscription__c(account__c = a.Id, zuoraid__c = 'test2', name='Test', version__c = 2);
        insert s2;
        SubscriptionLineItem__c sli2 = new SubscriptionLineItem__c(subscription__c = s2.Id, name='Test', zuoraid__c = 'test');
        insert sli2;
        database.executeBatch(new BatchSubscriptionLinkage(true));
        database.executeBatch(new BatchSLILinkage(true));
    }
    
    static TestMethod void test2() {
        Account a = new Account(name = 'Test');
        insert a;
        Subscription__c s1 = new Subscription__c(account__c = a.Id, zuoraid__c = 'test1', name='Test', version__c = 1);
        insert s1;
        SubscriptionLineItem__c sli1 = new SubscriptionLineItem__c(subscription__c = s1.Id, name='Test', zuoraid__c = 'test1');
        insert sli1;
        Subscription__c s2 = new Subscription__c(PrecedingSubscription__c = s1.Id, account__c = a.Id, zuoraid__c = 'test2', name='Test', version__c = 2);
        insert s2;
        SubscriptionLineItem__c sli2 = new SubscriptionLineItem__c(precedingsli__c = sli1.id, subscription__c = s2.Id, name='Test', zuoraid__c = 'test');
        insert sli2;
        database.executeBatch(new BatchSubscriptionLinkage(false));
        database.executeBatch(new BatchSLILinkage(false));
    }

    static TestMethod void test3() {
        String jobId = System.schedule('test', '0 0 0 3 9 ? 2022', new BatchSubscriptionLinkage_Sched_P());
    }

    static TestMethod void test4() {
        String jobId = System.schedule('test', '0 0 0 3 9 ? 2022', new BatchSubscriptionLinkage_Sched_S());
    }

    static TestMethod void test5() {
        String jobId = System.schedule('test', '0 0 0 3 9 ? 2022', new BatchSLILinkage_Sched_P());
    }

    static TestMethod void test6() {
        String jobId = System.schedule('test', '0 0 0 3 9 ? 2022', new BatchSLILinkage_Sched_S());
    }

}