@isTest
public class AccountOnboardingStatusTest {
    
    public static Id RTId = [SELECT Id FROM RecordType WHERE SObjectType = 'Case' and Name = 'Case: Onboarding' LIMIT 1].Id;
    public static Id RTIdX = [SELECT Id FROM RecordType WHERE SObjectType = 'Case' and Name != 'Case: Onboarding' LIMIT 1].Id;
    
    @testSetup
    public static void setupTestData() {
        List<Account> TestAccounts = new List<Account>();
        for (Integer x=0; x<3; x++) {
            TestAccounts.add(new Account(Name = 'TestAccount_' + x));
        }
        insert TestAccounts;
    }
    
    // Default value, set by workflow
    @isTest static void defaultValue() {
        Account a = [SELECT Id, Onboard_Status__c FROM Account WHERE Name='TestAccount_0' LIMIT 1];
        System.assertEquals(Label.ONBOARDSTATUS_NOSUB, a.Onboard_Status__c);
    }
    
    // Testing changes to related case
    @isTest static void caseChanging() {
        Account a = [SELECT Id, Onboard_Status__c FROM Account WHERE Name='TestAccount_0' LIMIT 1];
        
        // Case Solution new Record for Validation Rules
        casesolution__c CS1 = new casesolution__c();
        insert CS1;
            
        // Case without Onboarding RT
        Case c = new Case(AccountId = a.Id);
        insert c;
        
        //Junction Case Solution with Case
        casesolutionjunction__c junx = new casesolutionjunction__c(
        	Case__c = c.Id,
            CaseSolution__c = CS1.Id
        );
        insert junx;
        
        system.assertEquals(
            Label.ONBOARDSTATUS_NOSUB, 
            [SELECT Onboard_Status__c FROM Account WHERE Name='TestAccount_0' LIMIT 1].Onboard_Status__c
        );
        
        // Case changed to Onboarding RT
        c.RecordTypeId = RTId;
        c.Onboarding_Type__c = 'Onboarding Basic';
        update c;
        system.assertNotEquals(
            Label.ONBOARDSTATUS_NOSUB, 
            [SELECT Onboard_Status__c FROM Account WHERE Name='TestAccount_0' LIMIT 1].Onboard_Status__c
        );
        
        // Case changed back away from Onboarding RT
        c.RecordTypeId = RTIdX;
        c.Onboarding_Type__c = '';
        update c;
        system.assertEquals(
            Label.ONBOARDSTATUS_NOSUB, 
            [SELECT Onboard_Status__c FROM Account WHERE Name='TestAccount_0' LIMIT 1].Onboard_Status__c
        );
        
        // Case changed to Onboarding RT again
        c.RecordTypeId = RTId;
        c.Onboarding_Type__c = 'Onboarding Basic';
        update c;
        system.assertNotEquals(
            Label.ONBOARDSTATUS_NOSUB, 
            [SELECT Onboard_Status__c FROM Account WHERE Name='TestAccount_0' LIMIT 1].Onboard_Status__c
        );
        
        // Case deleted
        delete c;
        system.assertEquals(
            Label.ONBOARDSTATUS_NOSUB, 
            [SELECT Onboard_Status__c FROM Account WHERE Name='TestAccount_0' LIMIT 1].Onboard_Status__c
        );
        
    }
    
    // Testing changes to related subscription
    @isTest static void subChanging() {
        Account a = [SELECT Id, Onboard_Status__c FROM Account WHERE Name='TestAccount_0' LIMIT 1];
        
        Product2 p1 = new Product2(name='TestProduct');
        insert p1;
        
        Product2 p2 = new Product2(name='TestOnboard');
        insert p2;
        
        Product2 p3 = new Product2(name='TestOnboard Guest Management');
        insert p3;
        
        Subscription__c s1 = new Subscription__c(Account__c = a.Id, Status__c = 'Active', ZuoraId__c = 'x');
        insert s1;

        // Sub without Onboarding Name
        SubscriptionLineItem__c sub = new SubscriptionLineItem__c(
            Subscription__c = s1.Id,
            Product__c = p1.Id,
            ZuoraId__c = 'x'
        );
        insert sub;
        system.assertEquals(
            Label.ONBOARDSTATUS_NOSUB, 
            [SELECT Onboard_Status__c FROM Account WHERE Name='TestAccount_0' LIMIT 1].Onboard_Status__c
        );
        
        // Sub changed to Onboarding Name
        sub.Product__c = p2.Id; // includes the word 'onboard'
        update sub;
        system.assertEquals(
            Label.ONBOARDSTATUS_NOCASE, 
            [SELECT Onboard_Status__c FROM Account WHERE Name='TestAccount_0' LIMIT 1].Onboard_Status__c
        );
        
        // Sub changed to Onboarding_Guest Management Name
        sub.Product__c = p3.Id; // includes the word 'onboard && Guest Management'
        update sub;
        system.assertEquals(
            Label.ONBOARDSTATUS_NOSUB, 
            [SELECT Onboard_Status__c FROM Account WHERE Name='TestAccount_0' LIMIT 1].Onboard_Status__c
        );
        
        // Test no update on no change
        DateTime LastMod = [
            SELECT LastModifiedDate 
            FROM Account 
            WHERE Name='TestAccount_0' 
            LIMIT 1
        ].LastModifiedDate;
        sub.Product__c = p3.Id;
        update sub;
        DateTime CurrentMod = [
            SELECT LastModifiedDate 
            FROM Account 
            WHERE Name='TestAccount_0' 
            LIMIT 1
        ].LastModifiedDate;
        system.assertEquals(LastMod, CurrentMod);
        
        // Sub changed away from Onboarding Name
        sub.Product__c = p1.Id;
        update sub;
        system.assertEquals(
            Label.ONBOARDSTATUS_NOSUB, 
            [SELECT Onboard_Status__c FROM Account WHERE Name='TestAccount_0' LIMIT 1].Onboard_Status__c
        );
        
        // Sub deleted
        delete sub;
        system.assertEquals(
            Label.ONBOARDSTATUS_NOSUB, 
            [SELECT Onboard_Status__c FROM Account WHERE Name='TestAccount_0' LIMIT 1].Onboard_Status__c
        );
        
    }
    
    // Testing case and subscription
    @isTest static void caseAndSub() {
        Account a = [SELECT Id, Onboard_Status__c FROM Account WHERE Name='TestAccount_0' LIMIT 1];
        
        Product2 p1 = new Product2(name='TestProduct');
        insert p1;
        
        Product2 p2 = new Product2(name='TestOnboard');
        insert p2;
        
        Product2 p3 = new Product2(name='TestOnboard Guest Management');
        insert p3;
        
        Subscription__c s1 = new Subscription__c(Account__c = a.Id, Status__c = 'Active', ZuoraId__c = 'x');
        insert s1;

        // Sub with Onboarding Name
        SubscriptionLineItem__c sub = new SubscriptionLineItem__c(
            Subscription__c = s1.Id,
            Product__c = p2.Id,
            ZuoraId__c = 'x'
        );
        insert sub;
        system.assertEquals(
            Label.ONBOARDSTATUS_NOCASE, 
            [SELECT Onboard_Status__c FROM Account WHERE Name='TestAccount_0' LIMIT 1].Onboard_Status__c
        );
        
        // Case with Onboarding RT & OnboardingType -> Basic
        Case c = new Case(AccountId = a.Id, RecordTypeId = RTId, Onboarding_Type__c = 'Onboarding Basic');
        insert c;
        system.assertNotEquals(
            Label.ONBOARDSTATUS_NOCASE, 
            [SELECT Onboard_Status__c FROM Account WHERE Name='TestAccount_0' LIMIT 1].Onboard_Status__c
        );
        
    }
    
    // Testing method for batching
    @isTest static void batchProcess() {
        Test.startTest();
        
        List<Account> Accounts = [SELECT Id, Onboard_Status__c FROM Account];
        
        // corrupt data by deleting Onboarding Status
        for (Account Acct : Accounts) {
            Acct.Onboard_Status__c = null;
        }
        update Accounts;
        
        // before process, a selected account should have null onboarding status
        system.assertEquals(null, [SELECT Id, Onboard_Status__c FROM Account][2].Onboard_Status__c);
        
        // after process, a selected account should not have null onboarding status
        Database.executeBatch(
            new BatchUtil(
                'AccountOnboardingStatus',
                'SELECT Id, Onboard_Status__c FROM Account'
            )
        );
        Test.stopTest();
        system.assertNotEquals(null, [SELECT Id, Onboard_Status__c FROM Account][2].Onboard_Status__c);
        
    }
    
    // Testing method for batch without method parameter
    @isTest static void batchProcess2() {
        Test.startTest();
        
        List<Account> Accounts = [SELECT Id, Onboard_Status__c FROM Account];
        //system.assertEquals(0, [SELECT Id FROM Account WHERE Onboard_Status__c = null].size());
        
        String s = null;

        Database.executeBatch(
            new BatchUtil(
                'SELECT Id, Onboard_Status__c FROM Account',
                'Onboard_Status__c',
                s
            )
        );
        Test.stopTest();
        
        //system.assertEquals(3, [SELECT Id FROM Account WHERE Onboard_Status__c = null].size());
        
    }
    
}