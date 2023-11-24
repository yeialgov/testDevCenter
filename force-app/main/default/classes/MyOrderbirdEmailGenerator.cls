global class MyOrderbirdEmailGenerator implements Schedulable{
    global void execute(SchedulableContext SC) {
        List<Account> NeedsMyObEmail = [SELECT Id, MyOrderbirdEmail__c FROM Account WHERE MyOrderbirdEmail__c = null AND Id IN (SELECT Account__c FROM MyObvenue__c WHERE Login__c != null) LIMIT 200];
        Set<Id> AccountIds = new Set<Id>();
        for (Account a : NeedsMyObEmail) { AccountIds.add(a.Id); }
        Map<Id, String> EmailMap = new Map<Id, String>();
        for (MyObVenue__c v : [SELECT Id, Login__c, Account__c FROM MyObVenue__c WHERE Account__c IN :AccountIds AND Login__c != null ORDER BY LastOpenShiftTimestamp__c]) {
            EmailMap.put(v.Account__c, v.Login__c);
        }
        for (Account a : NeedsMyObEmail) { a.MyOrderbirdEmail__c = EmailMap.get(a.Id); }
        update NeedsMyObEmail;
    }
}