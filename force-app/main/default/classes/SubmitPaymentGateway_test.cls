@isTest public class SubmitPaymentGateway_test {

    static TestMethod void test() {
        Account a = new Account(name='test');
        insert a;
        insert new Payment__c(NeedsAttention__c = true, ZuoraId__c = 'abc', Account__c = a.Id);
        String jobId = System.schedule('test', '0 0 0 3 9 ? 2022', new SubmitPaymentGateway_sched());
    }
    
    static TestMethod void test2() {
        Account a = new Account(name='test');
        insert a;
        insert new Payment__c(NeedsAttention__c = true, ZuoraId__c = 'abc', Account__c = a.Id);
        SubmitPaymentGateway.SubmitPayment();
    }
}