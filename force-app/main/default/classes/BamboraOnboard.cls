public class BamboraOnboard implements Queueable, Database.AllowsCallouts {
    
    public Final Id MyObVenueId;
    
    public BamboraOnboard(Id iMyObVenueId) {
        MyObVenueId = iMyObVenueId;
    }
    
    public void execute(QueueableContext context) {
        MyObVenue__c v = [SELECT Id, BamboraId__c, Account__r.Target_Product__c, Account__r.CustomerId__c FROM MyObVenue__c WHERE Id = :MyObVenueId LIMIT 1];
        if (v.Account__r.Target_Product__c == 'MINI') {
            system.debug(v.Account__r.CustomerId__c);
            v.BamboraId__c = getBamboraId(String.valueOf(v.Account__r.CustomerId__c));
            update v;
        }
    }
    
    public static String getBamboraId(String CustId) {
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(BamboraOnboarding__c.getAll().get('MINI').API_URL__c);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setBody(json.serialize(new BamboraMINIOnboard(CustId)).replace('_x',''));
        system.debug(req.getBody());
        HttpResponse res;
        if (test.isRunningTest()) { res = new HttpResponse(); res.setBody('{"id":"abc123"}'); } else { res = h.send(req); }
        return ((BamboraResponse)JSON.deserialize(res.getBody(), BamboraResponse.class)).Id;
    }
    
    public class BamboraMINIOnboard {
        public BoardingWrap Boarding;
        public PackageWrap Package_x;
        public PriceWrap Price;
        public PartnerWrap Partner;
        public BamboraMINIOnboard(String CustId) {
            Boarding = new BoardingWrap();
            Package_x = new PackageWrap();
            Price = new PriceWrap();
            Partner = new PartnerWrap(CustId);
        }
    }
    
    public class BoardingWrap {
		public String CultureCode = 'de-DE';
		public String CountryIso3Code = 'DEU';
		public String BackofficeVersion = 'Bambora';
    }
    
    public class PackageWrap {
		public String Code = 'ACCEPTANCE_POS';
		public String TerminalModel = 'PAX A920';
		public String PaymentServiceProvider = 'Payworks';
    }
    
    public class PriceWrap {
		//public String PricePlanName = 'CONNECT_LIGHT';
		public String PricePlanName = 'CONNECT_LIGHT_MINI';
    }
    
    public class PartnerWrap {
        public String Code;
        public String Source;
        public String ReferenceId;
        public String ReferenceEmail;
        public String ExternalReference;
        public PartnerWrap(String CustId) {
            Code = 'A00252810';
            Source = 'Orderbird';
            ReferenceId = '0051p00000AtuSDAAZ';
            ReferenceEmail = 'valeria.meissner@orderbird.com';
            ExternalReference = CustId;
        }
    }
    
    public class BamboraResponse {
        public String Id;
    }
    
}