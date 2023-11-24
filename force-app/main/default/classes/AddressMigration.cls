global class AddressMigration implements Database.Batchable<sObject>{
    
    global String Filter;
    
    global AddressMigration() {
        Filter = '';
    }
    
    global AddressMigration(String f) {
        Filter = f;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        String Query = 'SELECT Id, '
            + 'BillingStreet, BillingCity, BillingPostalCode, BillingCountry, '
            + 'ShippingStreet, ShippingCity, ShippingPostalCode, ShippingCountry, '
            + 'VenueStreet__c, VenueCity__c, VenuePostalCode__c, VenueCountry__c, '
            + 'SF_BillTo_Contact__c, SF_SoldTo_Contact__c, SF_Venue_Contact__c, '
            + 'SF_BillTo_Contact__r.MailingStreet, SF_BillTo_Contact__r.MailingCity, SF_BillTo_Contact__r.MailingPostalCode, SF_BillTo_Contact__r.MailingCountry, '
            + 'SF_SoldTo_Contact__r.MailingStreet, SF_SoldTo_Contact__r.MailingCity, SF_SoldTo_Contact__r.MailingPostalCode, SF_SoldTo_Contact__r.MailingCountry, '
            + 'SF_Venue_Contact__r.MailingStreet, SF_Venue_Contact__r.MailingCity, SF_Venue_Contact__r.MailingPostalCode, SF_Venue_Contact__r.MailingCountry, '
            + 'AddressSyncType__c, AddressBuilder__c, AddressBuilder_Shipping__c, AddressBuilderMatch__c, SF_BillTo_Contact__r.FirstName, SF_SoldTo_Contact__r.FirstName, '
            + 'SF_BillTo_Contact__r.Attention__c, SF_BillTo_Contact__r.Addressee__c, SF_SoldTo_Contact__r.Attention__c, SF_SoldTo_Contact__r.Addressee__c '
            + 'FROM Account WHERE Address_Error__c = true';
        Query += Filter;
        return Database.getQueryLocator(Query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        /*Map<String, String> AddressMap = new Map<String, String>{'Billing' => 'SF_BillTo_Contact__r', 'Shipping' => 'SF_SoldTo_Contact__r', 'Venue' => 'SF_Venue_Contact__r'};
        List<String> AddressTypes = new List<String>{'Street', 'City', 'PostalCode', 'Country'};
        Map<String, String> ContactTypes = new Map<String, String>{'SF_BillTo_Contact__r' => 'AddressBuilder__c', 'SF_SoldTo_Contact__r' => 'AddressBuilder_Shipping__c'};
        for (sObject s : scope) {
            for (String addr : AddressMap.keySet()) {
                for (String type : AddressTypes) {
                    String Field = addr + type;
                    if (addr == 'Venue') Field += '__c';
                    if (s.getSObject(AddressMap.get(addr)) != null) {
                        s.put(Field, (String)s.getSObject(AddressMap.get(addr)).get('Mailing' + type));
                    } else {
                        s.put(Field, null);
                    }
                }
            }
            for (String ct : ContactTypes.keySet()) {
                String AddressBuilder = (String)s.get(ContactTypes.get(ct));
                if (s.getSObject(ct) != null) {
                    if (AddressBuilder == null && (String)s.getSObject(ct).get('FirstName') == '[not provided]') AddressBuilder = '["'+ct+'.Addressee__c","'+ct+'.Attention__c","empty"]';
                    if (AddressBuilder != null && ((String)s.getSObject(ct).get('Attention__c')) != null) AddressBuilder = AddressBuilder.replace((ct+'.Attention__c'), ((String)s.getSObject(ct).get('Attention__c')));
                    if (AddressBuilder != null && ((String)s.getSObject(ct).get('Addressee__c')) != null) AddressBuilder = AddressBuilder.replace((ct+'.Addressee__c'), ((String)s.getSObject(ct).get('Addressee__c')));
                }
                s.put(ContactTypes.get(ct), AddressBuilder);
            }
            Boolean MatchBS = (String)s.get('SF_BillTo_Contact__c') == (String)s.get('SF_SoldTo_Contact__c') && (Boolean)s.get('AddressBuilderMatch__c');
            Boolean MatchBV = (String)s.get('SF_BillTo_Contact__c') == (String)s.get('SF_Venue_Contact__c') || (String)s.get('SF_Venue_Contact__c') == null;
            Boolean MatchSV = (String)s.get('SF_SoldTo_Contact__c') == (String)s.get('SF_Venue_Contact__c') || (String)s.get('SF_Venue_Contact__c') == null;
            if (MatchBS) s.put('AddressSyncType__c', 'BILL-SHIP');
            if (MatchSV) s.put('AddressSyncType__c', 'SHIP-VENUE');
            if (MatchBV) s.put('AddressSyncType__c', 'BILL-VENUE');
            if (MatchBS && MatchBV) s.put('AddressSyncType__c', 'ALL');
        }*/
        for (sObject s : scope) {
            s.put('VenueStreet__c', (String)s.get('BillingStreet'));
            s.put('VenueCity__c', (String)s.get('BillingCity'));
            s.put('VenuePostalCode__c', (String)s.get('BillingPostalCode'));
            s.put('VenueCountry__c', (String)s.get('BillingCountry'));
        }
        update scope;
    }
    
    global void finish(Database.BatchableContext BC){}
    
}