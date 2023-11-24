@isTest public class AccountStatus_Calculator_Test {

    static TestMethod void test1() {
        Account a = new Account(name='test');
        insert a;
        Subscription__c s = new Subscription__c(Account__c=a.Id, ZuoraId__c='test');
        insert s;
        SubscriptionLineItem__c sli = new SubscriptionLineItem__c(Subscription__c=s.Id, ZuoraId__c='test');
        insert sli;
        Database.executeBatch(new AccountStatus_Calculator());
        String jobId = System.schedule('test', '0 0 0 3 9 ? 2022', new AccountStatus_Scheduler());
    }
}