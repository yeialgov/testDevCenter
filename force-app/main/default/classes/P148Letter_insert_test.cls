@isTest
public class P148Letter_insert_test {
    Static TestMethod void test() {
        Account a = new Account(name='test');
        insert a;
        Contact c = new Contact(lastname='test', accountid=a.id, email='test@test.com');
        insert c;
        a.SF_BillTo_Contact__c = c.Id;
        update a;
        MyObVenue__c v = new MyObVenue__c(contact__c=c.Id,myorderbirdid__c='123');
        insert v;
    	P148Letter__c l = new P148Letter__c(venue__c=v.Id);
    	insert l;
    }
}