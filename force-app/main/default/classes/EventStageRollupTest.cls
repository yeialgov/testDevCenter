@isTest
 public class EventStageRollupTest {

    static testMethod void testFunction() {
    	
    	 /* POSITIVE TESTING */

        Account a = new Account(Name = 'LULACCOUNT');
        insert a;
        Opportunity o = new Opportunity (Name = 'LULOPP' , StageName = 'Potential' , CloseDate = System.Today(), AccountId = a.Id);
        insert o;
        Event e = new Event (WhatId = o.Id,Subject = 'CRAZY', Opportunity_Stage__c = 'Introduction / Demo' , Activity_Type__c = 'Demo', DurationInMinutes = 30 , ActivityDateTime = System.Now());
        insert e;
        
        System.assertEquals('Introduction / Demo', [SELECT StageName FROM Opportunity WHERE Id=: o.Id].StageName);
        
        /* FALSE POSITIVE TESTING */
        
        Account a2 = new Account(Name = 'LULACCOUNT');
        insert a2;
        Opportunity o2 = new Opportunity (Name = 'LULOPP' , StageName = 'Potential' , CloseDate = System.Today(), AccountId = a2.Id);
        insert o2;
        Event e2 = new Event (WhatId = o2.Id,Subject = 'CRAZY', Opportunity_Stage__c = 'Introduction / Demo' , Activity_Type__c = 'Call' , DurationInMinutes = 30 , ActivityDateTime = System.Now());
        insert e2;
        
        System.assertEquals('Potential', [SELECT StageName FROM Opportunity WHERE Id=: o2.Id].StageName);
        
        e2.Activity_Type__c = 'Demo';
        e2.Opportunity_Stage__c = 'Introduction / Demo';
        
        update e2;
        
        System.assertEquals('Introduction / Demo', [SELECT StageName FROM Opportunity WHERE Id=: o.Id].StageName);

    } 
}