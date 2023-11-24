@isTest(seeAllData=true)
public class OBInvoiceSendTest {

    static testMethod void testScheduler() {
        OBInvoice__c inv = new OBInvoice__c(Addressee__c='test',ExternalId__c='x',Email__c='test@test.com',InvoiceDate__c=date.today(),Amount__c=0);
        insert inv;
        test.startTest();
 		OBInvoiceSendScheduler dbs = new OBInvoiceSendScheduler();
        String sch = '0 0 23 * * ?';
        system.schedule('Test check', sch, dbs);
        test.stopTest();
    }

}