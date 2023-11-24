@isTest
public class AccountStatementExtensionTest {

    static testMethod void stdCont() {
        
        Account a = new Account(name='test');
        insert a;
        
        insert new Invoice__c(Account__c = a.Id, Amount__c = 123.45, ZuoraId__c = 'test');
        insert new Payment__c(Account__c = a.Id, Amount__c = 67.89, Status__c = 'Processed', ZuoraId__c = 'test', EffectiveDate__c = Datetime.now());
        insert new Refund__c(Account__c = a.Id, Amount__c = 10.11, ZuoraId__c = 'test', Status__c = 'Processed');

		ApexPages.StandardController sc = new ApexPages.StandardController(a);

        AccountStatementController ac = new AccountStatementController();
        ac.acctId = a.Id;
        ac.init();
       
        
    }

}