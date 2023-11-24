@isTest
public class CCPD_Calculator_Test {

    @isTest static void defaultValue() {
        Account acc = new Account(name='Test', PaymentTerm__c='test');
        insert acc;
        Invoice__c inv = new Invoice__c(Account__c = acc.Id, CustomerAccount__c = acc.Id, Amount__c = 100, Balance__c = 90, Status__c='Posted');
        insert inv;
        insert new InvoiceLineItem__c(Invoice__c=inv.Id, ChargeName__c='Payment by Instalments Setup Fee');
        Payment__c pay = new Payment__c(Account__c = acc.Id, ZuoraId__c = 'x');
        insert pay;
        InvoicePayment__c ip = new InvoicePayment__c(Invoice__c = inv.Id, Payment__c = pay.Id, ZuoraId__c = 'x');
        insert ip;
        Subscription__c sub = new Subscription__c(Account__c = acc.Id, Status__c = 'Active', ZuoraId__c ='x');
        insert sub;
        
        Database.executeBatch(new CCPD_Calculator());
        
    }
    
    @isTest static void alternateValue() {
        Account acc = new Account(name='Test', PaymentTerm__c='test');
        insert acc;
        Invoice__c inv = new Invoice__c(Account__c = acc.Id, CustomerAccount__c = acc.Id, Balance__c = 0);
        insert inv;
        Payment__c pay = new Payment__c(Account__c = acc.Id, ZuoraId__c = 'x');
        insert pay;
        InvoicePayment__c ip = new InvoicePayment__c(Invoice__c = inv.Id, Payment__c = pay.Id, ZuoraId__c = 'x');
        insert ip;
        Subscription__c sub = new Subscription__c(Account__c = acc.Id, Status__c = 'Active', ZuoraId__c ='x');
        insert sub;
        
        Database.executeBatch(new CCPD_Calculator());
        
    }
    
    @isTest static void test2() {
        CCPD_Calculator c = new CCPD_Calculator();
        Date d = c.ConvertDateTime(DateTime.newInstance(2019, 1, 1), Date.newInstance(2019, 2, 2));
    }

}