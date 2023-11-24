public class AutoSurvInsertSendGridHelper {
    
    @future(callout=true)
    public Static void send(String AuSuTriggerList) {
        Set<Id> idSet = new Set<Id>();
        for (AutomatedSurvey__c ausu : (List<AutomatedSurvey__c>)json.deserialize(AuSuTriggerList, List<AutomatedSurvey__c>.class)) {
            idSet.add(ausu.Id);
        }
        List<AutomatedSurvey__c> lstAuSu = [
            SELECT Id, Contact__r.Email, Contact__r.Account.PrimaryLanguage__c
            FROM AutomatedSurvey__c
            WHERE Id IN :idSet AND Contact__r.Email != null
        ];
        EmailWrapper EW = new EmailWrapper(lstAuSu);
        String jsonBody = json.serialize(EW).replace('_x','');
        system.debug(jsonBody);
        if (!Test.isRunningTest()) {
            HttpRequest req = new HttpRequest();
            req.setMethod('POST');
            req.setEndpoint('https://api.sendgrid.com/v3/mail/send');
            req.setTimeout(120000);
            req.setHeader('content-type', 'application/json');
            req.setHeader('Authorization', 'Bearer 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');
            req.setBody(jsonBody);
            Http http = new Http();
            if (!test.isRunningTest()) {
                try {
                    HTTPResponse res = http.send(req);
                    system.debug(res.getBody());
                    system.debug(res.getStatus());
                    system.debug(res.getStatusCode());
                } catch (System.CalloutException e) {
                    System.debug(LoggingLevel.ERROR, e.getMessage());
                }
            }
        }
        
    }
    public class EmailWrapper {
        public String template_id { get; set; }
        public List<String> categories { get; set; }
        public AsmWrapper asm { get; set; }
        public List<PersonalizationWrapper> personalizations { get; set; }
        public FromWrapper from_x { get; set; }
        public FromWrapper reply_to { get; set; }
        public EmailWrapper(List<AutomatedSurvey__c> lstAuSu) {
		    JsonStepper j = new JsonStepper((Map<String, Object>)JSON.deserializeUntyped([SELECT Body FROM StaticResource where name = 'NpsStrings' limit 1].body.tostring()));
            template_id = 'd-d31bd7acba674c5999178d525ecb83f4';
            categories = new List<String>{'nps'};
            asm = new AsmWrapper(21716);
            from_x = new FromWrapper();
            reply_to = new FromWrapper();
            personalizations = new List<PersonalizationWrapper>();
            for (AutomatedSurvey__c AuSu : lstAuSu) {
                personalizations.add(new PersonalizationWrapper(AuSu, j));
            }
        }
    }
    
    public class AsmWrapper {
        public Integer group_id;
        public AsmWrapper(Integer i) { group_id = i; }
    }
    
    public class FromWrapper {
        public String email { get; set; }
        public String name { get; set; }
        public FromWrapper() {
            email = 'knowledge@orderbird.com';
            name = 'orderbird';
        }
    }
    
    public class PersonalizationWrapper {
        public List<ToWrapper> to { get; set; }
        public String subject { get; set; }
        public DTDWrapper dynamic_template_data { get; set; }
        public PersonalizationWrapper(AutomatedSurvey__c AuSu, JsonStepper j) {
            to = new List<ToWrapper>{new ToWrapper(AuSu)};
            subject = 'orderbird';
            dynamic_template_data = new DTDWrapper(AuSu, j);
        }
    }
    
    public class DTDWrapper {
        public String Heading { get; set; }
        public String SubHeading { get; set; }
        public String Language { get; set; }
        public String token { get; set; }
        public String IntroText { get; set; }
        public String NpsQuestion { get; set; }
        public String LowDesc { get; set; }
        public String HighDesc { get; set; }
        public List<NpsNum> NpsResponse { get; set; }
        public DTDWrapper(AutomatedSurvey__c AuSu, JsonStepper j) {
            switch on AuSu.Contact__r.Account.PrimaryLanguage__c {
                when 'English' { Language = 'en_gb'; }
                when 'French' { Language = 'fr'; }
                when else { Language = 'de'; }
            }
            token = PortalToken.encryptPlain(AuSu.Id);
            Heading = s(j.x('Heading').m, Language);
            SubHeading = s(j.x('SubHeading').m, Language);
            IntroText = s(j.x('IntroText').m, Language);
            NpsQuestion = s(j.x('NpsQuestion').m, Language);
            LowDesc = s(j.x('LowDesc').m, Language);
            HighDesc = s(j.x('HighDesc').m, Language);
            NpsResponse = new List<NpsNum>();
            for (Integer i=0; i<11; i++) { NpsResponse.add(new NpsNum(i)); }
        }
    }
    
    public class NpsNum {
        public Integer Num { get; set; }
        public NpsNum(Integer i) {
            Num = i;
        }
    }
    
    public class ToWrapper {
        public String email { get; set; }
        public ToWrapper(AutomatedSurvey__c AuSu) {
            email = AuSu.Contact__r.Email;
        }
    }

    public class JsonStepper {
        public Map<String, Object> m { get; set; }
        public JsonStepper(Map<String, Object> inputMap) {
            m = inputMap;
        }
        public JsonStepper x(String s) {
            return new JsonStepper((Map<String, Object>)m.get(s));
        }
    }

    public Static String s (Map<String, Object> m, String s) {
        try{ return (String)m.get(s); } catch(exception e){ return ''; }
    }    

}