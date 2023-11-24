/**
 * author:  Bart
 * desc:    Sets Primary, ZBilling, and ZShipping Contacts on Lead Conversion and sets corresponding Address/Email/Phone fields
 * 
 */
public class ContactAutoPopulator {

    public List<Account> AccountsToUpdate;
    public Map<Id, SObject> AccountMap;
    
    // Instantiate class and create map to determine if lead is converting into new account
    public ContactAutoPopulator(List<Lead> leads) {
        AccountsToUpdate = new List<Account>();
        Set<Id> AccountIds = new Set<Id>();
        for (Lead l : leads) { AccountIds.add(l.ConvertedAccountId); }
        AccountMap = new Map<Id, SObject>([SELECT Id, (SELECT Id From Contacts) FROM Account WHERE Id IN :AccountIds]);
    }
    
    public void updateContactLookups(SObject so, SObject oldSo) {
        
        // Set lead converted into new account as Primary, ZBill, and ZShip Contacts
        if(
            (Boolean)so.get('IsConverted') 
            && !(Boolean)oldSo.get('IsConverted')
            && AccountMap.get((Id)so.get('ConvertedAccountId')).getSObjects('Contacts').size() == 1
        ) {
            Id CallerContactId = (Id)so.get('ConvertedContactId');
            if (!(Boolean)so.get('Has_Complete_Contact_Info__c')) CallerContactId = null;
            AccountsToUpdate.add(
                new Account(
                    Id = (Id)so.get('ConvertedAccountId'),
                    Primary_Contact__c = (Id)so.get('ConvertedContactId'),
                    SF_BillTo_Contact__c = (Id)so.get('ConvertedContactId'),
                    SF_SoldTo_Contact__c = (Id)so.get('ConvertedContactId'),
                    Caller_Contact__c = CallerContactId
                )
            );
        }
    }
    
    
    public void updateAccounts() {
        
        // Set Address/Email/Phone after conversion -- trigger will not do this because of recursion check
        AddressSync addressSync = new AddressSync(AccountsToUpdate);
        addressSync.loadRelatedContactAddresses();
        for (Account a : AccountsToUpdate) addressSync.updateAccountAddresses(a);
        
        // Finally: Commit changes
        update AccountsToUpdate;
    }
    
}