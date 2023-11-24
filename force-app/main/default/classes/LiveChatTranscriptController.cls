public class LiveChatTranscriptController {

    @AuraEnabled
    public Static String getCaseId(String LiveChatTranscriptId) {
        return [SELECT CaseId FROM LiveChatTranscript WHERE Id = :LiveChatTranscriptId LIMIT 1].CaseId;
    }
    @AuraEnabled
    public Static String getAccountId(String LiveChatTranscriptId) {
        return [SELECT Case.AccountId FROM LiveChatTranscript WHERE Id = :LiveChatTranscriptId LIMIT 1].Case.AccountId;
    }
    @AuraEnabled
    public static List<MyObVenue__c> getMyObVenues(String AccountId) {
        return [SELECT Id, Contact__c, MyOrderbirdId__c, Uncertainty__c FROM MyObVenue__c WHERE MyOrderbirdId__c != null AND Contact__r.AccountId = :AccountId ORDER BY MyOrderbirdId__c];
    }
}