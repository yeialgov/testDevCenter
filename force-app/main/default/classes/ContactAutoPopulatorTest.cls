@isTest
public class ContactAutoPopulatorTest {

    static testMethod void insertLeads() {
        
        Lead l = new Lead(LastName = 'test', Company = 'test');
        insert l;
        
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(l.Id);
        lc.setConvertedStatus('Qualified');
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        
        system.assert(lcr.isSuccess());
        
        Lead updL = [SELECT ConvertedAccountId, ConvertedContactId FROM Lead WHERE Id=:l.Id LIMIT 1];

        system.assertEquals(
            [SELECT Primary_Contact__c FROM Account WHERE Id=:updL.ConvertedAccountId LIMIT 1].Primary_Contact__c,
            updL.ConvertedContactId
        );

        system.assertEquals(
            [SELECT SF_SoldTo_Contact__c FROM Account WHERE Id=:updL.ConvertedAccountId LIMIT 1].SF_SoldTo_Contact__c,
            updL.ConvertedContactId
        );

        system.assertEquals(
            [SELECT SF_BillTo_Contact__c FROM Account WHERE Id=:updL.ConvertedAccountId LIMIT 1].SF_BillTo_Contact__c,
            updL.ConvertedContactId
        );
        
        Lead l2 = new Lead(LastName = 'test2', Company = 'test');
        insert l2;
        
        Database.LeadConvert lc2 = new Database.LeadConvert();
        lc2.setLeadId(l2.Id);
        lc2.setAccountId(updL.ConvertedAccountId);
        lc2.setConvertedStatus('Additional Contact');
        Database.LeadConvertResult lcr2 = Database.convertLead(lc2);
        
        system.assert(lcr2.isSuccess());

        Lead updL2 = [SELECT ConvertedAccountId, ConvertedContactId FROM Lead WHERE Id=:l2.Id LIMIT 1];

        system.assertEquals(
            [SELECT Primary_Contact__c FROM Account WHERE Id=:updL.ConvertedAccountId LIMIT 1].Primary_Contact__c,
            updL.ConvertedContactId
        );

        system.assertNotEquals(
            [SELECT Primary_Contact__c FROM Account WHERE Id=:updL2.ConvertedAccountId LIMIT 1].Primary_Contact__c,
            updL2.ConvertedContactId
        );

    }
}