@isTest public class BatchUtilTest {

    @testSetup
    public static void setupTestData() {
        List<Account> TestAccounts = new List<Account>();
        List<Lead> TestLeads = new List<Lead>();
        for (Integer x=0; x<3; x++) {
            TestAccounts.add(new Account(Name = 'TestAccount_' + x));
            TestLeads.add(new Lead(LastName='test_' + x, Company='test'));
        }
        insert TestAccounts;
        insert TestLeads;
    }
    


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
    
    // Testing method for batch without method parameter
    @isTest static void batchProcess2a() {
        Test.startTest();
        
        List<Account> Accounts = [SELECT Id, Onboard_Status__c FROM Account];
        //system.assertEquals(0, [SELECT Id FROM Account WHERE Onboard_Status__c = null].size());
        
        Database.executeBatch(
            new BatchUtil(
                'SELECT Id, taxexempted__c FROM Account',
                'taxexempted__c',
                true
            )
        );
        Test.stopTest();
        
        
    }
    
    @isTest static void testLeadTimeCalculator() {
        Database.executeBatch(
            new BatchUtil(
                'LeadTimeCalculator',
                'SELECT Id, First_Activity_Date_Time__c, First_Successful_Activity_Date_Time__c, '
                +'Lead_Created_Date_Time__c, Response_Time__c, Reaction_Time__c FROM Opportunity'
            )
        );
    }

}