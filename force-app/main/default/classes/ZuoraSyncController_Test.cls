@isTest
public class ZuoraSyncController_Test {

    @isTest static void test1() {
        Id pricebookId = Test.getStandardPricebookId();
        update new Pricebook2(id=pricebookId, key__c='main',isactive=true);
        ZuoraSyncController.UpsertCatalog(ZuoraSyncController.FetchCatalog());
        //ZuoraSyncController.syncCatalog();
        //ZuoraSyncController.syncCatalog();
        system.debug(JSON.serialize(new ZuoraSyncController.QueryCBAsRequest()));
        system.debug(JSON.serialize(new ZuoraSyncController.QueryCBAsRequest(Date.today())));
        ZObj.FetchCBA f = new ZObj.FetchCBA();
        f.AccountId = '';
        f.AdjustmentDate = Date.today();
        f.Amount = 0;
        f.CancelledOn = Date.today();
        f.Comment = '';
        f.Id = '';
        f.NumberX = '';
        f.SourceTransactionId = '';
        f.SourceTransactionNumber = '';
        f.SourceTransactionType = '';
        f.Status = '';
        f.Type = '';
        ZObj.FetchCBAs fc = new ZObj.FetchCBAs();
        fc.queryLocator = '';
        fc.done = true;
        fc.records = new List<ZObj.FetchCBA>{ f };
    }

    @isTest static void test2() {
        Id pricebookId = Test.getStandardPricebookId();
        update new Pricebook2(id=pricebookId, key__c='main',isactive=true);
        ZuoraSyncController.UpsertCatalog(ZuoraSyncController.FetchCatalog());
        //ZuoraSyncController.syncCatalog();
        Account a = new Account(name='test');
        insert a;
        Opportunity o = new Opportunity(accountid = a.Id, name='test', stagename='new', closedate=date.today(), lac_shorthand__c = 'Walk-In');
        insert o;
        Id pbId = Test.getStandardPricebookId();
        Quote q = new Quote(name='test',opportunityid=o.id, pricebook2Id = pbId);
        insert q;
        Product2 p = [SELECT Id FROM Product2 LIMIT 1];
        PricebookEntry pbe = [SELECT Id FROM PricebookEntry WHERE Pricebook2Id = :pbId and Product2Id = :p.Id LIMIT 1];
        QuoteLineItem qli = new QuoteLineItem(QuoteId = q.Id, Product2Id = p.Id, Quantity = 1, UnitPrice = 1, PricebookEntryId = pbe.Id);
        insert qli;
        String preview = ZuoraSyncController.PreviewAmendment(q.Id);
        ZuoraSyncController.BillSimpleTSE(date.today(), 'test','test');
        ZuoraSyncController.BillComplexTSE(date.today(), 'test','test', Date.today().addMonths(6), false);
        ZuoraSyncController.BillComplexTSE(date.today(), 'test','test', Date.today().addMonths(6), true);
    }
    
    @isTest static void test2b() {
        Id pricebookId = Test.getStandardPricebookId();
        update new Pricebook2(id=pricebookId, key__c='main',isactive=true);
        ZuoraSyncController.UpsertCatalog(ZuoraSyncController.FetchCatalog());
        //ZuoraSyncController.syncCatalog();
        Account a = new Account(name='test');
        insert a;
        Opportunity o = new Opportunity(accountid = a.Id, name='test', stagename='new', closedate=date.today(), lac_shorthand__c = 'Walk-In');
        insert o;
        Id pbId = Test.getStandardPricebookId();
        Quote q = new Quote(name='test',opportunityid=o.id, pricebook2Id = pbId);
        insert q;
        Product2 p = [SELECT Id FROM Product2 LIMIT 1];
        PricebookEntry pbe = [SELECT Id FROM PricebookEntry WHERE Pricebook2Id = :pbId and Product2Id = :p.Id LIMIT 1];
        QuoteLineItem qli = new QuoteLineItem(QuoteId = q.Id, Product2Id = p.Id, Quantity = 1, UnitPrice = 1, PricebookEntryId = pbe.Id);
        insert qli;
        String preview = ZuoraSyncController.PreviewAmendment(q.Id);
        ZuoraSyncController.ProcessQuote(q.Id);
        Opportunity o2 = new Opportunity(accountid = a.Id, name='test2', stagename='new', closedate=date.today(), lac_shorthand__c = 'Walk-In');
        insert o2;
        Quote q2 = new Quote(name='test2',opportunityid=o2.id, pricebook2id = pbId);
        insert q2;
        QuoteLineItem qli2 = new QuoteLineItem(QuoteId = q2.Id, Product2Id = p.Id, Quantity = 3, UnitPrice = 1, PricebookEntryId = pbe.Id);
        QuoteLineItem qli3 = new QuoteLineItem(QuoteId = q2.Id, Product2Id = p.Id, Quantity = -1, UnitPrice = 1, PricebookEntryId = pbe.Id);
        insert qli2;
        insert qli3;
        ZuoraSyncController.ProcessQuote(q2.Id);
        String cancel = ZuoraSyncController.CancelSubscriptions('["test"]',null);
        ZObj.CreatePreviewReq cpr = new ZObj.CreatePreviewReq(q.Id);
    }
    
    @isTest static void test3() {
        ZuoraSyncController.FetchInvoiceCollection();
        ZuoraSyncController.FetchInvoiceCollection('Invoice__c','test');
        ZuoraSyncController.FetchInvoiceCollection('InvoiceLineItem__c','test');
        ZuoraSyncController.InvoiceZObjCollection InvoiceCollection = ZuoraSyncController.FetchInvoiceCollection(Date.today());
        ZuoraSyncController.InvoiceCollectionUpsert(InvoiceCollection);
    }

    @isTest static void test4() {
        ZuoraSyncController.FetchPaymentCollection();
        ZuoraSyncController.FetchPaymentCollection('Payment__c','test');
        ZuoraSyncController.PaymentZObjCollection PaymentCollection = ZuoraSyncController.FetchPaymentCollection(Date.today());
        ZuoraSyncController.PaymentCollectionUpsert(PaymentCollection);
    }

    @isTest static void test5() {
        ZuoraSyncController.FetchInvPmtCollection();
        ZuoraSyncController.FetchInvPmtCollection('InvoicePayment__c','test');
        ZuoraSyncController.InvPmtZObjCollection InvPmtCollection = ZuoraSyncController.FetchInvPmtCollection(Date.today());
        ZuoraSyncController.InvPmtCollectionUpsert(InvPmtCollection);
    }

    @isTest static void test6() {
        ZuoraSyncController.FetchRefundCollection();
        ZuoraSyncController.FetchRefundCollection('Refund__c','test');
        ZuoraSyncController.RefundZObjCollection RefundCollection = ZuoraSyncController.FetchRefundCollection(Date.today());
        ZuoraSyncController.RefundCollectionUpsert(RefundCollection);
    }

    @isTest static void test7() {
        ZuoraSyncController.FetchInvRefCollection();
        ZuoraSyncController.FetchInvRefCollection('InvoiceRefund__c','test');
        ZuoraSyncController.InvRefZObjCollection InvRefCollection = ZuoraSyncController.FetchInvRefCollection(Date.today());
        ZuoraSyncController.InvRefCollectionUpsert(InvRefCollection);
    }
    
    @isTest static void test8() {
        ZuoraSyncController.PaymentZObjCollection PaymentCollection = (ZuoraSyncController.PaymentZObjCollection)JSON.deserialize(
            '{"FetchPayments":[{"done":true,"records":[{"id":"test"}]}],"queryLocators":[{"objectName":"test","queryLocator":"test"}]}', 
            ZuoraSyncController.PaymentZObjCollection.class
        );
        ZuoraSyncController.PaymentCollectionUpsert(PaymentCollection);
    }

    @isTest static void test9() {
        ZuoraSyncController.RefundZObjCollection RefundCollection = (ZuoraSyncController.RefundZObjCollection)JSON.deserialize(
            '{"FetchRefunds":[{"done":true,"records":[{"id":"test"}]}],"queryLocators":[{"objectName":"test","queryLocator":"test"}]}', 
            ZuoraSyncController.RefundZObjCollection.class
        );
        ZuoraSyncController.RefundCollectionUpsert(RefundCollection);
    }
    
    @isTest static void test10() {
        ZObj.FetchPayment FetchPayment = new ZObj.FetchPayment();
        FetchPayment.Amount = 0;
        FetchPayment.AppliedCreditBalanceAmount = 0;
        FetchPayment.AppliedInvoiceAmount = 0;
        FetchPayment.AuthTransactionId = 'test';
        FetchPayment.BankIdentificationNumber = 'test';
        FetchPayment.CancelledOn = DateTime.now();
        FetchPayment.CreatedDate = DateTime.now();
        FetchPayment.CreditBalanceAmount = 0;
        //FetchPayment.CurrencyX = 'EUR';
        FetchPayment.EffectiveDate = DateTime.now();
        FetchPayment.GatewayResponse = 'test';
        FetchPayment.GatewayResponseCode = 'test';
        FetchPayment.GatewayState = 'test';
        FetchPayment.Id = 'test';
        FetchPayment.RefundAmount = 0;
        FetchPayment.SettledOn = DateTime.now();
        FetchPayment.Status = 'test';
        FetchPayment.SubmittedOn = DateTime.now();
        //FetchPayment.Success = true;
        FetchPayment.Type = 'test';
        FetchPayment.UnappliedAmount = 0;
    }

    @isTest static void test11() {
        ZObj.FetchRefund FetchRefund = new ZObj.FetchRefund();
        FetchRefund.Amount = 0;
        FetchRefund.CancelledOn = DateTime.now();
        FetchRefund.CurrencyX = 'EUR';
        FetchRefund.EffectiveDate = DateTime.now();
        FetchRefund.GatewayResponse = 'test';
        FetchRefund.GatewayResponseCode = 'test';
        FetchRefund.GatewayState = 'test';
        FetchRefund.Id = 'test';
        FetchRefund.SettledOn = DateTime.now();
        FetchRefund.Status = 'test';
        FetchRefund.Type = 'test';
    }

    @isTest static void test12() {
        ZObj.AmendmentSet Data = new ZObj.AmendmentSet(
        	null,null,null,null,null,null
        );
        String s = ZuoraSyncController.ExecuteAmendment(Data, true, Date.today());
        s = ZuoraSyncController.ExecuteAmendment(Data, false, Date.today());
    }
    
    @isTest static void test13() {
        Account a = new Account(name='test',ZuoraId__c='test');
        insert a;
        Subscription__c s = new Subscription__c(Account__c=a.Id, ZuoraId__c='test', Status__c='Active');
        insert s;
        ZuoraSyncController.FetchActiveSubscriptions('test');
    }
    
    @isTest static void test14() {
        Account a = new Account(name='test',ZuoraId__c='test');
        insert a;
        Subscription__c s = new Subscription__c(Account__c=a.Id, ZuoraId__c='test', Status__c='Active');
        insert s;
        ZuoraSyncController.InvoiceCollectionUpsert(
        	new ZuoraSyncController.InvCombinedZObjCollection(
                new List<ZObj.FetchInvoice>{
                    (ZObj.FetchInvoice)json.deserialize('{"Id":"test","AccountId":"test","IncludesRecurring":true,"IncludesUsage":true,"IncludesOneTime":true}', ZObj.FetchInvoice.class)
                },
                new List<ZObj.FetchInvoiceItem>{
                    (ZObj.FetchInvoiceItem)json.deserialize('{"Id":"test","InvoiceId":"test","RatePlanChargeId":"test"}', ZObj.FetchInvoiceItem.class)
                },
                new List<ZuoraSyncController.QueryLocator>()
            ),
            true
        );
    }
    
    @isTest static void test15() {
        ZuoraSyncController.AccountZObjCollection a = ZuoraSyncController.FetchAccountCollection();
        a = ZuoraSyncController.FetchAccountCollection(Date.today());
        a = ZuoraSyncController.FetchAccountCollection('Account', 'QueryLocator');
    }
    
    @isTest static void test16() {
        Account a = new Account(name='test',ZuoraId__c='test');
        insert a;
        insert new PaymentMethod__c(Account__c=a.Id,ZuoraId__c='test',name='test',BankTransferAccountNumberMask__c='xyz');
        ZuoraSyncController.AccountCollectionUpsert(
        	new ZuoraSyncController.AccountZObjCollection(
                new List<ZObj.FetchAccount>{
                    (ZObj.FetchAccount)json.deserialize(
                        '{"AutoPay":true,"Id":"test","DefaultPaymentMethodId":"test"}', 
                        ZObj.FetchAccount.class
                    )
                },
                new List<ZuoraSyncController.QueryLocator>()
            )
        );
    }

    @isTest static void test17() {
        Account a = new Account(name='test',ZuoraId__c='test');
        insert a;
        ZuoraSyncController.InvoiceCollectionUpsert(
        	new ZuoraSyncController.InvoiceZObjCollection(
                new List<ZObj.FetchInvoice>{
                    (ZObj.FetchInvoice)json.deserialize(
                        '{"Id":"test","AccountId":"test","IncludesOneTime":true,"IncludesRecurring":true,"IncludesUsage":true}', 
                        ZObj.FetchInvoice.class
                    )
                },
                new List<ZuoraSyncController.QueryLocator>()
            )
        );
    }

    @isTest static void test18() {
        ZuoraSyncController.InvItemZObjCollection a = ZuoraSyncController.FetchInvItemCollection();
        a = ZuoraSyncController.FetchInvItemCollection(Date.today());
        a = ZuoraSyncController.FetchInvItemCollection('InvoiceLineItem__c', 'QueryLocator');
    }
    
    @isTest static void test19() {
        Account a = new Account(name='test',ZuoraId__c='test');
        insert a;
        Invoice__c i = new Invoice__c(ZuoraId__c='test',Account__c=a.Id,SuppressTriggeredEmail__c=true);
        insert i;
        Subscription__c s = new Subscription__c(ZuoraId__c='test',Account__c=a.Id);
        insert s;
        SubscriptionLineItem__c sl = new SubscriptionLineItem__c(ZuoraId__c='test',Subscription__c=s.Id);
        insert sl;
        ZuoraSyncController.InvItemCollectionUpsert(
        	new ZuoraSyncController.InvItemZObjCollection(
                new List<ZObj.FetchInvoiceItem>{
                    (ZObj.FetchInvoiceItem)json.deserialize(
                        '{"Id":"test","InvoiceId":"test","SubscriptionId":"test","RatePlanChargeId":"test"}', 
                        ZObj.FetchInvoiceItem.class
                    )
                },
                new List<ZuoraSyncController.QueryLocator>()
            )
        );
    }

    @isTest static void test20() {
        ZuoraSyncController.SubscriptionZObjCollection a = ZuoraSyncController.FetchSubscriptionCollection();
        a = ZuoraSyncController.FetchSubscriptionCollection(Date.today());
        a = ZuoraSyncController.FetchSubscriptionCollection('Subscription__c', 'QueryLocator');
    }
    
    @isTest static void test21() {
        Account a = new Account(name='test',ZuoraId__c='test');
        insert a;
        ZuoraSyncController.SubscriptionCollectionUpsert(
        	new ZuoraSyncController.SubscriptionZObjCollection(
                new List<ZObj.FetchSubscription>{
                    (ZObj.FetchSubscription)json.deserialize(
                        '{"Id":"test","AccountId":"test","AutoRenew":true,"IsInvoiceSeparate":true}', 
                        ZObj.FetchSubscription.class
                    )
                },
                new List<ZuoraSyncController.QueryLocator>()
            )
        );
    }

    @isTest static void test22() {
        ZuoraSyncController.SLIMapZObjCollection a = ZuoraSyncController.FetchSLIMapCollection();
        a = ZuoraSyncController.FetchSLIMapCollection(Date.today());
        a = ZuoraSyncController.FetchSLIMapCollection('SLIMap__c', 'QueryLocator');
    }
    
    @isTest static void test23() {
        ZuoraSyncController.SLIMapCollectionUpsert(
        	new ZuoraSyncController.SLIMapZObjCollection(
                new List<ZObj.FetchSLIMapping>{
                    (ZObj.FetchSLIMapping)json.deserialize(
                        '{"Id":"test","SubscriptionId":"test"}', 
                        ZObj.FetchSLIMapping.class
                    )
                },
                new List<ZuoraSyncController.QueryLocator>()
            )
        );
    }

    /*@isTest static void test24() {
        ZuoraSyncController.SubItemZObjCollection a = ZuoraSyncController.FetchSubItemCollection();
        a = ZuoraSyncController.FetchSubItemCollection(Date.today());
        a = ZuoraSyncController.FetchSubItemCollection('SubscriptionLineItem__c', 'QueryLocator');
    }*/
    
    @isTest static void test25() {
        Account a = new Account(name='test',ZuoraId__c='test');
        insert a;
        Subscription__c s = new Subscription__c(ZuoraId__c='test',Account__c=a.Id);
        insert s;
        Product2 p = new Product2(ZuoraId__c='test',name='test');
        insert p;
        SLIMap__c m = new SLIMap__c(RatePlanId__c='test', SubscriptionId__c='test');
        insert m;
        /*ZuoraSyncController.SubItemCollectionUpsert(
        	new ZuoraSyncController.SubItemZObjCollection(
                new List<ZObj.FetchSubItem>{
                    (ZObj.FetchSubItem)json.deserialize(
                        '{"Id":"test","SubscriptionId":"test","RatePlanId":"test","ProductRatePlanChargeId":"test"}', 
                        ZObj.FetchSubItem.class
                    )
                },
                new List<ZuoraSyncController.QueryLocator>()
            )
        );*/
    }

    @isTest static void test26() {
        Account a = new Account(name='test',ZuoraId__c='test');
        insert a;
        ZuoraSyncController.PaymentCollectionUpsert(
        	new ZuoraSyncController.PaymentZObjCollection(
                new List<ZObj.FetchPayment>{
                    (ZObj.FetchPayment)json.deserialize(
                        '{"Id":"test","AccountId":"test"}', 
                        ZObj.FetchPayment.class
                    )
                },
                new List<ZuoraSyncController.QueryLocator>()
            )
        );
    }

    @isTest static void test27() {
        Account a = new Account(name='test',ZuoraId__c='test');
        insert a;
        Invoice__c i = new Invoice__c(ZuoraId__c='test',Account__c=a.Id,SuppressTriggeredEmail__c=true);
        insert i;
        Payment__c p = new Payment__c(ZuoraId__c='test',Account__c=a.Id);
        insert p;
        ZuoraSyncController.InvPmtCollectionUpsert(
        	new ZuoraSyncController.InvPmtZObjCollection(
                new List<ZObj.FetchInvPmt>{
                    (ZObj.FetchInvPmt)json.deserialize(
                        '{"Id":"test","InvoiceId":"test","PaymentId":"test"}', 
                        ZObj.FetchInvPmt.class
                    )
                },
                new List<ZuoraSyncController.QueryLocator>()
            )
        );
    }

    @isTest static void test28() {
        Account a = new Account(name='test',ZuoraId__c='test');
        insert a;
        Invoice__c i = new Invoice__c(ZuoraId__c='test',Account__c=a.Id,SuppressTriggeredEmail__c=true);
        insert i;
        Refund__c r = new Refund__c(ZuoraId__c='test',Account__c=a.Id);
        insert r;
        ZuoraSyncController.InvRefCollectionUpsert(
        	new ZuoraSyncController.InvRefZObjCollection(
                new List<ZObj.FetchInvRef>{
                    (ZObj.FetchInvRef)json.deserialize(
                        '{"Id":"test","InvoiceId":"test","RefundId":"test"}', 
                        ZObj.FetchInvRef.class
                    )
                },
                new List<ZuoraSyncController.QueryLocator>()
            )
        );
    }

    @isTest static void test29() {
        Account a = new Account(name='test',ZuoraId__c='test');
        insert a;
        ZuoraSyncController.RefundCollectionUpsert(
        	new ZuoraSyncController.RefundZObjCollection(
                new List<ZObj.FetchRefund>{
                    (ZObj.FetchRefund)json.deserialize(
                        '{"Id":"test","AccountId":"test"}', 
                        ZObj.FetchRefund.class
                    )
                },
                new List<ZuoraSyncController.QueryLocator>()
            )
        );
    }

    @isTest static void test30() {
        ZuoraSyncController.PmtMtdZObjCollection a = ZuoraSyncController.FetchPmtMtdCollection();
        a = ZuoraSyncController.FetchPmtMtdCollection(Date.today());
        a = ZuoraSyncController.FetchPmtMtdCollection('PaymentMethod__c', 'QueryLocator');
    }
    
    @isTest static void test31() {
        Account a = new Account(name='test',ZuoraId__c='test');
        insert a;
        ZuoraSyncController.PmtMtdCollectionUpsert(
        	new ZuoraSyncController.PmtMtdZObjCollection(
                new List<ZObj.FetchPmtMtd>{
                    (ZObj.FetchPmtMtd)json.deserialize(
                        '{"Id":"test","AccountId":"test","Active":true,"BankTransferAccountNumberMask":"abc"}', 
                        ZObj.FetchPmtMtd.class
                    )
                },
                new List<ZuoraSyncController.QueryLocator>()
            )
        );
    }
    
    @isTest static void test32() {
        ZObj.Amendment zA = new ZObj.Amendment(
            new ZObj.AmendmentPair(
                new QuoteLineItem(),
                new SubscriptionLineItem__c()
            ),
            new Map<String, Decimal>(),
            'test'
        );
        zA = new ZObj.Amendment(
            new QuoteLineItem(),
            'test'
        );
        zA = new ZObj.Amendment(
            new QuoteLineItem(),
            'test',
            new Map<String, Decimal>()
        );
    }

    @isTest static void test33() {
        ZObj.AmendItem zA = new ZObj.AmendItem(
            'test',
            new QuoteLineItem()
        );
        zA = new ZObj.AmendItem(
            new SubscriptionLineItem__c(),
            new QuoteLineItem()
        );
        zA = new ZObj.AmendItem(
            new SubscriptionLineItem__c(),
            new QuoteLineItem(),
            1
        );
    }
    
    @isTest static void test34() {
        test.startTest();
 		SchedFetch_Account SchedFetch_Account = new SchedFetch_Account();
        String sch = '0 0 0 * * ?';
        system.schedule('Test check', sch, SchedFetch_Account);
        test.stopTest();
    }

    @isTest static void test35() {
        test.startTest();
 		SchedFetch_Invoice SchedFetch_Invoice = new SchedFetch_Invoice();
        String sch = '0 0 0 * * ?';
        system.schedule('Test check', sch, SchedFetch_Invoice);
        test.stopTest();
    }

    @isTest static void test36() {
        test.startTest();
 		SchedFetch_InvoiceLineItem SchedFetch_InvoiceLineItem = new SchedFetch_InvoiceLineItem();
        String sch = '0 0 0 * * ?';
        system.schedule('Test check', sch, SchedFetch_InvoiceLineItem);
        test.stopTest();
    }

    @isTest static void test37() {
        test.startTest();
 		SchedFetch_InvoicePayment SchedFetch_InvoicePayment = new SchedFetch_InvoicePayment();
        String sch = '0 0 0 * * ?';
        system.schedule('Test check', sch, SchedFetch_InvoicePayment);
        test.stopTest();
    }

    @isTest static void test38() {
        test.startTest();
 		SchedFetch_InvoiceRefund SchedFetch_InvoiceRefund = new SchedFetch_InvoiceRefund();
        String sch = '0 0 0 * * ?';
        system.schedule('Test check', sch, SchedFetch_InvoiceRefund);
        test.stopTest();
    }

    @isTest static void test39() {
        test.startTest();
 		SchedFetch_Payment SchedFetch_Payment = new SchedFetch_Payment();
        String sch = '0 0 0 * * ?';
        system.schedule('Test check', sch, SchedFetch_Payment);
        test.stopTest();
    }

    @isTest static void test40() {
        test.startTest();
 		SchedFetch_PaymentMethod SchedFetch_PaymentMethod = new SchedFetch_PaymentMethod();
        String sch = '0 0 0 * * ?';
        system.schedule('Test check', sch, SchedFetch_PaymentMethod);
        test.stopTest();
    }

    @isTest static void test41() {
        test.startTest();
 		SchedFetch_Refund SchedFetch_Refund = new SchedFetch_Refund();
        String sch = '0 0 0 * * ?';
        system.schedule('Test check', sch, SchedFetch_Refund);
        test.stopTest();
    }

    @isTest static void test42() {
        test.startTest();
 		SchedFetch_SLIMap SchedFetch_SLIMap = new SchedFetch_SLIMap();
        String sch = '0 0 0 * * ?';
        system.schedule('Test check', sch, SchedFetch_SLIMap);
        test.stopTest();
    }

    @isTest static void test43() {
        test.startTest();
 		SchedFetch_Subscription SchedFetch_Subscription = new SchedFetch_Subscription();
        String sch = '0 0 0 * * ?';
        system.schedule('Test check', sch, SchedFetch_Subscription);
        test.stopTest();
    }

    /*@isTest static void test44() {
        test.startTest();
 		SchedFetch_SubscriptionLineItem SchedFetch_SubscriptionLineItem = new SchedFetch_SubscriptionLineItem();
        String sch = '0 0 0 * * ?';
        system.schedule('Test check', sch, SchedFetch_SubscriptionLineItem);
        test.stopTest();
    }*/

    @isTest static void test45() {
        test.startTest();
 		SchedClear_SLIMap SchedClear_SLIMap = new SchedClear_SLIMap();
        String sch = '0 0 0 * * ?';
        system.schedule('Test check', sch, SchedClear_SLIMap);
        test.stopTest();
    }
    
    @isTest static void test46() {
        test.startTest();
        System.enqueueJob(new EnqueueQueryMoreZuora());
        test.stopTest();
    }

    @isTest static void test47() {
        Contact c = new Contact(lastname='test',email='test@test.com');
        insert c;
        Account a = new Account(name='test',ZuoraId__c='test',SF_BillTo_Contact__c=c.Id);
        insert a;
        Invoice__c i = new Invoice__c(ZuoraId__c='test',Account__c=a.Id,SuppressTriggeredEmail__c=true);
        insert i;
        test.startTest();
        System.enqueueJob(new InvoicePDFSender(new List<Invoice__c>{i}));
        test.stopTest();
    }
    
    @isTest static void test48() {
        test.startTest();
        System.enqueueJob(new EnqueueAccountInvoiceSend('test'));
        test.stopTest();
    }
    
    @isTest static void test49() {
        ZuoraSyncController.CBAZObjCollection a = ZuoraSyncController.FetchCBACollection();
        a = ZuoraSyncController.FetchCBACollection(Date.today());
        a = ZuoraSyncController.FetchCBACollection('PaymentMethod__c', 'QueryLocator');
    }
    
    @isTest static void test50() {
        Account a = new Account(name='test',ZuoraId__c='test');
        insert a;
        ZuoraSyncController.CBACollectionUpsert(
            new ZuoraSyncController.CBAZObjCollection(
                new List<ZObj.FetchCBA>{
                    (ZObj.FetchCBA)json.deserialize(
                        '{"Id":"test","AccountId":"test"}', 
                        ZObj.FetchCBA.class
                    )
                        },
                new List<ZuoraSyncController.QueryLocator>()
            )
        );
    }
    
    @isTest static void test51() {
        ZObj.RevokeSubReq rsr = new ZObj.RevokeSubReq(Date.today(), Date.today());
        
    }
    
    @isTest static void test52() {
        ZuoraSyncController.CreateBillRunsForPrepayers(new List<ZObj.CreateBillRun> { new ZObj.CreateBillRun('test',Date.today()) });
    }
    
    @isTest static void test53() {
        ZuoraSyncController.UpdateBillingBatches(new List<ZObj.BatchChange>{new ZObj.BatchChange('test','test')});
    }
    
    @isTest static void test54() {
        ZuoraSyncController.InstalmentPaymentRun(new List<ZObj.CreatePayment>{new ZObj.CreatePayment('test','test','test',12.34)});
    }
    
}