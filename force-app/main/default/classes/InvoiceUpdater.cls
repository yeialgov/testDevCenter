global class InvoiceUpdater implements Database.Batchable<sObject>, Database.AllowsCallouts{
    
    global String Query;
    
    global InvoiceUpdater() {
        Query  = 'SELECT Id, ZuoraId__c, VATId__c, TaxExemptReason__c, VAT_ref__c FROM Invoice__c WHERE Id IN (SELECT ParentId FROM Invoice__History WHERE Field = \'HasBeenEmailed__c\' AND CreatedDate >= YESTERDAY)';
    }
    
    global InvoiceUpdater(Boolean b) {
        if (b) {
            Query  = 'SELECT Id, ZuoraId__c, VATId__c, TaxExemptReason__c, VAT_ref__c FROM Invoice__c WHERE HasBeenEmailed__c = TRUE AND ZuoraId__c != null AND VATId__c != NULL';
        } else {
            Query  = 'SELECT Id, ZuoraId__c, VATId__c, TaxExemptReason__c, VAT_ref__c FROM Invoice__c WHERE VAT_ref__c != null';
        }
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(Query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        List<ZObj.InvoiceVATUpdate> BatchChanges = new List<ZObj.InvoiceVATUpdate>(); for (sObject s : scope) { BatchChanges.add(new ZObj.InvoiceVATUpdate((Invoice__c)s)); } ZuoraSyncController.UpdateInvoiceBatches(BatchChanges);
    }
    
    global void finish(Database.BatchableContext BC){
    }

}