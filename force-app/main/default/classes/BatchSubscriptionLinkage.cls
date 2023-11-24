global class BatchSubscriptionLinkage implements Database.Batchable<sObject>{
    
    global final String Query;
    global final Boolean IsPreceding;
    
    global BatchSubscriptionLinkage(Boolean Type){
        IsPreceding = Type;
        if (IsPreceding) {
            Query = 'SELECT Id, Name, Version__c, PrecedingSubscription__c, SupercedingSubscription__c '
            + 'FROM Subscription__c WHERE PrecedingSubscription__c = NULL AND Version__c > 1';
        } else {
            Query = 'SELECT Id, PrecedingSubscription__c '
            + 'FROM Subscription__c WHERE PrecedingSubscription__r.SupercedingSubscription__c = NULL AND PrecedingSubscription__c != NULL';
        }
    }
    
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(Query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        Map<String, String> RelationMap = new Map<String, String>();
        if (IsPreceding) {
            Map<String, String> VersionKeys = new Map<String, String>();
            for (SObject s : scope) {
                VersionKeys.put(
                    (String)s.get('Id'),
                    (String)s.get('Name') + ':' + String.valueOf(((Decimal)s.get('Version__c') - 1.0).setScale(0))
                );
            }
            system.debug(json.serialize(VersionKeys));
            for (Subscription__c sub : [
                SELECT Id, Version_Key__c 
                FROM Subscription__c 
                WHERE Version_Key__c IN :VersionKeys.values()
            ]) {
                RelationMap.put(sub.Version_Key__c, sub.Id);
            }
            for (SObject s : scope) {
                String PrecedentId = RelationMap.get(VersionKeys.get((String)s.get('Id')));
                if (PrecedentId != null) s.put('PrecedingSubscription__c', PrecedentId);
            }
            update scope;
        } else {
            Set<String> VersionKeys = new Set<String>();
            for (SObject s : scope) {
                RelationMap.put(
                    (String)s.get('PrecedingSubscription__c'),
                    (String)s.get('Id')
                );
            }
            List<Subscription__c> Subscriptions = [
                SELECT Id, SupercedingSubscription__c 
                FROM Subscription__c
                WHERE Id IN :RelationMap.keySet()
            ];
            for (Subscription__c Subscription : Subscriptions) {
                Subscription.SupercedingSubscription__c = RelationMap.get(Subscription.Id);
            }
            update Subscriptions;
        }
    }
    
    global void finish(Database.BatchableContext BC){}
    
}