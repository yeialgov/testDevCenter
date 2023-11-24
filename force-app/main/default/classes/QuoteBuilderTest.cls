@isTest(SeeAllData=true)
public class QuoteBuilderTest {

    @isTest static void test1() {
        Account a = new Account(name='test');
        insert a;
        SubscriptionPickerController.getSubscriptionsFromCase(a.Id);
        Boolean b = NewQuoteController.getAcctMgmtPerm();
    }
    
    @isTest static void test2() {
        Account a = new Account(name='test');
        insert a;
        Opportunity o = new Opportunity(Name='test', StageName='New', CloseDate=Date.today(), AccountId=a.Id, LAC_Shorthand__c='Walk-In');
        insert o;
        NewQuoteController.JItem jitem1 = new NewQuoteController.JItem();
        jitem1.isBundle = false;
        jitem1.isBundleItem = false;
        NewQuoteController.JDetail jdetail1 = new NewQuoteController.JDetail();
        jdetail1.PayByInstalment = false;
        jdetail1.WireFirstPayment = false;
        NewQuoteController.JItemList jitemlist = new NewQuoteController.JItemList();
        jitemlist.Items = new List<NewQuoteController.JItem>{ jitem1 };
        jitemlist.Details = jdetail1;
        map<id, ProductBundle__c> bundlemap = new map<id, ProductBundle__c>();
        for (ProductBundle__c bundle : ((NewQuoteController.JPricingWrapper)JSON.deserialize(NewQuoteController.getPrices('EUR'), NewQuoteController.JPricingWrapper.class)).Bundles){
            bundlemap.put(bundle.id, bundle);
        }
        map<id, PricebookEntry> pricemap = new map<id, PricebookEntry>();
        for (PricebookEntry pm : ((NewQuoteController.JPricingWrapper)JSON.deserialize(NewQuoteController.getPrices('EUR'), NewQuoteController.JPricingWrapper.class)).Pricebook){
            pricemap.put(pm.id, pm);
        }
        NewQuoteController.upsertQuote(
            JSON.serialize(jitemlist),
            JSON.serialize(bundlemap),
            JSON.serialize(pricemap),
            'null',
            o.Id,
            null,
            'EUR'
        );
    }

    @isTest static void test3() {
        Account a = new Account(name='test');
        insert a;
        Opportunity o = new Opportunity(Name='test', StageName='New', CloseDate=Date.today(), AccountId=a.Id, LAC_Shorthand__c='Walk-In');
        insert o;
        Quote q = new Quote(OpportunityId=o.Id,Name='test');
        insert q;
        NewQuoteController.JItem jitem1 = new NewQuoteController.JItem();
        jitem1.isBundle = false;
        jitem1.isBundleItem = false;
        NewQuoteController.JDetail jdetail1 = new NewQuoteController.JDetail();
        jdetail1.PayByInstalment = false;
        jdetail1.WireFirstPayment = false;
        jdetail1.PayPalLink = false;
        NewQuoteController.JItemList jitemlist = new NewQuoteController.JItemList();
        jitemlist.Items = new List<NewQuoteController.JItem>{ jitem1 };
        jitemlist.Details = jdetail1;
        map<id, ProductBundle__c> bundlemap = new map<id, ProductBundle__c>();
        for (ProductBundle__c bundle : ((NewQuoteController.JPricingWrapper)JSON.deserialize(NewQuoteController.getPrices('EUR'), NewQuoteController.JPricingWrapper.class)).Bundles){
            bundlemap.put(bundle.id, bundle);
        }
        map<id, PricebookEntry> pricemap = new map<id, PricebookEntry>();
        for (PricebookEntry pm : ((NewQuoteController.JPricingWrapper)JSON.deserialize(NewQuoteController.getPrices('EUR'), NewQuoteController.JPricingWrapper.class)).Pricebook){
            pricemap.put(pm.id, pm);
        }
        NewQuoteController.upsertQuote(
            JSON.serialize(jitemlist),
            JSON.serialize(bundlemap),
            JSON.serialize(pricemap),
            'null',
            o.Id,
            q.Id,
            'EUR'
        );
    }
    
    @isTest static void test4() {
        Account a = new Account(name='test');
        insert a;
        Opportunity o = new Opportunity(Name='test', StageName='New', CloseDate=Date.today(), AccountId=a.Id, LAC_Shorthand__c='Walk-In');
        insert o;
        Quote q = new Quote(OpportunityId=o.Id,Name='test');
        insert q;
        NewQuoteController.forecastInvoice(q.Id);
        String s = NewQuoteController.getCatalog('EUR', a.Id);
        s = NewQuoteController.getContacts(q.Id, 'Quote');
        s = NewQuoteController.getQuoteLineItems(q.Id);
        s = NewQuoteController.getSubscriptionLineItems(o.Id);
        s = NewQuoteController.getSendTemplates('Quote');
        NewQuoteController.JBundle JBundle = new NewQuoteController.JBundle();
        boolean b = NewQuoteController.getBamboraEligibility(q.ID);
    }
    
    /*@isTest static void pdfemail() {
        Account a = new Account(name='test');
        insert a;
        Contact c = new Contact(AccountId=a.Id, Lastname='test', Email='bart.collins@orderbird.com');
        insert c;
        String ContactIdsString = JSON.serialize(new List<String>{c.Id});
        Opportunity o = new Opportunity(Name='test', StageName='New', CloseDate=Date.today(), AccountId=a.Id, LAC_Shorthand__c='Walk-In');
        insert o;
        Quote q = new Quote(OpportunityId=o.Id,Name='test');
        insert q;
        String OWEAId = [SELECT Id FROM OrgWideEmailAddress][0].Id;
        Boolean b = NewQuoteController.sendPdfEmails(
            String.valueOf(q.Id), 
            ContactIdsString, 
            '[]',
            'Quote',
            'EmailSubject',
            'EmailText',
            '[]',
            OWEAId
        );
    }*/
    
}