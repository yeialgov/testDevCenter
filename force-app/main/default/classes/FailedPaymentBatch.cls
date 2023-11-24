global class FailedPaymentBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{
    
    global FailedPaymentBatch() {
        SetQuery(true);
    }
    
    global void SetQuery(Boolean IsInitial) {
        Query  = 'SELECT Id, ZuoraId__c, Target_Product__c,';
        Query += '  ( ';
        Query += '    SELECT Id, Days_Since_Last_Shift_Open__c, ChurnPrediction__c ';
        Query += '    FROM MyOrderbird_Log_ons__r ';
        Query += '    WHERE Days_Since_Last_Shift_Open__c != NULL ';
        Query += '    	AND Days_Since_Last_Shift_Open__c < 20 ';
        Query += '    ORDER BY ChurnPrediction__c ';
        Query += '    LIMIT 1 ';
        Query += '  ), ';
        Query += '  ( ';
        Query += '    SELECT Id ';
        Query += '    FROM Invoices__r ';
        Query += '    WHERE HasFullBalance__c = TRUE ';
        Query += '  ), ';
        Query += '  ( ';
        Query += '    SELECT Id, Evaluation__c ';
        Query += '    FROM Payments__r ';
        Query += '    WHERE Evaluation__c IN (\'Sepa Failed\', \'Sepa Refunded\', \'Sepa Aborted\') ';
        Query += '      AND CreatedDate__c = LAST_n_DAYS:27 ';
        Query += '  ) ';
        Query += 'FROM Account ';
        if (IsInitial) {
            Query += 'WHERE Id IN (SELECT Account__c FROM Refund__c WHERE CreatedDate = TODAY) ';
        } 
        /* The account with 'SEPA Aborted' are excluded from Smart Collections
         * because of CDS-3175
         * else {
            Query += 'WHERE Id IN (SELECT Account__c FROM Payment__c WHERE CreatedDate = TODAY AND Evaluation__c = \'Sepa Aborted\') ';
            Query += 'AND Id NOT IN :AllAccounts ';
        }*/
        Query += '  AND Dunning_0_Date__c = NULL ';
        if (test.isRunningTest()) Query += '  AND Name = \'isRunning Test Account\' ';
        Query += '  LIMIT 200 ';
        // First = true;
    }
    
    global String Query;
    global Map<Id, Invoice__c> InvoiceMap;
    //global Boolean First;
    global Map<String, sObject> BatchMap = new Map<String, sObject>();
    global Map<String, Date> DateMap = new Map<String, Date>();
    global List<ZObj.BatchChange> BatchChanges = new List<ZObj.BatchChange>();
    global List<InvoiceLineItem__c> DownshiftILIs = new List<InvoiceLineItem__c>();
    
    global Map<String, Integer> FreqOrder = new Map<String, Integer>{'Ten_Year'=>120,'Three_Year'=>36,'Year'=>12,'Quarter'=>3,'Month'=>1};
        
        global Database.QueryLocator start(Database.BatchableContext BC){
            return Database.getQueryLocator(Query);
        }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        Set<String> AllAccounts = new Set<String>();
        List<String> BatchChange = new List<String>();
        List<String> Downshift = new List<String>();
        for (sObject s : scope) {
            AllAccounts.add((String)s.get('Id'));
        }
        /* if (First) {
            SetQuery(false);
            List<sObject> scope_append = Database.query(Query);
            for (sObject s : scope_append) {
                AllAccounts.add((String)s.get('Id'));
            }
            scope.addAll(scope_append);
            First = false;
        } */
        InvoiceMap = new Map<Id, Invoice__c>([
            SELECT Id, (
                SELECT Id, SubscriptionLineItem__c, SubscriptionLineItem__r.Name, SubscriptionLineItem__r.Frequency__c, ServiceStartDate__c 
                FROM Invoice_Line_Items__r 
                WHERE SubscriptionLineItem__r.Product__r.DownshiftsTo__c != NULL 
                  AND ServiceStartDate__c = LAST_n_DAYS:30
            )
            FROM Invoice__c
            WHERE Account__c IN :AllAccounts AND HasFullBalance__c = TRUE
        ]);
        for (sObject s : scope) {
            if (!IsVenueActive(s)) {
                BatchChange(s);
            } else if (HasMultipleFailures(s) || IsLikelyChurner(s)){
                if (CanDownshift(s)) {
                    Downshift(s);
                } else {
                    BatchChange(s);
                }
            }
        }
        doBatchUpdates();
        doDownshifting();
    }
    
    global static Boolean IsVenueActive(sObject s) {
        try{ return ((List<MyObVenue__c>)(s.getSObjects('MyOrderbird_Log_ons__r'))).size() > 0; }catch(exception e){ return false; }
    }
    
    global static Boolean IsLikelyChurner(sObject s) {
        MyObVenue__c venue = (MyObVenue__c)(s.getSObjects('MyOrderbird_Log_ons__r'))[0];
        return venue.ChurnPrediction__c != null && venue.ChurnPrediction__c > 0.5 ;
    }
    
    global static Boolean HasMultipleFailures(sObject s) {
        try{
            List<Payment__c> Payments = (List<Payment__c>)s.getSObjects('Payments__r');
            return (Payments.size() > 1 || Payments[0].Evaluation__c == 'Sepa Refunded' || Payments[0].Evaluation__c == 'Sepa Aborted');
        }catch(exception e){ return false; }
    }
    
    global Boolean CanDownshift(sObject s) {
        try{ 
            for (Invoice__c Inv : (List<Invoice__c>)(s.getSObjects('Invoices__r'))) {
                if (InvoiceMap.get(Inv.Id).Invoice_Line_Items__r.size() > 0) return true; 
            }
        } catch(exception e){}
        return false;
    }
    
    global void BatchChange(sObject s) {
        String Collection_Batch;
        if((String)s.get('Target_Product__c')=='MINI')
            Collection_Batch = 'Batch9';
        else
        	Collection_Batch = 'Batch8';
        s.put('Batch__c', Collection_Batch);
        BatchMap.put((String)s.get('ZuoraId__c'), s);
        BatchChanges.add(new ZObj.BatchChange((String)s.get('ZuoraId__c'), Collection_Batch));
    }
    
    global void Downshift(sObject s) {
        List<InvoiceLineItem__c> ILIs = new List<InvoiceLineItem__c>();
        for (Invoice__c Inv : (List<Invoice__c>)(s.getSObjects('Invoices__r'))) {
            for (InvoiceLineItem__c ILI : InvoiceMap.get(Inv.Id).Invoice_Line_Items__r) {
                DateMap.put(ILI.SubscriptionLineItem__r.Name, ILI.ServiceStartDate__c);
                if (ILIs.size()==0) {
                    ILIs.add(ILI);
                } else if (ILIs[0].SubscriptionLineItem__r.Frequency__c == ILI.SubscriptionLineItem__r.Frequency__c) {
                    ILIs.add(ILI);
                } else if (FreqOrder.get(ILI.SubscriptionLineItem__r.Frequency__c) > FreqOrder.get(ILIs[0].SubscriptionLineItem__r.Frequency__c)) {
                    ILIs = new List<InvoiceLineItem__c>();
                    ILIs.add(ILI);
                }
            }
        }
        DownshiftILIs.addAll(ILIs);
    }
    
    global void doDownshifting() {
        Set<String> SLIIds = new Set<String>();
        List<PricebookEntry> pbes = [
            SELECT Id, Key__c, Name, Pricebook2Id, Product2Id, CurrencyIsoCode, 
              UnitPrice, IsActive, UseStandardPrice 
            FROM PricebookEntry
        ];
        Map<String, PricebookEntry> pbeMap = new Map<String, PricebookEntry>();
        for (PricebookEntry pbe : pbes) { pbeMap.put(pbe.Key__c, pbe); }
        for (InvoiceLineItem__c ILI : DownshiftILIs) { SLIIds.add(ILI.SubscriptionLineItem__r.Name); }
        List<SubscriptionLineItem__c> SLIs = [
            SELECT Id, Name, Subscription__r.Account__r.CurrencyIsoCode, Subscription__r.Account__c, Product__c, 
                Product__r.ZuoraId__c, Product__r.DownshiftsTo__r.ZuoraId__c, CurrencyIsoCode, 
                Product__r.DownshiftsTo__c, Quantity__c, EffectiveStartDate__c, Frequency__c
            FROM SubscriptionLineItem__c 
            WHERE Subscription__r.Status__c = 'Active'
            	AND Name IN :SLIIds
        ];
        List<Opportunity> newOpps = new List<Opportunity>();
        List<Quote> newQuotes = new List<Quote>();
        List<QuoteLineItem> newQLIs = new List<QuoteLineItem>();
        for (SubscriptionLineItem__c sli : SLIs) {
            for (Integer i=0; i<2; i++) {
                newOpps.add(new Opportunity(
                    CurrencyIsoCode = sli.Subscription__r.Account__r.CurrencyIsoCode,
                    AccountId = sli.Subscription__r.Account__c,
                    Name = 'Downshift Auto-Opportunity',
                    StageName = 'Potential',
                    CloseDate = Date.today().addDays(14),
                    OppCategory__c = 'Account Management',
                    Opportunity_Type_1__c = 'Downshift Autochange'
                ));
            }
        }
        insert newOpps;
        //////////
        Integer x = 0;
        for (Integer i=0; i<2; i++) {
            for (SubscriptionLineItem__c sli : SLIs) {
                newQuotes.add(new Quote(
                    name='Downshift Auto-Quote',
                    Pricebook2Id = [SELECT Id From Pricebook2 WHERE Key__c = 'Main' LIMIT 1].Id,
                    Tax = 0,
                    ContractEffectiveDate__c = DateMap.get(sli.Name),
                    InvoiceDate__c = Date.today(),
                    InvoiceTargetDate__c = Date.today(),
                    POS_Start_Date__c = DateMap.get(sli.Name),
                    ExpirationDate = Date.today().addDays(30),
                    Pay_by_Instalment__c = false,
                    PaymentMethod__c = 'Bank Transfer',
                    WireFirstPayment__c = false,
                    PayPalLink__c = false,
                    InvoiceOwner__c = sli.Subscription__r.Account__c,
                    Contains_Recurring_Items__c = true,
                    CurrencyIsoCode = sli.CurrencyIsoCode,
                    AutoAcceptPriority__c = 1,
                    OpportunityId = newOpps[x].Id
                ));
                x++;
            }
        }
        insert newQuotes;
        x = 0;
        for (SubscriptionLineItem__c sli : SLIs) {
            newQLIs.add(new QuoteLineItem(
                QuoteId = newQuotes[x].id,
                Product2Id = sli.Product__c,
                SubscriptionLineItem__c = sli.Id,
                Quantity = sli.Quantity__c * -1,
                PricebookEntryId = pbeMap.get(sli.Subscription__r.Account__r.CurrencyIsoCode + ':' + sli.Product__r.ZuoraId__c).Id,
                UnitPrice = pbeMap.get(sli.Subscription__r.Account__r.CurrencyIsoCode + ':' + sli.Product__r.ZuoraId__c).UnitPrice
            ));
            x++;
            newQLIs.add(new QuoteLineItem(
                QuoteId = newQuotes[x].id,
                Product2Id = sli.Product__r.DownshiftsTo__c,
                Quantity = sli.Quantity__c,
                PricebookEntryId = pbeMap.get(sli.Subscription__r.Account__r.CurrencyIsoCode + ':' + sli.Product__r.DownshiftsTo__r.ZuoraId__c).Id,
                UnitPrice = pbeMap.get(sli.Subscription__r.Account__r.CurrencyIsoCode + ':' + sli.Product__r.DownshiftsTo__r.ZuoraId__c).UnitPrice
            ));
            x++;
        }
        insert newQLIs;
    }
    
    global void doBatchUpdates() {
        if (BatchChanges.size() > 0) {
            for (ZObj.SuccessId zs : ZuoraSyncController.UpdateBillingBatches(BatchChanges)) {
                if (!zs.Success) BatchMap.remove(zs.Id);
            }
            update BatchMap.values();
        }
    }
    
    global void finish(Database.BatchableContext BC){
        if (!test.isRunningTest()) System.enqueueJob(new EnqueueAQA());
    }
    
}