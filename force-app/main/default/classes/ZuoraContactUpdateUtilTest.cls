/**
 * @author keylight
 */
@IsTest
private class ZuoraContactUpdateUtilTest {/*
	@IsTest static void contactNeedsUpdate_no_change_should_return_false() {
		Contact c1 = new Contact(FirstName='Hans');
		Contact c2 = new Contact(FirstName='Hans');
		System.assertEquals(false, ZuoraContactUpdateUtil.contactNeedsUpdate(c1, c2));
	}

	@IsTest static void contactNeedsUpdate_no_watched_fields_should_return_false() {
		Contact c1 = new Contact(OtherStreet='Str1');
		Contact c2 = new Contact(OtherStreet='Str2');
		System.assertEquals(false, ZuoraContactUpdateUtil.contactNeedsUpdate(c1, c2));
	}

	@IsTest static void contactNeedsUpdate_change_should_return_true() {
		Contact c1 = new Contact(FirstName='Hans1');
		Contact c2 = new Contact(FirstName='Hans2');
		System.assertEquals(true, ZuoraContactUpdateUtil.contactNeedsUpdate(c1, c2));
	}

	@IsTest static void no_billto_soldto_flags_should_return_no_contacts() {
		List<Zuora__CustomerAccount__c> billingAccounts = new List<Zuora__CustomerAccount__c>();
		Account a = new Account(Name='Test');
		insert a;
		Zuora__CustomerAccount__c b1 = new Zuora__CustomerAccount__c(Zuora__Account__c = a.Id, Zuora__BillToId__c='b1');
		billingAccounts.add(b1);
		Contact c1 = new Contact(AccountId=a.Id, FirstName='Hans1');
		Contact c2 = new Contact(AccountId=a.Id, FirstName='Hans2');
		System.assertEquals(0, ZuoraContactUpdateUtil.getZuoraContactUpdates(c1, c2, billingAccounts).size());
	}

	@IsTest static void no_changes_should_return_no_contacts() {
		List<Zuora__CustomerAccount__c> billingAccounts = new List<Zuora__CustomerAccount__c>();
		Account a = new Account(Name='Test');
		insert a;
		Zuora__CustomerAccount__c b1 = new Zuora__CustomerAccount__c(Zuora__Account__c = a.Id, Zuora__BillToId__c='b1');
		billingAccounts.add(b1);
		Contact c1 = new Contact(AccountId=a.Id, LastName='Hans1');
		Contact c2 = new Contact(AccountId=a.Id, LastName='Hans1');
		insert c1;
		insert c2;
		a.SF_BillTo_Contact__c = c2.Id;
		update a;
		System.assertEquals(0, ZuoraContactUpdateUtil.getZuoraContactUpdates(c1, c2, billingAccounts).size());
	}

	@IsTest static void no_billings_accounts_should_return_no_contacts() {
		List<Zuora__CustomerAccount__c> billingAccounts = new List<Zuora__CustomerAccount__c>();
		Account a = new Account(Name='Test');
		insert a;
		Contact c1 = new Contact(AccountId=a.Id, LastName='Hans1');
		Contact c2 = new Contact(AccountId=a.Id, LastName='Hans2');
		insert c1;
		insert c2;
		a.SF_BillTo_Contact__c = c2.Id;
		update a;
		System.assertEquals(0, ZuoraContactUpdateUtil.getZuoraContactUpdates(c1, c2, billingAccounts).size());
	}

	@IsTest static void changes_with_billings_accounts_should_return_contacts() {
		List<Zuora__CustomerAccount__c> billingAccounts = new List<Zuora__CustomerAccount__c>();
		Account a = new Account(Name='Test');
		insert a;
		Zuora__CustomerAccount__c b1 = new Zuora__CustomerAccount__c(Zuora__Account__c = a.Id, Zuora__BillToId__c='b1');
		billingAccounts.add(b1);
		Contact c1 = new Contact(AccountId=a.Id, LastName='Hans1');
		Contact c2 = new Contact(AccountId=a.Id, LastName='Hans2');
		insert c1;
		insert c2;
		a.SF_BillTo_Contact__c = c2.Id;
		update a;
		c2 = [SELECT Zuora_BillTo_Contact__c, Zuora_SoldTo_Contact__c, Addressee__c, Attention__c, AccountId, Description, FirstName, LastName, MailingStreet, MailingCity, MailingPostalCode, MailingCountry, Email FROM Contact WHERE Id=:c2.Id];
		List<ZuoraContactUpdate> contactUpdates = ZuoraContactUpdateUtil.getZuoraContactUpdates(c1, c2, billingAccounts);
		System.assertEquals(1, contactUpdates.size());
		ZuoraContactUpdate cu = contactUpdates.get(0);
		System.assertEquals('b1', cu.zuoraId);
	}*/
}