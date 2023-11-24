global class InvoicePayment_Batch implements Database.Batchable<sObject>{
    
    global final String Query;
    
    global InvoicePayment_Batch() {
        Query = 'SELECT Id, IsQualifyingPayment__c, IsQualifyingPayment_Formula__c FROM InvoicePayment__c '
            + 'WHERE (IsQualifyingPayment__c = TRUE AND IsQualifyingPayment_Formula__c = FALSE) '
            + 'OR (IsQualifyingPayment__c = FALSE AND IsQualifyingPayment_Formula__c = TRUE)';
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        for (SObject s : scope) {
            s.put('IsQualifyingPayment__c', (Boolean)s.get('IsQualifyingPayment_Formula__c'));
        }
        update scope;
    }
    
    global void finish(Database.BatchableContext BC){
    }
    
}