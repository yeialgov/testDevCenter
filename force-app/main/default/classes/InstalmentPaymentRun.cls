global class InstalmentPaymentRun implements Database.Batchable<sObject>, Database.AllowsCallouts{
    
    global String Query;
    
    global InstalmentPaymentRun() {
        Query  = 'SELECT Id, Age__c, Balance__c, Amount__c, ZuoraId__c, Account__r.ZuoraId__c, Account__r.DefaultPaymentMethod__r.ZuoraId__c, ';
        Query += '  (SELECT Id FROM Invoice_Line_Items__r WHERE SubscriptionLineItem__r.Product__r.Name LIKE \'%Instalment%\') ';
        Query += 'FROM Invoice__c ';
        Query += 'WHERE Balance__c > 0 AND Status__c = \'Posted\' ';
        Query += '  AND Account__r.Batch__c = \'Batch4\' ';
        Query += '  AND Account__r.DefaultPaymentMethod__r.BankTransferType__c = \'SEPA\' ';
        Query += '  AND Account__r.DefaultPaymentMethod__r.PaymentMethodStatus__c = \'Active\' ';
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(Query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        List<ZObj.CreatePayment> CreatePayments = new List<ZObj.CreatePayment>();
        for (sObject s : scope) {
            if ((s.getSObjects('Invoice_Line_Items__r')) == null) {
                // Non-instalment Payment
                CreatePayments.add(new ZObj.CreatePayment(
                    (String)s.getSObject('Account__r').get('ZuoraId__c'),
                    (String)s.get('ZuoraId__c'),
                    (String)s.getSObject('Account__r').getSObject('DefaultPaymentMethod__r').get('ZuoraId__c'),
                    (Decimal)s.get('Balance__c')
                ));              
            } else if ((Decimal)s.get('Age__c') > 29 && (Decimal)s.get('Age__c') < 54 && (Decimal)s.get('Balance__c') > 5 + ((Decimal)s.get('Amount__c') / 3)) {
                // Instalment Payment
                CreatePayments.add(new ZObj.CreatePayment(
                    (String)s.getSObject('Account__r').get('ZuoraId__c'),
                    (String)s.get('ZuoraId__c'),
                    (String)s.getSObject('Account__r').getSObject('DefaultPaymentMethod__r').get('ZuoraId__c'),
                    ((Decimal)s.get('Balance__c') - ((Decimal)s.get('Amount__c') / 3)).setScale(2)
                ));
            }
        }
        ZuoraSyncController.InstalmentPaymentRun(CreatePayments);
    }
    
    global void finish(Database.BatchableContext BC){
    }
    
}