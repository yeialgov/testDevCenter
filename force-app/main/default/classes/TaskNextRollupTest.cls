@isTest
 public class TaskNextRollupTest {

    static testMethod void testFunction() {

        Datetime now = System.Now()+2;
        
        Account a = new Account(Name = 'LULACCOUNT');
        insert a;
        Opportunity o = new Opportunity (Name = 'LULOPP' , StageName = 'Potential' , CloseDate = System.Today(), AccountId = a.Id);
        insert o;
        Task t = new Task (WhatId = o.Id,Subject = 'CRAZY' ,   Next_Step__c = 'OMFG' , Next_Step_Date__c = now , Opportunity_Stage__c = o.StageName , Next_Step_relevant__c = TRUE , Status = 'Completed' , Notes_and_Comments__c = 'Bananaboy');
        insert t;

        System.assertEquals('OMFG', [SELECT Next_Step_PL__c FROM Opportunity WHERE Id=: o.Id].Next_Step_PL__c);
        System.assertEquals(now, [SELECT NextStepDate__c FROM Opportunity WHERE Id=: o.Id].NextStepDate__c);
        System.assertEquals('Bananaboy', [SELECT Next_Step_Comments__c FROM Opportunity WHERE Id=: o.Id].Next_Step_Comments__c);

        
        t.Next_Step__c = 'WTFMAN';
        update t;
        System.assertEquals('WTFMAN', [SELECT Next_Step_PL__c FROM Opportunity WHERE Id=: o.Id].Next_Step_PL__c);

        t.Opportunity_Stage__c = 'Qualification';
        update t;
        System.assertEquals('Qualification', [SELECT StageName FROM Opportunity WHERE Id=: o.Id].StageName);

        t.Opportunity_Stage__c = null;
        update t;
        System.assertEquals('Qualification', [SELECT StageName FROM Opportunity WHERE Id=: o.Id].StageName);

        t.Next_Step__c = null;
        try {
            update t; 
       } catch(Exception e) {
           System.Assert(e.getMessage().contains('Please specify the next step!'));
       }

        t.Next_Step__c = 'Cool Shit';
        t.Next_Step_Date__c = null;
        try {
            update t; 
        } catch (Exception e) {
            System.Assert(e.getMessage().contains('Please specify the next step date!'));
        }
    } 
}