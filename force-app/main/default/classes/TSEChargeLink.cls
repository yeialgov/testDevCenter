global class TSEChargeLink implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        
        Map<String, Set<String>> AcctMap = new Map<String, Set<String>>();
        Set<String> ExcludeChargeNames = new Set<String>();
        
        List<MyObVenue__c> unlinkedVenues = [
            SELECT Id, Account__c, TSE_Charges__c
            FROM MyObVenue__c 
            WHERE TSE_Charges__c = 'NEED' 
        ];
        
        for (MyObVenue__c unlinkedVenue : unlinkedVenues) { AcctMap.put(unlinkedVenue.Account__c, new Set<String>()); }

        List<MyObVenue__c> linkedVenues = [
            SELECT Id, Account__c, TSE_Charges__c
            FROM MyObVenue__c 
            WHERE TSE_Charges__c != 'NEED' AND TSE_Charges__c != 'ERROR' 
            AND TSE_Charges__c != 'SKIP' AND TSE_Charges__c != null
            AND Account__c IN :AcctMap.keySet()
        ];

        for (MyObVenue__c linkedVenue : linkedVenues) { ExcludeChargeNames.addAll(linkedVenue.TSE_Charges__c.split(',')); }
        
        List<SubscriptionLineItem__c> charges = [
            SELECT Id, Name, Subscription__r.Account__c
            FROM SubscriptionLineItem__c
            WHERE Name NOT IN :ExcludeChargeNames 
                AND Subscription__r.Account__c IN :AcctMap.keySet()
                AND Product__r.Name LIKE '%tse%' 
                AND (NOT Product__r.Name LIKE '%discount%') 
        ];
        
        for (SubscriptionLineItem__c charge : charges) { AcctMap.get(charge.Subscription__r.Account__c).add(charge.Name); }
        
        for (MyObVenue__c unlinkedVenue : unlinkedVenues) {
            if (AcctMap.get(unlinkedVenue.Account__c).size()>0) unlinkedVenue.TSE_Charges__c = AcctMap.get(unlinkedVenue.Account__c).toString().replace('{','').replace('}','');
        }
        
        update unlinkedVenues;
    }

}