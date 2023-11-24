/*************************************************************************
* Author:           Richard Abendroth
* Author-Email:     development@incubes.com
* Author-Website:   www.incubes.com
*
* Name:             TriggerUtilTests
* Type:             Test class
*
* Description:      - Test class for the TriggerUtil Class. 
*                   - Will test the following classes
*                       - TriggerUtil
*************************************************************************/
@isTest
public class TriggerUtilTests {
    
    @isTest
    public static void TestIsChangedException(){
        Account acc = TestUtil.GetAccount();
        insert acc;
        
        System.assertEquals(true, TriggerUtil.isChanged(acc.Id, 'Id'));
        System.assertEquals(false, TriggerUtil.isChanged(null, 'Id'));
        System.assertEquals(false, TriggerUtil.isChanged(acc.Id, null)); 
    }

    @isTest
    public static void executeTrigger_should_return_true() {
        TriggerSupport__c ts = new TriggerSupport__c();
        ts.name = 'Account';
        ts.Active__c = true;
        insert ts;
        System.assertEquals(true, TriggerUtil.executeTrigger('Account'));
    }

    @isTest
    public static void executeTrigger_should_return_false() {
        TriggerSupport__c ts = new TriggerSupport__c();
        ts.name = 'Account';
        ts.Active__c = false;
        insert ts;
        System.assertEquals(false, TriggerUtil.executeTrigger('Account'));
    }

    @isTest
    public static void executeTrigger_should_return_true_if_setting_not_exists() {
        System.assertEquals(true, TriggerUtil.executeTrigger('Account'));
    }
}