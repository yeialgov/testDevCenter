global class ContactMerge implements Database.Batchable<sObject>{
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        String Query = 'SELECT Id, Merge_Into__c FROM Contact WHERE Merge_Into__c != null ';
        return Database.getQueryLocator(Query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        for (sObject s : scope) {
            Contact cMaster = [SELECT Id FROM Contact WHERE Id=:(Id)s.get('Merge_Into__c') LIMIT 1];
            Contact cGoner = [SELECT Id FROM Contact WHERE Id=:(Id)s.get('Id') LIMIT 1];
            merge cMaster cGoner; 
        }
    }
    
    global void finish(Database.BatchableContext BC){}
    
}