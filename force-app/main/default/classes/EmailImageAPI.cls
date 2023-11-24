@RestResource(urlMapping='/email_image')
global class EmailImageAPI {
    
    @HttpGet
    @Produces('image/png')
    global static void emailOpen() {
        RestRequest req = System.RestContext.request;
        String keyToken = req.params.get('id');
        
        List<EmailMessage> EmailMessages = [SELECT Id, Key__c, LastNotified__c FROM EmailMessage WHERE Key__c = :keyToken AND (LastNotified__c < :DateTime.now().addDays(-1) OR LastNotified__c = null)];
        for (EmailMessage em : EmailMessages) em.LastNotified__c = DateTime.now();
        update EmailMessages;
        
        System.RestContext.response.addHeader('content-type','image/png');
        System.RestContext.response.responseBody = EncodingUtil.base64Decode('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABAQMAAAAl21bKAAAAA1BMVEUyNDVtDDvwAAAAAXRSTlPM0jRW/QAAAApJREFUeJxjYgAAAAYAAzY3fKgAAAAASUVORK5CYII=');
        
    }
    
}