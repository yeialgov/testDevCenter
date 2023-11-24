public class SendGrid {

    public static void SendEmail(EmailWrapper EW) {
        String jsonBody = json.serialize(EW).replace('_x','');
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
            } catch (System.CalloutException e) {
                System.debug(LoggingLevel.ERROR, e.getMessage());
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
        public EmailWrapper(String TemplateId, List<String> CategoryList, List<PersonalizationWrapper> PersonalizationList, Integer AsmNumber) {
            template_id = TemplateId;
            categories = CategoryList;
            asm = new AsmWrapper(AsmNumber);
            from_x = new FromWrapper();
            reply_to = new FromWrapper();
            personalizations = PersonalizationList;
        }
    }
    
    public class AsmWrapper {
        public Integer group_id;
        public AsmWrapper(Integer i) { group_id = i; }
    }
    
    public class PersonalizationWrapper {
        public List<ToWrapper> to { get; set; }
        public Map<String, Object> dynamic_template_data { get; set; }
        public PersonalizationWrapper(String EmailAddress, Map<String,Object> DTD) {
            to = new List<ToWrapper>{new ToWrapper(EmailAddress)};
            dynamic_template_data = DTD;
        }
    }
        
    public class ToWrapper {
        public String email { get; set; }
        public ToWrapper(String EmailAddress) {
            email = EmailAddress;
        }
    }
    
    public class FromWrapper {
        public String email { get; set; }
        public String name { get; set; }
        public FromWrapper() {
            email = 'insights@orderbird.com';
            name = 'orderbird Insights';
        }
    }

}