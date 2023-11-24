/**
 * @author keylight
 */
global class ZuoraAccountUpdateBatch implements Database.Batchable<ZuoraAccountUpdate>, Database.AllowsCallouts, Database.Stateful {
	@TestVisible private Map<ID, Account> accounts;
	@TestVisible private List<ZuoraAccountUpdate> accountUpdates;
	private Map<ID, Account> accountsToUpdate = new Map<ID, Account>();

	global ZuoraAccountUpdateBatch(List<ZuoraAccountUpdate> accountUpdates) {
		this.accountUpdates = accountUpdates;
	}
	
	global Iterable<ZuoraAccountUpdate> start(Database.BatchableContext BC) {
		List<ID> accountIds = new List<ID>();
		for (ZuoraAccountUpdate accountUpdate : this.accountUpdates) {
			accountIds.add(accountUpdate.account.Id);
		}
		this.accounts = new Map<ID, Account>([SELECT Id, ZuoraSyncFailed__c FROM Account WHERE Id IN :accountIds]);
		return this.accountUpdates;
	}

   	global void execute(Database.BatchableContext BC, List<ZuoraAccountUpdate> accountUpdates) {
		for (ZuoraAccountUpdate accountUpdate : accountUpdates) {
			this.sendUpdate(accountUpdate);
		}
	}
	
	global void finish(Database.BatchableContext BC) {
		update this.accountsToUpdate.values();
	}

	private void sendUpdate(ZuoraAccountUpdate accountUpdate) {
		Account account = this.accountsToUpdate.get(accountUpdate.account.Id);
		Boolean failedBefore = false;
		if (account == null) {
			account = this.accounts.get(accountUpdate.account.Id);
			this.accountsToUpdate.put(accountUpdate.account.Id, account);
		} else {
			failedBefore = account.ZuoraSyncFailed__c;
		}
		String res = accountUpdate.send();
		System.debug(res);
		account.ZuoraSyncFailed__c = res == null || failedBefore;
	}
}