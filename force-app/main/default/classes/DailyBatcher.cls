global class DailyBatcher implements Database.Batchable<sObject>{
    
    global final String Query;
    global final String ObjectName;
    
    global DailyBatcher(String objName) {
        ObjectName = objName;
        Query = 'SELECT Id FROM ' + ObjectName;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        Map<String, Schema.SObjectType> globDesc = Schema.getGlobalDescribe();
        List<sObject> eventList = new List<sObject>();
        for (SObject s : scope) {
            sObject sObj = Schema.getGlobalDescribe().get('Batch_' + ObjectName.replace('__c','') + '__e').newSObject();
            sObj.put('RecordId__c', (Id)s.get('Id'));
            eventList.add(sObj);
        }
        EventBus.publish(eventList);
    }
    
    global void finish(Database.BatchableContext BC){
    }
    
}