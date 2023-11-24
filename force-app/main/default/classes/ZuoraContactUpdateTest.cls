/**
 * @author keylight
 */
@IsTest
private class ZuoraContactUpdateTest {
	@isTest static void constructer_test() {
		Contact c = new Contact();
		String zId = 'test';
		ZuoraContactUpdate cu = new ZuoraContactUpdate(c, zId);
        System.assertEquals(c, cu.contact);
        System.assertEquals(zId, cu.zuoraId);
    }

    @isTest static void should_return_json() {
		Contact c = new Contact(FirstName='Test', LastName='Test2');
		String zId = 'test';
		ZuoraContactUpdate cu = new ZuoraContactUpdate(c, zId);
		String json = cu.toJson();
        System.assertEquals('{"Description":"","FirstName":"Test","LastName":"Test2"}', json.deleteWhitespace());
    }

     @isTest static void run_send() {
     	Test.setMock(HttpCalloutMock.class, new ZuoraHttpCalloutMock());
		Contact c = new Contact(FirstName='Test', LastName='Test2', Addressee__c='Test', Attention__c='Test');
		String zId = 'test';
		ZuoraContactUpdate cu = new ZuoraContactUpdate(c, zId);
		cu.send();
    }
}