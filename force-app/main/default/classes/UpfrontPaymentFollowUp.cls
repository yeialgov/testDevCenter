global class UpfrontPaymentFollowUp implements Database.Batchable<sObject>{

    global String Query;
    global Boolean ResetBatch;
    
    // things that make clock stop: Batch isn't 7, CCD isn't null, or there's an invoice
    
    global UpfrontPaymentFollowUp(Integer iBatchNo) {
        ResetBatch = iBatchNo != 0;
        Query = 'SELECT Id, Batch7_Age__c ';
        Query += 'FROM Account ';
        if (iBatchNo == 1) {
            Query += 'WHERE Batch7_Age__c != null ';
            Query += 'AND Id IN (SELECT CustomerAccount__c FROM Invoice__c) ';
        } else if (iBatchNo == 2) {
            Query += 'WHERE Batch7_Age__c != null ';
            Query += 'AND Id NOT IN (SELECT CustomerAccount__c FROM Invoice__c) AND (';
            Query += 'Closed_Contract_Date__c != NULL ';
            Query += 'OR (Batch__c != \'Batch7\' AND Batch__c != \'Batch4\')) ';
        } else {
            Query += 'WHERE Id IN (SELECT Account__c FROM Subscription__c WHERE Status__c = \'Active\') ';
            Query += 'AND Id NOT IN (SELECT CustomerAccount__c FROM Invoice__c) ';
            Query += 'AND Closed_Contract_Date__c = NULL ';
            Query += 'AND (Batch__c = \'Batch7\' OR Batch__c = \'Batch4\') ';
        }
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(Query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        Set<Id> AcctIds = new Set<Id>(); Map<Id, Date> DateMap = new Map<Id, Date>();
        for (sObject s : scope) { AcctIds.add((Id)s.get('Id')); }
        for (AggregateResult ar : [SELECT AccountId, MIN(AcceptedDate__c) AccDate FROM Quote WHERE AcceptedDate__c != NULL AND AccountId IN :AcctIds GROUP BY AccountId]) {DateMap.put((Id)ar.get('AccountId'), (Date)ar.get('AccDate'));}
        for (sObject s : scope) { s.put('Batch7_Age__c', ResetBatch ? null : Math.abs(Date.today().daysBetween(DateMap.get((Id)s.get('Id'))))); } update scope;
    }        

    global void finish(Database.BatchableContext BC){}

}