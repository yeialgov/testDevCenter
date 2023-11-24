@isTest(seeAllData=true) public class BamboraOnboard_test {

    static TestMethod void test() {
        Account a = new Account(name='test', Target_Product__c = 'MINI');
        insert a;
        Contact c = new Contact(lastname='test', accountid = a.id);
        insert c;
        MyObVenue__c v = new MyObVenue__c(contact__c = c.id);
        insert v;
        system.enqueueJob(new BamboraOnboard(v.Id));
    }
}