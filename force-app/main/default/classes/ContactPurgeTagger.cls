global class ContactPurgeTagger implements Database.Batchable<sObject>{
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        String Query = 'SELECT Id, Privacy_Contact__c FROM Account '
            + 'WHERE Account_Status__c NOT IN (\'Partner\') '
            + 'AND Id NOT IN (SELECT AccountId FROM Opportunity WHERE CreatedDate = LAST_n_DAYS:365 OR LastActivityDate = LAST_n_DAYS:365 OR Open_Tasks__c > 0) '
            + 'AND Id NOT IN (SELECT Account__c FROM Subscription__c WHERE (SubscriptionEndDate__c = null AND Status__c != \'Expired\') OR SubscriptionEndDate__c > LAST_n_DAYS:365) '
            + 'AND CreatedDate < LAST_n_DAYS:365 AND Privacy_Contact__c = null ';
        return Database.getQueryLocator(Query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        List<Contact> insContacts = new List<Contact>();
        Map<Id, Id> contactMap = new Map<Id, Id>();
        for (sObject s : scope) {
            insContacts.add( new Contact(
                AccountId = (String)s.get('Id'), InactiveEmployee__c = true, LastName = 'Deleted Contact'
            ) );
        }
        insert insContacts;
        for (Contact cnct : insContacts) {
            contactMap.put(cnct.AccountId, cnct.Id);
        }
        for (sObject s : scope) {
            s.put('Privacy_Contact__c', contactMap.get((String)s.get('Id')));
        }
        update scope;
        List<Contact> mergeContacts = [
            SELECT Id, AccountId, Merge_Into__c FROM Contact WHERE AccountId IN :contactMap.keySet()
        ];
        for (Contact cnct : mergeContacts) {
            Id mInto = contactMap.get(cnct.AccountId);
            if (mInto != cnct.Id) cnct.Merge_Into__c = mInto;
        }
        update mergeContacts;
    }
    
    global void finish(Database.BatchableContext BC){}
    
}