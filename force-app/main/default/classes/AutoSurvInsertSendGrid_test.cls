@isTest (seeAllData=true) public class AutoSurvInsertSendGrid_test {
    static TestMethod void test() {
        Account a = new Account(Name='test');
        insert a;
        Contact c = new Contact(Lastname='test', AccountId=a.Id, Email='bart.collins@orderbird.com');
        insert c;
        AutomatedSurvey__c ausu = new AutomatedSurvey__c(Contact__c = c.Id);
        insert ausu;
    }

}