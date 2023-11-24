public class CockpitController {
    
    @AuraEnabled
    public static List<AutomatedSurvey__c> getNPS(String AccountId) {
        Set<String> EmailSet = new Set<String>();
        for (Contact c : [SELECT Id, Email FROM Contact WHERE AccountId = :AccountId AND Email != null]) {
            if (!c.Email.containsIgnoreCase('orderbird')) EmailSet.add(c.Email);
        }
        system.debug(json.serialize(EmailSet));
        return [
            SELECT Id, Contact__c, NPS__c, Contact__r.Email
            FROM AutomatedSurvey__c 
            WHERE NPS__c != null 
              AND DateResponded__c >= LAST_n_MONTHS:6
              AND Contact__r.Email IN :EmailSet
            ORDER BY DateResponded__c DESC
            LIMIT 3
        ];
    }
    
    @AuraEnabled
    public static List<AggregateResult> getActiveDevices(String AccountId) {
        Set<String> ProdSubSet = new Set<String>();
        List<AggregateResult> ActiveDevices = new List<AggregateResult>();
        List<AggregateResult> ARs = [
            SELECT SUM(Quantity__c) Qty, Product__r.Name Prod, Product__c ProdId, Subscription__r.Name SubName, Subscription__c
            FROM SubscriptionLineItem__c 
            WHERE 
                Subscription__r.Account__c = :AccountId 
                AND (
                    Status_Active_Device__c > 0 
                    OR Status_Active_Service__c > 0
                )
                AND Product__r.Model__c != 'DiscountFixedAmount' 
                AND Product__r.Model__c != 'DiscountPercentage' 
            GROUP BY Product__r.Name, Product__c, Subscription__r.Name, Subscription__c
            ORDER BY SUM(Quantity__c) DESC, Product__r.Name
        ];
        for (AggregateResult AR : ARs) {
            if (!ProdSubSet.contains((String)AR.get('ProdId')+(String)AR.get('SubName'))) {
                ProdSubSet.add((String)AR.get('ProdId')+(String)AR.get('SubName'));
                ActiveDevices.add(AR);
            }
        }
        return ActiveDevices;
    }
    
    @AuraEnabled
    public static Decimal getMRR(String AccountId) {
        AggregateResult[] ARs = [
            SELECT MAX(CalcMRR__c) MRR, Name
            FROM SubscriptionLineItem__c 
            WHERE 
                Subscription__r.Account__c = :AccountId 
                AND (
                    Status_Active_Device__c > 0 
                    OR Status_Active_Service__c > 0 
                    OR Status_Future_Customer__c > 0
                )
            GROUP BY Name
        ];
        Decimal MRR = 0.0;
        for (AggregateResult AR : ARs) {
            MRR += (Decimal)AR.get('MRR');
        }
        return MRR;
    }
    
}