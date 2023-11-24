global class BatchSLILinkage implements Database.Batchable<sObject>{
    
    global final String Query;
    global final Boolean IsPreceding;
    
    global BatchSLILinkage(Boolean Type){
        IsPreceding = Type;
        if (IsPreceding) {
            Query = 'SELECT Id, Name, Subscription__r.Version__c, PrecedingSLI__c, SupercedingSLI__c '
            + 'FROM SubscriptionLineItem__c WHERE PrecedingSLI__c = NULL AND Subscription__r.Version__c > 1';
        } else {
            Query = 'SELECT Id, PrecedingSLI__c '
            + 'FROM SubscriptionLineItem__c WHERE PrecedingSLI__r.SupercedingSLI__c = NULL AND PrecedingSLI__c != NULL';
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
                    (String)s.get('Name') + ':' + String.valueOf(((Decimal)(s.getSObject('Subscription__r').get('Version__c')) - 1.0).setScale(0))
                );
            }
            for (SubscriptionLineItem__c sub : [
                SELECT Id, Version_Key__c 
                FROM SubscriptionLineItem__c 
                WHERE Version_Key__c IN :VersionKeys.values()
            ]) {
                RelationMap.put(sub.Version_Key__c, sub.Id);
            }
            for (SObject s : scope) {
                String PrecedentId = RelationMap.get(VersionKeys.get((String)s.get('Id')));
                if (PrecedentId != null) s.put('PrecedingSLI__c', PrecedentId);
            }
            update scope;
        } else {
            Set<String> VersionKeys = new Set<String>();
            for (SObject s : scope) {
                RelationMap.put(
                    (String)s.get('PrecedingSLI__c'),
                    (String)s.get('Id')
                );
            }
            List<SubscriptionLineItem__c> SLIs = [
                SELECT Id, SupercedingSLI__c 
                FROM SubscriptionLineItem__c
                WHERE Id IN :RelationMap.keySet()
            ];
            for (SubscriptionLineItem__c SLI : SLIs) {
                SLI.SupercedingSLI__c = RelationMap.get(SLI.Id);
            }
            update SLIs;
        }
    }
    
    global void finish(Database.BatchableContext BC){}
    
}