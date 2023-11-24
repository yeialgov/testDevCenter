@isTest public class InterwegaController_Test {
    static TestMethod void test1() {
        insert new Account(name='test',Interwega_Status__c='test');
        Integer i = InterwegaController.CountInterwega();
        String s = InterwegaController.ClearInterwega();
        system.assertEquals(1, i);
        system.assertEquals('OK', s);
    }
    
    static TestMethod void test2() {
        Account a = new Account(name='test');
        insert a;
        String custId = [SELECT Id, CustomerId__c FROM Account WHERE Id=:a.Id LIMIT 1].CustomerId__c;
        insert new Interwega_Import__c(CustomerId__c=custId, Interwega_Status__c='test');
    }

    static TestMethod void test3() {
        insert new Account(name='test',Interwega_Status__c='test');
        Database.executeBatch(new InterwegaBatch());
    }
}