@isTest public class DeletionTriggerTest {

    static TestMethod void test() {
        Account a = new Account(name='test');
        insert a;
        Contact c = new Contact(lastname = 'test', accountId = a.Id);
        insert c;
        Invoice__c i = new Invoice__c(Account__c = a.Id);
        insert i;
        InvoiceLineItem__c ii = new InvoiceLineItem__c(Invoice__c = i.Id);
        insert ii;
        MyObVenue__c v = new MyObVenue__c(Contact__c = c.Id, MyOrderbirdId__c = 'test');
        insert v;
        try{ delete v; } catch(exception e){}
        try{ delete ii; } catch(exception e){}
        try{ delete i; } catch(exception e){}
    }
}