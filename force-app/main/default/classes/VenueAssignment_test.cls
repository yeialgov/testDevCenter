@isTest public class VenueAssignment_test {

    static TestMethod void test() {
        Account a = new Account(name='test');
        insert a;
        Contact c = new Contact(lastname='test', accountid=a.Id);
        insert c;
        MyObVenue__c v = new MyObVenue__c(Contact__c = c.id);
        insert v;
        test.starttest();
        Database.executeBatch(new VenueAssignment());
        test.stoptest();
        system.assertEquals([SELECT Id, Venue__c FROM Account WHERE Id = :a.Id][0].Venue__c, v.Id);
        String jobId = System.schedule('test', '0 0 0 3 9 ? 2022', new VenueAssignment_Scheduler());
    }
}