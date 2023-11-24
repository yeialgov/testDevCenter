@isTest public class NetsuiteAddressCopierTest {
	
    static testMethod void test1() {
        Account a = new Account(name='t', Account_Status__c = 'Active Customer', Last_Status_Update__c = DateTime.now().addDays(-1));
        insert a;
        Contact c = new Contact(lastname='t', AccountId = a.Id);
        insert c;
        a.SF_SoldTo_Contact__c = c.Id;
        update a;
        Database.executeBatch(new NetsuiteAddressCopier());
    }
	
    static testMethod void test2() {
        Account a = new Account(name='t', Account_Status__c = 'Active Customer', Last_Status_Update__c = DateTime.now().addDays(-1));
        insert a;
        Contact c = new Contact(lastname='t', AccountId = a.Id);
        insert c;
        a.SF_SoldTo_Contact__c = c.Id;
        a.AddressBuilder_Shipping__c = '["Name","empty"]';
        update a;
        Database.executeBatch(new NetsuiteAddressCopier());
    }
	
    static testMethod void test3() {
        Account a = new Account(name='t', Account_Status__c = 'Active Customer', Last_Status_Update__c = DateTime.now().addDays(-1));
        insert a;
        Contact c = new Contact(firstname = '[not provided]', lastname='t', AccountId = a.Id);
        insert c;
        a.SF_SoldTo_Contact__c = c.Id;
        update a;
        Database.executeBatch(new NetsuiteAddressCopier());
    }

    static testMethod void testScheduler() {
        test.startTest();
 		NetsuiteAddressCopierScheduler dbs = new NetsuiteAddressCopierScheduler();
        String sch = '0 0 23 * * ?';
        system.schedule('Test check', sch, dbs);
        test.stopTest();
    }

}