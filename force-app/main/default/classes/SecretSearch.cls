public class SecretSearch {
    
    @AuraEnabled
    public static String searchResults(String searchString) {
        return JSON.serialize([
            FIND :searchString
            IN Name Fields
            RETURNING Account(
                Id, Name, Website, Account_Status__c, VenueStreet__c, VenueCity__c
                WHERE 
                	(Account_Status__c LIKE '%Customer%' OR Account_Status__c LIKE '%Prospect%') 
                	AND (NOT Account_Status__c LIKE '%Closed%')
                ORDER BY Name, Account_Status__c
            ) LIMIT 100
        ]);
    }

}