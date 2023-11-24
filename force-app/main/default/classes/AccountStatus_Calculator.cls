global class AccountStatus_Calculator implements Database.Batchable<sObject>{
    
    global final String Query;
    
    global AccountStatus_Calculator() {
        Query = 'SELECT Id, RecordType.Name, Account_Status__c, Number_of_Active_Subscriptions_2__c, NS_Customer_Internal_ID__c FROM Account';
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        AccountStatus_Controller.ExecuteAccountStatusUpdate(scope);
    }
    
    global void finish(Database.BatchableContext BC){
    }
    
}