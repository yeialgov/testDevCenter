global class SchedClear_SLIMap implements Schedulable {
    global void execute(SchedulableContext sc) {
        delete [SELECT Id FROM SLIMap__c LIMIT 10000];
    }
}