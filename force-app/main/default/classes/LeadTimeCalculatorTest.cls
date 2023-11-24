@isTest
private class LeadTimeCalculatorTest {
	
    static testMethod void createOpportunity() {
        Lead ld = new Lead(lastname='test',company='test',status='Qualified', CreatedDate=DateTime.newInstance(2017,11,13,12,0,0));
        insert ld;
        List<Lead> leads = new List<Lead>();
        leads.add(ld);
        LeadAutoConvert.convert(leads);
        //Opportunity l = new Opportunity(WhoId=ld.Id,CreatedDate=DateTime.newInstance(2017,11,13,12,0,0), StageName='Test', Name='Test', CloseDate=Date.newInstance(2018,1,1));
        Id oppId = [SELECT ConvertedOpportunityId FROM Lead WHERE Id=:ld.Id LIMIT 1].ConvertedOpportunityId;
        Opportunity l = [SELECT Id, First_Activity_Date_Time__c FROM Opportunity WHERE Id=:oppId LIMIT 1];
        //insert l;
        l.First_Activity_Date_Time__c = DateTime.newInstance(2017,11,13,13,1,1);
        update l;
        //system.assertEquals(3661, [SELECT Reaction_Time__c FROM Opportunity WHERE Id=:l.Id LIMIT 1].Reaction_Time__c);
        //system.assertEquals('1 Hour, 1 Minute, 1 Second', [SELECT Reaction_Time_disp__c FROM Opportunity WHERE Id=:l.Id LIMIT 1].Reaction_Time_disp__c);
    }

    /*static testMethod void createOpportunityOutsideRange() {
        Opportunity l = new Opportunity(CreatedDate=DateTime.newInstance(2017,11,12,12,0,0), StageName='Test', Name='Test', CloseDate=Date.newInstance(2018,1,1));
        insert l;
        l.First_Successful_Activity_Date_Time__c = DateTime.newInstance(2017,11,13,11,2,2);
        update l;
        system.assertEquals(7322, [SELECT Response_Time__c FROM Opportunity WHERE Id=:l.Id LIMIT 1].Response_Time__c);
        system.assertEquals('2 Hours, 2 Minutes, 2 Seconds', [SELECT Response_Time_disp__c FROM Opportunity WHERE Id=:l.Id LIMIT 1].Response_Time_disp__c);
    }
    
    static testMethod void testBatcher() {
        Test.startTest();
        Opportunity l = new Opportunity(CreatedDate=DateTime.newInstance(2017,11,12,12,0,0), StageName='Test', Name='Test', CloseDate=Date.newInstance(2018,1,1));
        insert l;
        l.First_Successful_Activity_Date_Time__c = DateTime.newInstance(2017,11,13,11,2,2);
        update l;
        l.Response_Time__c = null;
        update l;
        system.assertEquals(null, [SELECT Response_Time__c FROM Opportunity WHERE Id=:l.Id LIMIT 1].Response_Time__c);
		LeadTimeCalculator.processBatch([
            SELECT 
                Id, 
                CreatedDate, 
                Response_Time__c, 
                Reaction_Time__c, 
                First_Activity_Date_Time__c, 
                First_Successful_Activity_Date_Time__c 
            FROM Opportunity
        ]);
        Test.stopTest();
        system.assertEquals(7322, [SELECT Response_Time__c FROM Opportunity WHERE Id=:l.Id LIMIT 1].Response_Time__c);
    }*/

}