@isTest public class BillRunForPrepayers_Test {
    
    static TestMethod void test1() {
        Account a = new Account(name='test', Batch__c='Batch7', ZuoraId__c='t');
        insert a;
        insert new Subscription__c(Account__c=a.Id, ServiceActivationDate__c=Date.today(), ZuoraId__c='t');
        insert new Payment__c(Account__c=a.Id, ZuoraId__c='t');
        BillRunForPrepayers b = new BillRunForPrepayers(); 
        database.executebatch(b, 50);
    }
    
    static TestMethod void test2() {
        String jobId = System.schedule('test', '0 0 0 3 9 ? 2022', new BillRunForPrepayers_Scheduler());
    }
    
}