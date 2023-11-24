public class AddressBuilderController {
    
    @AuraEnabled
    public Static String getTaskAccountId(String TaskId) {
        Task t = [SELECT Id, Account__c FROM Task WHERE Id = :TaskId LIMIT 1];
        if (t != null) { return t.Account__c; } else { return null; }
    }
    
    @AuraEnabled
    public Static Boolean SyncAddress(String AccountId, String AddressBuilder, String Type) {
        Map<String, String> Prefix = new Map<String, String>{'BILL'=>'Billing', 'SHIP'=>'Shipping', 'VENUE'=>'Venue'};
            Map<String, String> Suffix = new Map<String, String>{'BILL'=>'', 'SHIP'=>'', 'VENUE'=>'__c'};
                List<String> Fields = new List<String>{'Street', 'PostalCode', 'City', 'Country'};
                    Account a = [
                        SELECT Id, AddressSyncType__c, AddressBuilder__c, AddressBuilder_Shipping__c,
                        BillingStreet, BillingPostalCode, BillingCity, BillingCountryCode, BillingCountry,
                        ShippingStreet, ShippingPostalCode, ShippingCity, ShippingCountryCode, ShippingCountry,
                        VenueStreet__c, VenuePostalCode__c, VenueCity__c, VenueCountryCode__c, VenueCountry__c
                        FROM Account
                        WHERE Id = :AccountId
                    ];
        if (Type == 'SHIP') {
            a.AddressBuilder_Shipping__c = AddressBuilder;
        } else if (Type == 'BILL') {
            a.AddressBuilder__c = AddressBuilder;
            if (a.AddressSyncType__c == 'ALL' || a.AddressSyncType__c == 'BILL-SHIP') a.AddressBuilder_Shipping__c = AddressBuilder;
        }
        if (a.AddressSyncType__c != null) {
            Map<String, String> SyncMap = new Map<String, String>();
            if (a.AddressSyncType__c == 'ALL') {
                SyncMap = new Map<String, String>{'VENUE' => 'BILL', 'SHIP' => 'BILL'};
                    } else {
                        SyncMap.put(a.AddressSyncType__c.split('-')[1], a.AddressSyncType__c.split('-')[0]);
                    }
            for (String SyncTo : SyncMap.keySet()) {
                for (String Field : Fields) {
                    a.put(
                        (Prefix.get(SyncTo) + Field + Suffix.get(SyncTo)), 
                        a.get(Prefix.get(SyncMap.get(SyncTo)) + Field + Suffix.get(SyncMap.get(SyncTo)))
                    );
                }
            }
        }
        update a;
        return true;
    }
    
    @AuraEnabled
    public Static void ChangeSyncType(String AccountId, String SyncType, String Winner, String Losers) {
        Map<String, String> Prefix = new Map<String, String>{'BILL'=>'Billing', 'SHIP'=>'Shipping', 'VENUE'=>'Venue'};
            Map<String, String> Suffix = new Map<String, String>{'BILL'=>'', 'SHIP'=>'', 'VENUE'=>'__c'};
                List<String> Fields = new List<String>{'Street', 'PostalCode', 'City', 'Country'};
                    Account a = [
                        SELECT Id, AddressSyncType__c,
                        BillingStreet, BillingPostalCode, BillingCity, BillingCountryCode, BillingCountry,
                        ShippingStreet, ShippingPostalCode, ShippingCity, ShippingCountryCode, ShippingCountry,
                        VenueStreet__c, VenuePostalCode__c, VenueCity__c, VenueCountryCode__c, VenueCountry__c
                        FROM Account
                        WHERE Id = :AccountId
                    ];
        if (Winner != null) {
            for (String Loser : (List<String>)json.deserialize(Losers, List<String>.class)) {
                for (String Field : Fields) {
                    a.put(
                        (Prefix.get(Loser) + Field + Suffix.get(Loser)), 
                        a.get(Prefix.get(Winner) + Field + Suffix.get(Winner))
                    );
                }
            }
        }
        a.AddressSyncType__c = SyncType;
        update a;
    }
}