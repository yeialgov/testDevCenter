@isTest(SeeAllData=true) public class SlackNPS_test {

    static TestMethod void test1() {
        Contact c = new Contact(LastName='test',Email='test@test.com');
        insert c;
        insert new AutomatedSurvey__c(Contact__c = c.Id, NPS__c = 0, DateResponded__c=Date.today().addDays(-5));
        system.schedule('jobName', '0 0 0 * * ?', new SlackNPS_scheduler());
    }
    
    static TestMethod void test2() {
        Contact c = new Contact(LastName='test',Email='test@test.com');
        insert c;
        insert new AutomatedSurvey__c(Contact__c = c.Id, NPS__c = 0, DateResponded__c=Date.today().addDays(-5));
        insert new AutomatedSurvey__c(Contact__c = c.Id, NPS__c = 0, DateResponded__c=Date.today().addDays(-45));
        insert new AutomatedSurvey__c(Contact__c = c.Id, NPS__c = 0, DateResponded__c=Date.today().addDays(-205));
        system.enqueueJob(new SlackNPS());
    }
    
    static TestMethod void test3() {
        Contact c = new Contact(LastName='test',Email='test@test.com');
        insert c;
        AutomatedSurvey__c ausu = new AutomatedSurvey__c(Contact__c = c.Id, NPS__c = 0);
        insert ausu;
        system.enqueueJob(new SlackNPS(ausu.Id));
        SlackNPS.NPSAccessory acc = new SlackNPS.NPSAccessory('10');
        acc = new SlackNPS.NPSAccessory('9');
        acc = new SlackNPS.NPSAccessory('8');
        acc = new SlackNPS.NPSAccessory('7');
        acc = new SlackNPS.NPSAccessory('6');
        acc = new SlackNPS.NPSAccessory('5');
        acc = new SlackNPS.NPSAccessory('4');
        acc = new SlackNPS.NPSAccessory('3');
        acc = new SlackNPS.NPSAccessory('2');
        acc = new SlackNPS.NPSAccessory('1');
    }
    
}