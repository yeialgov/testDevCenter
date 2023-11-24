/**
 * @author keylight
 */
public with sharing class QuoteAccountSync {
    /*@TestVisible private List<zqu__Quote__c> quotes;
    private Map<ID, Account> accounts;

    public QuoteAccountSync(List<zqu__Quote__c> quotes) {
        this.quotes = quotes;
    }

    public List<Account> updateAccounts() {
        Map<ID, Account> accounts = getAccounts();
        Map<Id,Account> updateAccountsMap = new Map<Id,Account>();
        for (zqu__Quote__c quote : this.quotes) {
            if (quote.zqu__BillToContact__c != null || quote.zqu__SoldToContact__c != null) {
                Account account = accounts.get(quote.zqu__Account__c);
                account.SF_BillTo_Contact__c = quote.zqu__BillToContact__c;
                account.SF_SoldTo_Contact__c = quote.zqu__SoldToContact__c;
                updateAccountsMap.put(account.Id, account);
            }
        }
        return updateAccountsMap.values();
    }

    public Map<ID, Account> getAccounts() {
        if(this.accounts == null) {
            List<ID> accountIds = new List<ID>();
            for (zqu__Quote__c quote : this.quotes) {
                accountIds.add(quote.zqu__Account__c);
            }
            this.accounts = new Map<ID, Account>([
                    SELECT Id, SF_BillTo_Contact__c, SF_SoldTo_Contact__c , CurrencyISOCode, VATNumber__c, taxExempted__c
                    FROM Account
                    WHERE Id IN :accountIds]);

            return this.accounts;
        } else {
            return this.accounts;
        }
    }*/
}