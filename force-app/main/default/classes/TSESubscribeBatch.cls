global class TSESubscribeBatch implements Schedulable {
    
    global static Integer DaysToRenewalCutoff = 31;
    global static Boolean DoProrate = false;
    global static TSE_Settings__c Settings = TSE_Settings__c.getInstance([SELECT Id FROM Profile where Name = 'System Administrator' LIMIT 1].Id);
    global static Date SubStartDefault = Settings.SubscriptionStartDate__c == null ? Date.today() : Settings.SubscriptionStartDate__c;
    
    global void execute(SchedulableContext sc) {
        doTSESub();
    }
    
    @future(callout=true)
    global static void doTSESub() {
        try {
            MyObVenue__c venue = [
                SELECT Id, Account__c, Account__r.CurrencyIsoCode, Account__r.ZuoraId__c, TSE_Charges__c, MyOrderbirdId__c, Wizard_Complete__c
                FROM MyObVenue__c 
                WHERE Wizard_Complete__c >= :Date.newInstance(2020,7,29) AND TSE_Revoke__c = null AND TSE_Charges__c = null AND Account__r.Target_Product__c != 'MINI'
                ORDER BY Wizard_Complete__c
                LIMIT 1
            ];
            
            Date SubStart = (venue.Wizard_Complete__c < DateTime.newInstance(2020,5,11) || venue.Wizard_Complete__c > DateTime.newInstance(2020,7,28)) ? Date.newInstance(venue.Wizard_Complete__c.year(), venue.Wizard_Complete__c.month(), venue.Wizard_Complete__c.day()) : SubStartDefault;
                
            List<String> LinkedCharges = new List<String>();
            
            String AccountId = venue.Account__c;
            String AccountCurr = venue.Account__r.CurrencyIsoCode;
            List<MyObVenue__c> OtherVenues = [SELECT Id, TSE_Charges__c FROM MyObVenue__c WHERE Account__c = :AccountId AND TSE_Charges__c != null];
            for (MyObVenue__c OtherVenue : OtherVenues) {
                LinkedCharges.addAll(OtherVenue.TSE_Charges__c.split(','));
            }
            if ( (!LinkedCharges.contains('NEED') && !LinkedCharges.contains('ERROR')) || venue.Account__r.ZuoraId__c == null ) {
                
                List<SubscriptionLineItem__c> UnlinkedCharges = [
                    SELECT Id, Name 
                    FROM SubscriptionLineItem__c 
                    WHERE Name NOT IN :LinkedCharges 
                    AND Subscription__r.Account__c = :AccountId
                    AND Product__r.Name LIKE '%tse%' 
                    AND (NOT Product__r.Name LIKE '%discount%') 
                    AND IsCurrent__C = TRUE
                ];
                
                if (UnlinkedCharges.size() > 0) {
                    venue.TSE_Charges__c = UnlinkedCharges[0].Name;
                } else {
                    
                    List<SubscriptionLineItem__c> ServiceLicenses = [
                        SELECT Id, ESD_Matches_SubTSD__c, EffectiveStartDate__c, Subscription__r.Account__c, Subscription__r.Account__r.CurrencyIsoCode, Subscription__r.InvoiceOwner__c,
                        Subscription__r.TermType__c, Subscription__r.Status__c, Subscription__r.ZuoraId__c, Subscription__r.Account__r.ZuoraId__c
                        FROM SubscriptionLineItem__c 
                        WHERE Status_Active_Service__c = 1 
                        AND Product__r.Model__C in ('perunit', 'flatfee') 
                        AND Subscription__r.Account__c = :AccountId
                        ORDER BY Product__r.Price_EUR__c DESC, EffectiveStartDate__c
                    ];
                    
                    String tsec;
                    if ((!DoProrate || Test.isRunningTest()) && ServiceLicenses.size() == 0) { tsec = SimpleNoProrate(AccountId, AccountCurr, SubStart); } else {
                        if (ServiceLicenses[0].ESD_Matches_SubTSD__c){ tsec = SimpleProrate(ServiceLicenses[0], SubStart); } else { tsec = ComplexProrate(ServiceLicenses[0], SubStart); }
                    }
                    venue.TSE_Charges__c = tsec;
                    
                }
                
            } else { venue.TSE_Charges__c = 'ERROR'; }
            update venue;
        } catch(exception e) {system.debug(e.getMessage());}
    }
    
    public static Boolean IsRenewalDateTooSoon(Date d, Date SubStart) {
        return SubStart.daysBetween(RenewalDate(d, SubStart)) < DaysToRenewalCutoff;
    }
    
    public static Date RenewalDate(Date d, Date SubStart) {
        Date RenewalDate = Date.newInstance(SubStart.year()-1, d.month(), d.day());
        while (RenewalDate < SubStart) { RenewalDate = Date.newInstance(RenewalDate.year()+1, d.month(), d.day()); }
        return RenewalDate;
    }
    
    public static String SimpleNoProrate(Id AccountId, String AccountCurr, Date SubStart) { //simple without proration
        list<PricebookEntry> pbes = [SELECT Id, key__c, Name, Pricebook2Id, Product2Id, CurrencyIsoCode, UnitPrice, IsActive, UseStandardPrice FROM PricebookEntry];
        map<string, PricebookEntry> pbeMap = new map<string, PricebookEntry>();
        for (PricebookEntry pbe : pbes) { pbeMap.put(pbe.key__c, pbe); }
        Opportunity newOpp = new Opportunity(CurrencyIsoCode=AccountCurr,AccountId=AccountId,name='TSE Autosubscribe',stagename='Potential',closedate=date.today().addDays(14),oppcategory__c='Account Management',opportunity_type_1__c='TSE Auto-subscribe'); 
        insert newOpp;
        Quote newQuote = new Quote(
            name='TSE Auto-subscribe Quote',
            Pricebook2Id = [SELECT Id From Pricebook2 WHERE Key__c = 'Main' LIMIT 1].Id,
            Tax = 0,
            AutoAcceptPriority__c = 50,
            ContractEffectiveDate__c = SubStart,
            InvoiceDate__c = SubStart,
            InvoiceTargetDate__c = Date.today(),
            POS_Start_Date__c = SubStart,
            ExpirationDate = date.today().addDays(30),
            Pay_by_Instalment__c = false,
            PaymentMethod__c = 'Bank Transfer',
            WireFirstPayment__c = false,
            PayPalLink__c = false,
            InvoiceOwner__c = AccountId,
            Contains_Recurring_Items__c = true,
            CurrencyIsoCode = AccountCurr,
            opportunityid = newOpp.id
        );
        insert newQuote;
        List<Product2> prods = [SELECT Id, ZuoraId__c FROM Product2 WHERE UniqueSysRef__c IN ('TSE', 'TSE_fee')];
        for (Product2 prod : prods) {
            insert new QuoteLineItem(
                QuoteId = newQuote.Id,
                Product2Id = prod.Id,
                Quantity = 1,
                PricebookEntryId = pbeMap.get(AccountCurr + ':' + prod.ZuoraId__c).Id,
                UnitPrice = pbeMap.get(AccountCurr + ':' + prod.ZuoraId__c).UnitPrice
            );
        }
        return 'NEED';
    }
    
    public static String SimpleProrate(SubscriptionLineItem__c SLI, Date SubStart) { //simple with proration
        if (IsRenewalDateTooSoon(SLI.EffectiveStartDate__c, SubStart)) { return ComplexProrate(SLI, SubStart); } else { return PerformSP(SLI, SubStart); }
    }

    public static String ComplexProrate(SubscriptionLineItem__c SLI, Date SubStart) { //complicated proration
        if (EvalSub(SLI)) { return ExecCP(SLI, SubStart); } return SimpleNoProrate(SLI.Subscription__r.Account__c, SLI.Subscription__r.Account__r.CurrencyIsoCode, SubStart);
    }

    public static String PerformSP(SubscriptionLineItem__c SLI, Date SubStart) {
        if (EvalSub(SLI)) { return ExecSP(SLI, SubStart); } return SimpleNoProrate(SLI.Subscription__r.Account__c, SLI.Subscription__r.Account__r.CurrencyIsoCode, SubStart);
    }
    
    public static Boolean EvalSub(SubscriptionLineItem__c SLI) {
        return (SLI.Subscription__r.TermType__c == 'Evergreen' && SLI.Subscription__r.Status__c == 'Active' && SLI.Subscription__r.Account__c == SLI.Subscription__r.InvoiceOwner__c);
    }
    
    public static String ExecSP(SubscriptionLineItem__c SLI, Date SubStart) {
        if (ZuoraSyncController.BillSimpleTSE(SubStart, SLI.Subscription__r.ZuoraId__c, SLI.Subscription__r.Account__r.ZuoraId__c)) { return 'NEED'; } else { return SimpleNoProrate(SLI.Subscription__r.Account__c, SLI.Subscription__r.Account__r.CurrencyIsoCode, SubStart); }
    }
    
    public static String ExecCP(SubscriptionLineItem__c SLI, Date SubStart	) {
        if (ZuoraSyncController.BillComplexTSE(SubStart, SLI.Subscription__r.ZuoraId__c, SLI.Subscription__r.Account__r.ZuoraId__c, RenewalDate(SLI.EffectiveStartDate__c, SubStart), IsRenewalDateTooSoon(SLI.EffectiveStartDate__c, SubStart))) { return 'NEED'; } else { return SimpleNoProrate(SLI.Subscription__r.Account__c, SLI.Subscription__r.Account__r.CurrencyIsoCode, SubStart); }
    }
        
}