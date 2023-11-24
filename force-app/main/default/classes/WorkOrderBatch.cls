// class to manage the WorkOrder Items
public with sharing class WorkOrderBatch implements
Database.Batchable<sObject>, Database.Stateful {


// instance member to retain state across transactions
public Integer recordsProcessed = 0;
public List<Work_Order__c> listRecordsToCreate = new List<Work_Order__c>();
public List<Work_Order__c> listRecordsToRemove = new List<Work_Order__c>();

//gets all work order which have the field processed__c == false
public Database.QueryLocator start(Database.BatchableContext bc) {
    return Database.getQueryLocator(
        'SELECT Id, Message__c,	Operation__c ' +
        'FROM Work_Order__c ' +
        'Where Processed__c = false'
    );
}

//calls the service class with the remove or create parameter to define the operation
public void execute(Database.BatchableContext bc, List<Work_Order__c> scope){
    for(Work_Order__c wo: scope){
        if(wo.Operation__c =='Remove'){
            listRecordsToRemove.add(wo);
        }
        if(wo.Operation__c =='Create'){
            listRecordsToCreate.add(wo);
        }
    }
    if(listRecordsToRemove !=null && listRecordsToRemove.size()>0){
        WorkOrderSerivce.startNegativeProcess(listRecordsToRemove);
    }
    if(listRecordsToCreate !=null && listRecordsToCreate.size()>0){
        WorkOrderSerivce.startPositiveProcess(listRecordsToCreate);
    }
}

public void finish(Database.BatchableContext bc){
}
}