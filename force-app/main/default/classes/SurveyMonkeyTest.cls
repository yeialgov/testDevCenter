@isTest public class SurveyMonkeyTest {

    static TestMethod void test() {
        Account a = new Account(Name='test');
        insert a;
        Contact c = new Contact(Lastname='test', AccountId=a.Id, Email='bart.collins@orderbird.com');
        insert c;
        AutomatedSurvey__c ausu = new AutomatedSurvey__c(Contact__c = c.Id);
        insert ausu;
    }
    
    static TestMethod void test2() {
        SurveyMonkeyAPI.upsertAnswers('surveyId');
        SurveyMonkeyAPI.createWebhook('CollectorId');
        String s = SurveyMonkeyAPI.getWebhooks();
        s = SurveyMonkeyAPI.getWebhook('webhookId');
        s = SurveyMonkeyAPI.getErrorMessage('errorId');
        s = SurveyMonkeyAPI.getResponse('CollectorId', 'ResponseId');
        s = SurveyMonkeyAPI.getSurveyDetails('SurveyId');
        s = SurveyMonkeyAPI.getResponses('SurveyId');
        SurveyMonkeyAPI.newMonthCollector();
        SurveyMonkeyAPI.getResponse('ResponseId', 'RecipientId', 'CollectorId');
		SurveyMonkeyRestResource.SurveyCallback();
    }
    
    static TestMethod void test3() {
         test.starttest();
         ScheduledNPSNewMonth sNPSnm = new ScheduledNPSNewMonth();   
         String chron = '0 0 23 * * ?';        
         system.schedule('Test Sched', chron, sNPSnm);
         test.stopTest();
    }
}