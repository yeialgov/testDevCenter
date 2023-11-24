public class TaskNextRollup  {

    Map<Id, Task> newMap;
    Map<Id, Task> oldMap;

    public TaskNextRollup(Map<Id, Task> newMap, Map<Id, Task> oldMap) {
        this.newMap = newMap;
        this.oldMap = oldMap;       
    }

    public void execute() {
    
        Set< Opportunity > oppsToUpdate = new Set< Opportunity > ();
        List< Id > whatIDList = new List< Id > ();
        Map<Id, Opportunity> checkOpps = new Map<Id, Opportunity>();
        
        for (Task t2 : newMap.values()) {
            whatIDList.add(t2.WhatId);
        }
        
        for (Opportunity o2:[SELECT Id,StageName FROM Opportunity WHERE Id IN :whatIDList]) {
            checkOpps.put(o2.Id, o2);
        }
    
        for (Task t : newMap.values()) {
    
            Opportunity o = checkOpps.get(t.WhatId); 
            
            /* ####################################################
            Validations, to make agents fill out certain fields on the task regarding the next steps. 
            does not apply to closed opportunities and not for admins */
    
            if (o != null) {
            
                if (o.StageName != 'Closed Won' && o.StageName != 'Closed Lost' 
                    && !Label.Admin_Users.contains(UserInfo.getUserId().substring(0,15)) 
                ) {
        
                    if(t.Next_Step__c == null && t.Next_Step_relevant__c == TRUE ) {
                        t.Next_Step__c.addError('Please specify the next step!');
                    } 
                    if(t.Next_Step_Date__c == null  && t.Next_Step_relevant__c == TRUE) {
                            t.Next_Step_Date__c.addError('Please specify the next step date!');
                    }
        
                }
                /* #############################################################
                Selection for which tasks should be rolled up to the opportunity
                only those that are Completed, and are relevant to the next step (is set by the button) will be updated
                Either for newly created tasks, or for those where the next step fields get changed */
        
                if (t.Status == 'Completed' && t.Next_Step_relevant__c == TRUE &&
                       (oldMap == null 
                    || t.Next_Step__c != oldMap.get( t.Id ).Next_Step__c 
                    || t.Next_Step_Date__c != oldMap.get( t.Id ).Next_Step_Date__c 
                    || t.Opportunity_Stage__c != oldMap.get( t.Id ).Opportunity_Stage__c 
                    || t.Priority != oldMap.get( t.Id ).Priority
                    || t.Notes_and_Comments__c != oldMap.get( t.Id ).Notes_and_Comments__c)
                ) {
                
                /* ######################################################
                List of fields on the opportunity that will get filled by values from the tasks */
                
                    o.Next_Step_PL__c = t.Next_Step__c; 
                    o.NextStepDate__c = t.Next_Step_Date__c;  
                    o.Next_Step_Comments__c = t.Notes_and_Comments__c;
                    o.Sales_Rep_Priority__c = t.Priority;
                    if(t.Opportunity_Stage__c != null) {
                       o.StageName = t.Opportunity_Stage__c; 
                    }
                    oppsToUpdate.add(o); 
                         
                }
            }
        }
     
        update new List<Opportunity>(oppsToUpdate);      
 
    } 
}