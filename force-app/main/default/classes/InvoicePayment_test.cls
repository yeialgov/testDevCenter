@isTest public class InvoicePayment_test {

    static testMethod void test() {
    
        Account a = new Account(name='test');
        insert a;
        Invoice__c i = new Invoice__c(Account__c = a.Id, ZuoraId__c = 'test');
        insert i;
        Payment__c p = new Payment__c(Account__c = a.Id, ZuoraId__c = 'test');
        insert p;
        InvoicePayment__c ip = new InvoicePayment__c(
            Invoice__c = i.Id, Payment__c = p.Id, ZuoraId__c = 'test', IsQualifyingPayment__c = false
        );
        insert ip;
        ip.IsQualifyingPayment__c = true;
        update ip;
        system.debug(json.serialize([select id, isqualifyingpayment__c, isqualifyingpayment_formula__c from invoicepayment__c]));
        Database.executeBatch(new InvoicePayment_batch());
        String jobId = System.schedule('test', '0 0 0 3 9 ? 2022', new InvoicePayment_scheduler());

    
    }

}