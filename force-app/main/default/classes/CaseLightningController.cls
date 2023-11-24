public class CaseLightningController {
    
    /*@AuraEnabled
    public static void insertCaseCall(String CaseId, String Comment) {
        Case c = [SELECT Id, ContactId FROM Case WHERE Id = :CaseId LIMIT 1];
        insert new Task(
            WhoId = c.ContactId,
            WhatId = CaseId,
            Subject = 'Call',
            Description = Comment,
            OwnerId = UserInfo.getUserId(),
            ActivityDate = Date.today(),
            Status = 'Completed'
        );
    }

    @AuraEnabled
    public static void insertCaseComment(String CaseId, String Comment) {
        insert new CaseComment(
        	ParentId = CaseId,
            CommentBody = Comment
        );
    }*/
    
    @AuraEnabled
    public static String getContacts(String AccountId) {
        return JSON.serialize([SELECT Id, Name FROM Contact WHERE AccountId = :AccountId]);
    }
    
    @AuraEnabled
    public static void setCaseContact(String CaseId, String ContactId, Boolean Selected) {
        Case c = [SELECT Id, ContactId FROM Case WHERE Id = :CaseId LIMIT 1];
        if (Selected) {
            c.ContactId = ContactId;
        } else {
            c.ContactId = null;
        }
        update c;
    }
    
    @AuraEnabled
    public static List<Task> getOpenTasks(String CaseId) {
        return [
            SELECT Id, Subject, ActivityDate, Status, Owner.Name 
            FROM Task 
            WHERE Status != 'Completed' AND WhatId = :CaseId
            ORDER BY ActivityDate, CreatedDate
        ];
    }
    
    @AuraEnabled
    public static void closeOpenTask(String TaskId) {
        Task t = [SELECT Id, Status, Outcome__c FROM Task WHERE Id = :TaskId];
        t.Status = 'Completed';
        t.Outcome__c = 'Successful';
        update t;
    }

}