/**
 * @author keylight
 */
global class ZuoraContactUpdateBatch implements Database.Batchable<ZuoraContactUpdate>, Database.AllowsCallouts, Database.Stateful {
	@TestVisible private Map<ID, Contact> contacts;
	@TestVisible private List<ZuoraContactUpdate> contactUpdates;
	private Map<ID, Contact> contactsToUpdate = new Map<ID, Contact>();

	global ZuoraContactUpdateBatch(List<ZuoraContactUpdate> contactUpdates) {
		this.contactUpdates = contactUpdates;
	}
	
	global Iterable<ZuoraContactUpdate> start(Database.BatchableContext BC) {
		List<ID> contactIds = new List<ID>();
		for (ZuoraContactUpdate contactUpdate : this.contactUpdates) {
			contactIds.add(contactUpdate.contact.Id);
		}
		this.contacts = new Map<ID, Contact>([SELECT Id, ZuoraSyncFailed__c FROM Contact WHERE Id IN :contactIds]);
		return this.contactUpdates;
	}

   	global void execute(Database.BatchableContext BC, List<ZuoraContactUpdate> contactUpdates) {
		for (ZuoraContactUpdate contactUpdate : contactUpdates) {
			this.sendUpdate(contactUpdate);
		}
	}
	
	global void finish(Database.BatchableContext BC) {
		update this.contactsToUpdate.values();
	}

	private void sendUpdate(ZuoraContactUpdate contactUpdate) {
		Contact contact = this.contactsToUpdate.get(contactUpdate.contact.Id);
		Boolean failedBefore = false;
		if (contact == null) {
			contact = this.contacts.get(contactUpdate.contact.Id);
			this.contactsToUpdate.put(contactUpdate.contact.Id, contact);
		} else {
			failedBefore = contact.ZuoraSyncFailed__c;
		}
		String res = contactUpdate.send();
		contact.ZuoraSyncFailed__c = res == null || failedBefore;
	}
}