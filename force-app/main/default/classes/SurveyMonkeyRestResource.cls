@RestResource(urlMapping='/SurveyMonkey')
global class SurveyMonkeyRestResource {

    // https://orderbird.force.com/SurveyMonkey/services/apexrest/SurveyMonkey
        
    @HttpPost
    global static void SurveyCallback() {
        String body = '';
        try { body = RestContext.request.requestBody.toString(); } catch (exception e) {}
        if (test.isRunningTest()) body = '{"resources":{"respondent_id":"test","recipient_id":"test","collector_id":"test"}}';
        CallbackJSON cbj = (CallbackJSON)JSON.deserialize(body, CallbackJSON.class);
        SurveyMonkeyAPI.getResponse(cbj.resources.respondent_id, cbj.resources.recipient_id, cbj.resources.collector_id);
    }
    
    public class CallbackJSON {
        public ResourcesJSON resources { get; set; }
    }
    
    public class ResourcesJSON {
        public String respondent_id { get; set; }
        public String recipient_id { get; set; }
        public String collector_id { get; set; }
    }
    
    @HttpGet
    global static void TestEndpoint() {
        system.debug('received head post; endpoint confirmed');
    }

}