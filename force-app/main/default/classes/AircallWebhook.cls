@RestResource(urlMapping='/aircall')
global class AircallWebhook {
    
    private static String username = '2309ddf2879968f710d27dd5c3579f04';
    private static String password = '4f1b03edce94e18510a78581eaf6ae8d';
    
    @HttpPost
    global static void call_created() {
        RestRequest req = System.RestContext.request;
        AircallPayload payload = (AircallPayload)JSON.deserialize(req.requestBody.toString().replace('"number"','"numberX"'), AircallPayload.class);
		BusinessHours bh = [SELECT Id FROM BusinessHours WHERE IsDefault=true];
        Boolean AfterHours = !BusinessHours.isWithin(bh.id, Datetime.now());
        List<Aircall_Forwarding_Rule__c> Rules = [SELECT Id, Transfer_to__c FROM Aircall_Forwarding_Rule__c WHERE Transfer_From_NumberId__c = :payload.data.numberX.id AND After_Hours__c = :AfterHours];
        system.debug(json.serialize(Rules));
        system.debug(req.requestBody.toString());
        system.debug(json.serialize(payload));
        if (Rules.size() > 0 && payload.data.numberX.open) {
	        Http http = new Http();
            HttpRequest reqOut = new HttpRequest();
            reqOut.setMethod('POST');
			reqOut.setEndpoint('callout:Aircall/v1/calls/' + payload.data.id + '/transfers');
            reqOut.setHeader('content-type', 'application/json');
            reqOut.setBody('{"number": "' + Rules[0].Transfer_to__c + '"}');
            HTTPResponse res;
            if (!Test.isRunningTest()) res = http.send(reqOut);
        }
        System.RestContext.response.statusCode = 200;        
    }
    
    @HttpGet
    global static void ping() {
        System.RestContext.response.statusCode = 200;
        System.RestContext.response.responseBody = Blob.valueOf('success');
    }
    
    public class AircallPayload {
        public String event { get; set; }
        public String token { get; set; }
        public AircallData data { get; set; }
    }
    
    public class AircallData {
        public String id { get; set; }
        public AircallNumber numberX { get; set; }
    }
    
    public class AircallNumber {
        public Integer id { get; set; }
        public Boolean open { get; set; }
    }
    
}