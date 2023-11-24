/**
 * @author keylight
 */
public with sharing class ZuoraAccountUpdateUtil {/*
    public static List<ZuoraAccountUpdate> getZuoraAccountUpdates(
        Account oldAccount,
        Account newAccount,
        List<Zuora__CustomerAccount__c> billingAccounts
        ) {
        List<ZuoraAccountUpdate> accountUpdates = new List<ZuoraAccountUpdate>();
        if (ZuoraAccountUpdateUtil.accountNeedsUpdate(oldAccount, newAccount)) {
            for (Zuora__CustomerAccount__c billingAccount : billingAccounts) {
                if (billingAccount.Zuora__Account__c == newAccount.Id) {
                    accountUpdates.add(new ZuoraAccountUpdate(newAccount, billingAccount.Zuora__Zuora_Id__c));
                }
            }    
        }
        return accountUpdates;
    }

    public static List<ZuoraContactUpdate> getZuoraContactUpdates(
        Account oldAccount,
        Account newAccount,
        List<Contact> contacts,
        List<Zuora__CustomerAccount__c> billingAccounts
        ) {
        List<ZuoraContactUpdate> contactUpdates = new List<ZuoraContactUpdate>();
        if (ZuoraAccountUpdateUtil.billToNeedsUpdate(oldAccount, newAccount)) {
            for (Contact contact : contacts) {
                if (contact.Id == newAccount.SF_BillTo_Contact__c) {
                    for (Zuora__CustomerAccount__c billingAccount : billingAccounts) {
                        if (billingAccount.Zuora__Account__c == newAccount.Id) {
                            contactUpdates.add(new ZuoraContactUpdate(contact, billingAccount.Zuora__BillToId__c));
                        }
                    }    
                }
            }
        }
        if (ZuoraAccountUpdateUtil.soldToNeedsUpdate(oldAccount, newAccount)) {
            for (Contact contact : contacts) {
                if (contact.Id == newAccount.SF_SoldTo_Contact__c) {
                    for (Zuora__CustomerAccount__c billingAccount : billingAccounts) {
                        if (billingAccount.Zuora__Account__c == newAccount.Id) {
                            contactUpdates.add(new ZuoraContactUpdate(contact, billingAccount.Zuora__SoldToId__c));
                        }
                    }    
                }
            }
        }
        return contactUpdates;
    }

    private static Boolean billToNeedsUpdate(Account a1, Account a2) {
        return a1.SF_BillTo_Contact__c != a2.SF_BillTo_Contact__c;
    }

    private static Boolean soldToNeedsUpdate(Account a1, Account a2) {
        return a1.SF_SoldTo_Contact__c != a2.SF_SoldTo_Contact__c;
    } 
            
    @TestVisible
    private static Boolean accountNeedsUpdate(Account a1, Account a2) {
        for (String field : accountFields) {
            if (a1.get(field) != a2.get(field)) return true;
        }
        return false;
    }

    private static List<String> accountFields = new List<String>{
            'myOrderbirdEmail__c',
            'LegalCompanyName__c',
            'NS_Customer_Internal_ID__c',
            'SF_BillTo_Contact__c',
            'SF_SoldTo_Contact__c',
            'taxExempted__c',
            'VATNumber__c',
            'Tax_Exempt_Reason__c',
            'Exclude_Contact_Name_on_Invoice__c',
            'Exclude_Account_Name_on_Invoice__c',
         /**   'Dunning_0_Date__c',
            'Dunning_1_Date__c',
            'Dunning_2_Date__c',
            'Dunning_X_Date__c', *
            'Name'
    };*/
}