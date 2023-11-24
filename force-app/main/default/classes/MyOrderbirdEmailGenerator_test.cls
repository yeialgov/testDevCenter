@isTest public class MyOrderbirdEmailGenerator_test {

    Static TestMethod void test() {
        Account a = new Account(name='Test');
        insert a;
        Contact c = new Contact(AccountId=a.Id, LastName='Test');
        insert c;
        MyObVenue__c v = new MyObVenue__c(Contact__c = c.Id, Login__c = 'test@test.com');
        insert v;
        String jobId = System.schedule('test', '0 0 0 3 9 ? 2022', new MyOrderbirdEmailGenerator());
    }
}