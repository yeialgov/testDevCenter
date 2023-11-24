global class BillingBatchUpdater implements Database.Batchable<sObject>, Database.AllowsCallouts{
    
    global String Query;
    
    global BillingBatchUpdater() {
        Query  = 'SELECT Id, Batch__c, Target_Batch__c, ZuoraId__c FROM Account WHERE Target_Batch__c != NULL';
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(Query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        List<ZObj.BatchChange> BatchChanges = new List<ZObj.BatchChange>();
        Map<String,String> zMap = new Map<String,String>();
        List<Account> UpsertAccounts = new List<Account>();
        for (sObject s : scope) {
            zMap.put((String)s.get('ZuoraId__c'), (String)s.get('Target_Batch__c'));
            BatchChanges.add(new ZObj.BatchChange((String)s.get('ZuoraId__c'), (String)s.get('Target_Batch__c')));
        }
        for (ZObj.SuccessId zs : ZuoraSyncController.UpdateBillingBatches(BatchChanges)) {
            if (zs.Success) UpsertAccounts.add(new Account(ZuoraId__c = zs.Id, Batch__c = zMap.get(zs.Id), PaymentTerm__c = 'Due Upon Receipt' ));
        }
        upsert UpsertAccounts ZuoraId__c;
    }
    
    global void finish(Database.BatchableContext BC){
    }

}