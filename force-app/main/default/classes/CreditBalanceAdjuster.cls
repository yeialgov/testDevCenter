global class CreditBalanceAdjuster implements Database.Batchable<sObject>, Database.AllowsCallouts{
    
    global String Query;
    
    global CreditBalanceAdjuster() {
        Id SysAdminId = [SELECT Id FROM Profile where Name = 'System Administrator' LIMIT 1].Id;
        DebtCollection__c dc = DebtCollection__c.getInstance(SysAdminId);
        Query = 'SELECT Id, Name, Credit_Balance__c,';
        Query += ' (SELECT Id, Amount__c, SourceTransactionType__c, Type__c, Invoice__c FROM Credit_Balance_Adjustments__r ORDER BY Name DESC)';
        Query += ' FROM Account WHERE Name != \'Hofmann Leasing\' AND Name != \'Leascorp\' AND Credit_Balance__c > 0 AND Id IN (SELECT Account__c FROM Invoice__c WHERE Balance__c > 0 AND InvoiceDate__c <= TODAY)';
        if (!Test.isRunningTest()) Query += ' LIMIT ' + dc.CBBatchLimit__c;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(Query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
		Map<Id, Decimal> AmtMap = new Map<Id, Decimal>();
		Map<Id, Decimal> AdjMap = new Map<Id, Decimal>();
        for (sObject s : scope) {
            Account acct = (Account)s;
            Decimal CreditBalance = acct.Credit_Balance__c;
            List<CreditBalanceAdjustment__c> CBAs = (List<CreditBalanceAdjustment__c>)s.getSObjects('Credit_Balance_Adjustments__r');
            
            // iterate through Credit Balance Adjustments
            // these are ordered chronologically descending from the query
            // map credit balance amounts to the invoice that caused it by increase adjustment, if not caused by invoice then map amount to the account
            Integer x = 0;
            do {
                CreditBalanceAdjustment__c CBA = CBAs[x];
                Decimal AdjAmt = Math.min(CBA.Amount__c, CreditBalance);
                //if (CBA.Type__c == 'Increase' && CBA.SourceTransactionType__c == 'Invoice') AmtMap.put(CBA.Invoice__c, Math.min(CBA.Amount__c, CreditBalance));
                if (CBA.Type__c == 'Increase') {
                    Id MapId = acct.Id;
                    if (CBA.SourceTransactionType__c == 'Invoice') MapId = CBA.Invoice__c;
                    AmtMap.put(MapId, AmtMap.get(MapId) == null ? AdjAmt : AmtMap.get(MapId) + AdjAmt);
                    CreditBalance -= CBA.Amount__c;
                }
                x++;
            } while(CreditBalance > 0 && x < CBAs.size());
            
            // map amounts unattributed to invoices to the account 
            if (CreditBalance > 0) AmtMap.put(acct.Id, AmtMap.get(acct.Id) == null ? CreditBalance : AmtMap.get(acct.Id) + CreditBalance);
        }
        
        // map subscription to invoice it caused
        Map<Id, Id> InvSubMap = new Map<Id, Id>();
        for (AggregateResult ar : [SELECT SubscriptionLineItem__r.Subscription__c subId, Invoice__c invId FROM InvoiceLineItem__c WHERE Invoice__c IN :AmtMap.keySet() GROUP BY SubscriptionLineItem__r.Subscription__c, Invoice__c]) {
            InvSubMap.put((Id)ar.get('subId'), (Id)ar.get('invId'));
        }
        
        // iterate through invoices that include line items from those subscriptions
        for (AggregateResult ar : [
            SELECT Invoice__c invId, MAX(Invoice__r.Balance__c) bal, Invoice__r.Name, SubscriptionLineItem__r.Subscription__c subId 
            FROM InvoiceLineItem__c 
            WHERE Invoice__r.Status__c = 'Posted' AND Invoice__r.InvoiceDate__c <= TODAY AND SubscriptionLineItem__r.Subscription__c IN :InvSubMap.keySet() AND Invoice__r.Balance__c > 0
            GROUP BY Invoice__c, Invoice__r.Name, SubscriptionLineItem__r.Subscription__c
            ORDER BY Invoice__r.Name
        ]) {
            
            //only need to step through if there is remaining credit balance to spend related to invoice
            Decimal CrtBalance = AmtMap.get(InvSubMap.get((Id)ar.get('subId')));
            if (CrtBalance > 0) {
                Decimal InvBalance = (Decimal)ar.get('bal');
                Decimal PrevBalance = AdjMap.get((Id)ar.get('invId')) == null ? 0.0 : AdjMap.get((Id)ar.get('invId'));
                
                // decrease open balance of invoice if prior adjustments are planned
                InvBalance -= PrevBalance;
                
                // adjustment will be for credit balance amount, or whatever is left of invoice balance
                Decimal AdjAmount = Math.min(CrtBalance, InvBalance);
                
                // reduce remaining credit balance
                AmtMap.put(InvSubMap.get((Id)ar.get('subId')), CrtBalance - AdjAmount);
                
                // increase planned credit balance adjustment
                AdjMap.put((Id)ar.get('invId'), AdjAmount + PrevBalance);
            }
        }
        // convert remaining invoice-related credit balances to account-related
        for (Invoice__c inv : [SELECT Id, Account__c FROM Invoice__c WHERE Id IN :amtMap.keySet()]) {
            if (amtMap.get(inv.Id) > 0) {
                amtMap.put(
                    inv.Account__c, 
                    amtMap.get(inv.Account__c) == null ? amtMap.get(inv.Id) : amtMap.get(inv.Id) + amtMap.get(inv.Account__c)
                );
            }
        }
        
        // iterate through all open invoices to apply remaining credit balance
        for (Invoice__c inv : [SELECT Id, Account__c, Balance__c FROM Invoice__c WHERE Status__c = 'Posted' AND InvoiceDate__c <= TODAY AND Account__c IN :amtMap.keySet() AND Balance__c > 0]) {
            Decimal CrtBalance = AmtMap.get(inv.Account__c);
            if (CrtBalance > 0) {
                Decimal InvBalance = inv.Balance__c;
                Decimal PrevBalance = AdjMap.get(inv.Id) == null ? 0.0 : AdjMap.get(inv.Id);
                
                // decrease open balance of invoice if prior adjustments are planned
                InvBalance -= PrevBalance;
                
                // adjustment will be for credit balance amount, or whatever is left of invoice balance
                Decimal AdjAmount = Math.min(CrtBalance, InvBalance);
                
                // reduce remaining credit balance
                AmtMap.put(inv.Account__c, CrtBalance - AdjAmount);
                
                // increase planned credit balance adjustment
                AdjMap.put(inv.Id, AdjAmount + PrevBalance);
            }
        }
        
        Map<Id,Invoice__c> InvoiceMap = new Map<Id,Invoice__c>([SELECT Id, ZuoraId__c FROM Invoice__c WHERE Id IN :AdjMap.keySet()]);
        Integer x = -1;
        List<List<ZObj.CreateCBA>> lstCBAs = new List<List<ZObj.CreateCBA>>();
        List<ZObj.CreateCBA> CBAs = new List<ZObj.CreateCBA>();
        for (Id invId : AdjMap.keySet()) {
            x++;
            if (x==50) {
                x=0;
                lstCBAs.add(CBAs);
                CBAs = new List<ZObj.CreateCBA>();
            }
            CBAs.add(new ZObj.CreateCBA(AdjMap.get(invId), InvoiceMap.get(invId).ZuoraId__c, 'Decrease'));
        }
        if (CBAs.size() > 0) lstCBAs.add(CBAs);
        if (lstCBAs.size() > 0) ZuoraSyncController.CreateCreditBalanceAdjustments(lstCBAs);        
    }
    
    global void finish(Database.BatchableContext BC){
    }
    
}