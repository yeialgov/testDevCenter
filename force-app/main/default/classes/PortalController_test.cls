@isTest public class PortalController_test {

    static TestMethod void test() {
        Account a = new Account(name='test');
        insert a;
        Contact c = new Contact(lastname='test', accountid=a.id, email='test@test.com');
        insert c;
        a.SF_BillTo_Contact__c = c.Id;
        update a;
        MyObVenue__c v = new MyObVenue__c(contact__c=c.Id,myorderbirdid__c='123');
        insert v;
        Invoice__c i = new Invoice__c(name='test', account__c = a.id, status__c = 'posted');
        insert i;
        Opportunity o = new Opportunity(LAC_Id__c = '110', AccountId = a.Id, name='test', CloseDate = date.today(), StageName='Potential');
        insert o;
        Quote q = new Quote(OpportunityId = o.Id, name='test');
        insert q;
        Subscription__c s = new Subscription__c(Account__c = a.id, ZuoraId__c = 'test');
        insert s;
        ProductCategory__c pc = new ProductCategory__c(ProductType__c = 'POS Service+Device', ZuoraId__c = 'test');
        insert pc;
        Product2 p1 = new Product2(ProductCategory__c = pc.id, name='test');
        insert p1;
        insert new SubscriptionLineItem__c(Subscription__c = s.id, product__c = p1.id, EffectiveStartDate__c = date.today(), EffectiveEndDate__c = date.today(), ZuoraId__c = 'test');
        insert new SubscriptionLineItem__c(Subscription__c = s.id, product__c = p1.id, EffectiveStartDate__c = date.today()+1, EffectiveEndDate__c = date.today()+1, ZuoraId__c = 'test1');
        String token = PortalToken.encryptToken('123');
        PortalController.LicenseWrapper pclw = new PortalController.LicenseWrapper(new list<aggregateresult>(), new list<aggregateresult>(), new list<aggregateresult>(), new list<aggregateresult>(), new list<aggregateresult>(), new list<aggregateresult>(), new list<aggregateresult>(), new list<aggregateresult>());
        system.debug(PortalController.getAccountInfo(token));
        system.debug(PortalController.verifyConnection(token, 'test'));
        system.debug(PortalController.getAccountInfo(token));
        system.debug(PortalController.getToken(a.Id));
        system.debug(PortalController.getInvoices(token));
        system.debug(PortalController.getTSE(token));
        system.debug(PortalController.getFinanzamt(token, '12345'));
        Map<String, Object> LetterMap = (Map<String, Object>)JSON.deserializeUntyped(PortalController.createP148Letter(token, '{"Venue":{"Account__r":{"Primary_Contact__r":{}}},"Finanzamt":{}}', true));
        Id LetterId = (String)LetterMap.get('StringValue');
        system.debug(PortalController.downloadP148Letter(token, 'test'));
        system.debug(PortalController.createP148Email(token, 'test'));
        system.debug(PortalController.getP148Key(token, 'test'));
        system.debug(PortalController.getInvoice(token, i.id));
        system.debug(PortalController.getQuotes(token));
        system.debug(PortalController.getQuote(token, q.Id));	
        system.debug(PortalController.getInvoicePDF(token, 'test'));
        system.debug(PortalController.CreateLicenseQuote(token, '[{"Type":"TSE","Frequency":"12","Num":1}]'));
        //system.debug(PortalController.getLicenses(token));
    }

    static TestMethod void test2() {
        Account a = new Account(name='test');
        insert a;
        Contact c = new Contact(lastname='test', accountid=a.id, email='test@test.com');
        insert c;
        a.SF_BillTo_Contact__c = c.Id;
        update a;
        MyObVenue__c v = new MyObVenue__c(contact__c=c.Id,myorderbirdid__c='123');
        insert v;
        Invoice__c i = new Invoice__c(name='test', account__c = a.id, status__c = 'posted');
        insert i;
        Opportunity o = new Opportunity(LAC_Id__c = '110', AccountId = a.Id, name='test', CloseDate = date.today(), StageName='Potential');
        insert o;
        Quote q = new Quote(OpportunityId = o.Id, name='test');
        insert q;
        Subscription__c s = new Subscription__c(Account__c = a.id, ZuoraId__c = 'test');
        insert s;
        ProductCategory__c pc = new ProductCategory__c(ProductType__c = 'POS Service+Device', ZuoraId__c = 'test');
        insert pc;
        Product2 p1 = new Product2(ProductCategory__c = pc.id, name='test');
        insert p1;
        insert new SubscriptionLineItem__c(Subscription__c = s.id, product__c = p1.id, EffectiveStartDate__c = date.today(), EffectiveEndDate__c = date.today(), ZuoraId__c = 'test');
        insert new SubscriptionLineItem__c(Subscription__c = s.id, product__c = p1.id, EffectiveStartDate__c = date.today()+1, EffectiveEndDate__c = date.today()+1, ZuoraId__c = 'test1');
        String token = PortalToken.encryptToken('123');
        system.debug(PortalController.getAccountInfo(token));
        system.debug(PortalController.verifyConnection(token, 'test'));
        system.debug(PortalController.getAccountInfo(token));
        system.debug(PortalController.getToken(a.Id));
        system.debug(PortalController.getTSE(token));
        Map<String, Object> LetterMap = (Map<String, Object>)JSON.deserializeUntyped(PortalController.createP148Letter(token, '{"Venue":{"Account__r":{"Primary_Contact__r":{}}},"Finanzamt":{}}', true));
        Id LetterId = (String)LetterMap.get('StringValue');
        system.debug(PortalController.CreateLicenseQuote(token, '[{"Type":"TSE","Frequency":"12","Num":1}]'));
        system.debug(PortalController.getLicenses(token));
    }
}