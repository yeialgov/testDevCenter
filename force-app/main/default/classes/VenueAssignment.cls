global class VenueAssignment implements Database.Batchable<sObject>{
    
    global final String Query;
    
    global VenueAssignment() {
        Query = 'SELECT Id, Venue__c, (SELECT Id FROM MyOrderbird_Log_ons__r ORDER BY AssignmentSort__c DESC LIMIT 1) FROM Account WHERE Id IN (SELECT Account__c FROM MyObVenue__c WHERE AssignmentFlag__c = TRUE)';
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        for (sObject s : scope) {
            s.put('Venue__c', ((List<MyObVenue__c>)s.getSObjects('MyOrderbird_Log_ons__r'))[0].Id);
        }
        update scope;
    }
    
    global void finish(Database.BatchableContext BC){
    }
    
}