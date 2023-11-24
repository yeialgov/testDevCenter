trigger SubscriptionTrigger on Subscription__c (after update) {
    List<SubscriptionLineItem__c> UpdateSLIs = new List<SubscriptionLineItem__c>();
    List<SubscriptionLineItem__c> SLIs = [
        SELECT Id, Account__c, Subscription__c, Product__c
        FROM SubscriptionLineItem__c
        WHERE Subscription__c IN :Trigger.newMap.keySet()
    ];
    Set<Id> ExcludeProdIds = new Map<Id, Product2>([SELECT Id FROM Product2 Where name='VAT 16%' OR name='VAT 19%']).keySet();

    for (SubscriptionLineItem__c SLI : SLIs) {
        Id AcctId = null;
        if (Trigger.newMap.get(SLI.Subscription__c).Status__c == 'Active') {
            AcctId = Trigger.newMap.get(SLI.Subscription__c).Account__c;
        }
        if (SLI.Account__c != AcctId) {
        	if (ExcludeProdIds.contains(SLI.Product__c)){
        	SLI.Account__c = null;
            }else{
            SLI.Account__c = AcctId;
            }
            UpdateSLIs.add(SLI);
        }
            
    }
    update UpdateSLIs;
    
}