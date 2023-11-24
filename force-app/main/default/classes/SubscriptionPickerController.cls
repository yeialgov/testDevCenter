public class SubscriptionPickerController {
    
    @AuraEnabled
    public static String getSubscriptionsFromCase(String AccountId) {
        return JSON.serialize([SELECT Id, Name, ZuoraId__c FROM Subscription__c WHERE Status__c = 'Active' AND Account__c=:AccountId]);
    }

}