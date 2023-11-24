global class BatchUtil implements Database.Batchable<sObject>{
    
    global final String Query;
    global final String Field;
    global final String Value;
    global final String Method;
    global final Boolean BoolValue;
    global final String VariableType;

    global BatchUtil(String methodName, String queryString){
        Query = queryString;
        Method = methodName;
    }
    
    global BatchUtil(String queryString, String fieldApiName, String newValue) {
        Query = queryString;
        Field = fieldApiName;
        Value = newValue;
    }
    
    global BatchUtil(String queryString, String fieldApiName, Boolean newValue) {
        Query = queryString;
        Field = fieldApiName;
        BoolValue = newValue;
        VariableType = 'Boolean';
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(Query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        if (Method == 'AccountOnboardingStatus') AccountOnboardingStatus.process((List<Account>)scope);
        if (Method == 'LeadTimeCalculator') LeadTimeCalculator.processBatch(scope);
        if (Method == null && Field != null) {
            for (SObject sobj : scope) {
                if (VariableType == 'Boolean') { sobj.put(Field, BoolValue); } else { sobj.put(Field, Value); }
            }
            update scope;
        }
    }
    
    global void finish(Database.BatchableContext BC){}
    
}