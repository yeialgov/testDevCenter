@isTest public class DailyBatcher_test {

    static TestMethod void test() {
        Account a = new Account(name='test');
        insert a;
        Opportunity o = new Opportunity(Name='test', StageName='New', CloseDate=Date.today(), AccountId=a.Id, LAC_Shorthand__c='Walk-In');
        insert o;
        List<Batch_Object__mdt> Objects = [SELECT DeveloperName FROM Batch_Object__mdt];
        for (Batch_Object__mdt Obj : Objects) database.executeBatch(new dailybatcher(Obj.DeveloperName));
        String jobId = System.schedule('test', '0 0 0 3 9 ? 2022', new DailyBatcher_scheduler());
    }
    
}