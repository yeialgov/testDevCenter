global class InstalmentBillRun implements Database.Batchable<sObject>, Database.AllowsCallouts{
    
    global String Query;
    
    global InstalmentBillRun() {
        Query  = 'SELECT Id, ZuoraId__c, (';
        Query += '  SELECT Id FROM Invoices__r ';
        Query += '  WHERE Age__c < 60 AND Status__c = \'Posted\' AND Balance__c > 0 AND Id IN (';
        Query += '    SELECT Invoice__c FROM InvoiceLineItem__c ';
        Query += '    WHERE SubscriptionLineItem__r.Product__r.Name LIKE \'%Instalment%\'';
        Query += '  )';
        Query += ') FROM Account ';
        Query += 'WHERE Batch__c = \'Batch4\' AND Id IN (SELECT CustomerAccount__c FROM Invoice__c WHERE Status__c = \'Posted\')';
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(Query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        Set<String> IdSet = new Set<String>();
        List<ZObj.BatchChange> BatchChanges = new List<ZObj.BatchChange>();
        Map<String,String> zMap = new Map<String,String>();
        List<Account> UpsertAccounts = new List<Account>();
        List<ZObj.CreateBillRun> BillRuns = new List<ZObj.CreateBillRun>();
        for (sObject s : scope) {
            if ((s.getSObjects('Invoices__r')) == null) {
                zMap.put((String)s.get('ZuoraId__c'), 'Batch2');
                BatchChanges.add(new ZObj.BatchChange((String)s.get('ZuoraId__c'), 'Batch2'));
            } else {
            	BillRuns.add(new ZObj.CreateBillRun((String)s.get('ZuoraId__c'), Date.today()));
            }
        }
        ZuoraSyncController.CreateBillRunsForPrepayers(BillRuns);
        if(BatchChanges != null) {for (ZObj.SuccessId zs : ZuoraSyncController.UpdateBillingBatches(BatchChanges)) {
            if (zs.Success) UpsertAccounts.add(new Account(ZuoraId__c = zs.Id, Batch__c = zMap.get(zs.Id) ));
        }}
        upsert UpsertAccounts ZuoraId__c;
    }
    
    global void finish(Database.BatchableContext BC){
    }
    
}