@isTest public class CreditBalanceAdjuster_test {

    static TestMethod void test() {
        Account a = new Account(name='test',Credit_Balance__c=12.34);
        insert a;
        insert new Invoice__c(Account__c=a.Id, Balance__c=10.01, Status__c='Posted', InvoiceDate__c=Date.today());
        Invoice__c inv = new Invoice__c(Account__c=a.Id, ZuoraId__c='z', Status__c='Posted', InvoiceDate__c=Date.today());
        insert inv;
        Subscription__c sub = new Subscription__c(Account__c=a.Id, ZuoraId__c='z');
        insert sub;
        SubscriptionLineItem__c sli = new SubscriptionLineItem__c(Subscription__c=sub.Id, ZuoraId__c='z');
        insert sli;
        insert new InvoiceLineItem__c(Invoice__c=inv.Id,SubscriptionLineItem__c=sli.Id, ZuoraId__c='z'); 
        insert new CreditBalanceAdjustment__c(Account__c=a.Id,Amount__c=9.10,Invoice__c=inv.Id,SourceTransactionType__c='Invoice',Type__c='Increase');
        Database.executeBatch(new CreditBalanceAdjuster());
    }

    static TestMethod void test2() {
        String jobId = System.schedule('test', '0 0 0 3 9 ? 2022', new CreditBalanceAdjuster_Scheduler());
    }

}