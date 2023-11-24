/**
 * @author joern
 * @description Sync address data from related (zuora billing/soldTo lookups) contacts
 * to billing and shipping address fields on account object
 * 
 * added email/phone sync (( contact ==> account only )) 
 * @modified by Bart
 * 
 */
public class AddressSync {
	@TestVisible private List<SObject> objList;
	@TestVisible private Map<ID, Account> relatedAccounts;
	@TestVisible private Map<ID, Contact> relatedContacts;

	public AddressSync(SObject[] objList) {
		this.objList = objList;
	}

	/**
	 * @description Used in account trigger (beforeUpdate)
	 * @param acc Account
	 */
	public void updateAccountAddresses(Account acc) {
		//unsetAccountAddresses(acc);
        setShipAndVenueAccountAddresses(acc);
        /*
		if (relatedContacts != null) {
			Contact billingContact = relatedContacts.get(acc.SF_BillTo_Contact__c);
			if (billingContact != null) {
				setBillingAccountAddress(acc, billingContact);
			}
			Contact shippingContact = relatedContacts.get(acc.SF_SoldTo_Contact__c);
			if (shippingContact != null) {
				setShippingAccountAddress(acc, shippingContact);
			}
		}*/
	}

	/**
	 * @description Used in contact trigger (afterUpdate). Updates account if BillTo and/or SoldTo contact changed
	 * @param cont Contact
	 * @return Account
	 */
	public Account updateAccountAddresses(Contact cont) {
		Account acc = relatedAccounts.get(cont.AccountId);
		if (acc == null) {
			return null;
		} else {
			setShipAndVenueAccountAddresses(acc);
            if (acc.Primary_Contact__c == cont.Id) {
                setPhoneAndEmail(acc, cont);
            }
			return acc;
		}
	}

	public void loadRelatedAccountAddresses() {
		Set<ID> accountIDs = findAccountIDs();
		this.relatedAccounts = new Map<ID, Account>([
				SELECT
						Phone, Email__c,			
            			SF_BillTo_Contact__c, SF_SoldTo_Contact__c, Primary_Contact__c,
						BillingStreet, BillingCity, BillingState, BillingCountry, BillingCountryCode, BillingPostalCode,
						VenueStreet__c, VenueCity__c, VenueCountry__c, VenuePostalCode__c,
						ShippingStreet, ShippingCity, ShippingState, ShippingCountry, ShippingCountryCode, ShippingPostalCode
				FROM Account
				WHERE Id IN :accountIDs
		]);
	}

	public void loadRelatedContactAddresses() {
		Set<ID> contactIDs = findContactIDs();
		relatedContacts = new Map<ID, Contact>([
				SELECT
						MailingStreet, MailingCity, MailingState, MailingCountry, MailingCountryCode, MailingPostalCode,
            			Phone, Email
				FROM Contact
				WHERE Id IN :contactIDs
		]);
	}

	@TestVisible
	private Set<ID> findContactIDs() {
		Set<ID> contactIDs = new Set<ID>();
		if (objList != null) {
			for (Account acc : (List<Account>) objList) {
				contactIDs.add(acc.SF_BillTo_Contact__c);
				contactIDs.add(acc.SF_SoldTo_Contact__c);
                contactIDs.add(acc.Primary_Contact__c);
			}
		}
		return contactIDs;
	}

	@TestVisible
	private Set<ID> findAccountIDs() {
		Set<ID> accountIDs = new Set<ID>();
		if (objList != null) {
			for (Contact cont : (List<Contact>) objList) {
				accountIDs.add(cont.AccountId);
			}
		}
		return accountIDs;
	}

	/*private void unsetAccountAddresses(Account acc) {
		acc.BillingStreet = null;
		acc.BillingCity = null;
		acc.BillingState = null;
		acc.BillingCountry = null;
		acc.BillingCountryCode = null;
		acc.BillingPostalCode = null;
		acc.ShippingStreet = null;
		acc.ShippingCity = null;
		acc.ShippingState = null;
		acc.ShippingCountry = null;
		acc.ShippingCountryCode = null;
		acc.ShippingPostalCode = null;
	}*/

	/*private void setBillingAccountAddress(Account acc, Contact cont) {
		acc.BillingStreet = cont.MailingStreet;
		acc.BillingCity = cont.MailingCity;
		acc.BillingState = cont.MailingState;
		acc.BillingCountry = cont.MailingCountry;
		acc.BillingCountryCode = cont.MailingCountryCode;
		acc.BillingPostalCode = cont.MailingPostalCode;
	}

	private void setShippingAccountAddress(Account acc, Contact cont) {
		acc.ShippingStreet = cont.MailingStreet;
		acc.ShippingCity = cont.MailingCity;
		acc.ShippingState = cont.MailingState;
		acc.ShippingCountry = cont.MailingCountry;
		acc.ShippingCountryCode = cont.MailingCountryCode;
		acc.ShippingPostalCode = cont.MailingPostalCode;
	}*/
    
    private void setShipAndVenueAccountAddresses(Account acc) {
		acc.ShippingStreet = acc.BillingStreet;
		acc.ShippingCity = acc.BillingCity;
		acc.ShippingCountry = acc.BillingCountry;
		acc.ShippingCountryCode = acc.BillingCountryCode;
		acc.ShippingPostalCode = acc.BillingPostalCode;
		acc.VenueStreet__c = acc.BillingStreet;
		acc.VenueCity__c = acc.BillingCity;
		acc.VenueCountry__c = acc.BillingCountry;
		acc.VenuePostalCode__c = acc.BillingPostalCode;
    }
    
    private void setPhoneAndEmail(Account acc, Contact cont) {
        acc.Phone = cont.Phone;
        acc.Email__c = cont.Email;
    }
}