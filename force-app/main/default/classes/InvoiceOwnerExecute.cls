global class InvoiceOwnerExecute {
    
    @future(callout=true)
    global static void execute() {
        
        QueryResultHandler Subscriptions = (QueryResultHandler)JSON.deserialize(ZuoraAPIManager.callZuoraAPI(
            'action/query',
            'POST',
            '{"queryString":"select Id, AccountId from Subscription where InvoiceOwnerId=\'8a28f1aa5e7e3966015e803f626918c0\' and CreatedDate < \'' + String.valueOf(Date.today().addDays(-7)) + 'T00:00:00\'' + '"}'
        ), QueryResultHandler.class);
        
        AmendHandler ah = new AmendHandler();
        Integer x = 0;
        while (x<10 && Subscriptions.records.size() > x) {
            ah.requests.add(new Request(Subscriptions.records[x]));
            x++;
        }
        
        ZuoraAPIManager.callZuoraAPI(
            'action/amend',
            'POST',
            JSON.serialize(ah)
        );
    }
    
    global class QueryResultHandler {
        public List<Subscription> records { get; set; }
    }   
    
    global class Subscription {
        public String Id { get; set; }
        public String AccountId { get; set; }
    }
    
    global class AmendHandler {
        public List<Request> requests { get; set; }
        public AmendHandler() { requests = new List<Request>();}
    }
    
    global class Request {
        public List<Amendment> Amendments { get; set; }
        public Request(Subscription Sub) { Amendments = new List<Amendment>{new Amendment(Sub)}; }
    }
    
    global class Amendment {
        public String Type { get; set; }
        public Date ContractEffectiveDate { get; set; }
        public String SubscriptionId { get; set; }
        public String Name { get; set; }
        public String DestinationInvoiceOwnerId { get; set; }
        public Amendment(Subscription Sub) {
            Type = 'OwnerTransfer';
            ContractEffectiveDate = Date.today();
            SubscriptionId = Sub.Id;
            Name = 'Invoice Owner Change';
            DestinationInvoiceOwnerId = Sub.AccountId;
        }
    }
    
}