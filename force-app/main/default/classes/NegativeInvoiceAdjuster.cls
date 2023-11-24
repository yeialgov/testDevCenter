global class NegativeInvoiceAdjuster implements Database.Batchable<sObject>, Database.AllowsCallouts{
    
    global String Query;
    
    global NegativeInvoiceAdjuster() {
        Query  = 'SELECT Id, Balance__c, ZuoraId__c, Account__r.ZuoraId__c FROM Invoice__c ';
        Query += 'WHERE Balance__c < 0 AND InvoiceDate__c <= TODAY AND Status__c = \'Posted\'';
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(Query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        List<ZObj.CreateCBA> CreateCBAs = new List<ZObj.CreateCBA>();
        for (sObject s : scope) {
            CreateCBAs.add(
                new ZObj.CreateCBA(
                    Math.abs((Decimal)s.get('Balance__c')), (String)s.get('ZuoraId__c'), 'Increase'
                )
            );
        }
        ZuoraSyncController.CreateCreditBalanceAdjustments(new List<List<ZObj.CreateCBA>>{ CreateCBAs });
    }
    
    global void finish(Database.BatchableContext BC){
    }
    
}