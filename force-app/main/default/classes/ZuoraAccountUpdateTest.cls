/**
 * @author keylight
 */
@IsTest
private class ZuoraAccountUpdateTest {
	@isTest static void constructer_test() {
		Account a = new Account();
		String zId = 'test';
		ZuoraAccountUpdate au = new ZuoraAccountUpdate(a, zId);
        System.assertEquals(a, au.account);
        System.assertEquals(zId, au.zuoraId);
    }

    @isTest static void should_return_json() {
		Account a = new Account(
				Name='AccountName',
				LegalCompanyName__c='Test',
				NS_Customer_Internal_ID__c='Test2',
				myOrderbirdEmail__c='email',
				taxExempted__c=true,
				VATNumber__c='111',
				Tax_Exempt_Reason__c='EU reverse charge mechanism');
		String zId = 'test';
		ZuoraAccountUpdate au = new ZuoraAccountUpdate(a, zId);
		String json = au.toJson();
        System.assertEquals('{"LegalCompanyName__c":"Test","NS_Customer_Internal_ID__c":"Test2","myOrderbirdEmail__c":"email","Tax_Exempt_Reason__c":"EUreversechargemechanism","name":"AccountName","taxInfo":{"VATId":"111","exemptStatus":"Yes"}}', json.deleteWhitespace());
    }

     @isTest static void run_send() {
     	Test.setMock(HttpCalloutMock.class, new ZuoraHttpCalloutMock());
		Account a = new Account(Name='Test', LegalCompanyName__c='Test', NS_Customer_Internal_ID__c='Test2', myOrderbirdEmail__c='email');
		String zId = 'test';
		ZuoraAccountUpdate au = new ZuoraAccountUpdate(a, zId);
		au.send();
    }
}