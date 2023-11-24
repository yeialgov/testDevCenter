global class SlackNPS_scheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        List<AutomatedSurvey__c> OpenSurveys = [SELECT Id, Locked__c FROM AutomatedSurvey__c WHERE NPS__c != null AND Locked__c = FALSE AND DateResponded__c >= 2020-07-01 AND DateResponded__c < TODAY];
        for (AutomatedSurvey__c OpenSurvey : OpenSurveys) {
            OpenSurvey.Locked__c = TRUE; system.enqueueJob(new SlackNPS(OpenSurvey.Id));
        }
        update OpenSurveys;
        system.enqueueJob(new SlackNPS());
    }
}