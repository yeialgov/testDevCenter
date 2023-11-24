/**
 * @author keylight
 */
public with sharing class ZuoraContactUpdateUtil {/*
	public static List<ZuoraContactUpdate> getZuoraContactUpdates(Contact oldContact, Contact newContact, List<Zuora__CustomerAccount__c> billingAccounts) {
		List<ZuoraContactUpdate> contactUpdates = new List<ZuoraContactUpdate>();
		if (ZuoraContactUpdateUtil.contactNeedsUpdate(oldContact, newContact)) {
			for (Zuora__CustomerAccount__c billingAccount : billingAccounts) {
	        	if (newContact.Zuora_BillTo_Contact__c && billingAccount.Zuora__Account__c == newContact.AccountId) {
            		contactUpdates.add(new ZuoraContactUpdate(newContact, billingAccount.Zuora__BillToId__c));
	            }
	            if (newContact.Zuora_SoldTo_Contact__c && billingAccount.Zuora__Account__c == newContact.AccountId) {
	            	contactUpdates.add(new ZuoraContactUpdate(newContact, billingAccount.Zuora__SoldToId__c));
	        	}
	        }    
        }
        return contactUpdates;
	}

	@TestVisible
	private static Boolean contactNeedsUpdate(Contact c1, Contact c2) {
        for (String field : contactFields) {
            if (c1.get(field) != c2.get(field)) return true;
        }
        return false;
    }

	private static List<String> contactFields = new List<String>{
	    'Attention__c',
	    'Addressee__c',
	    'Description',
	    'FirstName',
	    'LastName',
	    'MailingStreet',
	    'MailingPostalCode',
	    'MailingCity',
	    'MailingCountry',
	    'Email'
    };*/
}