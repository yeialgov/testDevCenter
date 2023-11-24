@isTest public class AddressMigration_test {
    public static TestMethod void test() {
        Account a = new Account(name='test');
        insert a;
        Contact c = new Contact(lastname='test', accountid = a.Id);
        insert c;
        a.SF_BillTo_Contact__c = c.Id;
        a.SF_SoldTo_Contact__c = c.Id;
        a.SF_Venue_Contact__c = c.Id;
        a.BillingCountry = 'Germany';
        update a;
        Database.executeBatch(new AddressMigration());
    }

}