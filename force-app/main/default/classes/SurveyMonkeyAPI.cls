public class SurveyMonkeyAPI {

    //public static String Token = 'AdUc8IXFTVjac2z0WU5Yt5EiRkjWXSJ-AfuAoKxCMwVwQjgjxYWAAff-DHmxdS0hb3GqKcWV.5q6-hTt47P5siJQn3eCv0bc-mx3v29L2Bj86Fyu0MCfUUHNLMiPP7Yr';
    public static String Token = 'Y5.KLTJGu1dKaO773XiZTmBGxWgMuOWCgAvHqyiLc2LrwhfF1vFuWNXESqvGuNGKhRXZUif6xxjeqZMQ1fGHDv-qlHWEJyCpUwNcaOKBJYrc7OkyqAH.-HAmnhjo0Hpw';
    public static String Endpoint = 'https://api.surveymonkey.net';
    
    public static Map<String, String> SurveyMap = new Map<String, String>{
        'German' => '151631860',
        'English' => '152258756',
        'French' => '152259317'
    };

    public static HttpResponse getResponse(Http h, HttpRequest r) {
        if (!Test.isRunningTest()) {
            system.debug('request: ' + r.getBody());
            HttpResponse res = h.send(r);
            system.debug('response: ' + res.getBody());
            return res;
        }
        // for testing
        HttpResponse res = new HttpResponse();
        if (
            r.getMethod() == 'GET'
            && (
                r.getEndpoint().contains('collectors?sort_by=id&') 
                || r.getEndpoint().contains('messages') 
                || r.getEndpoint() == Endpoint + '/v3/surveys/surveyId/pages'
                || r.getEndpoint() == Endpoint + '/v3/surveys/surveyId/pages/test/questions'
            )
        ) {
            res.setBody('{"data":[{"id":"test","heading":"test"}]}');
        } else if (
            r.getMethod() == 'POST'
            && (
                r.getEndpoint().contains('messages')
                && !r.getEndpoint().contains('bulk')
            ) || (
                r.getEndpoint().contains('collectors')
                && !r.getEndpoint().contains('details')
            )
        ) {
            res.setBody('{"id":"test"}');
        } else if (
            r.getEndpoint() == Endpoint + '/v3/surveys/surveyId/pages/test/questions/test'
        ) {
            res.setBody('{"answers":[{"choices":[{"id":"test","text":"test","position":0}]}]}');
        } else if (
            r.getEndpoint().contains('responses')
            && r.getEndpoint().contains('details')
        ) {
            res.setBody('{"metadata":{"contact":{"custom1":{"value":"a1u9E000000GZr2QAG"}}},"pages":[{"questions":[{"answers":[{"choice_id":"cid"}]}]}]}');
        }
        return res;
    }
        
    public static Map<String, Object> getSurveyFolders() {
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(Endpoint + '/v3/survey_folders');
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Bearer ' + Token);
        //req.setBody(reqBody);

        HttpResponse res = getResponse(h, req);
        return (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
    }
    
    public static Map<String, Object> getSurveys() {
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(Endpoint + '/v3/surveys?folder_id=1709937');
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Bearer ' + Token);
        //req.setBody(reqBody);

        HttpResponse res = getResponse(h, req);
        return (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
    }
    
    public static String XXgetFirstSurvey(Map<String,Object> ObjMap) {
        List<Object> data = (List<Object>)ObjMap.get('data');
        Map<String, Object> survey = (Map<String, Object>)data[0];
        system.debug(json.serializePretty(survey));
        return (String)survey.get('id');
    }
    
    public static String createCollector(String SurveyId) {
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(Endpoint + '/v3/surveys/' + SurveyId + '/collectors');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Bearer ' + Token);
        req.setBody(JSON.serialize(new CollectorWrapper()));

        HttpResponse res = getResponse(h, req);
        //return res.getBody();
        return (String)((Map<String, Object>)JSON.deserializeUntyped(res.getBody())).get('id');
    }
    
    public static String createMessage(String CollectorId, String MessageId) {
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(Endpoint + '/v3/collectors/' + CollectorId + '/messages');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Bearer ' + Token);
        req.setBody(JSON.serialize(new CopyMessageWrapper(CollectorId, MessageId)));
        system.debug(req.getBody());
        HttpResponse res = getResponse(h, req);
        system.debug(res.getBody());
        return (String)((Map<String, Object>)JSON.deserializeUntyped(res.getBody())).get('id');
    }
    
    public static String createMessage(
        String NewCollectorId, String OldCollectorId, String MessageId
    ) {
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(Endpoint + '/v3/collectors/' + NewCollectorId + '/messages');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Bearer ' + Token);
        req.setBody(JSON.serialize(new CopyMessageWrapper(OldCollectorId, MessageId)));
        system.debug(req.getBody());
        HttpResponse res = getResponse(h, req);
        system.debug(res.getBody());
        return (String)((Map<String, Object>)JSON.deserializeUntyped(res.getBody())).get('id');
    }
    
    public static String getMessage(String CollectorId) {
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(Endpoint + '/v3/collectors/' + CollectorId + '/messages');
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Bearer ' + Token);

        HttpResponse res = getResponse(h, req);
        return ((JSONWithDataList)JSON.deserialize(res.getBody(),JSONWithDataList.class)).data[0].id;
    }

    public static String deleteCollector(String CollectorId) {
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(Endpoint + '/v3/collectors/' + CollectorId);
        req.setMethod('DELETE');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Bearer ' + Token);

        HttpResponse res = getResponse(h, req);
        return res.getBody();
    }
    
    @future(callout=true)
    public static void addRecipients(String Language, String ASRecordJSON) {
        List<AutomatedSurvey__c> ASRecords = (List<AutomatedSurvey__c>)JSON.deserialize(ASRecordJSON, List<AutomatedSurvey__c>.class);
        String CollectorId = getCollector(SurveyMap.get(Language));
        String OldMessageId = getMessage(CollectorId);
        String MessageId = createMessage(CollectorId, OldMessageId);
        //String MessageId = createMessage(CollectorId);
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(Endpoint + '/v3/collectors/' + CollectorId + '/messages/' + MessageId + '/recipients/bulk');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Bearer ' + Token);
        List<ASContactWrapper> ASCWs = new List<ASContactWrapper>();
        for (AutomatedSurvey__c ausu : ASRecords) {
            ASCWs.add(new ASContactWrapper(ausu));
        }
        req.setBody(JSON.serialize(new ASWrapper(ASCWs)).replace('xx1','1'));

        HttpResponse res = getResponse(h, req);
        sendSurveys(CollectorId, MessageId);
    }

    @future(callout=true)
    public static void newMonthCollector() {
        for (String Language : SurveyMap.keySet()) {
            String OldCollectorId = getCollector(SurveyMap.get(Language));
            String NewCollectorId = createCollector(SurveyMap.get(Language));
            createWebhook(NewCollectorId);
            String OldMessageId = getMessage(OldCollectorId);
            String MessageId = createMessage(NewCollectorId, OldCollectorId, OldMessageId);
        }
    }
    
    @future(callout=true)
    public static void getResponse(String ResponseId, String RecipientId, String CollectorId) {
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(Endpoint + '/v3/collectors/' + CollectorId + '/responses/' + ResponseId + '/details');
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Bearer ' + Token);

        HttpResponse res = getResponse(h, req);
        JSONResponse response = (JSONResponse)JSON.deserialize(res.getBody(),JSONResponse.class);

        String comment;

        Set<String> answerIds = new Set<String>();
        for (JSONPage page : response.pages) {
            for (JSONQuestion question : page.questions) {
                for (JSONAnswer answer : question.answers) {
                    if (answer.choice_id != null) answerIds.add(answer.choice_id);
                    if (answer.text != null) comment = answer.text;
                }
            }
        }

        Map<String, Decimal> ValueMap = new Map<String, Decimal>();
        for (
            AutomatedSurveyAnswer__c asa : [
                SELECT Question__r.Field__c, AnswerId__c, Value__c
                FROM AutomatedSurveyAnswer__c
                WHERE AnswerId__c IN :answerIds
            ]
        ) {
            ValueMap.put(asa.Question__r.Field__c, asa.Value__c);
        }

        String queryString = 'SELECT ';
        for (String fieldName : ValueMap.keySet()) {
            queryString += fieldName + ', ';
        }
        queryString += 'Id, Comment__c FROM AutomatedSurvey__c WHERE Id = \'';
        queryString += response.metadata.contact.custom1.value;
        queryString += '\' LIMIT 1';

        try {
            AutomatedSurvey__c ausu = Database.query(queryString);
            ausu.DateResponded__c = Date.today();
            ausu.Comment__c = comment;

            for (String fieldName : ValueMap.keySet()) {
                ausu.put(fieldName, ValueMap.get(fieldName));
            }

            update ausu;
	
            if (ausu.NPS__c != null) System.enqueueJob(new SlackNPS(ausu.Id));

        } catch(exception e) {}
        
    }

    public class CollectorWrapper {
        public String type { get; set; }
        public String sender_email { get; set; }
        public String name { get; set; }
        public CollectorWrapper() {
            type = 'email';
            sender_email = 'knowledge@orderbird.com';
            Date t = Date.today();
            name = 'Integration Collector '
                + String.valueOf(t.year()) + '-'
                + String.valueOf(t.month());
        }
    }
    
    public class CopyMessageWrapper {
        public String from_collector_id { get; set; }
        public String from_message_id { get; set; }
        public Boolean include_recipients { get; set; }
        public CopyMessageWrapper(String CollectorId, String MessageId) {
            from_collector_id = CollectorId;
            from_message_id = MessageId;
            include_recipients = false;
        }
    }

    public class ASWrapper {
        public List<ASContactWrapper> contacts { get; set; }
        public ASWrapper(List<ASContactWrapper> c) {
            contacts = c;
        }
    }
    
    public class ASContactWrapper {
        public String email { get; set; }
        public String first_name { get; set; }
        public String last_name { get; set; }
        public ASCustomFields custom_fields { get; set; }
        public ASContactWrapper (AutomatedSurvey__c ausu) {
            email = ausu.Contact__r.Email;
            //first_name = ausu.Contact__r.FirstName;
            //last_name = ausu.Contact__r.LastName;
            first_name = 'Orderbird';
            last_name = 'Customer';
            custom_fields = new ASCustomFields(ausu.Id);
        }
    }
    
    public class ASCustomFields {
        public String xx1 { get; set; }
        public ASCustomFields(String ausuId) {
            xx1 = ausuId;
        }
    }
    
    public static String sendSurveys(String CollectorId, String MessageId) {
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(Endpoint + '/v3/collectors/' + CollectorId + '/messages/' + MessageId + '/send');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Bearer ' + Token);
        req.setBody('{}');

        HttpResponse res = getResponse(h, req);
        return res.getBody();
    }
    
    public static String getResponses(String SurveyId) {
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(Endpoint + '/v3/surveys/' + SurveyId + '/responses/bulk');
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Bearer ' + Token);
        //req.setBody('{}');

        HttpResponse res = getResponse(h, req);
        return res.getBody();
    }

    public static String getSurveyDetails(String SurveyId) {
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(Endpoint + '/v3/surveys/' + SurveyId + '/details');
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Bearer ' + Token);
        HttpResponse res = getResponse(h, req);
        return res.getBody();
    }

    public static String getCollector(String SurveyId) {
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(Endpoint + '/v3/surveys/' + SurveyId + '/collectors?sort_by=id&sort_order=DESC');
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Bearer ' + Token);
        HttpResponse res = getResponse(h, req);
        return ((JSONWithDataList)JSON.deserialize(res.getBody(),JSONWithDataList.class)).data[0].id;
    }

    public class JSONWithDataList {

        public List<JSONWithId> data { get; set; }
    }
    
    public class JSONWithId {
        public String id { get; set; }
        public String heading { get; set; }
    }

    public class JSONWithChoicesList {

        public JSONAnswers answers { get; set; }
    }
    
    public class JSONAnswers {

        public List<JSONWithIdPos> choices { get; set; }
    }
    
    public class JSONWithIdPos {
        public String id { get; set; }
        public Integer position { get; set; }
        public String text { get; set; }
    }

    public class JSONResponse {
        public JSONMetadata metadata { get; set; }
        public List<JSONPage> pages { get; set; }
    }

    public class JSONMetadata {

        public JSONContactMetadata contact { get; set; }
    }

    public class JSONContactMetadata {

        public JSONCustom1Metadata custom1 { get; set; }
    }

    public class JSONCustom1Metadata {

        public String value { get; set; }
    }

    public class JSONPage {

        public List<JSONQuestion> questions { get; set; }
    }

    public class JSONQuestion {

        public List<JSONAnswer> answers { get; set; }
    }

    public class JSONAnswer {

        public String choice_id { get; set; }
        public String text { get; set; }
    }

    public static String getResponse(String CollectorId, String ResponseId) {
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(Endpoint + '/v3/collectors/' + CollectorId + '/responses/' + ResponseId + '/details');
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Bearer ' + Token);
        //req.setBody('{}');

        HttpResponse res = getResponse(h, req);
        return res.getBody();
    }

    public static void createWebhook(String CollectorId) {
        
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(Endpoint + '/v3/webhooks');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Bearer ' + Token);
        req.setBody('{"name":"webhookname","event_type":"response_completed","object_type":"collector","object_ids":["' + CollectorId
                    + '"],"subscription_url":"https://orderbird.secure.force.com/SurveyMonkey/services/apexrest/SurveyMonkey?collector=' + CollectorId + '"}');

        HttpResponse res = getResponse(h, req);
        system.debug(res.getBody());
        //return res.getBody();
    }
    
    public static String getWebhooks() {
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(Endpoint + '/v3/webhooks');
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Bearer ' + Token);

        HttpResponse res = getResponse(h, req);
        return res.getBody();
    }
    
    public static String getWebhook(String webhookId) {
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(Endpoint + '/v3/webhooks/' + webhookId);
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Bearer ' + Token);

        HttpResponse res = getResponse(h, req);
        return res.getBody();
    }
    
    public static String getErrorMessage(String ErrorId) {
        
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(Endpoint + '/v3/errors/' + ErrorId);
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Bearer ' + Token);

        HttpResponse res = getResponse(h, req);
        return res.getBody();
    }
    
    public static JSONWithChoicesList getQuestion(String SurveyId, String PageId, String QuestionId) {
        
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(Endpoint + '/v3/surveys/' + SurveyId + '/pages/' + PageId + '/questions/' + QuestionId);
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Bearer ' + Token);

        HttpResponse res = getResponse(h, req);
        system.debug(res.getBody());
        return (JSONWithChoicesList)JSON.deserialize(res.getBody(),JSONWithChoicesList.class);
    }

    public static JSONWithDataList getQuestions(String SurveyId, String PageId) {
        
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(Endpoint + '/v3/surveys/' + SurveyId + '/pages/' + PageId + '/questions');
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Bearer ' + Token);

        HttpResponse res = getResponse(h, req);
        system.debug(res.getBody());
        return (JSONWithDataList)JSON.deserialize(res.getBody(),JSONWithDataList.class);
    }
    
    public static JSONWithDataList getSurveyPages(String SurveyId) {
        
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(Endpoint + '/v3/surveys/' + SurveyId + '/pages');
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Bearer ' + Token);

        HttpResponse res = getResponse(h, req);
        return (JSONWithDataList)JSON.deserialize(res.getBody(),JSONWithDataList.class);
    }
    
    public static void upsertAnswers(String SurveyId) {
        List<AutomatedSurveyQuestion__c> lstQue = new List<AutomatedSurveyQuestion__c>();
        List<AutomatedSurveyAnswer__c> lstAns = new List<AutomatedSurveyAnswer__c>();
        for (JSONWithId page : getSurveyPages(SurveyId).data) {
            for (JSONWithId question : getQuestions(SurveyId, page.id).data) {
                try {
                    lstQue.add(new AutomatedSurveyQuestion__c(
                        Description__c = question.heading,
                        QuestionId__c = question.id
                    ));
                    for (JSONWithIdPos answer : getQuestion(SurveyId, page.id, question.id).answers.choices) {
                        try {
                            lstAns.add(new AutomatedSurveyAnswer__c(
                                Value__c = answer.position - 1,
                                AnswerId__c = answer.id,
                                Text__c = answer.text,
                                Question__r = new AutomatedSurveyQuestion__c(QuestionId__c = question.id)
                            ));
                        } catch (exception ee) {}
                    }
                } catch (exception e) {}
            }
        }
        upsert lstQue QuestionId__c;
        upsert lstAns AnswerId__c;
    }

}