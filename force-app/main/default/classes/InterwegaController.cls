public class InterwegaController {
    
    @AuraEnabled
    public static Integer CountInterwega() {
        return [SELECT Id FROM Account WHERE Interwega_Status__c != null].size();
    }
    
    @AuraEnabled
    public static String ClearInterwega() {
        if (CountInterwega() < 201) {
            try {
                List<Account> Accounts = [
                    SELECT 
                    Id, Interwega_Business_Area__c, Interwega_Open_Balance__c, Interwega_Debt_Collection_Id__c,
                    Interwega_Open_Balance_wo_fees__c, Interwega_Reference_Date__c, Interwega_Status__c 
                    FROM Account
                    WHERE Interwega_Status__c != null
                ];
                for (Account a : Accounts) {
                    a.Interwega_Business_Area__c = null;
                    a.Interwega_Open_Balance__c = null;
                    a.Interwega_Open_Balance_wo_fees__c = null;
                    a.Interwega_Reference_Date__c = null;
                    a.Interwega_Status__c = null;
                    a.Interwega_Debt_Collection_Id__c = null;
                }
                update Accounts;
            } catch(exception e) {
                return e.getMessage();
            }
            return 'OK';
        } else {
            Database.executeBatch(new InterwegaBatch());
            return 'Process started. Wait until count goes to -0- before importing.';
        }
    }
    
}