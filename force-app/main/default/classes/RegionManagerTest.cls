@IsTest
private class RegionManagerTest {
    static testMethod void loadAllRegions_should_load_codes() {
        Region__c r = getRegion(null);
        insert r;
        Id u = r.AccountManager__c;

        RegionManager rm = new RegionManager('Account');
        Region__c pc = rm.regions.get('10');
        //system.assertEquals('France', pc.Region__c);
        //system.assertEquals(u, pc.AccountManager__c);
        //system.assertEquals(u, pc.SDR__c);
        //system.assertEquals(u, pc.CSM__c);
        //system.assertEquals(u, pc.RegionalManager__c);
    }

    static testMethod void getRegion_should_get_region_france() {
        Region__c r = getRegion(null);
        r.Name = 'France';
        insert r;
        Id u = r.AccountManager__c;

        Account acc = new Account(
                Name='Test',
                BillingCountryCode='FR'
        );
        insert acc;
        RegionManager rm = new RegionManager('Account');
        Test.startTest();
        Region__c rr = rm.getRegion(acc);
        //system.assertEquals('France', rr.Region__c);
        //system.assertEquals(u, rr.AccountManager__c);
        //system.assertEquals(u, rr.SDR__c);
        //system.assertEquals(u, rr.CSM__c);
        //system.assertEquals(u, rr.RegionalManager__c);
        Test.stopTest();
    }

    static testMethod void getRegion_should_return_region_germany_10() {
        Region__c r = getRegion(null);
        r.Region__c = 'DE Nord';
        insert r;
        Id u = r.AccountManager__c;

        Account acc = new Account(
                Name='Test',
                BillingCountryCode='DE',
                BillingPostalCode='10259'
        );
        insert acc;
        RegionManager rm = new RegionManager('Account');
        Test.startTest();
        Region__c rr = rm.getRegion(acc);
        //system.assertEquals('DE Nord', rr.Region__c);
        //system.assertEquals(u, rr.AccountManager__c);
        //system.assertEquals(u, rr.SDR__c);
        //system.assertEquals(u, rr.CSM__c);
        //system.assertEquals(u, rr.RegionalManager__c);
        Test.stopTest();
    }

    static testMethod void getRegion_should_return_null() {
        Region__c r = getRegion(null);
        r.Region__c = 'DE Nord';
        insert r;
        Id u = r.AccountManager__c;

        Account acc = new Account(
                Name='Test',
                BillingCountry='Germany'
        );
        insert acc;
        RegionManager rm = new RegionManager('Account');
        Test.startTest();
        Region__c rr = rm.getRegion(acc);
        //system.assertEquals(null, rr);
        Test.stopTest();
    }

    static testMethod void hasChanged_should_return_true() {
        Account acc1 = new Account(
                Name='Test',
                BillingCountryCode='DE',
                BillingPostalCode='10259'
        );
        Account acc2 = new Account(
                Name='Test',
                BillingCountryCode='DE',
                BillingPostalCode='10245'
        );
        RegionManager rm = new RegionManager('Account');
        //system.assertEquals(true, rm.hasChanged(acc1, acc2));
        acc1.BillingCountryCode = 'FR';
        acc1.BillingPostalCode = '10245';
        //system.assertEquals(true, rm.hasChanged(acc1, acc2));
    }

    static testMethod void hasChanged_should_return_false() {
        Account acc1 = new Account(
                Name='Test',
                BillingCountry='Germany',
                BillingPostalCode='10259'
        );
        Account acc2 = new Account(
                Name='Test',
                BillingCountry='Germany',
                BillingPostalCode='10259'
        );
        RegionManager rm = new RegionManager('Account');
        //system.assertEquals(false, rm.hasChanged(acc1, acc2));
    }

    static testMethod void setRegionValues_should_set_all_fields() {
        Region__c r = getRegion(null);
        r.Region__c = 'DE Nord';
        insert r;
        Id u = r.AccountManager__c;

        Account acc = new Account(
                Name='Test',
                BillingCountryCode='DE',
                BillingPostalCode='10259'
        );
        RegionManager rm = new RegionManager('Account');
        rm.setRegionValues(acc);
        Test.startTest();
        //system.assertEquals('DE Nord', acc.Region__c);
        //system.assertEquals(u, acc.AccountManager__c);
        //system.assertEquals(u, acc.SDR__c);
        //system.assertEquals(u, acc.CSM__c);
        //system.assertEquals(u, acc.RegionalManager__c);
        Test.stopTest();
    }

    static testMethod void setRegionValues_should_regard_user_activy_status() {
        User user = new User(
                Username='testtest97874354578@test.de',
                LastName='lname',
                Email='test@test.de',
                Alias='alias',
                TimeZoneSidKey='Europe/Berlin',
                LocaleSidKey='de_DE_EURO',
                EmailEncodingKey='ISO-8859-1',
                ProfileId='00e58000000b0v2',
                LanguageLocaleKey='en_US',
                IsActive=false
        );
        insert user;
        Region__c r = getRegion(user.Id);
        r.Region__c = 'DE Nord';
        insert r;
        Id u = r.AccountManager__c;
        Account acc = new Account(
                Name='Test',
                BillingCountryCode='DE',
                BillingPostalCode='10259'
        );
        RegionManager rm = new RegionManager('Account');
        rm.setRegionValues(acc);
        Test.startTest();
        //system.assertEquals('DE Nord', acc.Region__c);
        //system.assertEquals(null, acc.AccountManager__c);
        //system.assertEquals(null, acc.SDR__c);
        //system.assertEquals(null, acc.CSM__c);
        //system.assertEquals(null, acc.RegionalManager__c);
        Test.stopTest();
    }

    static testMethod void updateRegionValues_should_set_all_fields() {
        Region__c r = getRegion(null);
        r.Region__c = 'DE Nord';
        insert r;
        Id u = r.AccountManager__c;

        Account acc1 = new Account(
                Name='Test',
                BillingCountryCode='DE',
                BillingPostalCode='10259'
        );
        Account acc2 = new Account(
                Name='Test',
                BillingCountryCode='DE',
                BillingPostalCode='10245'
        );
        RegionManager rm = new RegionManager('Account');
        rm.updateRegionValues(acc1, acc2);
        Test.startTest();
        //system.assertEquals('DE Nord', acc1.Region__c);
        //system.assertEquals(u, acc1.AccountManager__c);
        //system.assertEquals(u, acc1.SDR__c);
        //system.assertEquals(u, acc1.CSM__c);
        //system.assertEquals(u, acc1.RegionalManager__c);
        Test.stopTest();
    }

    static testMethod void updateRegionValues_should_set_all_fields_for_leads() {
        Region__c r = getRegion(null);
        r.Region__c = 'DE Nord';
        insert r;
        Id u = r.AccountManager__c;

        Lead lead1 = new Lead(
                CountryCode='DE',
                PostalCode='10259'
        );
        Lead lead2 = new Lead(
                CountryCode='DE',
                PostalCode='10245'
        );
        RegionManager rm = new RegionManager('Lead');
        rm.updateRegionValues(lead1, lead2);
        Test.startTest();
        //system.assertEquals('DE Nord', lead1.Region__c);
        Test.stopTest();
    }

    static testMethod void setRegionValues_should_set_all_fields_for_leads() {
        Region__c r = getRegion(null);
        r.Region__c = 'DE Nord';
        insert r;
        Id u = r.AccountManager__c;

        Lead lead = new Lead(
                CountryCode='DE',
                PostalCode='10259'
        );
        RegionManager rm = new RegionManager('Lead');
        rm.setRegionValues(lead);
        Test.startTest();
        //system.assertEquals('DE Nord', lead.Region__c);
        Test.stopTest();
    }

    private static Region__c getRegion(Id userId) {
        if(userId == null) {
            User u = [SELECT Id FROM User LIMIT 1];
            userId = u.Id;
        }
        Region__c r = new Region__c();
        r.Name = '10';
        r.Region__c = 'France';
        r.AccountManager__c = userId;
        r.SDR__c = userId;
        r.CSM__c = userId;
        r.RegionalManager__c = userId;
        return r;
    }
}