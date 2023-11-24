public class EmailAutomater {
    
    @InvocableMethod(label='Automated Email' description='Sends Automated Email from Template')
    public static void AutomatedTemplateEmail(List<EmailAutomationRequest> requests) {
        Set<String> TemplateIds = new Set<String>();
        Set<String> EmailAddresses = new Set<String> { 'noreply@orderbird.com' };
            Map<String, Id> OWEAMap = new Map<String, Id>();
        for (EmailAutomationRequest request : requests) {
            if (!TemplateIds.contains(request.TemplateAdminName)) TemplateIds.add(request.TemplateAdminName);
            if (!EmailAddresses.contains(request.EmailAddress)) EmailAddresses.add(request.EmailAddress);
        }
        Map<String,SendTemplate__c> templateMap = new Map<String,SendTemplate__c>();
        for (SendTemplate__c st : [SELECT Id, AdminName__c, Subject__c, Message__c, Unwrapped_Div__c, Unwrapped_Message__c, Language__c FROM SendTemplate__c WHERE AdminName__c IN :TemplateIds]) {
            templateMap.put(st.AdminName__c, st);
        }
        for (OrgWideEmailAddress OWEA : [SELECT Id, Address FROM OrgWideEmailAddress WHERE IsAllowAllProfiles = TRUE AND Address IN :EmailAddresses]) {
            OWEAMap.put(OWEA.Address, OWEA.Id);
        }
        for (EmailAutomationRequest request : requests) {
            String AttachmentIdString = '[]';
            system.debug(json.serialize(request));
            system.debug(json.serialize(templateMap));
            if (request.AttachmentIds != null) AttachmentIdString = JSON.serialize(request.AttachmentIds.replace(' ','').split(','));
            Id OWEAId; // = OWEAMap.get('noreply@orderbird.com');
            if (OWEAMap.get(request.EmailAddress) != null) OWEAId = OWEAMap.get(request.EmailAddress);
            String EmailText = templateMap.get(request.TemplateAdminName).Message__c;
            if (EmailText == null) EmailText = '';
            String Language = templateMap.get(request.TemplateAdminName).Language__c;
            if (Language != 'English' && Language != 'French') Language = 'German';            
            if (templateMap.get(request.TemplateAdminName).Unwrapped_Div__c) EmailText = templateMap.get(request.TemplateAdminName).Unwrapped_Message__c.replace('<!--%%REPLACE%%-->',EmailText) + '<!--%%UNWRAPPED%%-->';
            
            String sObjectPerson = Id.valueOf(request.WhoId).getSObjectType().getDescribe().getName();
            String PersonId = request.WhoId;
            sObject Person = Database.query('SELECT Id, Email FROM ' + sObjectPerson + ' WHERE Id = :PersonId');
            
            String CCString = '[';
            Boolean First = true;
            try {
            if (request.CCAddresses != null) {
                for (String ccAddress : request.CCAddresses.split(',')) {
                    if (First) { First = false; } else { CCString += ','; }
                    EmailSender.CCObject cco = new EmailSender.CCObject();
                    cco.CCEmail = ccAddress;
                    cco.ContactId = PersonId;
                    CCString += JSON.serialize(cco);
                }
            }}catch(exception ee){}
            CCString += ']';
            
            if (Person.get('Email') != null) {
                if ([SELECT Id FROM Contact WHERE IsEmailBounced = TRUE AND Email = :(String)Person.get('Email')].size() == 0) {
                    EmailSender.sendAsyncEmail(
                        request.RelatedToId, 
                        JSON.serialize(new List<String>{request.WhoId}), 
                        CCString,
                        templateMap.get(request.TemplateAdminName).Subject__c, 
                        EmailText, 
                        AttachmentIdString, 
                        request.BCCAddresses,
                        OWEAId, 
                        Language,
                        request.OpenNotify == null ? FALSE : request.OpenNotify
                    );
                }
            }
        }
    }
    
    public class EmailAutomationRequest {
        
        @InvocableVariable(required=true)
        public Id WhoId;
        
        @InvocableVariable(required=true)
        public Id RelatedToId;
        
        @InvocableVariable(required=true)
        public String TemplateAdminName;
        
        @InvocableVariable
        public String EmailAddress;
        
        @InvocableVariable
        public String AttachmentIds;
        
        @InvocableVariable
        public String CCAddresses;
        
        @InvocableVariable
        public String BCCAddresses;
        
        @InvocableVariable
        public Boolean OpenNotify;
        
        public EmailAutomationRequest(Id iWhoId, Id iRelatedToId, String iTemplateAdminName) {
            WhoId = iWhoId;
            RelatedToId = iRelatedToId;
            TemplateAdminName = iTemplateAdminName;
        }
        
        public EmailAutomationRequest(Id iWhoId, Id iRelatedToId, String iTemplateAdminName, String iEmailAddress) {
            WhoId = iWhoId;
            RelatedToId = iRelatedToId;
            TemplateAdminName = iTemplateAdminName;
            EmailAddress = iEmailAddress;
        }
        
        public EmailAutomationRequest() {}
        
    }
    
}