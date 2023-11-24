public class SurveyController {
    
    @AuraEnabled
    public static Boolean InitSurvey(String token, String Lead) {
        try {
            AutomatedSurvey__c ausu = [SELECT Id, NPS__c, DateResponded__c FROM AutomatedSurvey__c WHERE Locked__c = FALSE AND Id = :PortalToken.decryptPlain(token) LIMIT 1];
            try {
                ausu.NPS__c = Integer.valueOf(Lead);
                ausu.DateResponded__c = Date.today();
                update ausu;
            } catch (exception ee) {}
            return ausu != null;
        } catch(exception e){
            return false;
        }
    }
    
    @AuraEnabled
    public static Boolean SubmitSurvey(String token, String Payload) {
        try {
            PayloadData p = (PayloadData)json.deserialize(Payload, PayloadData.class);
            AutomatedSurvey__c ausu = [SELECT Id, NPS__c, Comment__c, DateResponded__c, Locked__c FROM AutomatedSurvey__c WHERE Locked__c = FALSE AND Id = :PortalToken.decryptPlain(token) LIMIT 1];
            ausu.NPS__c = p.NPS;
            ausu.Comment__c = p.Comment;
            ausu.DateResponded__c = Date.today();
            ausu.Locked__c = true;
            update ausu;
            System.enqueueJob(new SlackNPS(ausu.Id));
            return ausu != null;
        } catch(exception e){
            return false;
        }
    }
    
    public class PayloadData {
        public Integer NPS;
        public String Comment;
    }
    
}