public class ActionsController {
    
    @AuraEnabled
    public static String createNewOpportunity(String AccountId, String AccountName){
        Opportunity o = new Opportunity(
            AccountId = AccountId,
            Name = AccountName + ' : Opportunity : ' + Date.today().format(),
            StageName = 'Potential',
            CloseDate = Date.today().addDays(14)
        );
        insert o;
        return o.Id;
    }
    
    @AuraEnabled
    public static String quickConvertLead(String LeadId) {
        Lead Lead = [SELECT Id, OwnerId FROM Lead WHERE Id = :LeadId LIMIT 1];
        Lead.OwnerId = UserInfo.getUserId();
        update Lead;
        
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(LeadId);
        
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);
        
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        
        Lead = [
            SELECT ConvertedOpportunityId, ConvertedAccountId, ConvertedContactId 
            FROM Lead 
            WHERE Id = :LeadId 
            LIMIT 1
        ];

		Task Task = new Task(
            Opportunity__c = Lead.ConvertedOpportunityId,
            Account__c = Lead.ConvertedAccountId,
            WhatId = Lead.ConvertedOpportunityId,
            WhoId = Lead.ConvertedContactId,
            Subject = 'New Converted Opportunity',
            Activity_Type__c = 'Call'
        );
        insert Task;
        return Lead.ConvertedOpportunityId;
    }
    
}