public class ZuoraFetchQueue implements Queueable, Database.AllowsCallouts {
    
    public Final String FetchType;
    
    public ZuoraFetchQueue(String iFetchType) {
        FetchType = iFetchType;
    }
    
    public void execute(QueueableContext context) {
        
        if (FetchType == 'ProductCatalog') {
            if (!test.isRunningTest()) System.enqueueJob(new ProdCatUpsert(0, JSON.serialize(ZuoraSyncController.FetchCatalog())));
        }
        
        if (FetchType == 'Account') {
            if (!test.isRunningTest()) ZuoraSyncController.AccountCollectionUpsert(ZuoraSyncController.FetchAccountCollection(Date.today().addDays(-2)));
        }
        
        if (FetchType == 'Subscription__c') {
            if (!test.isRunningTest()) ZuoraSyncController.SubscriptionCollectionUpsert(ZuoraSyncController.FetchSubscriptionCollection(Date.today().addDays(-2)));
        }
        
        if (FetchType == 'SLIMap__c') {
            if (!test.isRunningTest()) ZuoraSyncController.SLIMapCollectionUpsert(ZuoraSyncController.FetchSLIMapCollection(Date.today().addDays(-2)));
        }
        
        if (FetchType == 'SubscriptionLineItem__c:0') {
            if (!test.isRunningTest()) ZuoraSyncController.SubItemCollectionUpsert(ZuoraSyncController.FetchSubItemCollection(Date.today().addDays(-2), 0), 0);
        }
        
        if (FetchType == 'SubscriptionLineItem__c:1') {
            if (!test.isRunningTest()) ZuoraSyncController.SubItemCollectionUpsert(ZuoraSyncController.FetchSubItemCollection(Date.today().addDays(-2), 1), 1);
        }
        
        if (FetchType == 'SubscriptionLineItem__c:2') {
            if (!test.isRunningTest()) ZuoraSyncController.SubItemCollectionUpsert(ZuoraSyncController.FetchSubItemCollection(Date.today().addDays(-2), 2), 2);
        }
        
        if (FetchType == 'Invoice__c') {
            if (!test.isRunningTest()) ZuoraSyncController.InvoiceCollectionUpsert(ZuoraSyncController.FetchInvoiceCollection(Date.today().addDays(-2)));
        }
        
        if (FetchType == 'LargeAccount_Invoice__c') {
            List<String> AcctIds = new List<String>();
            for (Account a : [SELECT Id, ZuoraId__c FROM Account WHERE Invoice_Count__c > 200]) { AcctIds.add(a.ZuoraId__c); }
            if (!test.isRunningTest()) ZuoraSyncController.InvoiceCollectionUpsert(ZuoraSyncController.FetchInvoiceCollection(AcctIds, Date.today().addDays(-2)),true,true);
        }

        if (FetchType == 'InvoiceLineItem__c') {
            if (!test.isRunningTest()) ZuoraSyncController.InvItemCollectionUpsert(ZuoraSyncController.FetchInvItemCollection(Date.today().addDays(-2)));
        }
        
        if (FetchType == 'Payment__c') {
            if (!test.isRunningTest()) ZuoraSyncController.PaymentCollectionUpsert(ZuoraSyncController.FetchPaymentCollection(Date.today().addDays(-2)));
        }
        
        if (FetchType == 'Refund__c') {
            if (!test.isRunningTest()) ZuoraSyncController.RefundCollectionUpsert(ZuoraSyncController.FetchRefundCollection(Date.today().addDays(-2)));
        }
        
        if (FetchType == 'InvoicePayment__c') {
            if (!test.isRunningTest()) ZuoraSyncController.InvPmtCollectionUpsert(ZuoraSyncController.FetchInvPmtCollection(Date.today().addDays(-2)));
        }
        
        if (FetchType == 'InvoiceRefund__c') {
            if (!test.isRunningTest()) ZuoraSyncController.InvRefCollectionUpsert(ZuoraSyncController.FetchInvRefCollection(Date.today().addDays(-2)));
        }
        
        if (FetchType == 'PaymentMethod__c') {
            if (!test.isRunningTest()) ZuoraSyncController.PmtMtdCollectionUpsert(ZuoraSyncController.FetchPmtMtdCollection(Date.today().addDays(-2)));
        }
        
        if (FetchType == 'Amendment__c') {
            if (!test.isRunningTest()) ZuoraSyncController.AmendmentCollectionUpsert(ZuoraSyncController.FetchAmendmentCollection(Date.today().addDays(-2)));
        }
        
        if (FetchType == 'CreditBalanceAdjustment__c') {
            if (!test.isRunningTest()) ZuoraSyncController.CBACollectionUpsert(ZuoraSyncController.FetchCBACollection(Date.today().addDays(-2)));
        }
        
    }
}