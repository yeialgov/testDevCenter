@isTest
public class ZuoraFetchQueue_test {
    
    @isTest static void Test1() {
        System.enqueueJob(new ZuoraFetchQueue('ProductCatalog'));
        System.enqueueJob(new ZuoraFetchQueue('Account'));
        System.enqueueJob(new ZuoraFetchQueue('Subscription__c'));
        System.enqueueJob(new ZuoraFetchQueue('SLIMap__c'));
    }
    
    @isTest static void Test2() {
        Test.startTest();
        System.enqueueJob(new ZuoraFetchQueue('SubscriptionLineItem__c:0'));
        Test.stopTest();
        System.enqueueJob(new ZuoraFetchQueue('SubscriptionLineItem__c:1'));
        System.enqueueJob(new ZuoraFetchQueue('SubscriptionLineItem__c:2'));
        System.enqueueJob(new ZuoraFetchQueue('Invoice__c'));
    }
    
    @isTest static void Test3() {
        System.enqueueJob(new ZuoraFetchQueue('InvoiceLineItem__c'));
        System.enqueueJob(new ZuoraFetchQueue('Payment__c'));
        System.enqueueJob(new ZuoraFetchQueue('Refund__c'));
        System.enqueueJob(new ZuoraFetchQueue('InvoicePayment__c'));
    }
    
    @isTest static void Test4() {
        System.enqueueJob(new ZuoraFetchQueue('InvoiceRefund__c'));
        System.enqueueJob(new ZuoraFetchQueue('PaymentMethod__c'));
    }
    
    @isTest static void Test5() {
        ZuoraFetchScheduler p = new ZuoraFetchScheduler('ProductCatalog');
        String sch = '0 12 00 * * ?';
        system.schedule('ProductCatalog', sch, p);
    }
    
    @isTest static void Test6() {
        ZuoraFetchScheduler p = new ZuoraFetchScheduler('ProductCatalog');
        String sch = '0 12 00 * * ?';
        system.schedule('ProductCatalog', sch, p);
    }
    
    @isTest static void Test7() {
        ZObj.FetchCatalog cat = new ZObj.FetchCatalog();
        ZObj.FetchCatalogProducts fcp = new ZObj.FetchCatalogProducts();
        ZObj.FetchCatalogProductRatePlans fcprp = new ZObj.FetchCatalogProductRatePlans();
        ZObj.FetchCatalogProductRatePlanCharges fcprpc = new ZObj.FetchCatalogProductRatePlanCharges();
        ZObj.FetchCatalogPricing fcpricing = new ZObj.FetchCatalogPricing();
        fcprpc.pricing = new List<ZObj.FetchCatalogPricing>{fcpricing};
		fcprp.productRatePlanCharges = new List<ZObj.FetchCatalogProductRatePlanCharges>{fcprpc};
        fcp.productRatePlans = new List<ZObj.FetchCatalogProductRatePlans>{fcprp};
        cat.products = new List<ZObj.FetchCatalogProducts>{fcp};
		fcp.id = 'test';
        fcprp.id = 'test';
        fcprpc.id = 'test';
        fcprpc.name = 'test';
        fcprpc.taxable = true;
        System.enqueueJob(new ProdCatUpsert(0, JSON.serialize(cat)));
    }
}