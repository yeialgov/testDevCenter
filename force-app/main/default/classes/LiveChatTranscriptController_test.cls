@isTest public class LiveChatTranscriptController_test {

    static TestMethod void test() {
        Account a = new Account(name='Test');
        insert a;
        Case c = new Case(AccountId=a.Id);
        insert c;
        LiveChatVisitor v = new LiveChatVisitor();
        insert v;
        LiveChatTranscript l = new LiveChatTranscript(CaseId = c.Id, LiveChatVisitorId = v.Id);
        insert l;
        system.assertEquals(LiveChatTranscriptController.getCaseId(l.Id), c.Id);
        system.assertEquals(LiveChatTranscriptController.getAccountId(l.Id), a.Id);
    }
    static TestMethod void test_venues() {
        Account a = new Account(name='Test');
        insert a;
        Contact c = new Contact(
            lastname = 'TestMan',
            email = 'test@email.com',
            AccountId=a.Id);
        insert c;
        MyObVenue__c v = new MyObVenue__c(Contact__c=c.id, MyOrderbirdId__c='NotNull');
        insert v;
        system.assertEquals(LiveChatTranscriptController.getMyObVenues(a.Id).isEmpty(), false);
        }
}