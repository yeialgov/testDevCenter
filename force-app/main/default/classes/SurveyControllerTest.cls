@isTest(SeeAllData=true) public class SurveyControllerTest {

    static TestMethod void test() {
        Account a = new Account(Name='test');
        insert a;
        Contact c = new Contact(Lastname='test', AccountId=a.Id, Email='bart.collins@orderbird.com');
        insert c;
        AutomatedSurvey__c ausu = new AutomatedSurvey__c(Contact__c = c.Id);
        insert ausu;
        system.assert(!SurveyController.InitSurvey(PortalToken.encryptPlain('other'),'5'));
        system.assert(!SurveyController.SubmitSurvey(PortalToken.encryptPlain('other'),'{}'));
        system.assert(SurveyController.InitSurvey(PortalToken.encryptPlain(ausu.Id),'5'));
        system.assertEquals([SELECT Id, Nps__c FROM AutomatedSurvey__c WHERE Id = :ausu.Id LIMIT 1].Nps__c, 5);
        system.assert(SurveyController.SubmitSurvey(PortalToken.encryptPlain(ausu.Id),'{"NPS":6}'));
        system.assertEquals([SELECT Id, Nps__c FROM AutomatedSurvey__c WHERE Id = :ausu.Id LIMIT 1].Nps__c, 6);
        system.assert([SELECT Id, Locked__c FROM AutomatedSurvey__c WHERE Id = :ausu.Id LIMIT 1].Locked__c);
    }
}