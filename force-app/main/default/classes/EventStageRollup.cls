/* #############################################################
Class to roll up the stage of the related opportunity to "Demo/Introduction" whenever a Demo Event has been scheduled
Requested as part of https://jira.orderbird.com/browse/SAL-1101
################################################################
*/

/*
* modified on 31.10.18 to include cascading Event owner for Demos to Account Owner
*/


public class EventStageRollup  {
    
    Map<Id, Event> newMap;
    Map<Id, Event> oldMap;
    
    public EventStageRollup(Map<Id, Event> newMap, Map<Id, Event> oldMap) {
        this.newMap = newMap;
        this.oldMap = oldMap;       
    }
    
    public void execute() {
        
        List<Id> whatIDList = new List<Id>();
        Map<Id, Opportunity> checkOpps = new Map<Id, Opportunity>();
        Map<Id, Id> AccountOwnerMap = new Map<Id, Id>();
        Map<Id, Id> OpportunityOwnerMap = new Map<Id, Id>();
        Map<Id, String> OpportunityStageMap = new Map<Id, String>();
        
        for (Event e : newMap.values()) {
            whatIDList.add(e.WhatId);
        }
        
        for (Opportunity o2 : [SELECT Id, AccountId, Account.OwnerId, OwnerId, StageName FROM Opportunity WHERE Id IN :whatIDList]) {
            checkOpps.put(o2.Id, o2);
        }
        
        for (Event e : newMap.values()) {
            Opportunity o = checkOpps.get(e.WhatId); 
            
            /* Which events should be rolled up to the opportunity?
			Either for newly created events, or for those where the type field gets changed */
            
            if (
                e.Activity_Type__c == 'Demo' 
                && (
                    oldMap == null 
                    || e.Activity_Type__c != oldMap.get(e.Id).Activity_Type__c
                )
            ) {
                if(e.Opportunity_Stage__c != null) OpportunityStageMap.put(o.Id, e.Opportunity_Stage__c); 
            }
            
            if (
                e.Activity_Type__c == 'Demo' 
                && (
                    oldMap == null 
                    || e.Activity_Type__c != oldMap.get(e.Id).Activity_Type__c
                    || e.OwnerId != oldMap.get(e.Id).OwnerId
                )
            ) {
                AccountOwnerMap.put(o.AccountId, e.OwnerId);
                OpportunityOwnerMap.put(o.Id, e.OwnerId);
            }
        }
        
        List<Account> acctsToUpdate = [SELECT Id, OwnerId FROM Account WHERE Id IN :AccountOwnerMap.keySet()];
        for (Account a : acctsToUpdate) {
            a.OwnerId = AccountOwnerMap.get(a.Id);
        }
        
        List<Opportunity> oppsToUpdate = [SELECT Id, StageName, OwnerId FROM Opportunity WHERE Id IN :OpportunityOwnerMap.keySet() OR Id IN :OpportunityStageMap.keySet()];
        for (Opportunity o : oppsToUpdate) {
            if (OpportunityOwnerMap.keySet().contains(o.Id)) o.OwnerId = OpportunityOwnerMap.get(o.Id);
            if (OpportunityStageMap.keySet().contains(o.Id)) o.StageName = OpportunityStageMap.get(o.Id);
        }
        
        update oppsToUpdate;
        update acctsToUpdate;
    } 
}