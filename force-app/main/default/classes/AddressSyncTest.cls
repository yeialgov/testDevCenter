/**
 * @author joern
 */
@isTest(SeeAllData=false)
private class AddressSyncTest {


    @isTest static void constructer_test() {
        Account[] accounts = new List<Account>();
        accounts.add(new Account());
        AddressSync accTrigger = new AddressSync(accounts);
        System.assertEquals(accounts, accTrigger.objList);
    }


    @isTest static void findContactIDs_should_return_contact_ids() {
        initTestData();
        Account[] accounts = [SELECT Name, SF_SoldTo_Contact__c, SF_BillTo_Contact__c, Primary_Contact__c FROM Account];
        AddressSync AddrSync = new AddressSync(accounts);
        Set<ID> contactIDs = AddrSync.findContactIDs();
        System.assertEquals(3, contactIDs.size());
        System.assertEquals(true, contactIDs.contains(accounts[0].SF_SoldTo_Contact__c));
        System.assertEquals(true, contactIDs.contains(accounts[0].SF_BillTo_Contact__c));
    }


    @isTest static void findContactIDs_should_return_empty_contact_set() {
        AddressSync AddrSync = new AddressSync(null);
        Set<ID> contactIDs = AddrSync.findContactIDs();
        System.assertEquals(0, contactIDs.size());
    }


    @isTest static void findAccountIDs_should_return_account_ids() {
        initTestData();
        Contact[] contacts = [SELECT AccountId FROM Contact];
        AddressSync AddrSync = new AddressSync(contacts);
        Set<ID> accountIDs = AddrSync.findAccountIDs();
        System.assertEquals(1, accountIDs.size());
        System.assertEquals(true, accountIDs.contains(contacts[0].AccountId));
    }


    @isTest static void findAccountIDs_should_return_empty_account_set() {
        AddressSync AddrSync = new AddressSync(null);
        Set<ID> accountIDs = AddrSync.findAccountIDs();
        System.assertEquals(0, accountIDs.size());
    }


    @isTest static void loadRelatedContactAddresses_should_return_contacts() {
        initTestData();
        Account[] accounts = [SELECT Name, SF_SoldTo_Contact__c, SF_BillTo_Contact__c, Primary_Contact__c FROM Account];
        AddressSync AddrSync = new AddressSync(accounts);
        AddrSync.loadRelatedContactAddresses();
        Contact[] contacts = [SELECT ID, AccountId FROM Contact];
        System.assertEquals(2, AddrSync.relatedContacts.size());
        System.assertEquals(true, AddrSync.relatedContacts.containsKey(contacts[0].ID));
        System.assertEquals(true, AddrSync.relatedContacts.containsKey(contacts[1].ID));
    }


    @isTest static void loadRelatedContactAddresses_should_not_return_contacts() {
        initTestData2();
        Account[] accounts = [SELECT Name, SF_SoldTo_Contact__c, SF_BillTo_Contact__c, Primary_Contact__c FROM Account];
        AddressSync AddrSync = new AddressSync(accounts);
        AddrSync.loadRelatedContactAddresses();
        Contact[] contacts = [SELECT ID, AccountId FROM Contact];
        System.assertEquals(0, AddrSync.relatedContacts.size());
    }


    @isTest static void loadRelatedAccountAddresses_should_return_accounts() {
        initTestData();
        Contact[] contacts = [SELECT AccountId FROM Contact];
        AddressSync AddrSync = new AddressSync(contacts);
        AddrSync.loadRelatedAccountAddresses();
        Account[] accounts = [SELECT ID, Name, BillingStreet, BillingCity FROM Account];
        System.assertEquals(1, AddrSync.relatedAccounts.size());
        System.assertEquals(true, AddrSync.relatedAccounts.containsKey(accounts[0].ID));
    }


    @isTest static void updateAccountAddresses_should_update_address_from_related_contact() {
        initTestData();
        Account[] accounts = [SELECT Name, SF_SoldTo_Contact__c, SF_BillTo_Contact__c, Primary_Contact__c, BillingStreet, BillingCity, BillingPostalCode, BillingCountry, BillingCountryCode FROM Account];
        AddressSync AddrSync = new AddressSync(accounts);
        AddrSync.loadRelatedContactAddresses();
        AddrSync.updateAccountAddresses(accounts[0]);
        /*System.assertEquals('Leipzigerstr. 13', accounts[0].BillingStreet);
        System.assertEquals('Berlin', accounts[0].BillingCity);
        System.assertEquals('Germany', accounts[0].BillingCountry);
        System.assertEquals('121212', accounts[0].BillingPostalCode);
        System.assertEquals('Hansastr. 14', accounts[0].ShippingStreet);
        System.assertEquals('Köln', accounts[0].ShippingCity);
        System.assertEquals('Germany', accounts[0].ShippingCountry);
        System.assertEquals('21213', accounts[0].ShippingPostalCode);*/
    }


    @isTest static void updateAccountAddresses_should_unset_addresses() {
        initTestData2();
        Account[] accounts = [SELECT Name, SF_SoldTo_Contact__c, SF_BillTo_Contact__c, Primary_Contact__c, BillingStreet, BillingCity, BillingPostalCode, BillingCountry, BillingCountryCode FROM Account];
        AddressSync AddrSync = new AddressSync(accounts);
        AddrSync.loadRelatedContactAddresses();
        AddrSync.updateAccountAddresses(accounts[0]);
        /*System.assertEquals(null, accounts[0].BillingStreet);
        System.assertEquals(null, accounts[0].BillingCity);
        System.assertEquals(null, accounts[0].BillingCountry);
        System.assertEquals(null, accounts[0].BillingPostalCode);
        System.assertEquals(null, accounts[0].ShippingStreet);
        System.assertEquals(null, accounts[0].ShippingCity);
        System.assertEquals(null, accounts[0].ShippingCountry);
        System.assertEquals(null, accounts[0].ShippingPostalCode);*/
    }


    @isTest static void updateAccountAddresses_should_return_account_with_updated_billingadress() {
        initTestData();
        Contact[] contacts = [
                SELECT
                        AccountId, MailingStreet, MailingCity, MailingCountry, MailingCountryCode, MailingPostalCode, MailingState
                FROM Contact
                WHERE FirstName = 'Joe'
        ];
        AddressSync AddrSync = new AddressSync(contacts);
        AddrSync.loadRelatedAccountAddresses();
        Account acc = AddrSync.updateAccountAddresses(contacts[0]);
        /*System.assertEquals(acc.BillingStreet, contacts[0].MailingStreet);
        System.assertEquals(acc.BillingCity, contacts[0].MailingCity);
        System.assertEquals(acc.BillingCountry, contacts[0].MailingCountry);
        System.assertEquals(acc.BillingPostalCode, contacts[0].MailingPostalCode);*/
    }


    @isTest static void updateAccountAddresses_should_return_account_with_updated_shipppingadress() {
        initTestData();
        Contact[] contacts = [
                SELECT
                        AccountId, MailingStreet, MailingCity, MailingCountry, MailingCountryCode, MailingPostalCode, MailingState
                FROM Contact
                WHERE FirstName = 'Joe2'
        ];
        AddressSync AddrSync = new AddressSync(contacts);
        AddrSync.loadRelatedAccountAddresses();
        Account acc = AddrSync.updateAccountAddresses(contacts[0]);
        /*System.assertEquals(acc.ShippingStreet, contacts[0].MailingStreet);
        System.assertEquals(acc.ShippingCity, contacts[0].MailingCity);
        System.assertEquals(acc.ShippingCountry, contacts[0].MailingCountry);
        System.assertEquals(acc.ShippingPostalCode, contacts[0].MailingPostalCode);*/
    }


    @isTest static void updateAccountAddresses_without_related_account_should_return_null() {
        Contact conBilling = new Contact(
                FirstName = 'Joe',
                LastName = '_Muster_',
                Email = 'h@aol.c.com',
                Phone = '030 22001002001',
                MailingStreet = 'Leipzigerstr. 13',
                MailingCity = 'Berlin',
                MailingPostalCode = '121212',
                MailingCountry = 'Germany'
        );
        insert conBilling;

        Contact[] contacts = [
                SELECT
                        AccountId, MailingStreet, MailingCity, MailingCountry, MailingPostalCode, MailingState
                FROM Contact
                WHERE FirstName = 'Joe'
        ];
        AddressSync AddrSync = new AddressSync(contacts);
        AddrSync.loadRelatedAccountAddresses();
        Account acc = AddrSync.updateAccountAddresses(contacts[0]);
        System.assertEquals(null, acc);
    }


    private static void initTestData() {
        Account acc = new Account(
                Name = '__Account1221');
        insert acc;
        ID acctID = acc.ID;
        Contact conBilling = new Contact(
                FirstName = 'Joe',
                LastName = '__Smith12',
                Email = 'h@aol.c.com',
                Phone = '030 2001002001',
                MailingStreet = 'Leipzigerstr. 13',
                MailingCity = 'Berlin',
                MailingPostalCode = '121212',
                MailingCountry = 'Germany',
                AccountId = acctID);
        Contact conShipping = new Contact(
                FirstName = 'Joe2',
                Email = 'h2@aol.c.com',
                LastName = '__Smith21',
                Phone = '030 3120010202001',
                MailingStreet = 'Hansastr. 14',
                MailingCity = 'Köln',
                MailingPostalCode = '21213',
                MailingCountry = 'Germany',
                AccountId = acctID);
        insert conBilling;
        insert conShipping;
        acc.SF_SoldTo_Contact__c = conShipping.ID;
        acc.SF_BillTo_Contact__c = conBilling.ID;
        update acc;
    }


    private static void initTestData2() {
        Account acc = new Account(
                Name = '_Accountito_');
        insert acc;
        ID acctID = acc.ID;
        Contact conBilling = new Contact(
                FirstName = 'Joe',
                LastName = '_Muster_',
                Email = 'h@aol.c.com',
                Phone = '030 22001002001',
                MailingStreet = 'Leipzigerstr. 13',
                MailingCity = 'Berlin',
                MailingPostalCode = '121212',
                MailingCountry = 'Germany',
                AccountId = acctID);
        Contact conShipping = new Contact(
                FirstName = 'Joe2',
                Email = '_hsss2@aol.c.com',
                LastName = '_Smith2_',
                Phone = '0301 520010202001',
                MailingStreet = 'Popelstr 13',
                MailingCity = 'Köln',
                MailingPostalCode = '21212',
                MailingCountry = 'Germany',
                AccountId = acctID);
        insert conBilling;
        insert conShipping;
    }
}