global class BillRunForPrepayers implements Database.Batchable<sObject>, Database.AllowsCallouts{
    
    global String Query;
    
    global BillRunForPrepayers() {
        Query  = 'SELECT Id, ZuoraId__c, (SELECT ContractEffectiveDate__c, ServiceActivationDate__c FROM Subscriptions__r ORDER BY ServiceActivationDate__c DESC LIMIT 1) FROM Account';
        Query += ' WHERE (Batch__c = \'Batch7\' OR Batch__c = \'Batch4\') AND ZuoraId__c != NULL AND Id NOT IN (SELECT CustomerAccount__c FROM Invoice__c)';
        Query += ' AND Id IN (SELECT Account__c FROM Payment__c)';
    }

//  AND Id NOT IN (SELECT AccountId FROM Quote WHERE Status = \'Accepted\' AND Is_Missing_Documents__c = TRUE)    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(Query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        List<ZObj.CreateBillRun> BillRuns = new List<ZObj.CreateBillRun>();
        Set<String> AccountIds = new Set<String>();
        Set<String> ExcludeZIds = new Set<String>();
        Set<String> RestartZIds = new Set<String>();
        for (sObject s : scope) { AccountIds.add((String)s.get('Id')); }
        for (Account a : [SELECT Id, ZuoraId__c FROM Account WHERE Id IN (SELECT AccountId FROM Quote WHERE Status = 'Accepted' AND Is_Missing_Documents__c = TRUE)]) {
            ExcludeZIds.add(a.ZuoraId__c);
        }
        for (Account a : [SELECT Id, ZuoraId__c FROM Account WHERE Id IN (SELECT AccountId FROM Quote WHERE Status = 'Accepted' AND SpecialRestart__c > 0)]) {
            RestartZIds.add(a.ZuoraId__c);
        }
        for (sObject s : scope) {
            if (!ExcludeZIds.contains((String)s.get('ZuoraId__c'))) {
                List<sObject> Subscriptions = s.getSObjects('Subscriptions__r');
                if (Subscriptions != null) {
                    BillRuns.add(new ZObj.CreateBillRun((String)s.get('ZuoraId__c'), RestartZIds.contains((String)s.get('ZuoraId__c')) ? (Date)Subscriptions[0].get('ContractEffectiveDate__c') : (Date)Subscriptions[0].get('ServiceActivationDate__c')));
                }
            }
        }
        ZuoraSyncController.CreateBillRunsForPrepayers(BillRuns);
    }
    
    global void finish(Database.BatchableContext BC){
    }
    
}