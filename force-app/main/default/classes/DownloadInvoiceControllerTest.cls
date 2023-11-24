/**
 * Created by keylight
 */
@isTest
public class DownloadInvoiceControllerTest {

	@isTest
	static void testDownloadInvoiceController() {
		Test.setMock(HttpCalloutMock.class, new ZuoraHttpCalloutMock());
		Account a = new Account(name='test');
        insert a;
		Invoice__c invoice = new Invoice__c(ZuoraId__c='2345',Account__c=a.Id);
		insert invoice;

		Test.startTest();
		ApexPages.StandardController standardController = new ApexPages.StandardController(invoice);
		DownloadInvoiceController invoiceController = new DownloadInvoiceController(standardController);
		String result = invoiceController.getDisplay();
		System.assertEquals('Test', result);
		Test.stopTest();
	}
}