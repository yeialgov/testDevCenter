@isTest
public class LeadConvertTrigger_Test {
    
    static TestMethod void convertLead() {
        Lead l = new Lead(company='test',lastname='test');
        insert l;
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(l.Id);
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);
        Database.LeadConvertResult lcr = Database.convertLead(lc);
    }

}