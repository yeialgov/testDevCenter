@isTest public class InvoiceUpdater_Test {

    static TestMethod void test() {
        insert new Account(Name='Test',Batch__c='Batch1');
        Database.executeBatch(new InvoiceUpdater(), 50);
        Database.executeBatch(new InvoiceUpdater(false), 50);
        Database.executeBatch(new InvoiceUpdater(true), 50);
    }
    
    static TestMethod void test2() {
        String jobId = System.schedule('test', '0 0 0 3 9 ? 2022', new InvoiceUpdater_Scheduler());
    }

}