public class ZuoraSyncController {

    /****
    /* Component Actions
    /*
    /****/

    @AuraEnabled
    public Static Boolean syncCatalog() {
        
        if ([SELECT Id FROM asyncApexJob WHERE Status!='Completed' AND Status!='Aborted' AND Status!='Failed' AND ApexClass.Name = 'prodcatupsert' LIMIT 10].size() > 0) {
            return false;    
        }
        System.enqueueJob(new ProdCatUpsert(0, JSON.serialize(ZuoraSyncController.FetchCatalog())));
        return true;
    }
    
    @AuraEnabled
    public static void syncAccount(String AccountZId, Boolean RunFuture) {

        syncAccounts(new List<String>{AccountZId}, RunFuture);
    }
    
    @AuraEnabled
    public static void syncInvoiceItems(String InvoiceZId) {
        InvItemCollectionUpsert(FetchInvItemCollection(new List<String>{InvoiceZId}));
    }
    
    public static void syncAccounts(List<String> AccountZIds, Boolean RunFuture) {
        
        List<String> SubscriptionZIds = new List<String>();
        List<String> RatePlanZIds = new List<String>();
        List<String> InvoiceZIds = new List<String>();
        
        AccountZObjCollection Account = FetchAccountCollection(AccountZIds);
        
        SubscriptionZObjCollection Subscriptions = FetchSubscriptionCollection(AccountZIds);
        for (ZObj.FetchSubscription Subscription : Subscriptions.FetchSubscriptions) {
            SubscriptionZIds.add(Subscription.Id);
        }
        
        SLIMapZObjCollection SLIMap = null;
        if (SubscriptionZIds.size() > 0) {
            SLIMap = FetchSLIMapCollection(SubscriptionZIds);
            for (ZObj.FetchSLIMapping SLIMapping : SLIMap.FetchSLIMap) {
                RatePlanZIds.add(SLIMapping.Id);
            }
        }
        
        SubItemZObjCollection SubItemsCharge = null;
        SubItemZObjCollection SubItemsDiscount1 = null;
        SubItemZObjCollection SubItemsDiscount2 = null;
        if (RatePlanZIds.size() > 0) {
            SubItemsCharge = FetchSubItemCollection(RatePlanZIds, 0);
            SubItemsDiscount1 = FetchSubItemCollection(RatePlanZIds, 1);
            SubItemsDiscount2 = FetchSubItemCollection(RatePlanZIds, 2);
        }

        InvoiceZObjCollection Invoices = FetchInvoiceCollection(AccountZIds);
        for (ZObj.FetchInvoice Invoice : Invoices.FetchInvoices) {
            InvoiceZIds.add(Invoice.Id);
        }
        
        InvItemZObjCollection InvItems = null;
        if (InvoiceZIds.size() > 0) InvItems = FetchInvItemCollection(InvoiceZIds);
        
        PaymentZObjCollection Payments = FetchPaymentCollection(AccountZIds);
        
        RefundZObjCollection Refunds = FetchRefundCollection(AccountZIds);
        
        AccountCollectionUpsert(Account, false);
        SubscriptionCollectionUpsert(Subscriptions, false);
        if (SLIMap != null) SLIMapCollectionUpsert(SLIMap, false);
        if (SubItemsCharge != null) SubItemCollectionUpsert(SubItemsCharge, 0, false);
        if (SubItemsDiscount1 != null) SubItemCollectionUpsert(SubItemsDiscount1, 1, false);
        if (SubItemsDiscount2 != null) SubItemCollectionUpsert(SubItemsDiscount2, 2, false);
        InvoiceCollectionUpsert(Invoices, false);
        if (InvItems != null) InvItemCollectionUpsert(InvItems, false);
        PaymentCollectionUpsert(Payments, false);
        RefundCollectionUpsert(Refunds, false);
        //SendUnsentEmailsForAccount(AccountZIds);
        
        if (RunFuture) {
            if (InvoiceZIds.size() > 0) InvPmtCollectionFetchUpsert(InvoiceZIds);
            if (InvoiceZIds.size() > 0) InvRefCollectionFetchUpsert(InvoiceZIds);
            PmtMtdCollectionFetchUpsert(AccountZIds);
        }
    }
    
    @AuraEnabled
    public static String PreviewAmendment(String QuoteId) {
        
        return SendQuote(QuoteId, true);
    }
    
    @AuraEnabled
    public static String ProcessQuote(String QuoteId) {
        
        return SendQuote(QuoteId, false);
    }
    
    @AuraEnabled
    public static String CancelSubscriptions(String SubscriptionZIds, String EffectiveDate) {
        List<List<ZObj.FetchSubscriptionPackage>> FetchSubscriptions = new List<List<ZObj.FetchSubscriptionPackage>>();
        
        // Get Cancellation Date
        Date CancelDate = null;
        if (EffectiveDate != null) CancelDate = Date.valueOf(EffectiveDate);
        
        for (String SubscriptionZId : (List<String>)JSON.deserialize(SubscriptionZIds, List<String>.class)) {
            
            // Make Cancellation call for Each Subscription
            ZObj.UpdatedSubscription UpdatedSubscription = ((ZObj.UpdatedSubscription)JSON.deserialize(
                ZuoraAPIManager.callZuoraAPI(
                    'subscriptions/' + SubscriptionZId + '/cancel',
                    'PUT',
                    cleanJSONRequest(JSON.serialize(new ZObj.CancelSubReq(
                        SubscriptionZId, CancelDate
                    )))
                ), 
                ZObj.UpdatedSubscription.class
            ));
            
            // Add Each Involved Subscription to Collection for Upsert
            FetchSubscriptions.add(new List<ZObj.FetchSubscriptionPackage>{ 
                FetchSubscription(UpdatedSubscription.subscriptionId),
                    FetchSubscription(SubscriptionZId) 
                    });
        }
        for (List<ZObj.FetchSubscriptionPackage> FetchSubscription : FetchSubscriptions) {
            SubscriptionQuoteUpsert(
                null, 
                FetchSubscription
            );
        }
        return SubscriptionZIds;
    }

    @AuraEnabled
    public static String RevokeSubscription(String SubscriptionZId) {

        Subscription__c Subscription = [
            SELECT Id, Account__r.ZuoraId__c, Account__c, ContractEffectiveDate__c, ServiceActivationDate__c 
            FROM Subscription__c
            WHERE ZuoraId__c = :SubscriptionZId
            LIMIT 1
        ];

        // Make Cancellation call
        ZObj.UpdatedSubscription UpdatedSubscription = ((ZObj.UpdatedSubscription)JSON.deserialize(
            ZuoraAPIManager.callZuoraAPI(
                'subscriptions/' + SubscriptionZId + '/cancel',
                'PUT',
                cleanJSONRequest(JSON.serialize(new ZObj.RevokeSubReq(
                    Subscription.ContractEffectiveDate__c, Subscription.ServiceActivationDate__c
                )))
            ), 
            ZObj.UpdatedSubscription.class
        ));

        syncAccount(Subscription.Account__r.ZuoraId__c, false);

        return Subscription.Account__c; 
    }

    @AuraEnabled
    public static Boolean QuoteHasAttachment(String QuoteId) {
        return [SELECT Id FROM ContentDocumentLink where LinkedEntityId = :QuoteId].size()>0;
    } 

    /****
    /* Actions
    /*
    /****/
    
    public static ZObj.FetchCatalog FetchCatalog() {
        
        return (ZObj.FetchCatalog)JSON.deserialize(cleanJSONResponse(
            ZuoraAPIManager.callZuoraAPI(
                'catalog/products?pageSize=40',
                'GET',
                null
            )), 
            ZObj.FetchCatalog.class
        );
    }
    
    public static void UpsertCatalog(ZObj.FetchCatalog FetchedCatalog) {
        
        // Record collections for upsert/insert
        List<ProductCategory__c> lstProductCategoryUps = new List<ProductCategory__c>();
        List<Product2> lstProductUps = new List<Product2>();
        List<PricebookEntry> lstPricebookEntryUps = new List<PricebookEntry>();
        List<PricebookEntry> lstPricebookEntryIns = new List<PricebookEntry>();
        
        Id PricebookId = [SELECT Id FROM Pricebook2 WHERE Key__c = 'Main' LIMIT 1].Id;
        
        List<String> standardPriceProducts = new List<String>();
        for (PricebookEntry PricebookEntry : [SELECT Id, Product2.ZuoraId__c FROM PricebookEntry WHERE Pricebook2.Key__c = 'EUR']) {
            standardPriceProducts.add(PricebookEntry.Product2.ZuoraId__c);
        }
        
        // Create set of Pricebook Keys to know which already exist
        Set<String> setPricebookEntryKeys = new Set<String>();
        for (PricebookEntry PricebookEntry : [SELECT Id, Key__c FROM PricebookEntry]) {
            setPricebookEntryKeys.add(PricebookEntry.Key__c);
        }
        
        // Iterate through Zuora products
        for (ZObj.FetchCatalogProducts Product : FetchedCatalog.products) {
            
            // For each Z Product, add SF ProductCategory to collection for upsert
            lstProductCategoryUps.add(new ProductCategory__c(
                Name = Product.name,
                ZuoraId__c = Product.id,
                SKU__c = Product.sku,
                Category__c = Product.category,
                CheckoutCluster__c = Product.CheckoutClusterxxc,
                ProductGeneration__c = Product.ProductGenerationxxc,
                ProductType__c = Product.ProductTypexxc
            ));
            
            // Iterate through Zuora productRatePlans
            for (ZObj.FetchCatalogProductRatePlans ProductRatePlan : Product.productRatePlans) {
                
                Boolean VisibleToAll = false;
                Boolean VisibleToAcM = false;
                
                if (ProductRatePlan.QuoteBuilderVisibilityxxc != null) {
                    String QBV = ProductRatePlan.QuoteBuilderVisibilityxxc.substring(0,1);
                    VisibleToAll = (QBV == 'V');
                    VisibleToAcM = (VisibleToAll || QBV == 'A');
                }                    
                
                // Iterate through Zuora productRatePlanCharges
                for (ZObj.FetchCatalogProductRatePlanCharges ProductRatePlanCharge : ProductRatePlan.productRatePlanCharges) {
                    
                    // For each Z ProductRatePlanCharge, add SF Product to collection for upsert
                    Product2 NewProd = new Product2(
                        ProductCategory__r = new ProductCategory__c(ZuoraId__c = Product.id),
                        Name = ProductRatePlanCharge.name,
                        Product_Name_DE__c = ProductRatePlanCharge.Charge_Name_DExxc,
                        Product_Name_FR__c = ProductRatePlanCharge.Charge_Name_FRxxc,
                        ExternalId = ProductRatePlanCharge.External_Product_IDxxc,
                        ZuoraSubCategoryId__c = ProductRatePlan.id,
                        IsActive = (ProductRatePlan.status == 'Active'),
                        EffectiveStartDate__c = ProductRatePlan.effectiveStartDate,
                        EffectiveEndDate__c = ProductRatePlan.effectiveEndDate,
                        ZuoraId__c = ProductRatePlanCharge.id,
                        Type__c = ProductRatePlanCharge.type,
                        Model__c = ProductRatePlanCharge.model,
                        BillingPeriod__c = ProductRatePlanCharge.billingPeriod,
                        SpecificBillingPeriod__c = String.valueOf(ProductRatePlanCharge.specificBillingPeriod),
                        Taxable__c = ProductRatePlanCharge.taxable,
                        TriggerEvent__c = productRatePlanCharge.triggerEvent,
                        VisibleToAll__c = VisibleToAll,
                        VisibleToAcctMgmt__c = VisibleToAcM,
                        RatePlanName__c = ProductRatePlan.name,
                        ManualDiscount__c = ProductRatePlanCharge.QuoteBuilderOverrideBillingPeriodandPricexxc == 'yes',
                        LocalizedAvailability__c = ProductRatePlan.LocalizedAvailabilityxxc,
                        QuoteBuilderNameOverride__c = (ProductRatePlan.QuoteBuilderItemNamexxc == 'Rate Plan Name')
                    );
                    try {
                        NewProd.RecognizedRevenueAccountingCode__c = ProductRatePlanCharge.financeInformation.recognizedRevenueAccountingCode;
                    }catch(exception e){}
                    if (NewProd.Product_Name_DE__c == null) NewProd.Product_Name_DE__c = NewProd.Name;
                    if (NewProd.Product_Name_FR__c == null) NewProd.Product_Name_FR__c = NewProd.Name;
                    if (ProductRatePlanCharge.LicensedDevicesxxc != null) NewProd.LicensedDevices__c = Integer.valueOf(ProductRatePlanCharge.LicensedDevicesxxc);
                    if (ProductRatePlanCharge.PurchasePricexxc != null) NewProd.PurchasePrice__c = Integer.valueOf(ProductRatePlanCharge.PurchasePricexxc);
                    if (ProductRatePlanCharge.MRR_RPCxxc != null) NewProd.MRR__c = Decimal.valueOf(ProductRatePlanCharge.MRR_RPCxxc);
                    
                    // Iterate through Zuora productRatePlanChargePricing
                    for (ZObj.FetchCatalogPricing Pricing : ProductRatePlanCharge.pricing) {
                        
                        
                        // Do not insert/upsert PricebookEntry if there is no price/discount
                        if (Pricing.price != null || Pricing.discountAmount != null) {
                            //if (Pricing.price == null && Pricing.discountAmount == null && Pricing.currencyX == 'EUR') {
                            
                            // Create PricingKey as Currency:SFProductZId
                            String PricingKey = Pricing.currencyX + ':' + ProductRatePlanCharge.id;
                            
                            // Get the amount
                            Decimal usePrice = Pricing.price;
                            if (usePrice == null) usePrice = (-1 * Pricing.discountAmount);
                            
                            // add EUR price to Product
                            if (Pricing.currencyX == 'EUR') NewProd.Price_EUR__c = usePrice;
                            
                            // Cannot upsert PricebookEntry Product
                            // So use set of existing PricingKeys to determine if this PricebookEntry exists
                            
                            // if PricebookEntry does exist, add SF PricebookEntry to collection for upsert
                            if (setPricebookEntryKeys.contains(PricingKey)) {
                                lstPricebookEntryUps.add(new PricebookEntry(
                                    Key__c = PricingKey,
                                    UnitPrice = usePrice,
                                    IsActive = true,
                                    UseStandardPrice = false
                                ));
                            } else {
                                // if PricebookEntry does not exist, add SF PricebookEntry to collection for insert
                                lstPricebookEntryIns.add(new PricebookEntry(
                                    Pricebook2Id = PricebookId,
                                    Product2 = new Product2(ZuoraId__c = ProductRatePlanCharge.id),
                                    Key__c = PricingKey,
                                    UnitPrice = usePrice,
                                    IsActive = true,
                                    UseStandardPrice = false,
                                    CurrencyIsoCode = Pricing.currencyX
                                ));
                            }
                        }
                    }
                    lstProductUps.add(NewProd);
                }
            }
        }
        
        // loop thru
        
        // DML operations for record collections
        upsert lstProductCategoryUps ZuoraId__c;
        upsert lstProductUps ZuoraId__c;
        upsert lstPricebookEntryUps Key__c;
        insert lstPricebookEntryIns;
    }
    
    public static String SendQuote(String QuoteId, Boolean IsPreview) {
        
        List<String> ErrorMessages = new List<String>();
        
        Map<String, Decimal> UpdateReduceMap = new Map<String,Decimal>();
        List<QuoteLineItem> NewSubscriptionQLIs = new List<QuoteLineItem>();
        Map<String, List<QuoteLineItem>> NewProductAmendmentQLIs = new Map<String, List<QuoteLineItem>>();
        Map<String, List<ZObj.AmendmentPair>> UpdProductAmendmentQLIs = new Map<String, List<ZObj.AmendmentPair>>();
        Map<String, List<ZObj.AmendmentPair>> RemProductAmendmentQLIs = new Map<String, List<ZObj.AmendmentPair>>();
        Map<String, List<QuoteLineItem>> RepProductAmendmentQLIs = new Map<String, List<QuoteLineItem>>();
        
        Quote Quote = [
            SELECT Id, Name, SpecialOffer__c,
            AccountId, Account.Name, Account.CurrencyIsoCode, Account.Batch__c,
            Account.BillingCountry, Account.ZuoraId__c, Proration_Start_Date__c, 
            InvoiceOwner__c, InvoiceOwner__r.ZuoraId__c, Account.CustomerIdText__c,
            InvoiceDate__c, InvoiceTargetDate__c, Account.LegalCompanyName__c,
            Pay_by_Instalment__c, POS_Start_Date__c, ContractEffectiveDate__c, SpecialRestart__c, 
            Account.Tax_Exempt_Reason__c, Account.taxExempted__c, Account.VATNumber__c,
            WireFirstPayment__c, PaymentMethod__c, PayPalLink__c, AutoAcceptPriority__c
            FROM Quote
            WHERE Id = :QuoteId
            LIMIT 1
        ];
        Boolean isAcctMgmt = NewQuoteController.getAcctMgmtPerm();
        Quote.InvoiceDate__c = Quote.ContractEffectiveDate__c; // but today if in past
        Quote.InvoiceTargetDate__c = Quote.POS_Start_Date__c;  // but today if in past
        if (
            Quote.InvoiceDate__c < Date.today()
            || isAcctMgmt
        ) {
            Quote.InvoiceDate__c = Date.today();
        }
        if (
            Quote.InvoiceTargetDate__c < Date.today()
            || isAcctMgmt
        ) {
            Quote.InvoiceTargetDate__c = Date.today();
        }
        if (Quote.InvoiceTargetDate__c < Quote.InvoiceDate__c) ErrorMessages.add( 'Hey now. These dates don\'t make sense to me.' );
        
        if (Quote.InvoiceTargetDate__c == null) Quote.InvoiceTargetDate__c = Quote.InvoiceDate__c;
        
        List<QuoteLineItem> QLIs = [
            SELECT Id, Quantity, Product2Id, Product2.Type__c, SubscriptionLineItem__c,
            Product2.ZuoraId__c, Product2.ZuoraSubCategoryId__c, Product2.Model__c,
            QuoteId, Quote.POS_Start_Date__c, Quote.ContractEffectiveDate__c, Product2.Name,
            Product2.ManualDiscount__c, UnitPrice, BillingPeriodDurationOverride__c
            FROM QuoteLineItem 
            WHERE QuoteId = :QuoteId
        ];
        
        // Determine if there is an AES: Active, Evergreen Subscription without a different Invoice Owner
        String ActvEvrgrnSubZId = null;
        List<Subscription__c> ActvEvrgrnSub = [
            SELECT Id, ZuoraId__c
            FROM Subscription__c
            WHERE Status__c = 'Active' 
                AND TermType__c = 'EVERGREEN'
                AND Account__c = :Quote.AccountId
                AND HasDifferentInvoiceOwner__c = FALSE
                AND ContractEffectiveDate__c <= :Quote.ContractEffectiveDate__c
            ORDER BY SubscriptionStartDate__c DESC
        ];
        if (ActvEvrgrnSub.size() > 0) ActvEvrgrnSubZId = ActvEvrgrnSub[0].ZuoraId__c;
        
        // Active Subscription Line Items for the Account
        List<SubscriptionLineItem__c> SLIs = [
            SELECT Id, Quantity__c, Subscription__r.InvoiceOwner__c,
            Product__c, Product__r.ZuoraId__c, Product__r.ZuoraSubCategoryId__c,
            Subscription__c, Subscription__r.TermType__c, Subscription__r.ZuoraId__c,
            ZuoraId__c, ZuoraSubCategoryId__c, EffectiveStartDate__c
            FROM SubscriptionLineItem__c
            WHERE
            Subscription__r.Account__c = :Quote.AccountId
            AND Subscription__r.Status__c = 'Active'
            ORDER BY Subscription__r.SubscriptionStartDate__c DESC
        ];
        
        // Iterate through QuoteLineItems
        for (QuoteLineItem QLI : QLIs) {
            // Positive-Quantity QLI
            if (QLI.Quantity > 0) {
                if (ActvEvrgrnSub.size() == 0) {
                    // Only AES can have products added; Otherwise create AES
                    if (Quote.SpecialOffer__c == 'GuestMgmt 199EUR') {
                        if (QLI.Product2.Name.containsIgnoreCase('guest')) NewSubscriptionQLIs.add(QLI);
                    } else {
                    	NewSubscriptionQLIs.add(QLI);
                    }
                } else {
                    Boolean Matched = false;
                    for (SubscriptionLineItem__c SLI : SLIs) {
                        // Iterate through SLIs to find matches
                        if (
                            SLI.Product__c == QLI.Product2Id 
                            && QLI.Product2.Type__c != 'OneTime'
                            && SLI.Subscription__r.TermType__c == 'EVERGREEN'
                            && SLI.Subscription__r.InvoiceOwner__c == null
                            && !Matched
                        ) {
                            // SLI matches with QLI: Update Amendment
                            Matched = true;
                            if (UpdProductAmendmentQLIs.get(SLI.Subscription__r.ZuoraId__c) == null) {
                                UpdProductAmendmentQLIs.put(SLI.Subscription__r.ZuoraId__c, new List<ZObj.AmendmentPair>());
                            }
                            UpdProductAmendmentQLIs.get(SLI.Subscription__r.ZuoraId__c).add(new ZObj.AmendmentPair(QLI, SLI));
                            UpdateReduceMap.put(SLI.ZuoraId__c, SLI.Quantity__c + QLI.Quantity);
                        }
                    }
                    if (!Matched) {
                        // If no SLI matched with QLI: New Product Amendment
                        String mapKey = null;
                        if (SLIs.size() > 0) mapKey = SLIs[0].Subscription__r.ZuoraId__c;
                        if (NewProductAmendmentQLIs.get(mapKey) == null) {
                            NewProductAmendmentQLIs.put(mapKey, new List<QuoteLineItem>());
                        }
                        NewProductAmendmentQLIs.get(mapKey).add(QLI);
                    }
                }
            } else {
                //Negative QLI
                Decimal NegVal = QLI.Quantity * -1;
                for (SubscriptionLineItem__c SLI : SLIs) {
                    if (SLI.Id == QLI.SubscriptionLineItem__c && NegVal > 0) {
                        // Iterate through SLIs to find matches
                        if (NegVal >= SLI.Quantity__c) {
                            // SLI Quantity will be brought down to Zero: Remove Product Amendent
                            if (RemProductAmendmentQLIs.get(SLI.Subscription__r.ZuoraId__c) == null) {
                                RemProductAmendmentQLIs.put(SLI.Subscription__r.ZuoraId__c, new List<ZObj.AmendmentPair>());
                            }
                            RemProductAmendmentQLIs.get(SLI.Subscription__r.ZuoraId__c).add(new ZObj.AmendmentPair(QLI, SLI));
                            UpdateReduceMap.put(SLI.ZuoraId__c, 0);
                            NegVal -= SLI.Quantity__c;
                        } else if (QLI.Product2.Type__c == 'OneTime') {
                            // OneTime SLIs cannot have quantity updated:
                            //  - Remove Product Amendment
                            //  - New Product Amendment (add back to get desired quantity)
                            if (RemProductAmendmentQLIs.get(SLI.Subscription__r.ZuoraId__c) == null) {
                                RemProductAmendmentQLIs.put(SLI.Subscription__r.ZuoraId__c, new List<ZObj.AmendmentPair>());
                            }
                            RemProductAmendmentQLIs.get(SLI.Subscription__r.ZuoraId__c).add(new ZObj.AmendmentPair(QLI, SLI));
                            if (RepProductAmendmentQLIs.get(SLI.Subscription__r.ZuoraId__c) == null) {
                                RepProductAmendmentQLIs.put(SLI.Subscription__r.ZuoraId__c, new List<QuoteLineItem>());
                            }
                            RepProductAmendmentQLIs.get(SLI.Subscription__r.ZuoraId__c).add(QLI);
                            UpdateReduceMap.put(SLI.ZuoraId__c, 0);
                            UpdateReduceMap.put(QLI.Id, SLI.Quantity__c - NegVal);
                            NegVal = 0;
                        } else {
                            // SLI Quantity will be reduced: Update Product Amendment
                            if (UpdProductAmendmentQLIs.get(SLI.Subscription__r.ZuoraId__c) == null) {
                                UpdProductAmendmentQLIs.put(SLI.Subscription__r.ZuoraId__c, new List<ZObj.AmendmentPair>());
                            }
                            UpdProductAmendmentQLIs.get(SLI.Subscription__r.ZuoraId__c).add(new ZObj.AmendmentPair(QLI, SLI));
                            UpdateReduceMap.put(SLI.ZuoraId__c, SLI.Quantity__c - NegVal);
                            NegVal = 0;
                        }
                    }
                }
            }
        }
        
        // create and activate account in Zuora if needed
        String AccountZId = Quote.Account.ZuoraId__c;
        Boolean NeedsLink = false;
        if (AccountZId == null && !IsPreview) {
            AccountZId = CreateZuoraAccount(Quote).Id;
            String ContactZId = CreateZuoraContact(Quote, AccountZId).Id;
            ActivateAccount(AccountZId, ContactZId);
            NeedsLink = true;
        }
        
        Set<String> NewSubscriptionZIds = new Set<String>();
        Set<String> AmendingSubscriptions = new Set<String>();
        AmendingSubscriptions.addAll(NewProductAmendmentQLIs.keySet());
        AmendingSubscriptions.addAll(UpdProductAmendmentQLIs.keySet());
        AmendingSubscriptions.addAll(RemProductAmendmentQLIs.keySet());
        
        if (IsPreview) {
            // Create Invoice Preview and return JSON payload
            String r = '';
            for (String AmendingSubZId : AmendingSubscriptions) {
                r = r + (ExecuteAmendment(new ZObj.AmendmentSet(
                    NewProductAmendmentQLIs.get(AmendingSubZId),
                    UpdProductAmendmentQLIs.get(AmendingSubZId),
                    RemProductAmendmentQLIs.get(AmendingSubZId),
                    RepProductAmendmentQLIs.get(AmendingSubZId),
                    UpdateReduceMap,
                    ActvEvrgrnSubZId
                ),IsPreview,Quote.InvoiceTargetDate__c));
            }
            return r;
        } else {
            
            try {
                // Create Amendments
                for (String AmendingSubZId : AmendingSubscriptions) {
                    ZObj.AmendResults AmendResults = (ZObj.AmendResults)JSON.deserialize(
                        ExecuteAmendment(new ZObj.AmendmentSet(
                            NewProductAmendmentQLIs.get(AmendingSubZId),
                            UpdProductAmendmentQLIs.get(AmendingSubZId),
                            RemProductAmendmentQLIs.get(AmendingSubZId),
                            RepProductAmendmentQLIs.get(AmendingSubZId),
                            UpdateReduceMap,
                            ActvEvrgrnSubZId
                        ),IsPreview,null),
                        ZObj.AmendResults.class
                    );
                    for (ZObj.AmendResult AmendResult : AmendResults.results) {
                        if (AmendResult.Success) {
                            NewSubscriptionZIds.add(AmendResult.SubscriptionId);
                        } else {
                            for (ZObj.ZError ZError : AmendResult.Errors) {
                                ErrorMessages.add(ZError.Message);
                            }
                        }
                    }
                }
                
                // Create New Subscription                
                if (NewSubscriptionQLIs.size() > 0) {
                    ZObj.SubSuccessId SubSuccessResult = SubscriptionCreate(Quote, NewSubscriptionQLIs, AccountZId);
                    if (SubSuccessResult.success) {
                        NewSubscriptionZIds.add(SubSuccessResult.subscriptionId);
                    } else {
                        for (ZObj.ZReason ZReason : SubSuccessResult.reasons) {
                            ErrorMessages.add(ZReason.message);
                        }
                    }
                }
                
                // Do Proration with Start Date
                if (Quote.Proration_Start_Date__c != null) {
                    ZObj.UpdatedSubscription NewSub = (ZObj.UpdatedSubscription)JSON.deserialize(
                        ZuoraAPIManager.callZuoraAPI(
                            'subscriptions', 
                            'POST',
                            cleanJSONRequest(JSON.serialize(new ZObj.SubTSETermedProrateReq(Quote.Proration_Start_Date__c, AccountZId, Quote.POS_Start_Date__c, QLIs[0].Product2.ZuoraId__c, QLIs[0].Product2.ZuoraSubCategoryId__c)))
                        ),
                        ZObj.UpdatedSubscription.class
                    );
                    //if(NewSub.success) { CancelComplexTSE(NewSub.subscriptionId, Quote.POS_Start_Date__c, false); }
                }
                
            } catch(exception e) {
                ErrorMessages.add(e.getMessage());
            } finally {
                if (NeedsLink) LinkZuoraAccount(Quote.AccountId, AccountZId);
            }
            
            if (ErrorMessages.size() == 0 || test.isRunningTest()) {
                
                // Update Quote and Opportunity to show Quote was Accepted
                AcceptedQuoteRecordUpdates(QuoteId, Quote.InvoiceDate__c, Quote.InvoiceTargetDate__c);
                
                // Create invoice for transaction
                if (Quote.AutoAcceptPriority__c == null && ((!Quote.WireFirstPayment__c && !Quote.PayPalLink__c && Quote.Account.Batch__c != 'Batch7' && Quote.Account.Batch__c != 'Batch4' && Quote.Account.Batch__c != 'Batch10' && Quote.PaymentMethod__c != 'Wire Transfer') || Quote.Account.BillingCountry == 'Switzerland' || Quote.Account.BillingCountry == 'Liechtenstein' || Quote.InvoiceOwner__c != null)) {
                    AccountBillRun(
                        Quote.InvoiceOwner__r.ZuoraId__c,
                        AccountZId,
                        Quote.InvoiceDate__c, 
                        Quote.SpecialRestart__c > 0 ? Quote.InvoiceDate__c : Quote.InvoiceTargetDate__c
                    );
                } else if (Quote.AutoAcceptPriority__c != null) { System.enqueueJob(new EnqueueAQA()); }
            } else if (Quote.AutoAcceptPriority__c != null) { Quote.Status = 'Error'; update Quote; }
        }
        return JSON.serialize(ErrorMessages);
    }
    
    public static ZObj.SuccessId CreateZuoraAccount(Quote Quote) {
        
        return ((ZObj.SuccessId)JSON.deserialize(
            ZuoraAPIManager.callZuoraAPI(
                'object/account',
                'POST',
                cleanJSONRequest(JSON.serialize(new ZObj.CreateAccountReq(Quote)))
            ), 
            ZObj.SuccessId.class
        ));
    }
    
    public static ZObj.SuccessId CreateZuoraContact(Quote Quote, String AccountZId) {
        
        return ((ZObj.SuccessId)JSON.deserialize(
            ZuoraAPIManager.callZuoraAPI(
                'object/contact',
                'POST',
                cleanJSONRequest(JSON.serialize(new ZObj.CreateContactReq(
                    Quote, AccountZId
                )))
            ), 
            ZObj.SuccessId.class
        ));
    }
    
    public static void ActivateAccount(String AccountZId, String ContactZId) {
        
        ZObj.SuccessId ActivateResp = ((ZObj.SuccessId)JSON.deserialize(
            ZuoraAPIManager.callZuoraAPI(
                'object/account/' + AccountZId,
                'PUT',
                cleanJSONRequest(JSON.serialize(new ZObj.ActivateAccountReq(ContactZId)))
            ), 
            ZObj.SuccessId.class
        ));
    }
    
    public static String ExecuteAmendment(ZObj.AmendmentSet Data, Boolean IsPreview, Date InvoiceTargetDate) {
        
        return ZuoraAPIManager.callZuoraAPI(
            'action/amend', 
            'POST', 
            cleanJSONRequest(JSON.serialize(new ZObj.AmendActionReq(Data, IsPreview, InvoiceTargetDate)))
        );
    }
    
    public static ZObj.SubSuccessId SubscriptionCreate(
        Quote Quote, 
        List<QuoteLineItem> QLIs, 
        String AccountZId
    ) {
        
        return (ZObj.SubSuccessId)JSON.deserialize(
            ZuoraAPIManager.callZuoraAPI(
                'subscriptions', 
                'POST', 
                cleanJSONRequest(JSON.serialize(
                    new ZObj.CreateSubscriptionReq(Quote, QLIs, AccountZId)
                ))
            ), 
            ZObj.SubSuccessId.class
        );
    }
    
    public static void LinkZuoraAccount(String AccountId, String AccountZId) {
        Account Account = [
            SELECT Id, ZuoraId__c 
            FROM Account 
            WHERE Id = :AccountId 
            LIMIT 1
        ];
        Account.ZuoraId__c = AccountZId;
        update Account;
    }
    
    public static void AcceptedQuoteRecordUpdates(String QuoteId, Date InvoiceDate, Date InvoiceTargetDate) {
        // Set Quote to be updated with lookup to Subscription
        Quote Quote = [SELECT Id, IsAccepted__c, Status, OpportunityId, InvoiceDate__c, InvoiceTargetDate__c FROM Quote WHERE Id = :QuoteId LIMIT 1];
        Quote.Status = 'Accepted';
        Quote.IsAccepted__c = true;
        Quote.InvoiceDate__c = InvoiceDate;
        Quote.InvoiceTargetDate__c = InvoiceTargetDate;
        
        // Query Opportunity to be closed
        Opportunity updOpportunity = [SELECT Id, StageName, Skip_Validation__c FROM Opportunity WHERE Id = :Quote.OpportunityId LIMIT 1];
        updOpportunity.StageName = 'Closed Won';
        Decimal SV = updOpportunity.Skip_Validation__c;
        if (SV == null) SV = 0;
        updOpportunity.Skip_Validation__c = SV + 1;
        
        // Query Other Quotes on the Opportunity to be closed
        List<Quote> updQuotes = [SELECT Id, Status FROM Quote WHERE OpportunityId = :Quote.OpportunityId AND Id != :Quote.Id];
        for (Quote updQuote : updQuotes) {
            updQuote.Status = 'Rejected';
        }
        
        updQuotes.add(Quote);
        
        // Query Tasks to be closed
        List<Task> updTasks = [SELECT Id, Status FROM Task WHERE WhatId = :QuoteId];
        for (Task Task : updTasks) { Task.Status = 'Completed'; }
        
        try{ update updOpportunity; }catch(exception e){}
        try{ update updQuotes; }catch(exception e){}
        try{ update updTasks; }catch(exception e){}
    }
    
    @future(callout=true)
    public static void AccountBillRun(
        String InvOwnerAccountZId, 
        String CustomerAccountZId, 
        Date InvoiceDate, 
        Date InvoiceTargetDate
    ) { DoAccountBillRun(InvOwnerAccountZId, CustomerAccountZId, InvoiceDate, InvoiceTargetDate); }
    
    public static void DoAccountBillRun(
        String InvOwnerAccountZId, 
        String CustomerAccountZId, 
        Date InvoiceDate, 
        Date InvoiceTargetDate
    ) {
        String AccountZId = InvOwnerAccountZId;
        if (AccountZId == null) AccountZId = CustomerAccountZId;
        String DraftInvoiceZId = ((List<ZObj.SuccessId>)JSON.deserialize(
            cleanJSONResponse(ZuoraAPIManager.callZuoraAPI(
                'action/generate',
                'POST',
                cleanJSONRequest(JSON.serialize(new ZObj.GenerateInvoiceReq(
                    AccountZId, 
                    InvoiceDate, 
                    InvoiceTargetDate
                )))
            )), 
            List<ZObj.SuccessId>.class
        ))[0].Id;
        ZObj.SuccessId Success = ((ZObj.SuccessId)JSON.deserialize(
            cleanJSONResponse(ZuoraAPIManager.callZuoraAPI(
                'object/invoice/' + DraftInvoiceZId,
                'PUT',
                '{"Id":"'+DraftInvoiceZId+'","Status":"Posted"}'
            )), 
            ZObj.SuccessId.class
        ));
        syncAccounts(new List<String>{CustomerAccountZId,InvOwnerAccountZId}, false);
    }
    
    public static void FetchUpsertSubscriptionByAccount(String AccountZId) { FetchUpsertSubscriptionByAccountWasActive(AccountZId); FetchUpsertSubscriptionByAccountIsActive(AccountZId); }
    
    @future(callout=true)
    public static void FetchUpsertSubscriptionByAccountWasActive(String AccountZId) {
        
        UpsertSubscriptions(JSON.serialize(FetchActiveSubscriptions(AccountZId)));
    }
    
    @future(callout=true)
    public static void FetchUpsertSubscriptionByAccountIsActive(String AccountZId) {
        
        UpsertSubscriptions(JSON.serialize(FetchSubscriptions(AccountZId)));
    }
    
    public static void InstalmentPaymentRun(List<ZObj.CreatePayment> CreatePayments) {
        ZuoraAPIManager.callZuoraAPI(
            'action/create',
            'POST',
            cleanJSONRequest(JSON.serialize(new ZObj.CreatePayments(CreatePayments)))
        );
    }
    
    public static List<ZObj.SuccessId> UpdateBillingBatches(List<ZObj.BatchChange> BatchChanges) {
        return ((List<ZObj.SuccessId>)JSON.deserialize(
            cleanJSONResponse(ZuoraAPIManager.callZuoraAPI(
                'action/update',
                'POST',
                cleanJSONRequest(JSON.serialize(new ZObj.BatchChangePackage(BatchChanges)))
            )), List<ZObj.SuccessId>.class
        ));
    }

    public static List<ZObj.SuccessId> UpdateInvoiceBatches(List<ZObj.InvoiceVATUpdate> BatchChanges) {
        return ((List<ZObj.SuccessId>)JSON.deserialize(
            cleanJSONResponse(ZuoraAPIManager.callZuoraAPI(
                'action/update', 'POST',
                cleanJSONRequest(JSON.serialize(new ZObj.InvoiceVATUpdatePackage(BatchChanges)))
            )), List<ZObj.SuccessId>.class
        ));
    }

    public static void CreateCreditBalanceAdjustments(List<List<ZObj.CreateCBA>> lstCBAs) {
        for (List<ZObj.CreateCBA> CBAs : lstCBAs) {
            ZuoraAPIManager.callZuoraAPI(
                'action/create', 'POST',
                cleanJSONRequest(JSON.serialize(new ZObj.CreateCBAs(CBAs)))
            );
        }
    }

    public static void CreateBillRunsForPrepayers(List<ZObj.CreateBillRun> BillRuns) {
        List<ZObj.SuccessId> Responses = ((List<ZObj.SuccessId>)JSON.deserialize(
            cleanJSONResponse(ZuoraAPIManager.callZuoraAPI(
                'action/generate',
                'POST',
                cleanJSONRequest(JSON.serialize(new ZObj.CreateBillRuns(BillRuns)))
            )), 
            List<ZObj.SuccessId>.class
        ));
        List<ZObj.InvoicePost> InvoicePosts = new List<ZObj.InvoicePost>();
        for (ZObj.SuccessId Response : Responses) {
            if (Response.Success) InvoicePosts.add(new ZObj.InvoicePost(Response.Id));
        }
        ZuoraAPIManager.callZuoraAPI(
            'action/update',
            'POST',
            cleanJSONRequest(JSON.serialize(new ZObj.InvoicePosts(InvoicePosts)))
        );
    }

    public static void ZuoraUpsert(String sObjName, List<sObject> lstSObj, List<QueryMoreZuora__c> lstQMZ, Boolean RunQMZ) {
        try {
            system.debug(json.serialize(lstSObj));
            system.debug(Schema.getGlobalDescribe().get(sObjName).getDescribe().fields.getMap().get('ZuoraId__c'));
            database.upsert(lstSObj, Schema.getGlobalDescribe().get(sObjName).getDescribe().fields.getMap().get('ZuoraId__c'));
            insert lstQMZ;
            if (RunQMZ) EnqueueNextQMZ();
        }catch(exception e){
            system.debug(e.getMessage());
            system.debug(e.getStackTraceString());
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.toAddresses = new String[] { 'sfdc@orderbird.com' };
            message.subject = 'Zuora Sync Error: ' + sObjName;
            message.plainTextBody = json.serializePretty(lstQMZ);
            Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
            Messaging.sendEmail(messages);
            //if (Limits.getQueueableJobs() == 0) system.enqueueJob(new EnqueueZuoraUpdateRetry(sObjName, lstSObj, lstQMZ, RunQMZ));
        }
    }
        
    public static ZObj.FetchSubscriptionPackages FetchActiveSubscriptions(String AccountZId) {
        List<ZObj.FetchSubscriptionPackage> Subscriptions = new List<ZObj.FetchSubscriptionPackage>();
        for (Subscription__c Subscription : [
            SELECT Id, ZuoraId__c 
            FROM Subscription__c 
            WHERE 
            Account__r.ZuoraId__c = :AccountZId
            AND Status__c = 'Active'
        ]) {
            Subscriptions.add((ZObj.FetchSubscriptionPackage)JSON.deserialize(
                cleanJSONResponse(ZuoraAPIManager.callZuoraAPI(
                    'subscriptions/' + Subscription.ZuoraId__c,
                    'GET',
                    null
                )), 
                ZObj.FetchSubscriptionPackage.class
            ));
        }
        return new ZObj.FetchSubscriptionPackages(Subscriptions);
    }
    
    public static ZObj.FetchSubscriptionPackages FetchSubscriptions(String AccountZId) {
        
        return (ZObj.FetchSubscriptionPackages)JSON.deserialize(
            cleanJSONResponse(ZuoraAPIManager.callZuoraAPI( 'subscriptions/accounts/' + AccountZId, 'GET', null )), ZObj.FetchSubscriptionPackages.class );
    }
    
    public static ZObj.FetchSubscriptionPackage FetchSubscription(String SubscriptionZId) {
        
        return (ZObj.FetchSubscriptionPackage)JSON.deserialize(
            cleanJSONResponse(ZuoraAPIManager.callZuoraAPI(
                'subscriptions/' + SubscriptionZId + '?charge-detail=all-segments',
                'GET',
                null
            )), 
            ZObj.FetchSubscriptionPackage.class
        );
    }
    
    public static void SubscriptionQuoteUpsert(
        String QuoteId, 
        List<ZObj.FetchSubscriptionPackage> FetchedSubscriptions
    ) {
        
        SubscriptionQuoteLink Tree = new SubscriptionQuoteLink(QuoteId);
        Map<String, String> MapSubSupc = new Map<String, String>();
        Map<String, String> MapSubPrec = new Map<String, String>();
        
        if (FetchedSubscriptions.size() == 2) {
            for (ZObj.FetchSubscriptionRatePlans RatePlan : FetchedSubscriptions[0].ratePlans) {
                for (ZObj.FetchSubscriptionRatePlanCharges RatePlanCharge : RatePlan.ratePlanCharges) {
                    MapSubSupc.put(RatePlanCharge.numberX, RatePlanCharge.id);
                }
            }
            for (ZObj.FetchSubscriptionRatePlans RatePlan : FetchedSubscriptions[1].ratePlans) {
                for (ZObj.FetchSubscriptionRatePlanCharges RatePlanCharge : RatePlan.ratePlanCharges) {
                    MapSubPrec.put(RatePlanCharge.numberX, RatePlanCharge.id);
                }
            }
        }
        
        Integer SubscriptionNumber = 0;
        for (ZObj.FetchSubscriptionPackage FetchedSubscription : FetchedSubscriptions) {
            Subscription__c Subscription = new Subscription__c(
                Account__r = new Account(ZuoraId__c = FetchedSubscription.accountId),
                ZuoraId__c = FetchedSubscription.id,
                ZuoraName__c = FetchedSubscription.subscriptionNumber,
                Status__c = FetchedSubscription.status,
                TermType__c = FetchedSubscription.termType,
                SubscriptionStartDate__c = FetchedSubscription.subscriptionStartDate,
                TermStartDate__c = FetchedSubscription.termStartDate,
                TermEndDate__c = FetchedSubscription.termEndDate
            );
            if (SubscriptionNumber == 0) {
                Subscription.Quote__c = QuoteId;
                try{ if (!test.isRunningTest()) Subscription.PrecedingSubscription__r = new Subscription__c( ZuoraId__c = FetchedSubscriptions[1].id );  }catch(exception e){}
                Tree.SubscriptionsNew.add(Subscription);
            } else {
                Subscription.SupercedingSubscription__r = new Subscription__c(
                    ZuoraId__c = FetchedSubscriptions[0].id
                ); 
                Tree.SubscriptionsOld.add(Subscription);
            }
            for (ZObj.FetchSubscriptionRatePlans RatePlan : FetchedSubscription.ratePlans) {
                for (ZObj.FetchSubscriptionRatePlanCharges RatePlanCharge : RatePlan.ratePlanCharges) {
                    SubscriptionLineItem__c SubscriptionLineItem = new SubscriptionLineItem__c(
                        Subscription__r = new Subscription__c(ZuoraId__c = FetchedSubscription.id),
                        Product__r = new Product2(ZuoraId__c = RatePlanCharge.productRatePlanChargeId),
                        ZuoraId__c = RatePlanCharge.id,
                        ZuoraName__c = RatePlanCharge.numberX,
                        ZuoraSubCategoryId__c = RatePlan.id,
                        QuoteLineItem__c = RatePlanCharge.test1xxc,
                        Quantity__c = RatePlanCharge.quantity,
                        Description__c = RatePlanCharge.description,
                        DMRC__c = RatePlanCharge.dmrc,
                        DTCV__c = RatePlanCharge.dtcv,
                        MRR__c = RatePlanCharge.mrr,
                        Price__c = RatePlanCharge.price,
                        TCV__c = RatePlanCharge.tcv
                    );
                    if (SubscriptionNumber == 0) {
                        try {
                            Tree.QuoteLineItems.get(RatePlanCharge.test1xxc).SubscriptionLineItem__r = new SubscriptionLineItem__c(
                                ZuoraId__c = RatePlanCharge.id
                            );
                        } catch (exception e) {}
                        try {
                            if (MapSubPrec.get(RatePlanCharge.numberX) != null) {
                                SubscriptionLineItem.PrecedingSLI__r = new SubscriptionLineItem__c(
                                    ZuoraId__c = MapSubPrec.get(RatePlanCharge.numberX)
                                );
                            }
                        } catch (exception e) {}
                        if (SubscriptionLineItem.ZuoraId__c != null) Tree.SubscriptionLineItemsNew.add(SubscriptionLineItem);
                    } else {
                        try {
                            if (MapSubSupc.get(RatePlanCharge.numberX) != null) {
                                SubscriptionLineItem.SupercedingSLI__r = new SubscriptionLineItem__c(
                                    ZuoraId__c = MapSubSupc.get(RatePlanCharge.numberX)
                                );
                            }
                        } catch (exception e) {}
                        if (SubscriptionLineItem.ZuoraId__c != null) Tree.SubscriptionLineItemsOld.add(SubscriptionLineItem);
                    }
                }
            }
            SubscriptionNumber++;
        }
        
        
        if (!test.IsRunningTest()) {
            upsert Tree.SubscriptionsNew ZuoraId__c;
            upsert Tree.SubscriptionsOld ZuoraId__c;
            upsert Tree.SubscriptionLineItemsNew ZuoraId__c;
            upsert Tree.SubscriptionLineItemsOld ZuoraId__c;
            try {
                update Tree.QuoteLineItems.values();
            }catch(exception e){}
        }
    }
    
    public static void UpsertSubscriptions(String payload) {
        ZObj.FetchSubscriptionPackages FetchSubscriptions = 
            (ZObj.FetchSubscriptionPackages)JSON.deserialize(payload, ZObj.FetchSubscriptionPackages.class);
        List<Subscription__c> Subscriptions = new List<Subscription__c>();
        //List<SubscriptionLineItem__c> origSLIs = new List<SubscriptionLineItem__c>();
        List<SubscriptionLineItem__c> SLIs = new List<SubscriptionLineItem__c>();
        for (ZObj.FetchSubscriptionPackage Sub : FetchSubscriptions.Subscriptions) {
            Subscriptions.add(new Subscription__c(
                Account__r = new Account(ZuoraId__c = Sub.accountId),
                ContractEffectiveDate__c = Sub.contractEffectiveDate,
                CustomerAcceptanceDate__c = Sub.customerAcceptanceDate,
                InvoiceOwner__r = new Account(ZuoraId__c = Sub.invoiceOwnerAccountId),
                InvoiceSeparately__c = Sub.invoiceSeparately,
                Name = Sub.subscriptionNumber,
                ServiceActivationDate__c = Sub.serviceActivationDate,
                Status__c = Sub.status,
                SubscriptionStartDate__c = Sub.subscriptionStartDate,
                TermEndDate__c = Sub.termEndDate,
                TermStartDate__c = Sub.termStartDate,
                TermType__c = Sub.termType,
                ZuoraId__c = Sub.id
            ));
            for (ZObj.FetchSubscriptionRatePlans SubRP : Sub.ratePlans) {
                if (SubRP.lastChangeType != 'Remove') {
                    for (ZObj.FetchSubscriptionRatePlanCharges SubRPC : SubRP.ratePlanCharges) {
                        SubscriptionLineItem__c SLI = new SubscriptionLineItem__c(
                            Description__c = SubRPC.description,
                            DMRC__c = SubRPC.dmrc,
                            DTCV__c = SubRPC.dtcv,
                            EffectiveEndDate__c = SubRPC.effectiveEndDate,
                            EffectiveStartDate__c = SubRPC.effectiveStartDate,
                            MRR__c = SubRPC.mrr,
                            Name = SubRPC.numberX,
                            Price__c = SubRPC.price,
                            Product__r = new Product2(ZuoraId__c = SubRPC.productRatePlanChargeId),
                            QuoteLineItem__c = SubRPC.test1xxc,
                            Quantity__c = SubRPC.quantity,
                            Subscription__r = new Subscription__c(ZuoraId__c = Sub.id),
                            TCV__c = SubRPC.tcv,
                            Version__c = SubRPC.version,
                            ZuoraId__c = SubRPC.id,
                            ZuoraSubCategoryId__c = SubRP.id
                        );
                        //if (SubRPC.originalChargeId != SubRPC.id) {
                        //    SLI.OriginalSLI__r = new SubscriptionLineItem__c(ZuoraId__c = SubRPC.originalChargeId);
                        SLIs.add(SLI);
                        //} else {
                        //    origSLIs.add(SLI);
                        //}
                    }
                }
            }
        }
        upsert Subscriptions ZuoraId__c;
        //upsert origSLIs ZuoraId__c;
        upsert SLIs ZuoraId__c;
    }
    
    public static void InvoiceCollectionUpsert(InvCombinedZObjCollection InvoiceCollection, Boolean SuppressTriggeredEmail) {
        
        InvoiceCollectionUpsert(InvoiceCollection, SuppressTriggeredEmail, true);
    }
    
    public static void InvoiceCollectionUpsert(
        InvCombinedZObjCollection InvoiceCollection, 
        Boolean SuppressTriggeredEmail,
        Boolean RunQMZ
    ) {
        
        List<Invoice__c> Invoices = new List<Invoice__c>();
        List<InvoiceLineItem__c> InvoiceLineItems = new List<InvoiceLineItem__c>();
        Set<String> AccountZIds = new Set<String>();
        Set<String> AccountZIdsOK = new Set<String>();
        Set<String> InvoiceZIds = new Set<String>();
        Set<String> InvoiceZIdsOK = new Set<String>();
        Set<String> SubscriZIds = new Set<String>();
        Set<String> SubscriZIdsOK = new Set<String>();
        Map<String,String> CurrencyMap = new Map<String,String>();
        if (InvoiceCollection.FetchInvoices != null) {
            for (ZObj.FetchInvoice Invoice : InvoiceCollection.FetchInvoices) {
                AccountZIds.add(Invoice.AccountId);
            }
            for (Account a : [SELECT Id, ZuoraId__c, CurrencyIsoCode FROM Account WHERE ZuoraId__c IN :AccountZIds]) {
                AccountZIdsOK.add(a.ZuoraId__c);
                CurrencyMap.put(a.ZuoraId__c,a.CurrencyIsoCode);
            }
            for (ZObj.FetchInvoice Invoice : InvoiceCollection.FetchInvoices) {
                if (AccountZIdsOK.contains(Invoice.AccountId)) {
                    Invoices.add(new Invoice__c(
                        Account__r = new Account(ZuoraId__c = Invoice.AccountId),
                        CurrencyIsoCode = CurrencyMap.get(Invoice.AccountId),
                        ZuoraId__c = Invoice.Id,
                        Name = Invoice.InvoiceNumber,
                        AdjustmentAmount__c = Invoice.AdjustmentAmount,
                        Amount__c = Invoice.Amount,
                        AmountWithoutTax__c = Invoice.AmountWithoutTax,
                        Balance__c = Invoice.Balance,
                        CreditBalanceAdjustmentAmount__c = Invoice.CreditBalanceAdjustmentAmount,
                        DueDate__c = Invoice.DueDate,
                        IncludesHardware__c = Invoice.IncludesHardwarexxc == 't',
                        IncludesOneTime__c = Invoice.IncludesOneTime,
                        IncludesRecurring__c = Invoice.IncludesRecurring,
                        IncludesUsage__c = Invoice.IncludesUsage,
                        InvoiceDate__c = Invoice.InvoiceDate,
                        PaymentAmount__c = Invoice.PaymentAmount,
                        PostedDate__c = Invoice.PostedDate,
                        RefundAmount__c = Invoice.RefundAmount,
                        Status__c = Invoice.Status,
                        SuppressTriggeredEmail__c = SuppressTriggeredEmail,
                        TargetDate__c = Invoice.TargetDate,
                        TaxAmount__c = Invoice.TaxAmount,
                        TaxExemptAmount__c = Invoice.TaxExemptAmount,
                        UpdatedDate__c = Invoice.UpdatedDate,
                        VAT_ref__c = Invoice.VAT_refxxc
                    ));
                    InvoiceZIdsOK.add(Invoice.Id);
                }
            }
        }
        if (InvoiceCollection.FetchInvoiceItems != null) {
            for (ZObj.FetchInvoiceItem InvoiceItem : InvoiceCollection.FetchInvoiceItems) {
                InvoiceZIds.add(InvoiceItem.InvoiceId);
                SubscriZIds.add(InvoiceItem.ChargeId);
            }
            for (Invoice__c a : [SELECT Id, ZuoraId__c, CurrencyIsoCode FROM Invoice__c WHERE ZuoraId__c IN :InvoiceZIds]) {
                InvoiceZIdsOK.add(a.ZuoraId__c);
                CurrencyMap.put(a.ZuoraId__c, a.CurrencyIsoCode);
            }
            for (SubscriptionLineItem__c a : [SELECT Id, ZuoraId__c FROM SubscriptionLineItem__c WHERE ZuoraId__c IN :SubscriZIds]) {
                SubscriZIdsOK.add(a.ZuoraId__c);
            }
            for (ZObj.FetchInvoiceItem InvoiceItem : InvoiceCollection.FetchInvoiceItems) {
                if (
                    InvoiceZIdsOK.contains(InvoiceItem.InvoiceId) 
                    && (
                        SubscriZIdsOK.contains(InvoiceItem.ChargeId)
                        || SuppressTriggeredEmail
                    )
                ) {
                    InvoiceLineItem__c ILI = new InvoiceLineItem__c(
                        Invoice__r = new Invoice__c(ZuoraId__c = InvoiceItem.InvoiceId),
                        CurrencyIsoCode = CurrencyMap.get(InvoiceItem.InvoiceId),
                        ZuoraId__c = InvoiceItem.Id,
                        ChargeAmount__c = InvoiceItem.ChargeAmount,
                        ChargeName__c = InvoiceItem.ChargeName,
                        ServiceStartDate__c = InvoiceItem.ServiceStartDate,
                        ServiceEndDate__c = InvoiceItem.ServiceEndDate,
                        Quantity__c = InvoiceItem.Quantity,
                        TaxAmount__c = InvoiceItem.TaxAmount,
                        TaxExemptAmount__c = InvoiceItem.TaxExemptAmount
                    );
                    try{ ILI.UnitPrice__c = InvoiceItem.ChargeAmount / InvoiceItem.Quantity; } catch(exception e){}
                    if (!SuppressTriggeredEmail) ILI.SubscriptionLineItem__r = new SubscriptionLineItem__c(ZuoraId__c = InvoiceItem.ChargeId);
                    InvoiceLineItems.add(ILI);
                }
            }
        }
        List<QueryMoreZuora__c> QMZs = new List<QueryMoreZuora__c>();
        for (QueryLocator QueryLocator : InvoiceCollection.queryLocators) {
            QMZs.add(new QueryMoreZuora__c(
                Object__c = QueryLocator.objectName,
                queryLocator__c = QueryLocator.queryLocator
            ));
        }
        upsert Invoices ZuoraId__c;
        upsert InvoiceLineItems ZuoraId__c;
        insert QMZs;
        if (QMZs.size() > 0) {
            if (RunQMZ) EnqueueNextQMZ();
        }
    }
    
    public static AccountZObjCollection FetchAccountCollection(Date UpdatedDate) {
        
        List<QueryLocator> queryLocators = new List<QueryLocator>();
        ZObj.FetchAccounts FetchedAccounts = (ZObj.FetchAccounts)JSON.deserialize(
            cleanJSONResponse(ZuoraAPIManager.callZuoraAPI(
                'action/query',
                'POST',
                JSON.serialize(new QueryAccountsRequest(UpdatedDate))
            )),
            ZObj.FetchAccounts.class
        );
        if (!FetchedAccounts.done) queryLocators.add(new QueryLocator('Account',FetchedAccounts.queryLocator));
        return new AccountZObjCollection(FetchedAccounts.records, queryLocators);
    }
    
    public static AccountZObjCollection FetchAccountCollection(List<String> AccountZIds) {
        
        List<QueryLocator> queryLocators = new List<QueryLocator>();
        ZObj.FetchAccounts FetchedAccounts = (ZObj.FetchAccounts)JSON.deserialize(
            cleanJSONResponse(ZuoraAPIManager.callZuoraAPI(
                'action/query',
                'POST',
                JSON.serialize(new QueryAccountsRequest(AccountZIds))
            )),
            ZObj.FetchAccounts.class
        );
        return new AccountZObjCollection(FetchedAccounts.records, queryLocators);
    }
    
    public static AccountZObjCollection FetchAccountCollection(String ObjectName, String QueryLocator) {
        
        List<QueryLocator> queryLocators = new List<QueryLocator>();
        ZObj.FetchAccounts FetchedAccounts = new ZObj.FetchAccounts();
        if (ObjectName == 'Account') {
            FetchedAccounts = (ZObj.FetchAccounts)JSON.deserialize(
                cleanJSONResponse(ZuoraAPIManager.callZuoraAPI(
                    'action/queryMore',
                    'POST',
                    JSON.serialize(new QueryLocator(QueryLocator))
                )),
                ZObj.FetchAccounts.class
            );
            if (!FetchedAccounts.done) queryLocators.add(new QueryLocator('Account',FetchedAccounts.queryLocator));
        }
        return new AccountZObjCollection(FetchedAccounts.records, queryLocators);
    }
    
    public static AccountZObjCollection FetchAccountCollection() {
        
        List<QueryLocator> queryLocators = new List<QueryLocator>();
        ZObj.FetchAccounts FetchedAccounts = (ZObj.FetchAccounts)JSON.deserialize(
            cleanJSONResponse(ZuoraAPIManager.callZuoraAPI(
                'action/query',
                'POST',
                JSON.serialize(new QueryAccountsRequest())
            )),
            ZObj.FetchAccounts.class
        );
        if (!FetchedAccounts.done) queryLocators.add(new QueryLocator('Account',FetchedAccounts.queryLocator));
        return new AccountZObjCollection(FetchedAccounts.records, queryLocators);
    }
    
    @future(callout=true)
    public static void AccountFetch() {
        Date UpdatedDate = Date.today().addDays(-2);
        AccountCollectionUpsert(FetchAccountCollection(UpdatedDate));
    }
    
    public static void AccountCollectionUpsert(AccountZObjCollection AccountCollection) {
        
        AccountCollectionUpsert(AccountCollection, true);
    }
    
    public static void AccountCollectionUpsert(
        AccountZObjCollection AccountCollection,
        Boolean RunQMZ
    ) {
        List<Account> Accounts = new List<Account>();
        Set<String> AccountZIds = new Set<String>();
        Set<String> AccountZIdsOK = new Set<String>();
        Set<String> PmtMtdZIds = new Set<String>();
        Set<String> PmtMtdZIdsOK = new Set<String>();
        if (AccountCollection.FetchAccounts != null) {
            for (ZObj.FetchAccount Account : AccountCollection.FetchAccounts) {
                AccountZIds.add(Account.Id);
                PmtMtdZIds.add(Account.DefaultPaymentMethodId);
            }
            for (Account a : [SELECT Id, ZuoraId__c FROM Account WHERE ZuoraId__c IN :AccountZIds]) {
                AccountZIdsOK.add(a.ZuoraId__c);
            }
            for (PaymentMethod__c p : [SELECT Id, ZuoraId__c FROM PaymentMethod__c WHERE ZuoraId__c IN :PmtMtdZIds]) {
                PmtMtdZIdsOK.add(p.ZuoraId__c);
            }
            for (ZObj.FetchAccount Account : AccountCollection.FetchAccounts) {
                if (AccountZIdsOK.contains(Account.Id)) {
                    Account NewAcc = new Account(
                        ZuoraId__c = Account.Id,
                        Account_Balance_2__c = Account.Balance,
                        AutoPayUncheckedReason__c = Account.AutoPayUncheckedReasonxxc,
                        Batch__c = Account.Batch,
                        BillCycleDay__c = Account.BillCycleDay,
                        Credit_Balance__c = Account.CreditBalance,
                        PaymentGateway__c = Account.PaymentGateway,
                        PaymentTerm__c = Account.PaymentTerm,
                        ZuoraStatus__c = Account.Status,
                        TaxExemptCertificateID__c = Account.TaxExemptCertificateID,
                        TaxExemptCertificateType__c = Account.TaxExemptCertificateType,
                        TaxExemptEffectiveDate__c = Account.TaxExemptEffectiveDate,
                        TaxExemptExpirationDate__c = Account.TaxExemptExpirationDate,
                        //TaxExemptStatus__c = Account.TaxExemptStatus,
                        Outstanding_Invoice_Amount_2__c = Account.TotalInvoiceBalance,
                        VATNumber__c = Account.VATId,
                        LegalCompanyName__c = Account.LegalCompanyNamexxc,
                        Tax_Exempt_Reason__c = Account.Tax_Exempt_Reasonxxc
                    );
                    if (Account.AutoPay != null) NewAcc.AutoPay__c = Account.AutoPay;
                    if (PmtMtdZIdsOK.contains(Account.DefaultPaymentMethodId)) {
                        NewAcc.DefaultPaymentMethod__r = new PaymentMethod__c(ZuoraId__c = Account.DefaultPaymentMethodId);
                    }
                    Accounts.add(NewAcc);
                }
            }
        }
        List<QueryMoreZuora__c> QMZs = new List<QueryMoreZuora__c>();
        for (QueryLocator QueryLocator : AccountCollection.queryLocators) {
            QMZs.add(new QueryMoreZuora__c(
                Object__c = QueryLocator.objectName,
                queryLocator__c = QueryLocator.queryLocator
            ));
        }
        ZuoraUpsert('Account', Accounts, QMZs, RunQMZ);
        //upsert Accounts ZuoraId__c;
        //insert QMZs;
        //if (RunQMZ) EnqueueNextQMZ();
    }
    
    public static InvoiceZObjCollection FetchInvoiceCollection(Date UpdatedDate) {
        
        List<QueryLocator> queryLocators = new List<QueryLocator>();
        ZObj.FetchInvoices FetchedInvoices = (ZObj.FetchInvoices)JSON.deserialize(
            cleanJSONResponse(ZuoraAPIManager.callZuoraAPI(
                'action/query',
                'POST',
                JSON.serialize(new QueryInvoicesRequest(UpdatedDate))
            )),
            ZObj.FetchInvoices.class
        );
        if (!FetchedInvoices.done) queryLocators.add(new QueryLocator('Invoice__c',FetchedInvoices.queryLocator));
        return new InvoiceZObjCollection(FetchedInvoices.records, queryLocators);
    }
    
    public static InvoiceZObjCollection FetchInvoiceCollection(List<String> AccountZIds) {
        
        List<QueryLocator> queryLocators = new List<QueryLocator>();
        ZObj.FetchInvoices FetchedInvoices = (ZObj.FetchInvoices)JSON.deserialize(
            cleanJSONResponse(ZuoraAPIManager.callZuoraAPI(
                'action/query',
                'POST',
                JSON.serialize(new QueryInvoicesRequest(AccountZIds))
            )),
            ZObj.FetchInvoices.class
        );
        return new InvoiceZObjCollection(FetchedInvoices.records, queryLocators);
    }
    
    public static InvoiceZObjCollection FetchInvoiceCollection(List<String> AccountZIds, Date UpdatedDate) {
        
        List<QueryLocator> queryLocators = new List<QueryLocator>();
        ZObj.FetchInvoices FetchedInvoices = (ZObj.FetchInvoices)JSON.deserialize(
            cleanJSONResponse(ZuoraAPIManager.callZuoraAPI(
                'action/query', 'POST',
                JSON.serialize(new QueryInvoicesRequest(AccountZIds, UpdatedDate))
            )),
            ZObj.FetchInvoices.class
        );
        return new InvoiceZObjCollection(FetchedInvoices.records, queryLocators);
    }
    
    public static InvoiceZObjCollection FetchInvoiceCollection(String ObjectName, String QueryLocator) {
        
        List<QueryLocator> queryLocators = new List<QueryLocator>();
        ZObj.FetchInvoices FetchedInvoices = new ZObj.FetchInvoices();
        if (ObjectName == 'Invoice__c') {
            FetchedInvoices = (ZObj.FetchInvoices)JSON.deserialize(
                cleanJSONResponse(ZuoraAPIManager.callZuoraAPI(
                    'action/queryMore',
                    'POST',
                    JSON.serialize(new QueryLocator(QueryLocator))
                )),
                ZObj.FetchInvoices.class
            );
            if (!FetchedInvoices.done) queryLocators.add(new QueryLocator('Invoice__c',FetchedInvoices.queryLocator));
        }
        return new InvoiceZObjCollection(FetchedInvoices.records, queryLocators);
    }
    
    public static InvoiceZObjCollection FetchInvoiceCollection() {
        
        List<QueryLocator> queryLocators = new List<QueryLocator>();
        ZObj.FetchInvoices FetchedInvoices = (ZObj.FetchInvoices)JSON.deserialize(
            cleanJSONResponse(ZuoraAPIManager.callZuoraAPI(
                'action/query',
                'POST',
                JSON.serialize(new QueryInvoicesRequest())
            )),
            ZObj.FetchInvoices.class
        );
        if (!FetchedInvoices.done) queryLocators.add(new QueryLocator('Invoice__c',FetchedInvoices.queryLocator));
        return new InvoiceZObjCollection(FetchedInvoices.records, queryLocators);
    }
    
    public static void InvoiceCollectionUpsert(InvoiceZObjCollection InvoiceCollection) {
        
        InvoiceCollectionUpsert(InvoiceCollection, true);
    }
    
    public static void InvoiceCollectionUpsert(
        InvoiceZObjCollection InvoiceCollection,
        Boolean RunQMZ
    ) {
        InvoiceCollectionUpsert(InvoiceCollection, RunQMZ, false);
    }
    
    public static void InvoiceCollectionUpsert(
        InvoiceZObjCollection InvoiceCollection,
        Boolean RunQMZ,
        Boolean IncludeLargeAccounts
    ) {
        List<Invoice__c> Invoices = new List<Invoice__c>();
        Set<String> AccountZIds = new Set<String>();
        Set<String> AccountZIdsOK = new Set<String>();
        Map<String,String> CurrencyMap = new Map<String,String>();
        if (InvoiceCollection.FetchInvoices != null) {
            for (ZObj.FetchInvoice Invoice : InvoiceCollection.FetchInvoices) {
                AccountZIds.add(Invoice.AccountId);
            }
            for (Account a : [SELECT Id, ZuoraId__c, CurrencyIsoCode, Invoice_Count__c FROM Account WHERE ZuoraId__c IN :AccountZIds]) {
                if(a.Invoice_Count__c < 200 || IncludeLargeAccounts) AccountZIdsOK.add(a.ZuoraId__c);
                CurrencyMap.put(a.ZuoraId__c, a.CurrencyIsoCode);
            }
            for (ZObj.FetchInvoice Invoice : InvoiceCollection.FetchInvoices) {
                if (AccountZIdsOK.contains(Invoice.AccountId)) {
                    Invoices.add(new Invoice__c(
                        Account__r = new Account(ZuoraId__c = Invoice.AccountId),
                        CurrencyIsoCode = CurrencyMap.get(Invoice.AccountId),
                        ZuoraId__c = Invoice.Id,
                        Name = Invoice.InvoiceNumber,
                        AdjustmentAmount__c = Invoice.AdjustmentAmount,
                        Amount__c = Invoice.Amount,
                        AmountWithoutTax__c = Invoice.AmountWithoutTax,
                        Balance__c = Invoice.Balance,
                        CreditBalanceAdjustmentAmount__c = Invoice.CreditBalanceAdjustmentAmount,
                        DueDate__c = Invoice.DueDate,
                        IncludesHardware__c = Invoice.IncludesHardwarexxc == 't',
                        IncludesOneTime__c = Invoice.IncludesOneTime,
                        IncludesRecurring__c = Invoice.IncludesRecurring,
                        IncludesUsage__c = Invoice.IncludesUsage,
                        InvoiceDate__c = Invoice.InvoiceDate,
                        PaymentAmount__c = Invoice.PaymentAmount,
                        PostedDate__c = Invoice.PostedDate,
                        RefundAmount__c = Invoice.RefundAmount,
                        Status__c = Invoice.Status,
                        SuppressTriggeredEmail__c = true,
                        TargetDate__c = Invoice.TargetDate,
                        TaxAmount__c = Invoice.TaxAmount,
                        TaxExemptAmount__c = Invoice.TaxExemptAmount,
                        UpdatedDate__c = Invoice.UpdatedDate,
                        VAT_ref__c = Invoice.VAT_refxxc
                    ));
                }
            }
        }
        List<QueryMoreZuora__c> QMZs = new List<QueryMoreZuora__c>();
        for (QueryLocator QueryLocator : InvoiceCollection.queryLocators) {
            QMZs.add(new QueryMoreZuora__c(
                Object__c = QueryLocator.objectName,
                queryLocator__c = QueryLocator.queryLocator
            ));
        }
        ZuoraUpsert('Invoice__c', Invoices, QMZs, RunQMZ);
        //upsert Invoices ZuoraId__c;
        //insert QMZs;
        //if (RunQMZ) EnqueueNextQMZ();
    }
    
    public static InvItemZObjCollection FetchInvItemCollection(Date UpdatedDate) {
        
        List<QueryLocator> queryLocators = new List<QueryLocator>();
        ZObj.FetchInvoiceItems FetchedInvoiceItems = (ZObj.FetchInvoiceItems)JSON.deserialize(
            cleanJSONResponse(ZuoraAPIManager.callZuoraAPI(
                'action/query',
                'POST',
                JSON.serialize(new QueryInvoiceItemsRequest(UpdatedDate))
            )),
            ZObj.FetchInvoiceItems.class
        );
        if (!FetchedInvoiceItems.done) queryLocators.add(new QueryLocator('InvoiceLineItem__c',FetchedInvoiceItems.queryLocator));
        return new InvItemZObjCollection(FetchedInvoiceItems.records, queryLocators);
    }
    
    public static InvItemZObjCollection FetchInvItemCollection(List<String> InvoiceZIds) {
        
        List<QueryLocator> queryLocators = new List<QueryLocator>();
        ZObj.FetchInvoiceItems FetchedInvoiceItems = (ZObj.FetchInvoiceItems)JSON.deserialize(
            cleanJSONResponse(ZuoraAPIManager.callZuoraAPI(
                'action/query',
                'POST',
                JSON.serialize(new QueryInvoiceItemsRequest(InvoiceZIds))
            )),
            ZObj.FetchInvoiceItems.class
        );
        return new InvItemZObjCollection(FetchedInvoiceItems.records, queryLocators);
    }
    
    public static InvItemZObjCollection FetchInvItemCollection(String ObjectName, String QueryLocator) {
        
        List<QueryLocator> queryLocators = new List<QueryLocator>();
        ZObj.FetchInvoiceItems FetchedInvoiceItems = new ZObj.FetchInvoiceItems();
        if (ObjectName == 'InvoiceLineItem__c') {
            FetchedInvoiceItems = (ZObj.FetchInvoiceItems)JSON.deserialize(
                cleanJSONResponse(ZuoraAPIManager.callZuoraAPI(
                    'action/queryMore',
                    'POST',
                    JSON.serialize(new QueryLocator(QueryLocator))
                )),
                ZObj.FetchInvoiceItems.class
            );
            if (!FetchedInvoiceItems.done) queryLocators.add(new QueryLocator('InvoiceLineItem__c',FetchedInvoiceItems.queryLocator));
        }
        return new InvItemZObjCollection(FetchedInvoiceItems.records, queryLocators);
    }
    
    public static InvItemZObjCollection FetchInvItemCollection() {
        
        List<QueryLocator> queryLocators = new List<QueryLocator>();
        ZObj.FetchInvoiceItems FetchedInvoiceItems = (ZObj.FetchInvoiceItems)JSON.deserialize(
            cleanJSONResponse(ZuoraAPIManager.callZuoraAPI(
                'action/query',
                'POST',
                JSON.serialize(new QueryInvoiceItemsRequest())
            )),
            ZObj.FetchInvoiceItems.class
        );
        if (!FetchedInvoiceItems.done) queryLocators.add(new QueryLocator('InvoiceLineItem__c',FetchedInvoiceItems.queryLocator));
        return new InvItemZObjCollection(FetchedInvoiceItems.records, queryLocators);
    }
    
    public static void InvItemCollectionUpsert(InvItemZObjCollection InvItemCollection) {
        
        InvItemCollectionUpsert(InvItemCollection, true);
    }
    
    public static void InvItemCollectionUpsert(
        InvItemZObjCollection InvItemCollection,
        Boolean RunQMZ
    ) {
        
        List<InvoiceLineItem__c> InvoiceLineItems = new List<InvoiceLineItem__c>();
        Set<String> InvoiceZIds = new Set<String>();
        Set<String> InvoiceZIdsOK = new Set<String>();
        Set<String> SubscriZIds = new Set<String>();
        Set<String> SubscriZIdsOK = new Set<String>();
        Map<String,String> CurrencyMap = new Map<String,String>();
        if (InvItemCollection.FetchInvItems != null) {
            for (ZObj.FetchInvoiceItem InvoiceItem : InvItemCollection.FetchInvItems) {
                InvoiceZIds.add(InvoiceItem.InvoiceId);
                SubscriZIds.add(InvoiceItem.ChargeId);
            }
            for (Invoice__c a : [SELECT Id, ZuoraId__c, CurrencyIsoCode FROM Invoice__c WHERE ZuoraId__c IN :InvoiceZIds]) {
                InvoiceZIdsOK.add(a.ZuoraId__c);
                CurrencyMap.put(a.ZuoraId__c, a.CurrencyIsoCode);
            }
            for (SubscriptionLineItem__c a : [SELECT Id, ZuoraId__c FROM SubscriptionLineItem__c WHERE ZuoraId__c IN :SubscriZIds]) {
                SubscriZIdsOK.add(a.ZuoraId__c);
            }
            for (ZObj.FetchInvoiceItem InvoiceItem : InvItemCollection.FetchInvItems) {
                if (InvoiceZIdsOK.contains(InvoiceItem.InvoiceId)) {
                    InvoiceLineItem__c ILI = new InvoiceLineItem__c(
                        Invoice__r = new Invoice__c(ZuoraId__c = InvoiceItem.InvoiceId),
                        CurrencyIsoCode = CurrencyMap.get(InvoiceItem.InvoiceId),
                        ZuoraId__c = InvoiceItem.Id,
                        ChargeAmount__c = InvoiceItem.ChargeAmount,
                        ChargeName__c = InvoiceItem.ChargeName,
                        Quantity__c = InvoiceItem.Quantity,
                        ServiceStartDate__c = InvoiceItem.ServiceStartDate,
                        ServiceEndDate__c = InvoiceItem.ServiceEndDate,
                        TaxAmount__c = InvoiceItem.TaxAmount,
                        TaxExemptAmount__c = InvoiceItem.TaxExemptAmount
                    );
                    try{ ILI.UnitPrice__c = InvoiceItem.ChargeAmount / InvoiceItem.Quantity; } catch(exception e){}
                    if (SubscriZIdsOK.contains(InvoiceItem.ChargeId)) {
                        ILI.SubscriptionLineItem__r = new SubscriptionLineItem__c(ZuoraId__c = InvoiceItem.ChargeId);
                    }
                    InvoiceLineItems.add(ILI);
                }
            }
        }
        List<QueryMoreZuora__c> QMZs = new List<QueryMoreZuora__c>();
        for (QueryLocator QueryLocator : InvItemCollection.queryLocators) {
            QMZs.add(new QueryMoreZuora__c(
                Object__c = QueryLocator.objectName,
                queryLocator__c = QueryLocator.queryLocator
            ));
        }
        ZuoraUpsert('InvoiceLineItem__c', InvoiceLineItems, QMZs, RunQMZ);
        //upsert InvoiceLineItems ZuoraId__c;
        //insert QMZs;
        //if (RunQMZ) EnqueueNextQMZ();
    }
    
    public static AmendmentZObjCollection FetchAmendmentCollection(Date UpdatedDate) {
        
        List<QueryLocator> queryLocators = new List<QueryLocator>();
        ZObj.FetchAmendments FetchedAmendments = (ZObj.FetchAmendments)JSON.deserialize(
            cleanJSONResponse(ZuoraAPIManager.callZuoraAPI(
                'action/query', 'POST',
                JSON.serialize(new QueryAmendmentsRequest(UpdatedDate))
            )),
            ZObj.FetchAmendments.class
        );
        if (!FetchedAmendments.done) queryLocators.add(new QueryLocator('Amendment__c',FetchedAmendments.queryLocator));
        return new AmendmentZObjCollection(FetchedAmendments.records, queryLocators);
    }
    
    public static AmendmentZObjCollection FetchAmendmentCollection(String ObjectName, String QueryLocator) {
        
        List<QueryLocator> queryLocators = new List<QueryLocator>();
        ZObj.FetchAmendments FetchedAmendments = new ZObj.FetchAmendments();
        if (ObjectName == 'Amendment__c') {
            FetchedAmendments = (ZObj.FetchAmendments)JSON.deserialize(
                cleanJSONResponse(ZuoraAPIManager.callZuoraAPI(
                    'action/queryMore',
                    'POST',
                    JSON.serialize(new QueryLocator(QueryLocator))
                )),
                ZObj.FetchAmendments.class
            );
            if (!FetchedAmendments.done) queryLocators.add(new QueryLocator('Amendment__c',FetchedAmendments.queryLocator));
        }
        return new AmendmentZObjCollection(FetchedAmendments.records, queryLocators);
    }
    
    public static AmendmentZObjCollection FetchAmendmentCollection() {
        
        List<QueryLocator> queryLocators = new List<QueryLocator>();
        ZObj.FetchAmendments FetchedAmendments = (ZObj.FetchAmendments)JSON.deserialize(
            cleanJSONResponse(ZuoraAPIManager.callZuoraAPI(
                'action/query', 'POST',
                JSON.serialize(new QueryAmendmentsRequest())
            )),
            ZObj.FetchAmendments.class
        );
        if (!FetchedAmendments.done) queryLocators.add(new QueryLocator('Amendment__c',FetchedAmendments.queryLocator));
        return new AmendmentZObjCollection(FetchedAmendments.records, queryLocators);
    }
    
    public static void AmendmentCollectionUpsert(AmendmentZObjCollection AmendmentCollection) {
        
        AmendmentCollectionUpsert(AmendmentCollection, true);
    }
    
    public static void AmendmentCollectionUpsert(
        AmendmentZObjCollection AmendmentCollection,
        Boolean RunQMZ
    ) {
        
        Map<String, Date> AmendmentMap = new Map<String, Date>();
        if (AmendmentCollection.FetchAmendments != null) {
            for (ZObj.FetchAmendment Amendment : AmendmentCollection.FetchAmendments) {
                AmendmentMap.put(Amendment.SubscriptionId, Amendment.EffectiveDate);
            }
        }
        List<Subscription__c> Subscriptions = [
            SELECT Id, AmendmentEffectiveDate__c, ZuoraId__c 
            FROM Subscription__c
            WHERE ZuoraId__c IN :AmendmentMap.keySet()
        ];
        for (Subscription__c Subscription : Subscriptions) {
            Subscription.AmendmentEffectiveDate__c = AmendmentMap.get(Subscription.ZuoraId__c);
        }
        List<QueryMoreZuora__c> QMZs = new List<QueryMoreZuora__c>();
        for (QueryLocator QueryLocator : AmendmentCollection.queryLocators) {
            QMZs.add(new QueryMoreZuora__c(
                Object__c = QueryLocator.objectName,
                queryLocator__c = QueryLocator.queryLocator
            ));
        }
        update Subscriptions;
        insert QMZs;
        if (RunQMZ) EnqueueNextQMZ();
    }

    public static SubscriptionZObjCollection FetchSubscriptionCollection(Date UpdatedDate) {
        
        List<QueryLocator> queryLocators = new List<QueryLocator>();
        ZObj.FetchSubscriptions FetchedSubscriptions = (ZObj.FetchSubscriptions)JSON.deserialize(
            cleanJSONResponse(ZuoraAPIManager.callZuoraAPI(
                'action/query',
                'POST',
                JSON.serialize(new QuerySubscriptionsRequest(UpdatedDate))
            )),
            ZObj.FetchSubscriptions.class
        );
        if (!FetchedSubscriptions.done) queryLocators.add(new QueryLocator('Subscription__c',FetchedSubscriptions.queryLocator));
        return new SubscriptionZObjCollection(FetchedSubscriptions.records, queryLocators);
    }
    
    public static SubscriptionZObjCollection FetchSubscriptionCollection(List<String> AccountZIds) {
        
        List<QueryLocator> queryLocators = new List<QueryLocator>();
        ZObj.FetchSubscriptions FetchedSubscriptions = (ZObj.FetchSubscriptions)JSON.deserialize(
            cleanJSONResponse(ZuoraAPIManager.callZuoraAPI(
                'action/query',
                'POST',
                JSON.serialize(new QuerySubscriptionsRequest(AccountZIds))
            )),
            ZObj.FetchSubscriptions.class
        );
        return new SubscriptionZObjCollection(FetchedSubscriptions.records, queryLocators);
    }
    
    public static SubscriptionZObjCollection FetchSubscriptionCollection(String ObjectName, String QueryLocator) {
        
        List<QueryLocator> queryLocators = new List<QueryLocator>();
        ZObj.FetchSubscriptions FetchedSubscriptions = new ZObj.FetchSubscriptions();
        if (ObjectName == 'Subscription__c') {
            FetchedSubscriptions = (ZObj.FetchSubscriptions)JSON.deserialize(
                cleanJSONResponse(ZuoraAPIManager.callZuoraAPI(
                    'action/queryMore',
                    'POST',
                    JSON.serialize(new QueryLocator(QueryLocator))
                )),
                ZObj.FetchSubscriptions.class
            );
            if (!FetchedSubscriptions.done) queryLocators.add(new QueryLocator('Subscription__c',FetchedSubscriptions.queryLocator));
        }
        return new SubscriptionZObjCollection(FetchedSubscriptions.records, queryLocators);
    }
    
    public static SubscriptionZObjCollection FetchSubscriptionCollection() {
        
        List<QueryLocator> queryLocators = new List<QueryLocator>();
        ZObj.FetchSubscriptions FetchedSubscriptions = (ZObj.FetchSubscriptions)JSON.deserialize(
            cleanJSONResponse(ZuoraAPIManager.callZuoraAPI(
                'action/query',
                'POST',
                JSON.serialize(new QuerySubscriptionsRequest())
            )),
            ZObj.FetchSubscriptions.class
        );
        if (!FetchedSubscriptions.done) queryLocators.add(new QueryLocator('Subscription__c',FetchedSubscriptions.queryLocator));
        return new SubscriptionZObjCollection(FetchedSubscriptions.records, queryLocators);
    }
    
    public static void SubscriptionCollectionUpsert(SubscriptionZObjCollection SubscriptionCollection) {
        
        SubscriptionCollectionUpsert(SubscriptionCollection, true);
    }
    
    public static void SubscriptionCollectionUpsert(
        SubscriptionZObjCollection SubscriptionCollection,
        Boolean RunQMZ
    ) {
        
        List<Subscription__c> Subscriptions = new List<Subscription__c>();
        Set<String> AccountZIds = new Set<String>();
        Set<String> AccountZIdsOK = new Set<String>();
        Set<String> SubscriptionZIds = new Set<String>();
        Set<String> SubscriptionZIdsCirc = new Set<String>();
        Set<String> SubscriptionZIdsOK = new Set<String>();
        if (SubscriptionCollection.FetchSubscriptions != null) {
            for (ZObj.FetchSubscription Subscription : SubscriptionCollection.FetchSubscriptions) {
                AccountZIds.add(Subscription.AccountId);
                SubscriptionZIdsCirc.add(Subscription.Id);
                if (Subscription.InvoiceOwnerId != null) AccountZIds.add(Subscription.InvoiceOwnerId);
                if (Subscription.OriginalId != null) SubscriptionZIds.add(Subscription.OriginalId);
                if (Subscription.PreviousSubscriptionId != null) SubscriptionZIds.add(Subscription.PreviousSubscriptionId);
            }
            for (Account a : [SELECT Id, ZuoraId__c FROM Account WHERE ZuoraId__c IN :AccountZIds]) {
                AccountZIdsOK.add(a.ZuoraId__c);
            }
            for (Subscription__c s : [SELECT Id, ZuoraId__c FROM Subscription__c WHERE ZuoraId__c IN :SubscriptionZIds]) {
                SubscriptionZIdsOK.add(s.ZuoraId__c);
            }
            for (ZObj.FetchSubscription Subscription : SubscriptionCollection.FetchSubscriptions) {
                if (AccountZIdsOK.contains(Subscription.AccountId)) {
                    Subscription__c NewSub = new Subscription__c(
                        Account__r = new Account(ZuoraId__c = Subscription.AccountId),
                        ZuoraId__c = Subscription.Id,
                        AutoRenew__c = Subscription.AutoRenew,
                        CancelledDate__c = Subscription.CancelledDate,
                        ContractAcceptanceDate__c = Subscription.ContractAcceptanceDate,
                        ContractEffectiveDate__c = Subscription.ContractEffectiveDate,
                        CurrentTerm__c = Subscription.CurrentTerm,
                        CurrentTermPeriodType__c = Subscription.CurrentTermPeriodType,
                        IsInvoiceSeparate__c = Subscription.IsInvoiceSeparate,
                        Name = Subscription.Name,
                        RenewalSetting__c = Subscription.RenewalSetting,
                        RenewalTerm__c = Subscription.RenewalTerm,
                        RenewalTermPeriodType__c = Subscription.RenewalTermPeriodType,
                        ServiceActivationDate__c = Subscription.ServiceActivationDate,
                        Status__c = Subscription.Status,
                        SubscriptionEndDate__c = Subscription.SubscriptionEndDate,
                        SubscriptionStartDate__c = Subscription.SubscriptionStartDate,
                        TermEndDate__c = Subscription.TermEndDate,
                        TermStartDate__c = Subscription.TermStartDate,
                        TermType__c = Subscription.TermType,
                        Version__c = Subscription.Version
                    );
                    if (Subscription.InvoiceOwnerId != null && AccountZIdsOK.contains(Subscription.InvoiceOwnerId)) {
                        NewSub.InvoiceOwner__r = new Account(ZuoraId__c = Subscription.InvoiceOwnerId);
                    }
                    if (
                        Subscription.OriginalId != null 
                        && SubscriptionZIdsOK.contains(Subscription.OriginalId)
                        && !SubscriptionZIdsCirc.contains(Subscription.OriginalId)
                    ) {
                        NewSub.OriginalSubscription__r = new Subscription__c(ZuoraId__c = Subscription.OriginalId);
                    }
                    if (
                        Subscription.PreviousSubscriptionId != null 
                        && SubscriptionZIdsOK.contains(Subscription.PreviousSubscriptionId)
                        && !SubscriptionZIdsCirc.contains(Subscription.PreviousSubscriptionId)
                    ) {
                        NewSub.PreviousSubscription__r = new Subscription__c(ZuoraId__c = Subscription.PreviousSubscriptionId);
                    }
                    Subscriptions.add(NewSub);
                }
            }
        }
        List<QueryMoreZuora__c> QMZs = new List<QueryMoreZuora__c>();
        for (QueryLocator QueryLocator : SubscriptionCollection.queryLocators) {
            QMZs.add(new QueryMoreZuora__c(
                Object__c = QueryLocator.objectName,
                queryLocator__c = QueryLocator.queryLocator
            ));
        }
        ZuoraUpsert('Subscription__c', Subscriptions, QMZs, RunQMZ);
        //upsert Subscriptions ZuoraId__c;
        //insert QMZs;
        //if (RunQMZ) EnqueueNextQMZ();
    }
    
    public static SLIMapZObjCollection FetchSLIMapCollection(Date UpdatedDate) {
        
        List<QueryLocator> queryLocators = new List<QueryLocator>();
        ZObj.FetchSLIMap FetchedSLIMap = (ZObj.FetchSLIMap)JSON.deserialize(
            cleanJSONResponse(ZuoraAPIManager.callZuoraAPI(
                'action/query',
                'POST',
                JSON.serialize(new QuerySLIMapRequest(UpdatedDate))
            )),
            ZObj.FetchSLIMap.class
        );
        if (!FetchedSLIMap.done) queryLocators.add(new QueryLocator('SLIMap__c',FetchedSLIMap.queryLocator));
        return new SLIMapZObjCollection(FetchedSLIMap.records, queryLocators);
    }
    
    public static SLIMapZObjCollection FetchSLIMapCollection(List<String> SubscriptionZIds) {
        
        List<QueryLocator> queryLocators = new List<QueryLocator>();
        ZObj.FetchSLIMap FetchedSLIMap = (ZObj.FetchSLIMap)JSON.deserialize(
            cleanJSONResponse(ZuoraAPIManager.callZuoraAPI(
                'action/query',
                'POST',
                JSON.serialize(new QuerySLIMapRequest(SubscriptionZIds))
            )),
            ZObj.FetchSLIMap.class
        );
        return new SLIMapZObjCollection(FetchedSLIMap.records, queryLocators);
    }
    
    public static SLIMapZObjCollection FetchSLIMapCollection(String ObjectName, String QueryLocator) {
        
        List<QueryLocator> queryLocators = new List<QueryLocator>();
        ZObj.FetchSLIMap FetchedSLIMap = new ZObj.FetchSLIMap();
        if (ObjectName == 'SLIMap__c') {
            FetchedSLIMap = (ZObj.FetchSLIMap)JSON.deserialize(
                cleanJSONResponse(ZuoraAPIManager.callZuoraAPI(
                    'action/queryMore',
                    'POST',
                    JSON.serialize(new QueryLocator(QueryLocator))
                )),
                ZObj.FetchSLIMap.class
            );
            if (!FetchedSLIMap.done) queryLocators.add(new QueryLocator('SLIMap__c',FetchedSLIMap.queryLocator));
        }
        return new SLIMapZObjCollection(FetchedSLIMap.records, queryLocators);
    }
    
    public static SLIMapZObjCollection FetchSLIMapCollection() {
        
        List<QueryLocator> queryLocators = new List<QueryLocator>();
        ZObj.FetchSLIMap FetchedSLIMap = (ZObj.FetchSLIMap)JSON.deserialize(
            cleanJSONResponse(ZuoraAPIManager.callZuoraAPI(
                'action/query',
                'POST',
                JSON.serialize(new QuerySLIMapRequest())
            )),
            ZObj.FetchSLIMap.class
        );
        if (!FetchedSLIMap.done) queryLocators.add(new QueryLocator('SLIMap__c',FetchedSLIMap.queryLocator));
        return new SLIMapZObjCollection(FetchedSLIMap.records, queryLocators);
    }
    
    public static void SLIMapCollectionUpsert(SLIMapZObjCollection SLIMapCollection) {
        
        SLIMapCollectionUpsert(SLIMapCollection, true);
    }
    
    public static void SLIMapCollectionUpsert(
        SLIMapZObjCollection SLIMapCollection,
        Boolean RunQMZ
    ) {
        
        List<SLIMap__c> SLIMap = new List<SLIMap__c>();
        if (SLIMapCollection.FetchSLIMap != null) {
            for (ZObj.FetchSLIMapping SLIMapping : SLIMapCollection.FetchSLIMap) {
                SLIMap.add(new SLIMap__c(
                    RatePlanId__c = SLIMapping.Id,
                    SubscriptionId__c = SLIMapping.SubscriptionId
                ));
            }
        }
        List<QueryMoreZuora__c> QMZs = new List<QueryMoreZuora__c>();
        for (QueryLocator QueryLocator : SLIMapCollection.queryLocators) {
            QMZs.add(new QueryMoreZuora__c(
                Object__c = QueryLocator.objectName,
                queryLocator__c = QueryLocator.queryLocator
            ));
        }
        upsert SLIMap RatePlanId__c;
        insert QMZs;
        if (RunQMZ) EnqueueNextQMZ();
    }
    
    public static SubItemZObjCollection FetchSubItemCollection(Date UpdatedDate, Decimal DiscountType) {
        
        List<QueryLocator> queryLocators = new List<QueryLocator>();
        ZObj.FetchSubItems FetchedSubItems = (ZObj.FetchSubItems)JSON.deserialize(
            cleanJSONResponse(ZuoraAPIManager.callZuoraAPI(
                'action/query', 'POST',
                JSON.serialize(new QuerySubItemsRequest(UpdatedDate, DiscountType))
            )),
            ZObj.FetchSubItems.class
        );
        if (!FetchedSubItems.done) queryLocators.add(new QueryLocator('SubscriptionLineItem__c',FetchedSubItems.queryLocator,DiscountType));
        return new SubItemZObjCollection(FetchedSubItems.records, queryLocators);
    }
    
    public static SubItemZObjCollection FetchSubItemCollection(List<String> RatePlanZIds, Decimal DiscountType) {
        
        system.debug(json.serialize(RatePlanZIds));
        List<QueryLocator> queryLocators = new List<QueryLocator>();
        ZObj.FetchSubItems FetchedSubItems = (ZObj.FetchSubItems)JSON.deserialize(
            cleanJSONResponse(ZuoraAPIManager.callZuoraAPI(
                'action/query',
                'POST',
                JSON.serialize(new QuerySubItemsRequest(RatePlanZIds, DiscountType))
            )),
            ZObj.FetchSubItems.class
        );
        return new SubItemZObjCollection(FetchedSubItems.records, queryLocators);
    }
    
    public static SubItemZObjCollection FetchSubItemCollection(String ObjectName, String QueryLocator, Decimal DiscountType) {
        
        List<QueryLocator> queryLocators = new List<QueryLocator>();
        ZObj.FetchSubItems FetchedSubItems = new ZObj.FetchSubItems();
        if (ObjectName == 'SubscriptionLineItem__c') {
            FetchedSubItems = (ZObj.FetchSubItems)JSON.deserialize(
                cleanJSONResponse(ZuoraAPIManager.callZuoraAPI(
                    'action/queryMore', 'POST',
                    JSON.serialize(new QueryLocator(QueryLocator))
                )),
                ZObj.FetchSubItems.class
            );
            if (!FetchedSubItems.done) queryLocators.add(new QueryLocator('SubscriptionLineItem__c',FetchedSubItems.queryLocator,DiscountType));
        }
        return new SubItemZObjCollection(FetchedSubItems.records, queryLocators);
    }
    
    public static SubItemZObjCollection FetchSubItemCollection(Decimal DiscountType) {
        
        List<QueryLocator> queryLocators = new List<QueryLocator>();
        ZObj.FetchSubItems FetchedSubItems = (ZObj.FetchSubItems)JSON.deserialize(
            cleanJSONResponse(ZuoraAPIManager.callZuoraAPI(
                'action/query', 'POST',
                JSON.serialize(new QuerySubItemsRequest(DiscountType))
            )),
            ZObj.FetchSubItems.class
        );
        if (!FetchedSubItems.done) queryLocators.add(new QueryLocator('SubscriptionLineItem__c',FetchedSubItems.queryLocator,DiscountType));
        return new SubItemZObjCollection(FetchedSubItems.records, queryLocators);
    }
    
    public static void SubItemCollectionUpsert(SubItemZObjCollection SubItemCollection, Decimal DiscountType) {
        
        SubItemCollectionUpsert(SubItemCollection, DiscountType, true);
    }
    
    public static void SubItemCollectionUpsert(
        SubItemZObjCollection SubItemCollection,
        Decimal DiscountType,
        Boolean RunQMZ
    ) {
        List<SubscriptionLineItem__c> SubItems = new List<SubscriptionLineItem__c>();
        Set<String> SubscriptionZIds = new Set<String>();
        Set<String> SubscriptionZIdsOK = new Set<String>();
        Set<String> SubItemZIds = new Set<String>();
        Set<String> SubItemZIdsCirc = new Set<String>();
        Set<String> SubItemZIdsOK = new Set<String>();
        Set<String> QuoteItemIds = new Set<String>();
        Set<String> QuoteItemIdsOK = new Set<String>();
        Set<String> RatePlanIds = new Set<String>();
        Map<String, String> SLIMap = new Map<String, String>();
        if (SubItemCollection.FetchSubItems != null) {
            for (ZObj.FetchSubItem SubItem : SubItemCollection.FetchSubItems) {
                RatePlanIds.add(SubItem.RatePlanId);
                SubItemZIdsCirc.add(SubItem.Id);
                if (SubItem.OriginalId != null){
                    SubItemZIds.add(SubItem.OriginalId);
                    QuoteItemIds.add(SubItem.Test1xxc);
                }
            }
            for (SLIMap__c SLIMapRecord : [SELECT RatePlanId__c, SubscriptionId__c FROM SLIMap__c WHERE RatePlanId__c IN :RatePlanIds]) {
                SLIMap.put(SLIMapRecord.RatePlanId__c, SLIMapRecord.SubscriptionId__c);
                SubscriptionZIds.add(SLIMapRecord.SubscriptionId__c);
            }
            for (Subscription__c s : [SELECT Id, ZuoraId__c FROM Subscription__c WHERE ZuoraId__c IN :SubscriptionZIds]) {
                SubscriptionZIdsOK.add(s.ZuoraId__c);
            }
            for (SubscriptionLineItem__c si : [SELECT Id, ZuoraId__c FROM SubscriptionLineItem__c WHERE ZuoraId__c IN :SubItemZIds]) {
                SubItemZIdsOK.add(si.ZuoraId__c);
            }
            for (QuoteLineItem qli : [SELECT Id FROM QuoteLineItem WHERE Id IN :QuoteItemIds]) {
                QuoteItemIdsOK.add(qli.Id);
            }
            for (ZObj.FetchSubItem SubItem : SubItemCollection.FetchSubItems) {
                String SubscriptionZId = SLIMap.get(SubItem.RatePlanId);
                if (SubscriptionZId != null && SubscriptionZIdsOK.contains(SubscriptionZId)) {
                    SubscriptionLineItem__c NewSLI = new SubscriptionLineItem__c(
                        Subscription__r = new Subscription__c(ZuoraId__c = SubscriptionZId),
                        ZuoraId__c = SubItem.Id,
                        ZuoraSubCategoryId__c = SubItem.RatePlanId,
                        Description__c = SubItem.Description,
                        DMRC__c = SubItem.DMRC,
                        DTCV__c = SubItem.DTCV,
                        EffectiveEndDate__c = SubItem.EffectiveEndDate,
                        EffectiveStartDate__c = SubItem.EffectiveStartDate,
                        BillingPeriodAlignment__c = SubItem.BillingPeriodAlignment,
                        IsLastSegment__c = true,
                        MRR__c = SubItem.MRR,
                        Name = SubItem.ChargeNumber,
                        Product__r = new Product2(ZuoraId__c = SubItem.ProductRatePlanChargeId),
                        Quantity__c = SubItem.Quantity,
                        TCV__c = SubItem.TCV,
                        VAT_ref__c = SubItem.VAT_refxxc,
                        Version__c = SubItem.Version
                    );
                    if (DiscountType == 1) {
                        NewSLI.Price__c = SubItem.DiscountAmount * -1;
                    } else if (DiscountType == 0) {
                        NewSLI.Price__c = SubItem.Price;
                    }
                    if (
                        SubItemZIdsOK.contains(SubItem.OriginalId) 
                        && !SubItemZIdsCirc.contains(SubItem.OriginalId)
                    ) {
                        NewSLI.OriginalSLI__r = new SubscriptionLineItem__c(ZuoraId__c = SubItem.OriginalId);
                    }
                    if (QuoteItemIdsOK.contains(SubItem.Test1xxc)) {
                        NewSLI.QuoteLineItem__c = SubItem.Test1xxc;
                    }
                    if (SubItem.IsLastSegment != null) {
                        NewSLI.IsLastSegment__c = SubItem.IsLastSegment;
                        if (SubItem.IsLastSegment) SubItems.add(NewSLI);
                    } else {
                        SubItems.add(NewSLI);
                    }
                }
            }
        }
        List<QueryMoreZuora__c> QMZs = new List<QueryMoreZuora__c>();
        for (QueryLocator QueryLocator : SubItemCollection.queryLocators) {
            QMZs.add(new QueryMoreZuora__c(
                Object__c = QueryLocator.objectName,
                queryLocator__c = QueryLocator.queryLocator,
                IntParam__c = QueryLocator.intParam
            ));
        }
        ZuoraUpsert('SubscriptionLineItem__c', SubItems, QMZs, RunQMZ);
        //upsert SubItems ZuoraId__c;
        //insert QMZs;
        //if (RunQMZ) EnqueueNextQMZ();
    }
    
    public static PaymentZObjCollection FetchPaymentCollection(Date UpdatedDate) {
        
        List<QueryLocator> queryLocators = new List<QueryLocator>();
        ZObj.FetchPayments FetchedPayments = (ZObj.FetchPayments)JSON.deserialize(
            cleanJSONResponse(ZuoraAPIManager.callZuoraAPI(
                'action/query',
                'POST',
                JSON.serialize(new QueryPaymentsRequest(UpdatedDate))
            )),
            ZObj.FetchPayments.class
        );
        if (!FetchedPayments.done) queryLocators.add(new QueryLocator('Payment__c',FetchedPayments.queryLocator));
        return new PaymentZObjCollection(FetchedPayments.records, queryLocators);
    }
    
    public static PaymentZObjCollection FetchPaymentCollection(List<String> AccountZIds) {
        
        List<QueryLocator> queryLocators = new List<QueryLocator>();
        ZObj.FetchPayments FetchedPayments = (ZObj.FetchPayments)JSON.deserialize(
            cleanJSONResponse(ZuoraAPIManager.callZuoraAPI(
                'action/query',
                'POST',
                JSON.serialize(new QueryPaymentsRequest(AccountZIds))
            )),
            ZObj.FetchPayments.class
        );
        return new PaymentZObjCollection(FetchedPayments.records, queryLocators);
    }
    
    public static PaymentZObjCollection FetchPaymentCollection(String ObjectName, String QueryLocator) {
        
        List<QueryLocator> queryLocators = new List<QueryLocator>();
        ZObj.FetchPayments FetchedPayments = new ZObj.FetchPayments();
        if (ObjectName == 'Payment__c') {
            FetchedPayments = (ZObj.FetchPayments)JSON.deserialize(
                cleanJSONResponse(ZuoraAPIManager.callZuoraAPI(
                    'action/queryMore',
                    'POST',
                    JSON.serialize(new QueryLocator(QueryLocator))
                )),
                ZObj.FetchPayments.class
            );
            if (!FetchedPayments.done) queryLocators.add(new QueryLocator('Payment__c',FetchedPayments.queryLocator));
        }
        return new PaymentZObjCollection(FetchedPayments.records, queryLocators);
    }
    
    public static PaymentZObjCollection FetchPaymentCollection() {
        
        List<QueryLocator> queryLocators = new List<QueryLocator>();
        ZObj.FetchPayments FetchedPayments = (ZObj.FetchPayments)JSON.deserialize(
            cleanJSONResponse(ZuoraAPIManager.callZuoraAPI(
                'action/query',
                'POST',
                JSON.serialize(new QueryPaymentsRequest())
            )),
            ZObj.FetchPayments.class
        );
        if (!FetchedPayments.done) queryLocators.add(new QueryLocator('Payment__c',FetchedPayments.queryLocator));
        return new PaymentZObjCollection(FetchedPayments.records, queryLocators);
    }
    
    public static void PaymentCollectionUpsert(PaymentZObjCollection PaymentCollection) {
        
        PaymentCollectionUpsert(PaymentCollection, true);
    }
    
    public static void PaymentCollectionUpsert(
        PaymentZObjCollection PaymentCollection,
        Boolean RunQMZ
    ) {
        
        List<Payment__c> Payments = new List<Payment__c>();
        Set<String> AccountZIds = new Set<String>();
        Set<String> AccountZIdsOK = new Set<String>();
        Map<String,String> CurrencyMap = new Map<String,String>();
        if (PaymentCollection.FetchPayments != null) {
            for (ZObj.FetchPayment Payment : PaymentCollection.FetchPayments) {
                AccountZIds.add(Payment.AccountId);
            }
            for (Account a : [SELECT Id, ZuoraId__c, CurrencyIsoCode FROM Account WHERE ZuoraId__c IN :AccountZIds]) {
                AccountZIdsOK.add(a.ZuoraId__c);
                CurrencyMap.put(a.ZuoraId__c, a.CurrencyIsoCode);
            }
            for (ZObj.FetchPayment Payment : PaymentCollection.FetchPayments) {
                if (AccountZIdsOK.contains(Payment.AccountId)) {
                    Payments.add(new Payment__c(
                        Account__r = new Account(ZuoraId__c = Payment.AccountId),
                        CurrencyIsoCode = CurrencyMap.get(Payment.AccountId),
                        ZuoraId__c = Payment.Id,
                        Name = Payment.PaymentNumber,
                        AccountingCode__c = Payment.AccountingCode,
                        Amount__c = Payment.Amount,
                        AppliedAmount__c = Payment.AppliedInvoiceAmount,
                        AppliedCreditBalanceAmount__c = Payment.AppliedCreditBalanceAmount,
                        AuthTransactionId__c = Payment.AuthTransactionId,
                        BankIdentificationNumber__c = Payment.BankIdentificationNumber,
                        CancelledOn__c = Payment.CancelledOn,
                        Comment__c = Payment.Comment,
                        CreditBalanceAmount__c = Payment.CreditBalanceAmount,
                        //CurrencyIsoCode = Payment.CurrencyX,
                        EffectiveDate__c = Payment.EffectiveDate,
                        GatewayResponse__c = Payment.GatewayResponse,
                        GatewayResponseCode__c = Payment.GatewayResponseCode,
                        GatewayState__c = Payment.GatewayState,
                        CreatedDate__c = Payment.CreatedDate,
                        RefundAmount__c = Payment.RefundAmount,
                        SettledOn__c = Payment.SettledOn,
                        Status__c = Payment.Status,
                        SubmittedOn__c = Payment.SubmittedOn,
                        //Success__c = Payment.Success,
                        Type__c = Payment.Type,
                        UnappliedAmount__c = Payment.UnappliedAmount
                    ));
                }
            }
        }
        List<QueryMoreZuora__c> QMZs = new List<QueryMoreZuora__c>();
        for (QueryLocator QueryLocator : PaymentCollection.queryLocators) {
            QMZs.add(new QueryMoreZuora__c(
                Object__c = QueryLocator.objectName,
                queryLocator__c = QueryLocator.queryLocator
            ));
        }
        ZuoraUpsert('Payment__c', Payments, QMZs, RunQMZ);
        //upsert Payments ZuoraId__c;
        //insert QMZs;
        //if (RunQMZ) EnqueueNextQMZ();
    }
    
    public static InvPmtZObjCollection FetchInvPmtCollection(Date InvPmtCreatedDate) {
        
        List<QueryLocator> queryLocators = new List<QueryLocator>();
        ZObj.FetchInvPmts FetchedInvPmts = (ZObj.FetchInvPmts)JSON.deserialize(
            cleanJSONResponse(ZuoraAPIManager.callZuoraAPI(
                'action/query',
                'POST',
                JSON.serialize(new QueryInvPmtsRequest(InvPmtCreatedDate))
            )),
            ZObj.FetchInvPmts.class
        );
        if (!FetchedInvPmts.done) queryLocators.add(new QueryLocator('InvoicePayment__c',FetchedInvPmts.queryLocator));
        return new InvPmtZObjCollection(FetchedInvPmts.records, queryLocators);
    }
    
    public static InvPmtZObjCollection FetchInvPmtCollection(List<String> InvoiceZIds) {
        
        List<QueryLocator> queryLocators = new List<QueryLocator>();
        ZObj.FetchInvPmts FetchedInvPmts = (ZObj.FetchInvPmts)JSON.deserialize(
            cleanJSONResponse(ZuoraAPIManager.callZuoraAPI(
                'action/query', 'POST',
                JSON.serialize(new QueryInvPmtsRequest(InvoiceZIds))
            )),
            ZObj.FetchInvPmts.class
        );
        return new InvPmtZObjCollection(FetchedInvPmts.records, queryLocators);
    }
    
    public static InvPmtZObjCollection FetchInvPmtCollection(String ObjectName, String QueryLocator) {
        
        List<QueryLocator> queryLocators = new List<QueryLocator>();
        ZObj.FetchInvPmts FetchedInvPmts = new ZObj.FetchInvPmts();
        if (ObjectName == 'InvoicePayment__c') {
            FetchedInvPmts = (ZObj.FetchInvPmts)JSON.deserialize(
                cleanJSONResponse(ZuoraAPIManager.callZuoraAPI(
                    'action/queryMore',
                    'POST',
                    JSON.serialize(new QueryLocator(QueryLocator))
                )),
                ZObj.FetchInvPmts.class
            );
            if (!FetchedInvPmts.done) queryLocators.add(new QueryLocator('InvoicePayment__c',FetchedInvPmts.queryLocator));
        }
        return new InvPmtZObjCollection(FetchedInvPmts.records, queryLocators);
    }
    
    public static InvPmtZObjCollection FetchInvPmtCollection() {
        
        List<QueryLocator> queryLocators = new List<QueryLocator>();
        ZObj.FetchInvPmts FetchedInvPmts = (ZObj.FetchInvPmts)JSON.deserialize(
            cleanJSONResponse(ZuoraAPIManager.callZuoraAPI(
                'action/query',
                'POST',
                JSON.serialize(new QueryInvPmtsRequest())
            )),
            ZObj.FetchInvPmts.class
        );
        if (!FetchedInvPmts.done) queryLocators.add(new QueryLocator('InvoicePayment__c',FetchedInvPmts.queryLocator));
        return new InvPmtZObjCollection(FetchedInvPmts.records, queryLocators);
    }
    
    public static void InvPmtCollectionUpsert(InvPmtZObjCollection InvPmtCollection) {
        
        InvPmtCollectionUpsert(InvPmtCollection, true);
    }
    
    public static void InvPmtCollectionUpsert(
        InvPmtZObjCollection InvPmtCollection,
        Boolean RunQMZ
    ) {
        
        List<InvoicePayment__c> InvPmts = new List<InvoicePayment__c>();
        Set<String> InvoiceZIds = new Set<String>();
        Set<String> InvoiceZIdsOK = new Set<String>();
        Set<String> PaymentZIds = new Set<String>();
        Set<String> PaymentZIdsOK = new Set<String>();
        Map<String,String> CurrencyMap = new Map<String,String>();
        if (InvPmtCollection.FetchInvPmts != null) {
            for (ZObj.FetchInvPmt InvPmt : InvPmtCollection.FetchInvPmts) {
                InvoiceZIds.add(InvPmt.InvoiceId);
                PaymentZIds.add(InvPmt.PaymentId);
            }
            for (Invoice__c i : [SELECT Id, ZuoraId__c FROM Invoice__c WHERE ZuoraId__c IN :InvoiceZIds]) {
                InvoiceZIdsOK.add(i.ZuoraId__c);
            }
            for (Payment__c p : [SELECT Id, ZuoraId__c, CurrencyIsoCode FROM Payment__c WHERE ZuoraId__c IN :PaymentZIds]) {
                PaymentZIdsOK.add(p.ZuoraId__c);
                CurrencyMap.put(p.ZuoraId__c, p.CurrencyIsoCode);
            }
            for (ZObj.FetchInvPmt InvPmt : InvPmtCollection.FetchInvPmts) {
                if (InvoiceZIdsOK.contains(InvPmt.InvoiceId) && PaymentZIdsOK.contains(InvPmt.PaymentId)) {
                    InvPmts.add(new InvoicePayment__c(
                        Invoice__r = new Invoice__c(ZuoraId__c = InvPmt.InvoiceId),
                        Payment__r = new Payment__c(ZuoraId__c = InvPmt.PaymentId),
                        CurrencyIsoCode = CurrencyMap.get(InvPmt.PaymentId),
                        ZuoraId__c = InvPmt.Id,
                        Amount__c = InvPmt.Amount,
                        RefundAmount__c = InvPmt.RefundAmount
                    ));
                }
            }
        }
        List<QueryMoreZuora__c> QMZs = new List<QueryMoreZuora__c>();
        for (QueryLocator QueryLocator : InvPmtCollection.queryLocators) {
            QMZs.add(new QueryMoreZuora__c(
                Object__c = QueryLocator.objectName,
                queryLocator__c = QueryLocator.queryLocator
            ));
        }
        ZuoraUpsert('InvoicePayment__c', InvPmts, QMZs, RunQMZ);
        //upsert InvPmts ZuoraId__c;
        //insert QMZs;
        //if (RunQMZ) EnqueueNextQMZ();
    }
    
    public static RefundZObjCollection FetchRefundCollection(Date RefCreatedDate) {
        
        List<QueryLocator> queryLocators = new List<QueryLocator>();
        ZObj.FetchRefunds FetchedRefunds = (ZObj.FetchRefunds)JSON.deserialize(
            cleanJSONResponse(ZuoraAPIManager.callZuoraAPI(
                'action/query',
                'POST',
                JSON.serialize(new QueryRefundsRequest(RefCreatedDate))
            )),
            ZObj.FetchRefunds.class
        );
        if (!FetchedRefunds.done) queryLocators.add(new QueryLocator('Refund__c',FetchedRefunds.queryLocator));
        return new RefundZObjCollection(FetchedRefunds.records, queryLocators);
    }
    
    public static RefundZObjCollection FetchRefundCollection(List<String> AccountZIds) {
        
        List<QueryLocator> queryLocators = new List<QueryLocator>();
        ZObj.FetchRefunds FetchedRefunds = (ZObj.FetchRefunds)JSON.deserialize(
            cleanJSONResponse(ZuoraAPIManager.callZuoraAPI(
                'action/query',
                'POST',
                JSON.serialize(new QueryRefundsRequest(AccountZIds))
            )),
            ZObj.FetchRefunds.class
        );
        return new RefundZObjCollection(FetchedRefunds.records, queryLocators);
    }
    
    public static RefundZObjCollection FetchRefundCollection(String ObjectName, String QueryLocator) {
        
        List<QueryLocator> queryLocators = new List<QueryLocator>();
        ZObj.FetchRefunds FetchedRefunds = new ZObj.FetchRefunds();
        if (ObjectName == 'Refund__c') {
            FetchedRefunds = (ZObj.FetchRefunds)JSON.deserialize(
                cleanJSONResponse(ZuoraAPIManager.callZuoraAPI(
                    'action/queryMore',
                    'POST',
                    JSON.serialize(new QueryLocator(QueryLocator))
                )),
                ZObj.FetchRefunds.class
            );
            if (!FetchedRefunds.done) queryLocators.add(new QueryLocator('Refund__c',FetchedRefunds.queryLocator));
        }
        return new RefundZObjCollection(FetchedRefunds.records, queryLocators);
    }
    
    public static RefundZObjCollection FetchRefundCollection() {
        
        List<QueryLocator> queryLocators = new List<QueryLocator>();
        ZObj.FetchRefunds FetchedRefunds = (ZObj.FetchRefunds)JSON.deserialize(
            cleanJSONResponse(ZuoraAPIManager.callZuoraAPI(
                'action/query',
                'POST',
                JSON.serialize(new QueryRefundsRequest())
            )),
            ZObj.FetchRefunds.class
        );
        if (!FetchedRefunds.done) queryLocators.add(new QueryLocator('Refund__c',FetchedRefunds.queryLocator));
        return new RefundZObjCollection(FetchedRefunds.records, queryLocators);
    }
    
    public static void RefundCollectionUpsert(RefundZObjCollection RefundCollection) {
        
        RefundCollectionUpsert(RefundCollection, true);
    }
    
    public static void RefundCollectionUpsert(
        RefundZObjCollection RefundCollection,
        Boolean RunQMZ
    ) {
        
        List<Refund__c> Refunds = new List<Refund__c>();
        Set<String> AccountZIds = new Set<String>();
        Set<String> AccountZIdsOK = new Set<String>();
        Set<String> PaymentZIds = new Set<String>();
        Set<String> PaymentZIdsOK = new Set<String>();
        Map<String,String> CurrencyMap = new Map<String,String>();
        if (RefundCollection.FetchRefunds != null) {
            for (ZObj.FetchRefund Refund : RefundCollection.FetchRefunds) {
                AccountZIds.add(Refund.AccountId);
                PaymentZIds.add(Refund.PaymentId);
            }
            for (Account a : [SELECT Id, ZuoraId__c, CurrencyIsoCode FROM Account WHERE ZuoraId__c IN :AccountZIds]) {
                AccountZIdsOK.add(a.ZuoraId__c);
                CurrencyMap.put(a.ZuoraId__c, a.CurrencyIsoCode);
            }
            for (Payment__c p : [SELECT Id, ZuoraId__c FROM Payment__c WHERE ZuoraId__c IN :PaymentZIds]) {
                PaymentZIdsOK.add(p.ZuoraId__c);
            }
            for (ZObj.FetchRefund Refund : RefundCollection.FetchRefunds) {
                //if (AccountZIdsOK.contains(Refund.AccountId) && PaymentZIdsOK.contains(Refund.PaymentId)) {
                if (AccountZIdsOK.contains(Refund.AccountId)) {
                    Refunds.add(new Refund__c(
                        Account__r = new Account(ZuoraId__c = Refund.AccountId),
                        CurrencyIsoCode = CurrencyMap.get(Refund.AccountId),
                        //Payment__r = new Payment__c(ZuoraId__c = Refund.PaymentId),
                        ZuoraId__c = Refund.Id,
                        Name = Refund.RefundNumber,
                        Amount__c = Refund.Amount,
                        CancelledOn__c = Refund.CancelledOn,
                        //CurrencyIsoCode = Refund.CurrencyX,
                        GatewayResponse__c = Refund.GatewayResponse,
                        GatewayResponseCode__c = Refund.GatewayResponseCode,
                        GatewayState__c = Refund.GatewayState,
                        RefundDate__c = Refund.RefundDate,
                        SettledOn__c = Refund.SettledOn,
                        Status__c = Refund.Status,
                        Type__c = Refund.Type
                    ));
                }
            }
        }
        List<QueryMoreZuora__c> QMZs = new List<QueryMoreZuora__c>();
        for (QueryLocator QueryLocator : RefundCollection.queryLocators) {
            QMZs.add(new QueryMoreZuora__c(
                Object__c = QueryLocator.objectName,
                queryLocator__c = QueryLocator.queryLocator
            ));
        }
        ZuoraUpsert('Refund__c', Refunds, QMZs, RunQMZ);
        //upsert Refunds ZuoraId__c;
        //insert QMZs;
        //if (RunQMZ) EnqueueNextQMZ();
    }
    
    public static InvRefZObjCollection FetchInvRefCollection(Date InvRefCreatedDate) {
        
        List<QueryLocator> queryLocators = new List<QueryLocator>();
        ZObj.FetchInvRefs FetchedInvRefs = (ZObj.FetchInvRefs)JSON.deserialize(
            cleanJSONResponse(ZuoraAPIManager.callZuoraAPI(
                'action/query',
                'POST',
                JSON.serialize(new QueryInvRefsRequest(InvRefCreatedDate))
            )),
            ZObj.FetchInvRefs.class
        );
        if (!FetchedInvRefs.done) queryLocators.add(new QueryLocator('InvoiceRefund__c',FetchedInvRefs.queryLocator));
        return new InvRefZObjCollection(FetchedInvRefs.records, queryLocators);
    }
    
    public static InvRefZObjCollection FetchInvRefCollection(List<String> InvoiceZIds) {
        
        List<QueryLocator> queryLocators = new List<QueryLocator>();
        ZObj.FetchInvRefs FetchedInvRefs = (ZObj.FetchInvRefs)JSON.deserialize(
            cleanJSONResponse(ZuoraAPIManager.callZuoraAPI(
                'action/query', 'POST',
                JSON.serialize(new QueryInvRefsRequest(InvoiceZIds))
            )),
            ZObj.FetchInvRefs.class
        );
        if (!FetchedInvRefs.done) queryLocators.add(new QueryLocator('InvoiceRefund__c',FetchedInvRefs.queryLocator));
        return new InvRefZObjCollection(FetchedInvRefs.records, queryLocators);
    }
    
    public static InvRefZObjCollection FetchInvRefCollection(String ObjectName, String QueryLocator) {
        
        List<QueryLocator> queryLocators = new List<QueryLocator>();
        ZObj.FetchInvRefs FetchedInvRefs = new ZObj.FetchInvRefs();
        if (ObjectName == 'InvoiceRefund__c') {
            FetchedInvRefs = (ZObj.FetchInvRefs)JSON.deserialize(
                cleanJSONResponse(ZuoraAPIManager.callZuoraAPI(
                    'action/queryMore',
                    'POST',
                    JSON.serialize(new QueryLocator(QueryLocator))
                )),
                ZObj.FetchInvRefs.class
            );
            if (!FetchedInvRefs.done) queryLocators.add(new QueryLocator('InvoiceRefund__c',FetchedInvRefs.queryLocator));
        }
        return new InvRefZObjCollection(FetchedInvRefs.records, queryLocators);
    }
    
    public static InvRefZObjCollection FetchInvRefCollection() {
        
        List<QueryLocator> queryLocators = new List<QueryLocator>();
        ZObj.FetchInvRefs FetchedInvRefs = (ZObj.FetchInvRefs)JSON.deserialize(
            cleanJSONResponse(ZuoraAPIManager.callZuoraAPI(
                'action/query',
                'POST',
                JSON.serialize(new QueryInvRefsRequest())
            )),
            ZObj.FetchInvRefs.class
        );
        if (!FetchedInvRefs.done) queryLocators.add(new QueryLocator('InvoiceRefund__c',FetchedInvRefs.queryLocator));
        return new InvRefZObjCollection(FetchedInvRefs.records, queryLocators);
    }
    
    public static void InvRefCollectionUpsert(InvRefZObjCollection InvRefCollection) {
        
        InvRefCollectionUpsert(InvRefCollection, true);
    }
    
    public static void InvRefCollectionUpsert(
        InvRefZObjCollection InvRefCollection,
        Boolean RunQMZ
    ) {
        
        List<InvoiceRefund__c> InvRefs = new List<InvoiceRefund__c>();
        Set<String> InvoiceZIds = new Set<String>();
        Set<String> InvoiceZIdsOK = new Set<String>();
        Set<String> RefundZIds = new Set<String>();
        Set<String> RefundZIdsOK = new Set<String>();
        Map<String,String> CurrencyMap = new Map<String,String>();
        if (InvRefCollection.FetchInvRefs != null) {
            for (ZObj.FetchInvRef InvRef : InvRefCollection.FetchInvRefs) {
                InvoiceZIds.add(InvRef.InvoiceId);
                RefundZIds.add(InvRef.RefundId);
            }
            for (Invoice__c i : [SELECT Id, ZuoraId__c FROM Invoice__c WHERE ZuoraId__c IN :InvoiceZIds]) {
                InvoiceZIdsOK.add(i.ZuoraId__c);
            }
            for (Refund__c p : [SELECT Id, ZuoraId__c, CurrencyIsoCode FROM Refund__c WHERE ZuoraId__c IN :RefundZIds]) {
                RefundZIdsOK.add(p.ZuoraId__c);
                CurrencyMap.put(p.ZuoraId__c, p.CurrencyIsoCode);
            }
            for (ZObj.FetchInvRef InvRef : InvRefCollection.FetchInvRefs) {
                if (InvoiceZIdsOK.contains(InvRef.InvoiceId) && RefundZIdsOK.contains(InvRef.RefundId)) {
                    InvRefs.add(new InvoiceRefund__c(
                        Invoice__r = new Invoice__c(ZuoraId__c = InvRef.InvoiceId),
                        Refund__r = new Refund__c(ZuoraId__c = InvRef.RefundId),
                        CurrencyIsoCode = CurrencyMap.get(InvRef.RefundId),
                        ZuoraId__c = InvRef.Id,
                        RefundAmount__c = InvRef.RefundAmount
                    ));
                }
            }
        }
        List<QueryMoreZuora__c> QMZs = new List<QueryMoreZuora__c>();
        for (QueryLocator QueryLocator : InvRefCollection.queryLocators) {
            QMZs.add(new QueryMoreZuora__c(
                Object__c = QueryLocator.objectName,
                queryLocator__c = QueryLocator.queryLocator
            ));
        }
        ZuoraUpsert('InvoiceRefund__c', InvRefs, QMZs, RunQMZ);
        //upsert InvRefs ZuoraId__c;
        //insert QMZs;
        //if (RunQMZ) EnqueueNextQMZ();
    }
    
    public static PmtMtdZObjCollection FetchPmtMtdCollection() {
        
        List<QueryLocator> queryLocators = new List<QueryLocator>();
        ZObj.FetchPmtMtds FetchedPmtMtds = (ZObj.FetchPmtMtds)JSON.deserialize(
            cleanJSONResponse(ZuoraAPIManager.callZuoraAPI(
                'action/query',
                'POST',
                JSON.serialize(new QueryPmtMtdsRequest())
            )),
            ZObj.FetchPmtMtds.class
        );
        if (!FetchedPmtMtds.done) queryLocators.add(new QueryLocator('PaymentMethod__c',FetchedPmtMtds.queryLocator));
        return new PmtMtdZObjCollection(FetchedPmtMtds.records, queryLocators);
    }
    
    public static PmtMtdZObjCollection FetchPmtMtdCollection(Date UpdatedDate) {
        
        List<QueryLocator> queryLocators = new List<QueryLocator>();
        ZObj.FetchPmtMtds FetchedPmtMtds = (ZObj.FetchPmtMtds)JSON.deserialize(
            cleanJSONResponse(ZuoraAPIManager.callZuoraAPI(
                'action/query',
                'POST',
                JSON.serialize(new QueryPmtMtdsRequest(UpdatedDate))
            )),
            ZObj.FetchPmtMtds.class
        );
        if (!FetchedPmtMtds.done) queryLocators.add(new QueryLocator('PaymentMethod__c',FetchedPmtMtds.queryLocator));
        return new PmtMtdZObjCollection(FetchedPmtMtds.records, queryLocators);
    }
    
    public static PmtMtdZObjCollection FetchPmtMtdCollection(List<String> AccountZIds) {
        
        List<QueryLocator> queryLocators = new List<QueryLocator>();
        ZObj.FetchPmtMtds FetchedPmtMtds = (ZObj.FetchPmtMtds)JSON.deserialize(
            cleanJSONResponse(ZuoraAPIManager.callZuoraAPI(
                'action/query', 'POST',
                JSON.serialize(new QueryPmtMtdsRequest(AccountZIds))
            )),
            ZObj.FetchPmtMtds.class
        );
        return new PmtMtdZObjCollection(FetchedPmtMtds.records, queryLocators);
    }
    
    public static PmtMtdZObjCollection FetchPmtMtdCollection(String ObjectName, String QueryLocator) {
        
        ZObj.FetchPmtMtds FetchedPmtMtds = new ZObj.FetchPmtMtds();
        List<QueryLocator> queryLocators = new List<QueryLocator>();
        if (ObjectName == 'PaymentMethod__c') {
            FetchedPmtMtds = (ZObj.FetchPmtMtds)JSON.deserialize(
                cleanJSONResponse(ZuoraAPIManager.callZuoraAPI(
                    'action/queryMore',
                    'POST',
                    JSON.serialize(new QueryLocator(QueryLocator))
                )),
                ZObj.FetchPmtMtds.class
            );
            if (!FetchedPmtMtds.done) queryLocators.add(new QueryLocator('PaymentMethod__c',FetchedPmtMtds.queryLocator));
        }
        return new PmtMtdZObjCollection(FetchedPmtMtds.records, queryLocators);
    }
    
    public static void PmtMtdCollectionUpsert(PmtMtdZObjCollection PmtMtdCollection) {
        
        PmtMtdCollectionUpsert(PmtMtdCollection, true);
    }
    
    public static void PmtMtdCollectionUpsert(
        PmtMtdZObjCollection PmtMtdCollection,
        Boolean RunQMZ
    ) {
        
        List<PaymentMethod__c> PmtMtds = new List<PaymentMethod__c>();
        Set<String> AccountZIds = new Set<String>();
        Set<String> AccountZIdsOK = new Set<String>();
        if (PmtMtdCollection.FetchPmtMtds != null) {
            for (ZObj.FetchPmtMtd PmtMtd : PmtMtdCollection.FetchPmtMtds) {
                AccountZIds.add(PmtMtd.AccountId);
            }
            for (Account a : [SELECT Id, ZuoraId__c FROM Account WHERE ZuoraId__c IN :AccountZIds AND ZuoraId__c != null]) {
                AccountZIdsOK.add(a.ZuoraId__c);
            }
            for (ZObj.FetchPmtMtd PmtMtd : PmtMtdCollection.FetchPmtMtds) {
                if (AccountZIdsOK.contains(PmtMtd.AccountId) && PmtMtd.AccountId != null) {
                    PmtMtds.add(new PaymentMethod__c(
                        Account__r = new Account(ZuoraId__c = PmtMtd.AccountId),
                        ZuoraId__c = PmtMtd.Id,
                        Name = PmtMtd.Name,
                        FirstName__c = PmtMtd.FirstName,
                        LastName__c = PmtMtd.LastName,
                        AchAbaCode__c = PmtMtd.AchAbaCode,
                        AchAccountNumberMask__c = PmtMtd.AchAccountNumberMask,
                        AchAccountType__c = PmtMtd.AchAccountType,
                        AchBankName__c = PmtMtd.AchBankName,
                        Active__c = PmtMtd.Active,
                        BankBranchCode__c = PmtMtd.BankBranchCode,
                        BankCheckDigit__c = PmtMtd.BankCheckDigit,
                        BankCode__c = PmtMtd.BankCode,
                        BankIdentificationNumber__c = PmtMtd.BankIdentificationNumber,
                        BankName__c = PmtMtd.BankName,
                        BankTransferAccountName__c = PmtMtd.BankTransferAccountName,
                        BankTransferAccountNumberMask__c = PmtMtd.BankTransferAccountNumberMask,
                        BankTransferAccountType__c = PmtMtd.BankTransferAccountType,
                        BankTransferType__c = PmtMtd.BankTransferType,
                        BusinessIdentificationCode__c = PmtMtd.BusinessIdentificationCode,
                        City__c = PmtMtd.City,
                        Country__c = PmtMtd.Country,
                        CreditCardExpirationMonth__c = PmtMtd.CreditCardExpirationMonth,
                        CreditCardExpirationYear__c = PmtMtd.CreditCardExpirationYear,
                        CreditCardHolderName__c = PmtMtd.CreditCardHolderName,
                        CreditCardMaskNumber__c = PmtMtd.CreditCardMaskNumber,
                        CreditCardType__c = PmtMtd.CreditCardType,
                        IPAddress__c = PmtMtd.IPAddress,
                        LastFailedSaleTransactionDate__c = PmtMtd.LastFailedSaleTransactionDate,
                        LastTransactionDateTime__c = PmtMtd.LastTransactionDateTime,
                        LastTransactionStatus__c = PmtMtd.LastTransactionStatus,
                        PaymentMethodStatus__c = PmtMtd.PaymentMethodStatus,
                        MandateID__c = PmtMtd.MandateID,
                        PaypalBaid__c = PmtMtd.PaypalBaid,
                        PaypalEmail__c = PmtMtd.PaypalEmail,
                        PaypalPreapprovalKey__c = PmtMtd.PaypalPreapprovalKey,
                        PaypalType__c = PmtMtd.PaypalType,
                        Phone__c = PmtMtd.Phone,
                        Type__c = PmtMtd.Type
                    ));
                }
            }
        }
        List<QueryMoreZuora__c> QMZs = new List<QueryMoreZuora__c>();
        for (QueryLocator QueryLocator : PmtMtdCollection.queryLocators) {
            QMZs.add(new QueryMoreZuora__c(
                Object__c = QueryLocator.objectName,
                queryLocator__c = QueryLocator.queryLocator
            ));
        }
        ZuoraUpsert('PaymentMethod__c', PmtMtds, QMZs, RunQMZ);
        //upsert PmtMtds ZuoraId__c;
        //insert QMZs;
        //if (RunQMZ) EnqueueNextQMZ();
    }

    public static CBAZObjCollection FetchCBACollection() {
        
        List<QueryLocator> queryLocators = new List<QueryLocator>();
        ZObj.FetchCBAs FetchedCBAs = (ZObj.FetchCBAs)JSON.deserialize(
            cleanJSONResponse(ZuoraAPIManager.callZuoraAPI(
                'action/query',
                'POST',
                JSON.serialize(new QueryCBAsRequest())
            )),
            ZObj.FetchCBAs.class
        );
        if (!FetchedCBAs.done) queryLocators.add(new QueryLocator('CreditBalanceAdjustment__c',FetchedCBAs.queryLocator));
        return new CBAZObjCollection(FetchedCBAs.records, queryLocators);
    }
    
    public static CBAZObjCollection FetchCBACollection(Date UpdatedDate) {
        
        List<QueryLocator> queryLocators = new List<QueryLocator>();
        ZObj.FetchCBAs FetchedCBAs = (ZObj.FetchCBAs)JSON.deserialize(
            cleanJSONResponse(ZuoraAPIManager.callZuoraAPI(
                'action/query',
                'POST',
                JSON.serialize(new QueryCBAsRequest(UpdatedDate))
            )),
            ZObj.FetchCBAs.class
        );
        if (!FetchedCBAs.done) queryLocators.add(new QueryLocator('CreditBalanceAdjustment__c',FetchedCBAs.queryLocator));
        return new CBAZObjCollection(FetchedCBAs.records, queryLocators);
    }
    
    public static CBAZObjCollection FetchCBACollection(List<String> AccountZIds) {
        
        List<QueryLocator> queryLocators = new List<QueryLocator>();
        ZObj.FetchCBAs FetchedCBAs = (ZObj.FetchCBAs)JSON.deserialize(
            cleanJSONResponse(ZuoraAPIManager.callZuoraAPI(
                'action/query', 'POST',
                JSON.serialize(new QueryCBAsRequest(AccountZIds))
            )),
            ZObj.FetchCBAs.class
        );
        return new CBAZObjCollection(FetchedCBAs.records, queryLocators);
    }
    
    public static CBAZObjCollection FetchCBACollection(String ObjectName, String QueryLocator) {
        
        ZObj.FetchCBAs FetchedCBAs = new ZObj.FetchCBAs();
        List<QueryLocator> queryLocators = new List<QueryLocator>();
        if (ObjectName == 'CreditBalanceAdjustment__c') {
            FetchedCBAs = (ZObj.FetchCBAs)JSON.deserialize(
                cleanJSONResponse(ZuoraAPIManager.callZuoraAPI(
                    'action/queryMore', 'POST',
                    JSON.serialize(new QueryLocator(QueryLocator))
                )),
                ZObj.FetchCBAs.class
            );
            if (!FetchedCBAs.done) queryLocators.add(new QueryLocator('CreditBalanceAdjustment__c',FetchedCBAs.queryLocator));
        }
        return new CBAZObjCollection(FetchedCBAs.records, queryLocators);
    }
    
    public static void CBACollectionUpsert(CBAZObjCollection CBACollection) {
        
        CBACollectionUpsert(CBACollection, true);
    }
    
    public static void CBACollectionUpsert(
        CBAZObjCollection CBACollection,
        Boolean RunQMZ
    ) {
        List<CreditBalanceAdjustment__c> CBAs = new List<CreditBalanceAdjustment__c>();
        Set<String> AccountZIds = new Set<String>();
        Set<String> AccountZIdsOK = new Set<String>();
        Set<String> SourceTransactionZIds = new Set<String>();
        Set<String> InvoiceZIdsOK = new Set<String>();
        Set<String> PaymentZIdsOK = new Set<String>();
        Set<String> RefundZIdsOK = new Set<String>();
        if (CBACollection.FetchCBAs != null) {
            for (ZObj.FetchCBA CBA : CBACollection.FetchCBAs) {
                AccountZIds.add(CBA.AccountId);
                SourceTransactionZIds.add(CBA.SourceTransactionId);
            }
            for (Account a : [SELECT Id, ZuoraId__c FROM Account WHERE ZuoraId__c IN :AccountZIds AND ZuoraId__c != null]) {
                AccountZIdsOK.add(a.ZuoraId__c);
            }
            for (Invoice__c i : [SELECT Id, ZuoraId__c FROM Invoice__c WHERE ZuoraId__c IN :SourceTransactionZIds AND ZuoraId__c != null]) {
                InvoiceZIdsOK.add(i.ZuoraId__c);
            }
            for (Payment__c p : [SELECT Id, ZuoraId__c FROM Payment__c WHERE ZuoraId__c IN :SourceTransactionZIds AND ZuoraId__c != null]) {
                PaymentZIdsOK.add(p.ZuoraId__c);
            }
            for (Refund__c r : [SELECT Id, ZuoraId__c FROM Refund__c WHERE ZuoraId__c IN :SourceTransactionZIds AND ZuoraId__c != null]) {
                RefundZIdsOK.add(r.ZuoraId__c);
            }
            for (ZObj.FetchCBA CBA : CBACollection.FetchCBAs) {
                if (AccountZIdsOK.contains(CBA.AccountId) && CBA.AccountId != null) {
                    CreditBalanceAdjustment__c insCBA = new CreditBalanceAdjustment__c(
                        Account__r = new Account(ZuoraId__c = CBA.AccountId),
                        ZuoraId__c = CBA.Id,
                        Name = CBA.NumberX,
                        AdjustmentDate__c = CBA.AdjustmentDate,
                        Amount__c = CBA.Amount,
                        CancelledOn__c = CBA.CancelledOn,
                        Comment__c = CBA.Comment,
                        Status__c = CBA.Status,
                        SourceTransactionType__c = CBA.SourceTransactionType,
                        Type__c = CBA.Type
                    );
                    if (InvoiceZIdsOK.contains(CBA.SourceTransactionId)) insCBA.Invoice__r = new Invoice__c(ZuoraId__c = CBA.SourceTransactionId);
                    if (PaymentZIdsOK.contains(CBA.SourceTransactionId)) insCBA.Payment__r = new Payment__c(ZuoraId__c = CBA.SourceTransactionId);
                    if (RefundZIdsOK.contains(CBA.SourceTransactionId)) insCBA.Refund__r = new Refund__c(ZuoraId__c = CBA.SourceTransactionId);
                    CBAs.add(insCBA);
                }
            }
        }
        List<QueryMoreZuora__c> QMZs = new List<QueryMoreZuora__c>();
        for (QueryLocator QueryLocator : CBACollection.queryLocators) {
            QMZs.add(new QueryMoreZuora__c(
                Object__c = QueryLocator.objectName,
                queryLocator__c = QueryLocator.queryLocator
            ));
        }
        ZuoraUpsert('CreditBalanceAdjustment__c', CBAs, QMZs, RunQMZ);
        //upsert CBAs ZuoraId__c;
        //insert QMZs;
        //if (RunQMZ) EnqueueNextQMZ();
    }
    
    @future(callout=true)
    public static void InvPmtCollectionFetchUpsert(List<String> InvoiceZIds) {
        InvPmtCollectionUpsert(FetchInvPmtCollection(InvoiceZIds), false);
    }
    
    @future(callout=true)
    public static void InvRefCollectionFetchUpsert(List<String> InvoiceZIds) {
        InvRefCollectionUpsert(FetchInvRefCollection(InvoiceZIds), false);
    }
    
    @future(callout=true)
    public static void PmtMtdCollectionFetchUpsert(List<String> AccountZIds) {

        PmtMtdCollectionUpsert(FetchPmtMtdCollection(AccountZIds), false);
    }
    
    public static void SendUnsentEmailsForAccount(String AccountZId) {
        
        if (!test.isRunningTest()) System.enqueueJob(new EnqueueAccountInvoiceSend(AccountZId));
    }
    
    public static void ProcessNextQMZ() {
        
        List<QueryMoreZuora__c> QMZs = [
            SELECT Id, Object__c, QueryLocator__c, IntParam__c
            FROM QueryMoreZuora__c 
            ORDER BY Object__c, CreatedDate
        ];
        if (QMZs.size() > 0) {
            QueryMoreZuora__c QMZ = QMZs[0];
            if (QMZ.Object__c == 'Account')  {
                AccountZObjCollection col = FetchAccountCollection(
                    QMZ.Object__c, 
                    QMZ.QueryLocator__c
                );
                AccountCollectionUpsert(col);
            }
            if (QMZ.Object__c == 'Invoice__c')  {
                InvoiceZObjCollection col = FetchInvoiceCollection(
                    QMZ.Object__c, 
                    QMZ.QueryLocator__c
                );
                InvoiceCollectionUpsert(col);
            }
            if (QMZ.Object__c == 'InvoiceLineItem__c')  {
                InvItemZObjCollection col = FetchInvItemCollection(
                    QMZ.Object__c, 
                    QMZ.QueryLocator__c
                );
                InvItemCollectionUpsert(col);
            }
            if (QMZ.Object__c == 'Subscription__c')  {
                SubscriptionZObjCollection col = FetchSubscriptionCollection(
                    QMZ.Object__c, 
                    QMZ.QueryLocator__c
                );
                SubscriptionCollectionUpsert(col);
            }
            if (QMZ.Object__c == 'SLIMap__c')  {
                SLIMapZObjCollection col = FetchSLIMapCollection(
                    QMZ.Object__c, 
                    QMZ.QueryLocator__c
                );
                SLIMapCollectionUpsert(col);
            }
            if (QMZ.Object__c == 'SubscriptionLineItem__c')  {
                SubItemZObjCollection col = FetchSubItemCollection(
                    QMZ.Object__c, 
                    QMZ.QueryLocator__c,
                    QMZ.IntParam__c
                );
                SubItemCollectionUpsert(col, QMZ.IntParam__c);
            }
            if (QMZ.Object__c == 'Payment__c')  {
                PaymentZObjCollection col = FetchPaymentCollection(
                    QMZ.Object__c, 
                    QMZ.QueryLocator__c
                );
                PaymentCollectionUpsert(col);
            }
            if (QMZ.Object__c == 'InvoicePayment__c')  {
                InvPmtZObjCollection col = FetchInvPmtCollection(
                    QMZ.Object__c, 
                    QMZ.QueryLocator__c
                );
                InvPmtCollectionUpsert(col);
            }
            if (QMZ.Object__c == 'Refund__c')  {
                RefundZObjCollection col = FetchRefundCollection(
                    QMZ.Object__c, 
                    QMZ.QueryLocator__c
                );
                RefundCollectionUpsert(col);
            }
            if (QMZ.Object__c == 'InvoiceRefund__c')  {
                InvRefZObjCollection col = FetchInvRefCollection(
                    QMZ.Object__c, 
                    QMZ.QueryLocator__c
                );
                InvRefCollectionUpsert(col);
            }
            if (QMZ.Object__c == 'PaymentMethod__c')  {
                PmtMtdZObjCollection col = FetchPmtMtdCollection(
                    QMZ.Object__c, 
                    QMZ.QueryLocator__c
                );
                PmtMtdCollectionUpsert(col);
            }
            if (QMZ.Object__c == 'CreditBalanceAdjustment__c')  {
                CBAZObjCollection col = FetchCBACollection(
                    QMZ.Object__c, 
                    QMZ.QueryLocator__c
                );
                CBACollectionUpsert(col);
            }
            if (QMZ.Object__c == 'Amendment__c')  {
                AmendmentZObjCollection col = FetchAmendmentCollection(
                    QMZ.Object__c, 
                    QMZ.QueryLocator__c
                );
                AmendmentCollectionUpsert(col);
            }
            delete QMZ;
        }
    }
    
    public static void EnqueueNextQMZ() {
        
        if (!test.isRunningTest()) System.enqueueJob(new EnqueueQueryMoreZuora());
    }

    public static Boolean BillSimpleTSE(Date SubStart, String SubscriptionZId, String AccountZId) {
        ZObj.AmendResults AmendResults = (ZObj.AmendResults)JSON.deserialize(
            ZuoraAPIManager.callZuoraAPI(
                'action/amend', 
                'POST',
                cleanJSONRequest(JSON.serialize(new ZObj.AmendActionReq(new ZObj.AmendmentSet(SubscriptionZId), SubStart, new List<String>{'TSE','TSE_fee'}, Date.today(), 'SubscriptionStartDay', 'AlignToSubscriptionStart')))
            ),
            ZObj.AmendResults.class
        );
        try { if (AmendResults.results[0].Success && !test.isRunningTest()) { DoAccountBillRun(null, AccountZId, Date.today(), Date.today()); } else { return false; } } catch(exception e) { return false; }
        return true;
    }
    
    public static Boolean BillComplexTSE(Date SubStart, String SubscriptionZId, String AccountZId, Date RenewalDate, Boolean RenewalTooSoon) {
        if (AmendTSE(SubscriptionZId, RenewalDate)) {
            
            Boolean Cntnue = false;
            if (!RenewalTooSoon) {
                ZObj.UpdatedSubscription NewSub = (ZObj.UpdatedSubscription)JSON.deserialize(
                    ZuoraAPIManager.callZuoraAPI(
                        'subscriptions', 
                        'POST',
                        cleanJSONRequest(JSON.serialize(new ZObj.SubTSETermedProrateReq(SubStart, AccountZId, RenewalDate)))
                    ),
                    ZObj.UpdatedSubscription.class
                );
                if(NewSub.success) { Cntnue = true; } else { return false; }
                //if(NewSub.success) { Cntnue = CancelComplexTSE(NewSub.subscriptionId, RenewalDate); } else { return false; }
            }
            
            try { if(RenewalTooSoon || Cntnue) {
                SyncAccounts(new List<String>{AccountZId},false);
                return true;
            } } catch(exception e) { return false; }
        }
        return false;
    }
    
    public static Boolean AmendTSE(String SubscriptionZId, Date RenewalDate) { 
        ZObj.UpdatedSubscription AmRe = (ZObj.UpdatedSubscription)JSON.deserialize(
            ZuoraAPIManager.callZuoraAPI(
                'subscriptions/' + SubscriptionZId, 
                'PUT', 
                cleanJSONRequest(JSON.serialize(new ZObj.SubUpdReq('TSE', RenewalDate)))
            ),
            ZObj.UpdatedSubscription.class
        );
        return AmRe.Success; 
    }
    
    public static Boolean CancelComplexTSE(String SubscriptionZId, Date CancelDate) {
        return CancelComplexTSE(SubscriptionZId, CancelDate, true);
    }
    
    public static Boolean CancelComplexTSE(String SubscriptionZId, Date CancelDate, Boolean doBill) {
        ZObj.UpdatedSubscription CancSub = (ZObj.UpdatedSubscription)JSON.deserialize(
            ZuoraAPIManager.callZuoraAPI(
                'subscriptions/' + SubscriptionZId + '/cancel', 'PUT', 
                cleanJSONRequest(JSON.serialize(new ZObj.SubTSETermedCancelReq(CancelDate, doBill)))
            ),
            ZObj.UpdatedSubscription.class
        );
        return CancSub.success;
    }

    /****
    /* JSON Objects for Method Handling
    /*
    /****/
    
    public class InvCombinedZObjCollection {
        public List<ZObj.FetchInvoice> FetchInvoices { get; set; }
        public List<ZObj.FetchInvoiceItem> FetchInvoiceItems { get; set; }
        public List<QueryLocator> queryLocators { get; set; }
        public InvCombinedZObjCollection(
            List<ZObj.FetchInvoice> iFetchInvoices,
            List<ZObj.FetchInvoiceItem> iFetchInvoiceItems,
            List<QueryLocator> iQueryLocators
        ) {
            FetchInvoices = iFetchInvoices;
            FetchInvoiceItems = iFetchInvoiceItems;
            queryLocators = iQueryLocators;
        }
    }
    
    public class QueryAccountsRequest {
        public String queryString { get; set; }
        public QueryAccountsRequest() {
            queryString = 'select Id, AutoPay, AutoPayUncheckedReason__c, Balance, Batch, BillCycleDay,'
                + ' CreditBalance, DefaultPaymentMethodId, PaymentGateway, PaymentTerm, Status,'
                + ' TaxExemptCertificateID, TaxExemptCertificateType, TaxExemptEffectiveDate,'
                + ' TaxExemptExpirationDate, TaxExemptStatus, TotalInvoiceBalance, VATId,'
                + ' LegalCompanyName__c, Tax_Exempt_Reason__c'
                + ' from Account';
        }
        public QueryAccountsRequest(Date UpdatedDate) {
            queryString = 'select Id, AutoPay, AutoPayUncheckedReason__c, Balance, Batch, BillCycleDay,'
                + ' CreditBalance, DefaultPaymentMethodId, PaymentGateway, PaymentTerm, Status,'
                + ' TaxExemptCertificateID, TaxExemptCertificateType, TaxExemptEffectiveDate,'
                + ' TaxExemptExpirationDate, TaxExemptStatus, TotalInvoiceBalance, VATId,'
                + ' LegalCompanyName__c, Tax_Exempt_Reason__c'
                + ' from Account where UpdatedDate > \''
                + String.valueOf(UpdatedDate) + 'T00:00:00\'';
        }
        public QueryAccountsRequest(List<String> AccountZIds) {
            queryString = 'select Id, AutoPay, AutoPayUncheckedReason__c, Balance, Batch, BillCycleDay,'
                + ' CreditBalance, DefaultPaymentMethodId, PaymentGateway, PaymentTerm, Status,'
                + ' TaxExemptCertificateID, TaxExemptCertificateType, TaxExemptEffectiveDate,'
                + ' TaxExemptExpirationDate, TaxExemptStatus, TotalInvoiceBalance, VATId,'
                + ' LegalCompanyName__c, Tax_Exempt_Reason__c'
                + ' from Account where';
            for (Integer AcctIndex = 0; AcctIndex < AccountZIds.size(); AcctIndex++) {
                if (AcctIndex > 0) queryString = queryString + ' or ';
                queryString = queryString + ' Id = \'' + AccountZIds[AcctIndex] + '\'';
            }
        }
    }

    public class QueryAmendmentsRequest {
        public String queryString { get; set; }
        public QueryAmendmentsRequest() {
            queryString = 'select Id, EffectiveDate, SubscriptionId from Amendment';
        }
        public QueryAmendmentsRequest(Date UpdatedDate) {
            queryString = 'select Id, EffectiveDate, SubscriptionId'
                + ' from Amendment where UpdatedDate > \''
                + String.valueOf(UpdatedDate) + 'T00:00:00\'';
        }
    }
    
    public class QuerySubscriptionsRequest {
        public String queryString { get; set; }
        public QuerySubscriptionsRequest() {
            queryString = 'select Id, AccountId, AutoRenew, CancelledDate, ContractAcceptanceDate,'
                + ' ContractEffectiveDate, CurrentTerm, CurrentTermPeriodType, InvoiceOwnerId,'
                + ' IsInvoiceSeparate, Name, OriginalId, PreviousSubscriptionId,'
                + ' RenewalSetting, RenewalTerm, RenewalTermPeriodType, ServiceActivationDate,'
                + ' Status, SubscriptionEndDate, SubscriptionStartDate, TermEndDate, TermStartDate,'
                + ' TermType, Version'
                + ' from Subscription';
        }
        public QuerySubscriptionsRequest(List<String> AccountZIds) {
            queryString = 'select Id, AccountId, AutoRenew, CancelledDate, ContractAcceptanceDate,'
                + ' ContractEffectiveDate, CurrentTerm, CurrentTermPeriodType, InvoiceOwnerId,'
                + ' IsInvoiceSeparate, Name, OriginalId, PreviousSubscriptionId,'
                + ' RenewalSetting, RenewalTerm, RenewalTermPeriodType, ServiceActivationDate,'
                + ' Status, SubscriptionEndDate, SubscriptionStartDate, TermEndDate, TermStartDate,'
                + ' TermType, Version'
                + ' from Subscription where';
            for (Integer AcctIndex = 0; AcctIndex < AccountZIds.size(); AcctIndex++) {
                if (AcctIndex > 0) queryString = queryString + ' or ';
                queryString = queryString + ' AccountId = \'' + AccountZIds[AcctIndex] + '\'';
            }
        }
        public QuerySubscriptionsRequest(Date UpdatedDate) {
            queryString = 'select Id, AccountId, AutoRenew, CancelledDate, ContractAcceptanceDate,'
                + ' ContractEffectiveDate, CurrentTerm, CurrentTermPeriodType, InvoiceOwnerId,'
                + ' IsInvoiceSeparate, Name, OriginalId, PreviousSubscriptionId,'
                + ' RenewalSetting, RenewalTerm, RenewalTermPeriodType, ServiceActivationDate,'
                + ' Status, SubscriptionEndDate, SubscriptionStartDate, TermEndDate, TermStartDate,'
                + ' TermType, Version'
                + ' from Subscription where UpdatedDate > \''
                + String.valueOf(UpdatedDate) + 'T00:00:00\'';
        }
    }
    
    public class QuerySubItemsRequest { 
        public String queryString { get; set; }
        public QuerySubItemsRequest(Decimal DiscountType) {
            String PriceName = 'Price';
            if (DiscountType==1) PriceName = 'DiscountAmount';
            if (DiscountType==2) PriceName = 'DiscountPercentage';
            queryString = 'select Id, Description, DMRC, DTCV, EffectiveEndDate, EffectiveStartDate,'
                + ' MRR, Name, OriginalId, ProductRatePlanChargeId, Quantity, RatePlanId,'
                + ' Test1__c, TCV, VAT_ref__c, Version, IsLastSegment, BillingPeriodAlignment, ChargeNumber, '
                + PriceName
                + ' from RatePlanCharge';
        }
        public QuerySubItemsRequest(List<String> RatePlanZIds, Decimal DiscountType) {
            String PriceName = 'Price';
            if (DiscountType==1) PriceName = 'DiscountAmount';
            if (DiscountType==2) PriceName = 'DiscountPercentage';
            queryString = 'select Id, Description, DMRC, DTCV, EffectiveEndDate, EffectiveStartDate,'
                + ' MRR, Name, OriginalId, ProductRatePlanChargeId, Quantity, RatePlanId,'
                + ' Test1__c, TCV, VAT_ref__c, Version, IsLastSegment, BillingPeriodAlignment, ChargeNumber, '
                + PriceName
                + ' from RatePlanCharge where ';
            Boolean IsFirst = true;
            for (String RatePlanZId : RatePlanZIds) {
                if (IsFirst) {
                    IsFirst = false;
                } else {
                    queryString += ' or ';
                }
                queryString += 'RatePlanId = \'' + RatePlanZId + '\'';
            }
            system.debug(queryString);
        }
        public QuerySubItemsRequest(Date UpdatedDate, Decimal DiscountType) {
            String PriceName = 'Price';
            if (DiscountType==1) PriceName = 'DiscountAmount';
            if (DiscountType==2) PriceName = 'DiscountPercentage';
            queryString = 'select Id, Description, DMRC, DTCV, EffectiveEndDate, EffectiveStartDate,'
                + ' MRR, Name, OriginalId, ProductRatePlanChargeId, Quantity, RatePlanId,'
                + ' Test1__c, TCV, VAT_ref__c, Version, IsLastSegment, BillingPeriodAlignment, ChargeNumber, '
                + PriceName
                + ' from RatePlanCharge where UpdatedDate > \''
                + String.valueOf(UpdatedDate) + 'T00:00:00\'';
        }
    }
    
    public class QuerySLIMapRequest {
        public String queryString { get; set; }
        public QuerySLIMapRequest() {
            queryString = 'select Id, SubscriptionId'
                + ' from RatePlan';
        }
        public QuerySLIMapRequest(List<String> SubscriptionZIds) {
            queryString = 'select Id, SubscriptionId'
                + ' from RatePlan where ';
            Boolean IsFirst = true;
            for (String SubscriptionZId : SubscriptionZIds) {
                if (IsFirst) {
                    IsFirst = false;
                } else {
                    queryString += ' or ';
                }
                queryString += 'SubscriptionId = \'' + SubscriptionZId + '\'';
            }
        }
        public QuerySLIMapRequest(Date UpdatedDate) {
            queryString = 'select Id, SubscriptionId'
                + ' from RatePlan where UpdatedDate > \''
                + String.valueOf(UpdatedDate) + 'T00:00:00\'';
        }
    }
    
    public class QueryInvoicesRequest {
        public String queryString { get; set; }
        public QueryInvoicesRequest() {
            queryString = 'select AccountId, AdjustmentAmount, Amount, AmountWithoutTax, Balance, CreditBalanceAdjustmentAmount, DueDate, Id, IncludesHardware__c, IncludesOneTime, InvoiceNumber,'
                + ' IncludesRecurring, IncludesUsage, InvoiceDate, PaymentAmount, PostedDate, RefundAmount, Status, TargetDate, TaxAmount, TaxExemptAmount, UpdatedDate, VAT_ref__c'
                + ' from Invoice where Status=\'Posted\'';
        }
        public QueryInvoicesRequest(List<String> AccountZIds) {
            queryString = 'select AccountId, AdjustmentAmount, Amount, AmountWithoutTax, Balance, CreditBalanceAdjustmentAmount, DueDate, Id, IncludesHardware__c, IncludesOneTime, InvoiceNumber,'
                + ' IncludesRecurring, IncludesUsage, InvoiceDate, PaymentAmount, PostedDate, RefundAmount, Status, TargetDate, TaxAmount, TaxExemptAmount, UpdatedDate, VAT_ref__c'
                + ' from Invoice where';
            for (Integer AcctIndex = 0; AcctIndex < AccountZIds.size(); AcctIndex++) {
                if (AcctIndex > 0) queryString = queryString + ' or ';
                queryString = queryString + ' Status=\'Posted\' and AccountId = \'' + AccountZIds[AcctIndex] + '\'';
            }
        }
        public QueryInvoicesRequest(Date UpdatedDate) {
            queryString = 'select AccountId, AdjustmentAmount, Amount, AmountWithoutTax, Balance, CreditBalanceAdjustmentAmount, DueDate, Id, IncludesHardware__c, IncludesOneTime, InvoiceNumber,'
                + ' IncludesRecurring, IncludesUsage, InvoiceDate, PaymentAmount, PostedDate, RefundAmount, Status, TargetDate, TaxAmount, TaxExemptAmount, UpdatedDate, VAT_ref__c'
                + ' from Invoice where Status=\'Posted\' and UpdatedDate > \''
                + String.valueOf(UpdatedDate) + 'T00:00:00\'';
        }
        public QueryInvoicesRequest(List<String> AccountZIds, Date UpdatedDate) {
            queryString = 'select AccountId, AdjustmentAmount, Amount, AmountWithoutTax, Balance, CreditBalanceAdjustmentAmount, DueDate, Id, IncludesHardware__c, IncludesOneTime, InvoiceNumber,'
                + ' IncludesRecurring, IncludesUsage, InvoiceDate, PaymentAmount, PostedDate, RefundAmount, Status, TargetDate, TaxAmount, TaxExemptAmount, UpdatedDate, VAT_ref__c'
                + ' from Invoice where';
            for (Integer AcctIndex = 0; AcctIndex < AccountZIds.size(); AcctIndex++) {
                if (AcctIndex > 0) queryString = queryString + ' or ';
                queryString = queryString + ' Status=\'Posted\' and AccountId = \'' + AccountZIds[AcctIndex] + '\' and UpdatedDate > \''
                + String.valueOf(UpdatedDate) + 'T00:00:00\'';
            }
        }
    }
    
    public class QueryInvoiceItemsRequest {
        public String queryString { get; set; }
        public QueryInvoiceItemsRequest() {
            queryString = 'select ChargeId, ServiceStartDate, ServiceEndDate, ChargeAmount, ChargeName, Id, InvoiceId, Quantity, RatePlanChargeId, SubscriptionId, TaxAmount, TaxExemptAmount, UnitPrice'
                + ' from InvoiceItem';
        }
        public QueryInvoiceItemsRequest(List<String> InvoiceZIds) {
            queryString = 'select ChargeId, ServiceStartDate, ServiceEndDate, ChargeAmount, ChargeName, Id, InvoiceId, Quantity, RatePlanChargeId, SubscriptionId, TaxAmount, TaxExemptAmount, UnitPrice'
                + ' from InvoiceItem where ';
            Boolean IsFirst = true;
            for (String InvoiceZId : InvoiceZIds) {
                if (IsFirst) {
                    IsFirst = false;
                } else {
                    queryString += ' or ';
                }
                queryString += 'InvoiceId = \'' + InvoiceZId + '\'';
            }
        }
        public QueryInvoiceItemsRequest(String InvoiceZId) {
            queryString = 'select ChargeId, ServiceStartDate, ServiceEndDate, ChargeAmount, ChargeName, Id, InvoiceId, Quantity, RatePlanChargeId, SubscriptionId, TaxAmount, TaxExemptAmount, UnitPrice'
                + ' from InvoiceItem where InvoiceId=\'' + InvoiceZId + '\'';
        }
        public QueryInvoiceItemsRequest(Date UpdatedDate) {
            queryString = 'select ChargeId, ServiceStartDate, ServiceEndDate, ChargeAmount, ChargeName, Id, InvoiceId, Quantity, RatePlanChargeId, SubscriptionId, TaxAmount, TaxExemptAmount, UnitPrice'
                + ' from InvoiceItem where UpdatedDate > \'' 
                + String.valueOf(UpdatedDate) + 'T00:00:00\'';
        }
    }
    
    public class AccountZObjCollection{
        public List<ZObj.FetchAccount> FetchAccounts { get; set; }
        public List<QueryLocator> queryLocators { get; set; }
        public AccountZObjCollection(
            List<ZObj.FetchAccount> iFetchAccounts,
            List<QueryLocator> iQueryLocators
        ) {
            FetchAccounts = iFetchAccounts;
            queryLocators = iQueryLocators;
        }
    }
    
    public class InvoiceZObjCollection {
        public List<ZObj.FetchInvoice> FetchInvoices { get; set; }
        public List<QueryLocator> queryLocators { get; set; }
        public InvoiceZObjCollection(
            List<ZObj.FetchInvoice> iFetchInvoices,
            List<QueryLocator> iQueryLocators
        ) {
            FetchInvoices = iFetchInvoices;
            queryLocators = iQueryLocators;
        }
    }
    
    public class InvItemZObjCollection {
        public List<ZObj.FetchInvoiceItem> FetchInvItems { get; set; }
        public List<QueryLocator> queryLocators { get; set; }
        public InvItemZObjCollection(
            List<ZObj.FetchInvoiceItem> iFetchInvItems,
            List<QueryLocator> iQueryLocators
        ) {
            FetchInvItems = iFetchInvItems;
            queryLocators = iQueryLocators;
        }
    }
    
    public class AmendmentZObjCollection {
        public List<ZObj.FetchAmendment> FetchAmendments { get; set; }
        public List<QueryLocator> queryLocators { get; set; }
        public AmendmentZObjCollection(
            List<ZObj.FetchAmendment> iFetchAmendments,
            List<QueryLocator> iQueryLocators
        ) {
            FetchAmendments = iFetchAmendments;
            queryLocators = iQueryLocators;
        }
    }

    public class SubscriptionZObjCollection {
        public List<ZObj.FetchSubscription> FetchSubscriptions { get; set; }
        public List<QueryLocator> queryLocators { get; set; }
        public SubscriptionZObjCollection(
            List<ZObj.FetchSubscription> iFetchSubscriptions,
            List<QueryLocator> iQueryLocators
        ) {
            FetchSubscriptions = iFetchSubscriptions;
            queryLocators = iQueryLocators;
        }
    }
    
    public class SubItemZObjCollection {
        public List<ZObj.FetchSubItem> FetchSubItems { get; set; }
        public List<QueryLocator> queryLocators { get; set; }
        public SubItemZObjCollection(
            List<ZObj.FetchSubItem> iFetchSubItems,
            List<QueryLocator> iQueryLocators
        ) {
            FetchSubItems = iFetchSubItems;
            queryLocators = iQueryLocators;
        }
    }
    
    public class SLIMapZObjCollection {
        public List<ZObj.FetchSLIMapping> FetchSLIMap { get; set; }
        public List<QueryLocator> queryLocators { get; set; }
        public SLIMapZObjCollection(
            List<ZObj.FetchSLIMapping> iFetchSLIMap,
            List<QueryLocator> iQueryLocators
        ) {
            FetchSLIMap = iFetchSLIMap;
            queryLocators = iQueryLocators;
        }
    }
    
    public class PaymentZObjCollection {
        public List<ZObj.FetchPayment> FetchPayments { get; set; }
        public List<QueryLocator> queryLocators { get; set; }
        public PaymentZObjCollection(
            List<ZObj.FetchPayment> iFetchPayments,
            List<QueryLocator> iQueryLocators
        ) {
            FetchPayments = iFetchPayments;
            queryLocators = iQueryLocators;
        }
    }
    
    public class QueryPaymentsRequest {
        public String queryString { get; set; }
        public QueryPaymentsRequest() {
            queryString = 'select AccountId, AccountingCode, Amount, AppliedCreditBalanceAmount, AuthTransactionId,'
                + ' BankIdentificationNumber, CancelledOn, CreatedDate, Currency, EffectiveDate,'
                + ' GatewayResponse, GatewayResponseCode, GatewayState, Id, RefundAmount, SettledOn, Status,'
                + ' SubmittedOn, Type, UnappliedAmount, PaymentNumber, Comment'
                + ' from Payment';
        }
        public QueryPaymentsRequest(List<String> AccountZIds) {
            queryString = 'select AccountId, AccountingCode, Amount, AppliedCreditBalanceAmount, AuthTransactionId,'
                + ' BankIdentificationNumber, CancelledOn, CreatedDate, Currency, EffectiveDate,'
                + ' GatewayResponse, GatewayResponseCode, GatewayState, Id, RefundAmount, SettledOn, Status,'
                + ' SubmittedOn, Type, UnappliedAmount, PaymentNumber, Comment'
                + ' from Payment where';
            for (Integer AcctIndex = 0; AcctIndex < AccountZIds.size(); AcctIndex++) {
                if (AcctIndex > 0) queryString = queryString + ' or ';
                queryString = queryString + ' AccountId = \'' + AccountZIds[AcctIndex] + '\'';
            }
        }
        public QueryPaymentsRequest(Date UpdatedDate) {
            queryString = 'select AccountId, AccountingCode, Amount, AppliedCreditBalanceAmount, AuthTransactionId,'
                + ' BankIdentificationNumber, CancelledOn, CreatedDate, Currency, EffectiveDate,'
                + ' GatewayResponse, GatewayResponseCode, GatewayState, Id, RefundAmount, SettledOn, Status,'
                + ' SubmittedOn, Type, UnappliedAmount, PaymentNumber, Comment'
                + ' from Payment where UpdatedDate > \''
                + String.valueOf(UpdatedDate) + 'T00:00:00\'';
        }
    }
    
    public class InvPmtZObjCollection {
        public List<ZObj.FetchInvPmt> FetchInvPmts { get; set; }
        public List<QueryLocator> queryLocators { get; set; }
        public InvPmtZObjCollection(
            List<ZObj.FetchInvPmt> iFetchInvPmts,
            List<QueryLocator> iQueryLocators
        ) {
            FetchInvPmts = iFetchInvPmts;
            queryLocators = iQueryLocators;
        }
    }
    
    public class QueryInvPmtsRequest {
        public String queryString { get; set; }
        public QueryInvPmtsRequest() {
            queryString = 'select InvoiceId, PaymentId, Id, Amount, RefundAmount'
                + ' from InvoicePayment';
        }
        public QueryInvPmtsRequest(List<String> InvoiceZIds) {
            queryString = 'select InvoiceId, PaymentId, Id, Amount, RefundAmount'
                + ' from InvoicePayment where ';
            Boolean IsFirst = true;
            for (String InvoiceZId : InvoiceZIds) {
                if (IsFirst) {
                    IsFirst = false;
                } else {
                    queryString += ' or ';
                }
                queryString += 'InvoiceId = \'' + InvoiceZId + '\'';
            }
        }
        public QueryInvPmtsRequest(Date UpdatedDate) {
            queryString = 'select InvoiceId, PaymentId, Id, Amount, RefundAmount'
                + ' from InvoicePayment where UpdatedDate > \''
                + String.valueOf(UpdatedDate) + 'T00:00:00\'';
        }
    }
    
    public class RefundZObjCollection {
        public List<ZObj.FetchRefund> FetchRefunds { get; set; }
        public List<QueryLocator> queryLocators { get; set; }
        public RefundZObjCollection(
            List<ZObj.FetchRefund> iFetchRefunds,
            List<QueryLocator> iQueryLocators
        ) {
            FetchRefunds = iFetchRefunds;
            queryLocators = iQueryLocators;
        }
    }
    
    public class QueryRefundsRequest {
        public String queryString { get; set; }
        public QueryRefundsRequest() {
            queryString = 'select Id, AccountId, Amount, CancelledOn, GatewayResponse, RefundNumber,'
                + ' GatewayResponseCode, GatewayState, RefundDate, SettledOn, Status, Type'
                + ' from Refund';
        }
        public QueryRefundsRequest(List<String> AccountZIds) {
            queryString = 'select Id, AccountId, Amount, CancelledOn, GatewayResponse, RefundNumber,'
                + ' GatewayResponseCode, GatewayState, RefundDate, SettledOn, Status, Type'
                + ' from Refund where';
            for (Integer AcctIndex = 0; AcctIndex < AccountZIds.size(); AcctIndex++) {
                if (AcctIndex > 0) queryString = queryString + ' or ';
                queryString = queryString + ' AccountId = \'' + AccountZIds[AcctIndex] + '\'';
            }
        }
        public QueryRefundsRequest(Date UpdatedDate) {
            queryString = 'select Id, AccountId, Amount, CancelledOn, GatewayResponse, RefundNumber,'
                + ' GatewayResponseCode, GatewayState, RefundDate, SettledOn, Status, Type'
                + ' from Refund where UpdatedDate > \''
                + String.valueOf(UpdatedDate) + 'T00:00:00\'';
        }
    }
    
    public class InvRefZObjCollection {
        public List<ZObj.FetchInvRef> FetchInvRefs { get; set; }
        public List<QueryLocator> queryLocators { get; set; }
        public InvRefZObjCollection(
            List<ZObj.FetchInvRef> iFetchInvRefs,
            List<QueryLocator> iQueryLocators
        ) {
            FetchInvRefs = iFetchInvRefs;
            queryLocators = iQueryLocators;
        }
    }
    
    public class QueryInvRefsRequest {
        public String queryString { get; set; }
        public QueryInvRefsRequest() {
            queryString = 'select InvoiceId, RefundId, Id, RefundAmount'
                + ' from RefundInvoicePayment';
        }
        public QueryInvRefsRequest(List<String> InvoiceZIds) {
            queryString = 'select InvoiceId, RefundId, Id, RefundAmount'
                + ' from RefundInvoicePayment where ';
            Boolean IsFirst = true;
            for (String InvoiceZId : InvoiceZIds) {
                if (IsFirst) {
                    IsFirst = false;
                } else {
                    queryString += ' or ';
                }
                queryString += 'InvoiceId = \'' + InvoiceZId + '\'';
            }
        }
        public QueryInvRefsRequest(Date UpdatedDate) {
            queryString = 'select InvoiceId, RefundId, Id, RefundAmount'
                + ' from RefundInvoicePayment where UpdatedDate > \''
                + String.valueOf(UpdatedDate) + 'T00:00:00\'';
        }
    }
    
    public class PmtMtdZObjCollection {
        public List<ZObj.FetchPmtMtd> FetchPmtMtds { get; set; }
        public List<QueryLocator> queryLocators { get; set; }
        public PmtMtdZObjCollection(
            List<ZObj.FetchPmtMtd> iFetchPmtMtds,
            List<QueryLocator> iQueryLocators
        ) {
            FetchPmtMtds = iFetchPmtMtds;
            queryLocators = iQueryLocators;
        }
    }
    
    public class QueryPmtMtdsRequest {
        public String queryString { get; set; }
        public QueryPmtMtdsRequest() {
            queryString = 'select Id, AccountId, Name, FirstName, LastName,'
                + ' AchAbaCode, AchAccountNumberMask, AchAccountType, AchBankName,'
                + ' Active, BankBranchCode, BankCheckDigit, BankCode, BankIdentificationNumber,'
                + ' BankName, BankTransferAccountName, BankTransferAccountNumberMask,'
                + ' BankTransferAccountType, BankTransferType, BusinessIdentificationCode,'
                + ' City, Country, CreditCardExpirationMonth, CreditCardExpirationYear,'
                + ' CreditCardHolderName, CreditCardMaskNumber, CreditCardType, IPAddress,'
                + ' LastFailedSaleTransactionDate, LastTransactionDateTime, LastTransactionStatus,'
                + ' PaymentMethodStatus, PaypalBaid, PaypalEmail, PaypalPreapprovalKey,'
                + ' PaypalType, Phone, Type'
                + ' from PaymentMethod';
        }
        public QueryPmtMtdsRequest(List<String> AccountZIds) {
            queryString = 'select Id, AccountId, Name, FirstName, LastName,'
                + ' AchAbaCode, AchAccountNumberMask, AchAccountType, AchBankName,'
                + ' Active, BankBranchCode, BankCheckDigit, BankCode, BankIdentificationNumber,'
                + ' BankName, BankTransferAccountName, BankTransferAccountNumberMask,'
                + ' BankTransferAccountType, BankTransferType, BusinessIdentificationCode,'
                + ' City, Country, CreditCardExpirationMonth, CreditCardExpirationYear,'
                + ' CreditCardHolderName, CreditCardMaskNumber, CreditCardType, IPAddress,'
                + ' LastFailedSaleTransactionDate, LastTransactionDateTime, LastTransactionStatus,'
                + ' PaymentMethodStatus, PaypalBaid, PaypalEmail, PaypalPreapprovalKey,'
                + ' PaypalType, Phone, Type'
                + ' from PaymentMethod where';
            for (Integer AcctIndex = 0; AcctIndex < AccountZIds.size(); AcctIndex++) {
                if (AcctIndex > 0) queryString = queryString + ' or ';
                queryString = queryString + ' AccountId = \'' + AccountZIds[AcctIndex] + '\'';
            }
        }
        public QueryPmtMtdsRequest(Date UpdatedDate) {
            queryString = 'select Id, AccountId, Name, FirstName, LastName,'
                + ' AchAbaCode, AchAccountNumberMask, AchAccountType, AchBankName,'
                + ' Active, BankBranchCode, BankCheckDigit, BankCode, BankIdentificationNumber,'
                + ' BankName, BankTransferAccountName, BankTransferAccountNumberMask,'
                + ' BankTransferAccountType, BankTransferType, BusinessIdentificationCode,'
                + ' City, Country, CreditCardExpirationMonth, CreditCardExpirationYear,'
                + ' CreditCardHolderName, CreditCardMaskNumber, CreditCardType, IPAddress,'
                + ' LastFailedSaleTransactionDate, LastTransactionDateTime, LastTransactionStatus,'
                + ' PaymentMethodStatus, PaypalBaid, PaypalEmail, PaypalPreapprovalKey,'
                + ' PaypalType, Phone, Type'
                + ' from PaymentMethod where UpdatedDate > \''
                + String.valueOf(UpdatedDate) + 'T00:00:00\'';
        }
    }

    public class CBAZObjCollection {
        public List<ZObj.FetchCBA> FetchCBAs { get; set; }
        public List<QueryLocator> queryLocators { get; set; }
        public CBAZObjCollection(
            List<ZObj.FetchCBA> iFetchCBAs,
            List<QueryLocator> iQueryLocators
        ) {
            FetchCBAs = iFetchCBAs;
            queryLocators = iQueryLocators;
        }
    }
    
    public class QueryCBAsRequest {
        public String queryString { get; set; }
        public QueryCBAsRequest() {
            queryString = 'select Id, AccountId, AdjustmentDate, Amount,'
                + ' CancelledOn, Comment, Number, Status, Type,'
                + ' SourceTransactionId, SourceTransactionNumber, SourceTransactionType'
                + ' from CreditBalanceAdjustment';
        }
        public QueryCBAsRequest(List<String> AccountZIds) {
            queryString = 'select Id, AccountId, AdjustmentDate, Amount,'
                + ' CancelledOn, Comment, Number, Status, Type,'
                + ' SourceTransactionId, SourceTransactionNumber, SourceTransactionType'
                + ' from CreditBalanceAdjustment where';
            for (Integer AcctIndex = 0; AcctIndex < AccountZIds.size(); AcctIndex++) {
                if (AcctIndex > 0) queryString = queryString + ' or ';
                queryString = queryString + ' AccountId = \'' + AccountZIds[AcctIndex] + '\'';
            }
        }
        public QueryCBAsRequest(Date UpdatedDate) {
            queryString = 'select Id, AccountId, AdjustmentDate, Amount,'
                + ' CancelledOn, Comment, Number, Status, Type,'
                + ' SourceTransactionId, SourceTransactionNumber, SourceTransactionType'
                + ' from CreditBalanceAdjustment where UpdatedDate > \''
                + String.valueOf(UpdatedDate) + 'T00:00:00\'';
        }
    }

    public class QueryLocator {
        public String objectName { get; set; }
        public String queryLocator { get; set; }
        public Decimal intParam { get; set; }
        public QueryLocator(String iObject, String iQueryLocator, Decimal iIntParam) {
            objectName = iObject;
            queryLocator = iQueryLocator;
            intParam = iIntParam;
        }
        public QueryLocator(String iObject, String iQueryLocator) {
            objectName = iObject;
            queryLocator = iQueryLocator;
        }
        public QueryLocator(String iQueryLocator) {
            queryLocator = iQueryLocator;
        }
    }
    
    public class SubscriptionQuoteLink {
        public List<Subscription__c> SubscriptionsNew { get; set; }
        public List<Subscription__c> SubscriptionsOld { get; set; }
        public List<SubscriptionLineItem__c> SubscriptionLineItemsNew { get; set; }
        public List<SubscriptionLineItem__c> SubscriptionLineItemsOld { get; set; }
        public Map<String, QuoteLineItem> QuoteLineItems { get; set; }
        public SubscriptionQuoteLink(String QuoteId) {
            SubscriptionsNew = new List<Subscription__c>();
            SubscriptionLineItemsNew = new List<SubscriptionLineItem__c>();
            SubscriptionsOld = new List<Subscription__c>();
            SubscriptionLineItemsOld = new List<SubscriptionLineItem__c>();
            QuoteLineItems = new Map<String, QuoteLineItem>([
                SELECT Id, SubscriptionLineItem__c FROM QuoteLineItem WHERE QuoteId = :QuoteId
            ]);
        }
    }
    
    public class AccountCompare {
        public AccountCompare(Map<Id,Account> OldMap, Map<Id,Account> NewMap) {
            List<Account> SyncAccounts = new List<Account>();
            for (Id AcctId : NewMap.keySet()) {
                if (
                    NewMap.get(AcctId).ZuoraId__c != null
                    && (
                        OldMap.get(AcctId).LegalCompanyName__c != NewMap.get(AcctId).LegalCompanyName__c
                        || OldMap.get(AcctId).myOrderbirdEmail__c != NewMap.get(AcctId).myOrderbirdEmail__c
                        || OldMap.get(AcctId).Dunning_Status__c != NewMap.get(AcctId).Dunning_Status__c
                        || OldMap.get(AcctId).VATNumber__c != NewMap.get(AcctId).VATNumber__c
                        || OldMap.get(AcctId).Name != NewMap.get(AcctId).Name
                        || OldMap.get(AcctId).Tax_Exempt_Reason__c != NewMap.get(AcctId).Tax_Exempt_Reason__c
                    )
                ) {
                    SyncAccounts.add(NewMap.get(AcctId));
                }
            }
            try{
                if (SyncAccounts.size() > 0) UpdateZAccount(JSON.serialize(SyncAccounts));
            } catch(exception e){}
        }
    }
    
    @future(callout=true)
    public static void UpdateZAccount(String strAcct) {
        List<Account> Accts = (List<Account>)JSON.deserialize(strAcct, List<Account>.class);
        List<ZObj.SuccessId> SuccessIds = ((List<ZObj.SuccessId>)JSON.deserialize(
            ZuoraAPIManager.callZuoraAPI(
                'action/update',
                'POST',
                cleanJSONRequest(JSON.serialize(new ZObj.UpdateAccountReq(Accts)))
            ), 
            List<ZObj.SuccessId>.class
        ));
    }
    
    public static void UpdateZInvoice(List<String> InvoiceZIds) {
        List<ZObj.SuccessId> SuccessIds = ((List<ZObj.SuccessId>)JSON.deserialize(
            ZuoraAPIManager.callZuoraAPI(
                'action/update',
                'POST',
                cleanJSONRequest(JSON.serialize(new ZObj.UpdateInvoiceReq(InvoiceZIds)))
            ), 
            List<ZObj.SuccessId>.class
        ));
    }

    /****
    /* JSON Utilities
    /*
    /****/
    
    public Static String cleanJSONResponse(String s) {
        
        return s.replace('__c','xxc')
            .replace('Name__c','Namec')
            .replace('Price__c','Pricec')
            .replace('Reason__c','Reasonc')
            .replace('"number"','"numberX"').replace('"Number"','"NumberX"')
            .replace('"update"','"updateX"')
            .replace('"collect"','"collectX"')
            .replace('"currency"','"currencyX"').replace('"Currency"','"CurrencyX"')
            .replace('"test1__c"','"test1c"')
            .replace('"QuoteBuilderVisibility__c"','"QuoteBuilderVisibilityc"')
            .replace('_Name_DE__c','NameDEc').replace('_Name_FR__c','NameFRc');
    }
    
    public Static String cleanJSONRequest(String s) {
        
        return s
            .replace(',"BillingPeriodAlignment":null','').replace('"BillingPeriodAlignment":null,','')
            .replace(',"BillCycleType":null','').replace('"BillCycleType":null,','')
            .replace(',"upToPeriods":null','').replace('"upToPeriods":null,','')
            .replace(',"endDateCondition":null','').replace('"endDateCondition":null,','')
            .replace(',"discountLevel":null','').replace('"discountLevel":null,','')
            .replace(',"discountAmount":null','').replace('"discountAmount":null,','')
            .replace(',"triggerEvent":null','').replace('"triggerEvent":null,','')
            .replace(',"UpToPeriods":null','').replace('"UpToPeriods":null,','')
            .replace(',"EndDateCondition":null','').replace('"EndDateCondition":null,','')
            .replace(',"DiscountLevel":null','').replace('"DiscountLevel":null,','')
            .replace(',"Price":null','').replace('"Price":null,','')
            .replace(',"VAT_refxxc":null','').replace('"VAT_refxxc":null,','')
            .replace(',"DiscountAmount":null','').replace('"DiscountAmount":null,','')
            .replace(',"test1xxc":null','').replace('"test1xxc":null,','')
            .replace(',"quantity":null','').replace('"quantity":null,','')
            .replace('xxc','__c').replace('"collectX"','"collect"').replace('Pricec','Price__c').replace('"InvoiceProcessingOptions":null,','').replace(',"InvoiceProcessingOptions":null','').replace('Namec','Name__c').replace(',"AmendmentSubscriptionRatePlanId":null','').replace('collectX','collect').replace(',"quantity":null,',',').replace('"numberX"','"number"').replace('"updateX"','"update"').replace('"CurrencyX"','"Currency"').replace('"currencyX"','"currency"').replace('"test1c"','"test1__c"').replace('"QuoteBuilderVisibilityc"','"QuoteBuilderVisibility__c"').replace('NameDEc','_Name_DE__c').replace('NameFRc','_Name_FR__c');
    }
    
}