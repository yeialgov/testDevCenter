/**
 * @author joern
 */
@isTest
private class LeadAssignContactTest {
	@isTest static void should_assign_reverral_contact() {
		Contact[] contacts = new List<Contact>{
			new Contact(LastName = 'LastName1', PartnerID__c = '1234'),
			new Contact(LastName = 'LastName2', PartnerID__c = '2345'),
			new Contact(LastName = 'LastName3', PartnerID__c = '3456')
		};
		insert contacts;
		Lead lead1 = new Lead(PartnerID__c = '1234');
		Lead lead2 = new Lead(PartnerID__c = '3456');
		Lead lead3 = new Lead(PartnerID__c = '2345');
		Lead lead4 = new Lead();
		LeadAssignContact lacObj = new LeadAssignContact(new List<Lead>{lead1, lead2, lead3, lead4});
		lacObj.assign();
		System.assertEquals(contacts[0].Id, lead1.ReferralContact__c);
		System.assertEquals(contacts[2].Id, lead2.ReferralContact__c);
		System.assertEquals(contacts[1].Id, lead3.ReferralContact__c);
		System.assertEquals(null, lead4.ReferralContact__c);
	}


	@isTest static void should_not_assign_reverral_contact() {
		Lead lead1 = new Lead(PartnerID__c = '1234');
		Lead lead2 = new Lead();
		Lead lead3 = new Lead(PartnerID__c = '2345');
		LeadAssignContact lacObj = new LeadAssignContact(new List<Lead>{lead1});
		lacObj.assign();
		System.assertEquals(null, lead1.ReferralContact__c);
		System.assertEquals(null, lead2.ReferralContact__c);
		System.assertEquals(null, lead3.ReferralContact__c);
	}

	@isTest static void should_not_throw_exception() {
		LeadAssignContact lacObj = new LeadAssignContact(null);
		lacObj.assign();
        System.assertEquals(lacObj.leadsWithPartnerID.size(), 0);
	}
}