@isTest(seeAllData=true) public class InsightsSender_test {

    static TestMethod void test1() {
        Account a = new Account(name='Test');
        insert a;
        Contact c = new Contact(lastname='Test', AccountId=a.Id);
        insert c;
        MyObVenue__c v = new MyObVenue__c(Contact__c=c.Id, VenueName__c='8420964Test', InsightsEmail__c='sfdc@orderbird.com');
        insert v;
        insert new DataInsight__c(Relevance__c=.9,Venue_SFId__c=v.Id, Metric__c='Revenue', Value__c='123', Calculation_Timestamp__c = Datetime.now());
        insert new DataInsight__c(Relevance__c=.9,Venue_SFId__c=v.Id, Metric__c='Card_Payments_Percentage', Value__c='{"percentage":16.96,"industry":45.48,"comparison":"below industry"}', Calculation_Timestamp__c = Datetime.now());
        insert new DataInsight__c(Relevance__c=.9,Venue_SFId__c=v.Id, Metric__c='Hourly Revenue', Value__c='{"hours":[17,18,19,20,21,22,23,0],"revenue":[4.00,93.00,121.50,205.00,547.00,328.00,174.50,119.00]}', Calculation_Timestamp__c = Datetime.now());
        insert new DataInsight__c(Relevance__c=.9,Venue_SFId__c=v.Id, Metric__c='Week Comparison', Value__c='{"revenue":1592.00,"previous"487.50,"change":2.2656410256410256}', Calculation_Timestamp__c = Datetime.now());
        insert new DataInsight__c(Relevance__c=.9,Venue_SFId__c=v.Id, Metric__c='Revenue Watermark', Value__c='{"rank":1, "number":20, "date":null, "top":true, "overall":true}', Calculation_Timestamp__c = Datetime.now());
        insert new DataInsight__c(Relevance__c=.9,Venue_SFId__c=v.Id, Metric__c='Average Invoice', Value__c='{"current":53.07,"last":48.75,"change":0.0885470085470085}', Calculation_Timestamp__c = Datetime.now());
        insert new DataInsight__c(Relevance__c=.9,Venue_SFId__c=v.Id, Metric__c='Takeaway Percentage', Value__c='{"current":53.07,"last":48.75}', Calculation_Timestamp__c = Datetime.now());
        insert new DataInsight__c(Relevance__c=.9,Venue_SFId__c=v.Id, Metric__c='Top Food Items', Value__c='[{"i":"Divers. Vorspeisen","n":4,"d":5},{"i":"7 Gurkensalat 凉拌黄瓜","n":3,"d":1},{"i":"77 Mapo 麻婆豆腐","n":2,"d":81},{"i":"18 Hühnerfüßsalat 凤爪","n":2,"d":5},{"i":"16 Sellerie 芹菜","n":2,"d":27}]', Calculation_Timestamp__c = Datetime.now());
        insert new DataInsight__c(Relevance__c=.9,Venue_SFId__c=v.Id, Metric__c='Top Beverage Items', Value__c='[{"i":"Weißwein trocken 0.2l","n":4,"d":8},{"i":"Selters 0,75l","n":2,"d":1},{"i":"Jasmin Tee","n":2,"d":8},{"i":"Chysanthemen Tee","n":2,"d":8},{"i":"Alsterwasser 0.4l","n":2,"d":4}]', Calculation_Timestamp__c = Datetime.now());
        insert new DataInsight__c(Relevance__c=.9,Venue_SFId__c=v.Id, Metric__c='Food and Drinks Ratios', Value__c='{"current":{"food":66.67,"drinks":33.33,"others":0.0},"last":{"food":59.43,"drinks":40.57,"others":0.0}}', Calculation_Timestamp__c = Datetime.now());
        //
        Account a1 = new Account(name='Test');
        insert a1;
        Contact c1 = new Contact(lastname='Test', AccountId=a.Id);
        insert c1;
        MyObVenue__c v1 = new MyObVenue__c(InsightsVersion__c='2',Contact__c=c.Id, VenueName__c='8420964Test', InsightsEmail__c='sfdc@orderbird.com');
        insert v1;
        insert new DataInsight__c(Relevance__c=.9,Venue_SFId__c=v1.Id, Metric__c='Revenue', Value__c='123', Calculation_Timestamp__c = Datetime.now());
        insert new DataInsight__c(Relevance__c=.9,Venue_SFId__c=v1.Id, Metric__c='Card_Payments_Percentage', Value__c='{"percentage":16.96,"industry":45.48,"comparison":"below industry"}', Calculation_Timestamp__c = Datetime.now());
        insert new DataInsight__c(Relevance__c=.9,Venue_SFId__c=v1.Id, Metric__c='Hourly Revenue', Value__c='{"hours":[17,18,19,20,21,22,23,0],"revenue":[4.00,93.00,121.50,205.00,547.00,328.00,174.50,119.00]}', Calculation_Timestamp__c = Datetime.now());
        insert new DataInsight__c(Relevance__c=.9,Venue_SFId__c=v1.Id, Metric__c='Week Comparison', Value__c='{"revenue":1592.00,"previous"487.50,"change":2.2656410256410256}', Calculation_Timestamp__c = Datetime.now());
        insert new DataInsight__c(Relevance__c=.9,Venue_SFId__c=v1.Id, Metric__c='Revenue Watermark', Value__c='{"rank":1, "number":20, "date":null, "top":true, "overall":true}', Calculation_Timestamp__c = Datetime.now());
        insert new DataInsight__c(Relevance__c=.9,Venue_SFId__c=v1.Id, Metric__c='Average Invoice', Value__c='{"current":53.07,"last":48.75,"change":0.0885470085470085}', Calculation_Timestamp__c = Datetime.now());
        insert new DataInsight__c(Relevance__c=.9,Venue_SFId__c=v1.Id, Metric__c='Takeaway Percentage', Value__c='{"current":53.07,"last":48.75}', Calculation_Timestamp__c = Datetime.now());
        insert new DataInsight__c(Relevance__c=.9,Venue_SFId__c=v1.Id, Metric__c='Top Food Items', Value__c='[{"i":"Divers. Vorspeisen","n":4,"d":5},{"i":"7 Gurkensalat 凉拌黄瓜","n":3,"d":1},{"i":"77 Mapo 麻婆豆腐","n":2,"d":81},{"i":"18 Hühnerfüßsalat 凤爪","n":2,"d":5},{"i":"16 Sellerie 芹菜","n":2,"d":27}]', Calculation_Timestamp__c = Datetime.now());
        insert new DataInsight__c(Relevance__c=.9,Venue_SFId__c=v1.Id, Metric__c='Top Beverage Items', Value__c='[{"i":"Weißwein trocken 0.2l","n":4,"d":8},{"i":"Selters 0,75l","n":2,"d":1},{"i":"Jasmin Tee","n":2,"d":8},{"i":"Chysanthemen Tee","n":2,"d":8},{"i":"Alsterwasser 0.4l","n":2,"d":4}]', Calculation_Timestamp__c = Datetime.now());
        insert new DataInsight__c(Relevance__c=.9,Venue_SFId__c=v1.Id, Metric__c='Food and Drinks Ratios', Value__c='{"current":{"food":66.67,"drinks":33.33,"others":0.0},"last":{"food":59.43,"drinks":40.57,"others":0.0}}', Calculation_Timestamp__c = Datetime.now());
        Database.executeBatch(new InsightsSender(' AND VenueName__c=\'8420964Test\'','TODAY'));
    }
    
    static TestMethod void test2() {
        test.startTest();
 		InsightsSendScheduler dbs = new InsightsSendScheduler();
        String sch = '0 0 23 * * ?';
        system.schedule('Test check', sch, dbs);
        test.stopTest();
    }
    
    static TestMethod void test3() {
        test.startTest();
 		InsightsSubscription dbs = new InsightsSubscription();
        String sch = '0 0 23 * * ?';
        system.schedule('Test sub', sch, dbs);
        test.stopTest();
    }
    
    static TestMethod void testSG() {
        SendGrid.PersonalizationWrapper PW = new SendGrid.PersonalizationWrapper('test@test.com',null);
        SendGrid.ToWrapper TW = new SendGrid.ToWrapper('test@test.com');
    }
    
}