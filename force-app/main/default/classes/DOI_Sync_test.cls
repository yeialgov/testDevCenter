@isTest public class DOI_Sync_test {

    Static TestMethod void test1() {
        DOI_Sync_scheduler p = new DOI_Sync_scheduler();
        String sch = '0 12 00 * * ?';
        system.schedule('DOI_Sync', sch, p);
    }
    
    Static TestMethod void test2() {
        insert new Contact(Lastname = 'test', Firstname = 'test', Email = 'test@test.com');
        insert new Lead(Company = 'test', Lastname = 'test', Firstname = 'test', Email = 'test@test.com', DoubleOptIn__c = 'Verbal Ok', CountryCode = 'DE', Phone = '+4915134567890', LAC_Shorthand__c = 'Hotline');
        System.enqueueJob(new DOI_Sync());
    }
}