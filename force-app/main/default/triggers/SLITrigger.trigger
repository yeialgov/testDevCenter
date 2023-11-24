trigger SLITrigger on SubscriptionLineItem__c (before insert) {
    Set<Id> SubIds = new Set<Id>();
    Set<Id> ExcludeProdIds = new Map<Id, Product2>([SELECT Id FROM Product2 Where name='VAT 16%' OR name='VAT 19%']).keySet();
    for (SubscriptionLineItem__c SLI : Trigger.New) {
        SubIds.add(SLI.Subscription__c);
    }
    Map<Id, Subscription__c> SubMap = new Map<Id, Subscription__c>([
        SELECT Id, Status__c, Account__c FROM Subscription__c WHERE Id IN :SubIds
    ]);
    for (SubscriptionLineItem__c SLI : Trigger.New) {
        Subscription__c Sub = SubMap.get(SLI.Subscription__c);
        if (Sub.Status__c == 'Active') {
            SLI.Account__c = Sub.Account__c;
        } else {
            SLI.Account__c = null;
        } 
        if (ExcludeProdIds.contains(SLI.Product__c)){
            SLI.Account__c = null;
        }    
    }
}