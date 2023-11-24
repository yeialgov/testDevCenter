global class InterwegaBatch implements Database.Batchable<sObject>{
    
    global String Query;
    global InterwegaBatch() {
        Query  = 'SELECT Id, Interwega_Business_Area__c, Interwega_Open_Balance__c, Interwega_Debt_Collection_Id__c, ';
        Query += 'Interwega_Open_Balance_wo_fees__c, Interwega_Reference_Date__c, Interwega_Status__c FROM Account WHERE Interwega_Status__c != null';
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(Query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        for (SObject s : scope) {
            s.put('Interwega_Business_Area__c' , null);
            s.put('Interwega_Open_Balance__c' , null);
            s.put('Interwega_Open_Balance_wo_fees__c' , null);
            s.put('Interwega_Reference_Date__c' , null);
            s.put('Interwega_Status__c' , null);
            s.put('Interwega_Debt_Collection_Id__c' , null);
        }
        update scope;
    }

    global void finish(Database.BatchableContext BC){}

}