@isTest public class Instalment_test {

    static TestMethod void test1() {
        Account a = new Account(name='test', Batch__c='Batch4', ZuoraId__c='t');
        insert a;
        insert new Invoice__c(Account__c=a.Id,CustomerAccount__c=a.Id,Status__c='Posted');
        insert new Subscription__c(Account__c=a.Id, ServiceActivationDate__c=Date.today(), ZuoraId__c='t');
        insert new Payment__c(Account__c=a.Id, ZuoraId__c='t');
        InstalmentBillRun b = new InstalmentBillRun(); 
        database.executebatch(b, 50);
    }
    
    static TestMethod void test1a() {
        Account a = new Account(name='test', Batch__c='Batch4', ZuoraId__c='t');
        insert a;
        PaymentMethod__c pm = new PaymentMethod__c(Name='t',BankTransferAccountNumberMask__c='t',Account__c = a.Id, BankTransferType__c = 'SEPA', PaymentMethodStatus__c = 'Active', ZuoraId__c = 't');
        insert pm;
        a.DefaultPaymentMethod__c = pm.Id;
        update a;
        insert new Subscription__c(Account__c=a.Id, ServiceActivationDate__c=Date.today(), ZuoraId__c='t');
        insert new Invoice__c(Account__c=a.Id, ZuoraId__c='t', Balance__c=10, Status__c='Posted');
        InstalmentPaymentRun b = new InstalmentPaymentRun(); 
        database.executebatch(b, 50);
    }
    
    static TestMethod void test2() {
        System.schedule('test', '0 0 0 3 9 ? 2022', new InstalmentBillRun_scheduler());
        System.schedule('test2', '0 0 0 3 9 ? 2022', new InstalmentPaymentRun_scheduler());
    }

}