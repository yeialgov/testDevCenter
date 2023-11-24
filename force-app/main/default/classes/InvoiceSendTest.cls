@isTest(seeAllData=true)
public class InvoiceSendTest {

    static testMethod void testScheduler() {
        Account a = new Account(name='account');
        insert a;
        Contact c = new Contact(lastname='test',email='test@orderbird.com');
        insert c;
        a.SF_BillTo_Contact__c = c.Id;
        update a;
        Invoice__c inv = new Invoice__c(Status__c = 'Posted',Account__c = a.Id,InvoiceDate__c=date.today(),Amount__c=0);
        insert inv;
        test.startTest();
 		InvoiceSendScheduler dbs = new InvoiceSendScheduler();
        String sch = '0 0 23 * * ?';
        system.schedule('Test check', sch, dbs);
        test.stopTest();
    }

}