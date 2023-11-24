/**
 * @author keylight
 */
@isTest
private class ZuoraContactUpdateBatchTest {
	@isTest static void constructer_test() {
		Contact contact = new Contact(LastName='Test');
		String zuoraId = 'test';
		ZuoraContactUpdate contactUpdate = new ZuoraContactUpdate(contact, zuoraId);
		List<ZuoraContactUpdate> contactUpdates = new List<ZuoraContactUpdate>();
		contactUpdates.add(contactUpdate);
		ZuoraContactUpdateBatch zBatch = new ZuoraContactUpdateBatch(contactUpdates);
		System.assertEquals(contactUpdates, zBatch.contactUpdates);
    }

    @isTest static void start_should_set_contacts() {
		Contact contact = new Contact(LastName='Test');
		insert contact;
		String zuoraId = 'test';
		ZuoraContactUpdate contactUpdate = new ZuoraContactUpdate(contact, zuoraId);
		List<ZuoraContactUpdate> contactUpdates = new List<ZuoraContactUpdate>();
		contactUpdates.add(contactUpdate);
		ZuoraContactUpdateBatch zBatch = new ZuoraContactUpdateBatch(contactUpdates);
		zBatch.start(null);
		System.assertEquals(1, zBatch.contacts.size());
		System.assertEquals(true, zBatch.contacts.containsKey(contact.Id));
    }

    @isTest static void start_should_set_failed_sync_to_false() {
    	Test.setMock(HttpCalloutMock.class, new ZuoraHttpCalloutMock());
		Contact contact = new Contact(LastName='Test', ZuoraSyncFailed__c=true);
		insert contact;
		String zuoraId = 'test';
		ZuoraContactUpdate contactUpdate = new ZuoraContactUpdate(contact, zuoraId);
		List<ZuoraContactUpdate> contactUpdates = new List<ZuoraContactUpdate>();
		contactUpdates.add(contactUpdate);
		contactUpdates.add(contactUpdate);
		ZuoraContactUpdateBatch zBatch = new ZuoraContactUpdateBatch(contactUpdates);
		zBatch.start(null);
		Test.startTest();
		zBatch.execute(null, contactUpdates);
		Test.stopTest();
		zBatch.finish(null);
		Contact updatedContact = [SELECT Id, ZuoraSyncFailed__c FROM Contact WHERE Id =:contact.Id];
		System.assertEquals(false, updatedContact.ZuoraSyncFailed__c);
    }    

    @isTest static void start_should_set_failed_sync_to_true() {
    	Test.setMock(HttpCalloutMock.class, new ZuoraHttpCalloutMock(true));
		Contact contact = new Contact(LastName='Test', ZuoraSyncFailed__c=false);
		insert contact;
		String zuoraId = 'test';
		ZuoraContactUpdate contactUpdate = new ZuoraContactUpdate(contact, zuoraId);
		List<ZuoraContactUpdate> contactUpdates = new List<ZuoraContactUpdate>();
		contactUpdates.add(contactUpdate);
		ZuoraContactUpdateBatch zBatch = new ZuoraContactUpdateBatch(contactUpdates);
		zBatch.start(null);
		Test.startTest();
		zBatch.execute(null, contactUpdates);
		Test.stopTest();
		zBatch.finish(null);
		Contact updatedContact = [SELECT Id, ZuoraSyncFailed__c FROM Contact WHERE Id =:contact.Id];
		System.assertEquals(true, updatedContact.ZuoraSyncFailed__c);
    }    
}