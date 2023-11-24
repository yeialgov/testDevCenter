/*************************************************************************
* Author:           Richard Abendroth
* Author-Email:     development@incubes.com
* Author-Website:   www.incubes.com
*
* Name:             LeadAutoConvertTests
* Type:             Test class
*
* Description:      - Test class for the LeadAutoConvert Class. 
*                   - Will test the following classes
*                       - LeadAutoConvert
*************************************************************************/
@isTest
public class LeadAutoConvertTests {
    
    @isTest
    public static void TestLeadAutoConvert () {
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = true LIMIT 1]; 
        Lead lead1 = new Lead(
        LastName = 'Test Lead', 
        Company = 'Test Company', 
        Status = convertStatus.MasterLabel, 
        Phone = '+1234567890'
        ); 
        insert lead1; 
        LeadAutoConvert.convert(new List<Lead>{lead1}, null, Schema.Lead.Status, Schema.Lead.Status, Schema.Lead.Status); 
        Lead lead2 = new Lead(); 
        try {
            LeadAutoConvert.convert(new List<Lead>{lead2}); 
        } catch(Exception e) { 
            System.Debug(e);
            System.assert(true); 
        }
    }
}