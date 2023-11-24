/**
 * @author joern
 * @description Assign a partner contact if partnerID is set in lead (LeadAssignTrigger)
 *
 * @todo refactoring: to fit into LeadHandler behavior
 */
public with sharing class LeadAssignContact {

    @TestVisible
	private Map<String, Lead> leadsWithPartnerID = new Map<String, Lead>();

	public LeadAssignContact(Lead[] leads) {
        if(leads != null) {
		    prepare(leads);
        }
	}

	/**
	 * @description Assign referral contacts based on PartnerId__c field (beforeInsert/Update trigger)
	 */
	public void assign() {
		Set<String> partnerIDs = leadsWithPartnerID.keySet();
		for (Contact c : [SELECT Id, PartnerID__c FROM Contact WHERE PartnerID__c in :partnerIDs]) {
			Lead lead = leadsWithPartnerID.get(c.PartnerID__c);
			lead.ReferralContact__c = c.Id;
		}
	}

	private void prepare(Lead[] leads) {
		for (Lead lead : leads) {
			String partnerID = lead.PartnerID__c;
			if(!String.isBlank(partnerID)) {
				leadsWithPartnerID.put(partnerID, lead);
			}
		}
	}
}