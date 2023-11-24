@isTest public class BillingBatchUpdater_Test {

    static TestMethod void test() {
        insert new Account(Name='Test',Batch__c='Batch1');
        Database.executeBatch(new BillingBatchUpdater(), 50);
    }
    
    static TestMethod void test2() {
        String jobId = System.schedule('test', '0 0 0 3 9 ? 2022', new BillingBatchUpdater_Scheduler());
    }

}