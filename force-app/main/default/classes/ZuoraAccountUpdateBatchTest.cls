/**
 * @author keylight
 */
@isTest
private class ZuoraAccountUpdateBatchTest {
	@isTest static void constructer_test() {
		Account account = new Account(Name='Test');
		String zuoraId = 'test';
		ZuoraAccountUpdate accountUpdate = new ZuoraAccountUpdate(account, zuoraId);
		List<ZuoraAccountUpdate> accountUpdates = new List<ZuoraAccountUpdate>();
		accountUpdates.add(accountUpdate);
		ZuoraAccountUpdateBatch zBatch = new ZuoraAccountUpdateBatch(accountUpdates);
		System.assertEquals(accountUpdates, zBatch.accountUpdates);
    }

    @isTest static void start_should_set_accounts() {
		Account account = new Account(Name='Test');
		insert account;
		String zuoraId = 'test';
		ZuoraAccountUpdate accountUpdate = new ZuoraAccountUpdate(account, zuoraId);
		List<ZuoraAccountUpdate> accountUpdates = new List<ZuoraAccountUpdate>();
		accountUpdates.add(accountUpdate);
		ZuoraAccountUpdateBatch zBatch = new ZuoraAccountUpdateBatch(accountUpdates);
		zBatch.start(null);
		System.assertEquals(1, zBatch.accounts.size());
		System.assertEquals(true, zBatch.accounts.containsKey(account.Id));
    }

    @isTest static void start_should_set_failed_sync_to_false() {
    	Test.setMock(HttpCalloutMock.class, new ZuoraHttpCalloutMock());
		Account account = new Account(Name='Test', ZuoraSyncFailed__c=true);
		insert account;
		String zuoraId = 'test';
		ZuoraAccountUpdate accountUpdate = new ZuoraAccountUpdate(account, zuoraId);
		List<ZuoraAccountUpdate> accountUpdates = new List<ZuoraAccountUpdate>();
		accountUpdates.add(accountUpdate);
		accountUpdates.add(accountUpdate);
		ZuoraAccountUpdateBatch zBatch = new ZuoraAccountUpdateBatch(accountUpdates);
		zBatch.start(null);
		Test.startTest();
		zBatch.execute(null, accountUpdates);
		Test.stopTest();
		zBatch.finish(null);
		Account updatedAccount = [SELECT Id, ZuoraSyncFailed__c FROM Account WHERE Id =:account.Id];
		System.assertEquals(false, updatedAccount.ZuoraSyncFailed__c);
    }    

    @isTest static void start_should_set_failed_sync_to_true() {
    	Test.setMock(HttpCalloutMock.class, new ZuoraHttpCalloutMock(true));
		Account account = new Account(Name='Test', ZuoraSyncFailed__c=false);
		insert account;
		String zuoraId = 'test';
		ZuoraAccountUpdate accountUpdate = new ZuoraAccountUpdate(account, zuoraId);
		List<ZuoraAccountUpdate> accountUpdates = new List<ZuoraAccountUpdate>();
		accountUpdates.add(accountUpdate);
		ZuoraAccountUpdateBatch zBatch = new ZuoraAccountUpdateBatch(accountUpdates);
		zBatch.start(null);
		Test.startTest();
		zBatch.execute(null, accountUpdates);
		Test.stopTest();
		zBatch.finish(null);
		Account updatedAccount = [SELECT Id, ZuoraSyncFailed__c FROM Account WHERE Id =:account.Id];
		System.assertEquals(true, updatedAccount.ZuoraSyncFailed__c);
    }    
}