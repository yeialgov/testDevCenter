global class ScheduledNPS implements Schedulable{
    global void execute(SchedulableContext SC) {
        List<AutomatedSurvey__c> insAS = new List<AutomatedSurvey__c>();
        Set<Id> ContactIds = new Set<Id>();
        Map<Id,String> ContactEmailMap = new Map<Id,String>();
        Set<String> MiniEmails = new Set<String>();
        for (
            AggregateResult ar : [
                SELECT Email, MIN(Id) ContactId
                FROM Contact 
                WHERE 
                    Account.First_POS_Start_Date_2__c < LAST_n_DAYS:45 
                    AND Account.First_POS_Start_Date_2__c < LAST_n_DAYS:45 
                    AND Account.First_POS_Start_Date_2__c >= LAST_n_DAYS:75 
                    AND Email != null
                    AND Account.Account_Status__c = 'Active Customer'
                    AND CreatedDate < LAST_n_DAYS:30
                	AND InactiveEmployee__c = FALSE
                    AND AccountId NOT IN (
                        SELECT AccountId 
                        FROM Case 
                        WHERE 
                            AMCategory__c = 'Cancellation' 
                            AND (
                                (NOT Status LIKE '%Closed%') 
                                OR CreatedDate = LAST_n_DAYS:90
                            )
                    ) 
                GROUP BY Email 
                HAVING 
                    (MAX(Last_NPS_Response__c) < last_n_days:180 OR MAX(Last_NPS_Response__c) = null) 
                    AND (MAX(Last_NPS_Send__c) < last_n_days:90 OR MAX(Last_Nps_Send__c) = null)
                    AND (SUM(EmailOptOut__c) = 0)
                	AND MAX(Last_Nps_Send__c) = null
                ORDER BY MAX(Last_NPS_Send__c), MIN(CreatedDate) DESC
                LIMIT 200
            ]
        ){
            ContactIds.add((Id)ar.get('ContactId')); ContactEmailMap.put((Id)ar.get('ContactId'), (String)ar.get('Email'));
        }
        for (AggregateResult ar : [SELECT Email FROM Contact WHERE Email IN :ContactEmailMap.values() AND Account.Target_Product__c = 'MINI' GROUP BY Email]){ MiniEmails.add((String)ar.get('Email')); }
        for (Id ContactId : ContactIds){ insAS.add(new AutomatedSurvey__c(Contact__c = ContactId, IsMini__c = MiniEmails.contains(ContactEmailMap.get(ContactId)), DateSent__c = Date.today())); }
        NPSScheduler__c nps = NPSScheduler__c.getInstance();
        if (!nps.Testing__c) {
            insert insAS;
        } else { for (Contact c : [SELECT Id FROM Contact WHERE LastName = 'NPSTest']) { insert new AutomatedSurvey__c(Contact__c = c.Id); } }
    }
}