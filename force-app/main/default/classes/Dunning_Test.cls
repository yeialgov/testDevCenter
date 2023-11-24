@isTest
public class Dunning_Test {

    static testMethod void dunningMessages() {
        List<Account> insAccts = new List<Account>();
        insAccts.add( new Account(
            name='English Test',
            PrimaryLanguage__c = 'English'
        ));
        insAccts.add( new Account(
            name='German Test',
            PrimaryLanguage__c = 'German'
        ));
        insAccts.add( new Account(
            name='French Test',
            PrimaryLanguage__c = 'French'
        ));
        insert insAccts;
        dunningMessageController dmc = new dunningMessageController();
        for (Account a : insAccts) {
            dmc.acctId = a.Id;
        }
    }

    static testMethod void batchTest() {
        Id RTId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'Customer' LIMIT 1].Id;
        List<Account> insAccts = new List<Account>();
        List<Account> updAccts = new List<Account>();
        List<Contact> insCons = new List<Contact>();
        List<Invoice__c> insInvs = new List<Invoice__c>();
        for (Integer xx=0; xx<4; xx++) {
            insAccts.add( new Account(
                name='English Test',
                PrimaryLanguage__c = 'English',
                RecordTypeId = RTId,
                Dunning_0_Date__c = Date.newInstance(2011,1,1),
                SuccessfulTasks__c = xx
            ));
            insAccts.add( new Account(
                name='German MINITest',
                PrimaryLanguage__c = 'German',
                RecordTypeId = RTId,
                Dunning_0_Date__c = Date.newInstance(2011,1,1),
                Dunning_1_Date__c = Date.newInstance(2011,1,1),
                Target_Product__c = 'MINI',
                SuccessfulTasks__c = xx
            ));
            insAccts.add( new Account(
                name='German PROTest',
                PrimaryLanguage__c = 'German',
                RecordTypeId = RTId,
                Dunning_0_Date__c = Date.newInstance(2011,1,1),
                Dunning_1_Date__c = Date.newInstance(2011,1,1),
                Closed_Contract_Paid_Date__c = Date.newInstance(2011,1,1),
                SuccessfulTasks__c = xx
            ));
            insAccts.add( new Account(
                name='German Test2',
                PrimaryLanguage__c = 'German',
                RecordTypeId = RTId,
                Dunning_0_Date__c = Date.newInstance(2011,1,1),
                Dunning_1_Date__c = Date.newInstance(2011,1,1),
                Dunning_2_Date__c = Date.newInstance(2011,1,1),
                SuccessfulTasks__c = xx
            ));
            insAccts.add( new Account(
                name='French Test',
                PrimaryLanguage__c = 'French',
                RecordTypeId = RTId,
                Target_Product__c = 'PRO',
                SuccessfulTasks__c = xx
            ));
        }
        insert insAccts;
        for (Account a : insAccts) {
            insInvs.add(new Invoice__c(
            	Account__c = a.Id,
                Balance__c = 11,
                Status__c = 'Posted',
                DueDate__c = Date.today().addDays(Integer.valueOf(-10 * a.SuccessfulTasks__c - 2))
            ));
            insCons.add(new Contact(
            	Lastname = 'test',
                AccountId = a.Id,
                Email = 'noreply@orderbird.com'
            ));
        }
        insert insInvs;
        insert insCons;
        for (Contact c : insCons) {
            updAccts.add(new Account(
            	Id = c.AccountId,
                SF_BillTo_Contact__c = c.Id
            ));
        }
        update updAccts;
        for (Integer x=0; x<4; x++) {
            database.executeBatch(new DunningBatch(x), 20);
            system.debug(x);
        }
    }
    
    static testMethod void testScheduler() {
        test.startTest();
 		DunningBatch_Scheduler dbs = new DunningBatch_Scheduler();
        String sch = '0 0 23 * * ?';
        system.schedule('Test check', sch, dbs);
        test.stopTest();
    }

}