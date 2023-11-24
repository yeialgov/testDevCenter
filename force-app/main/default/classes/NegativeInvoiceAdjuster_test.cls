@isTest public class NegativeInvoiceAdjuster_test {

    static testMethod void test1() {
        Account a = new Account(name='test');
        insert a;
        insert new Invoice__c(Account__c=a.Id, Balance__c=-10.01, Status__c='Posted', InvoiceDate__c=Date.today(), ZuoraId__c='z');
        Database.executeBatch(new NegativeInvoiceAdjuster());
    }

    static TestMethod void test2() {
        String jobId = System.schedule('test', '0 0 0 3 9 ? 2022', new NegativeInvoiceAdjuster_scheduler());
    }

}