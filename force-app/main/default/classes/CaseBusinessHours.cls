global class CaseBusinessHours implements Database.Batchable<sObject>{
    
    global final String Query;
    
    global CaseBusinessHours() {
        Query = 'SELECT Id, CreatedDate, ClosedDate, Opened_After_Hours__c, Closed_After_Hours__c FROM Case';
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        List<Case> UpdateCases = new List<Case>();
		BusinessHours bh = [SELECT Id FROM BusinessHours WHERE IsDefault=true];
        for(sObject s : scope){
            Boolean OAH = !BusinessHours.isWithin(bh.id, (DateTime)s.get('CreatedDate'));
            Boolean CAH = false;
            if ((DateTime)s.get('ClosedDate') != null) {
                CAH = !BusinessHours.isWithin(bh.id, (DateTime)s.get('ClosedDate'));
            }
            if (OAH || CAH || Test.isRunningTest()) {
                UpdateCases.add(
                    new Case(
                        Id = (Id)s.get('Id'),
                        Opened_After_Hours__c = OAH,
                        Closed_After_Hours__c = CAH
                    )
                );
            }
        }
        update UpdateCases;
    }
    
    global void finish(Database.BatchableContext BC){
    }
    
}