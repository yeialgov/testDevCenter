public class CSVReportEmailer{
    
    public static void EmailCSVs() {
        
        List<CSVReport__c> CSVRs = [SELECT Id, EmailTo__c, FileName__c, Email_as_XLS__c FROM CSVReport__c WHERE EmailTo__c != null];
        
        Set<String> EmailAddresses = new Set<String>();
        List<Messaging.Email> Emails = new List<Messaging.Email>();
        
        for (CSVReport__c CSVR : CSVRs) {
            for (String EmailAddress : CSVR.EmailTo__c.replace(' ','').split(',')) {
                EmailAddresses.add(EmailAddress);
            }
        }
        
        for (String EmailAddress : EmailAddresses) {
            List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
            for (CSVReport__c CSVR : CSVRs) {
                if (CSVR.EmailTo__c.contains(EmailAddress)) {
                    Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
                    efa.setFileName(CSVR.FileName__c + '.csv');
                    String ReportOutput = 'CSV';
                    if (CSVR.Email_as_XLS__c) {
                        ReportOutput = 'XLS';
                        efa.setFileName(CSVR.FileName__c + '.xls');
                    }
                    PageReference pageRef = new PageReference('/apex/' + ReportOutput + 'Report');
                    pageRef.getParameters().put('id', CSVR.Id);
                    Blob csvBlob;
                    if(!test.isRunningTest()) csvBlob = pageRef.getContent();
                    efa.setBody(csvBlob);
                    fileAttachments.add(efa);
                }
            }
            Messaging.SingleEmailMessage em = new Messaging.SingleEmailMessage();
            em.setTreatBodiesAsTemplate(true);
            em.setPlainTextBody('');
            em.setSubject('Scheduled Reports');
            em.setToAddresses(new List<String>{EmailAddress});
            em.setFileAttachments(fileAttachments);
            Emails.add(em);
        }
        
        if (!test.isRunningTest()) Messaging.sendEmail( Emails );
        
    }
    
    @InvocableMethod(label='CSV Email' description='Sends CSV Reports via Email')
    public static void CSVInvocableEmail(List<CSVRequest> requests) {
        List<Messaging.Email> Emails = new List<Messaging.Email>();
        for (CSVRequest req : requests) {
            Set<String> CSVIds = new Set<String>(req.CSVReportIds.replace(' ','').replace(';',',').split(','));
            system.debug(json.serialize(CSVIds));
            List<CSVReport__c> CSVRs = [SELECT Id, EmailTo__c, FileName__c, Email_as_XLS__c FROM CSVReport__c WHERE Id IN :CSVIds];
            List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
            for (CSVReport__c CSVR : CSVRs) {
                Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
                efa.setFileName(CSVR.FileName__c + '.csv');
                String ReportOutput = 'CSV';
                if (CSVR.Email_as_XLS__c) {
                    ReportOutput = 'XLS';
                    efa.setFileName(CSVR.FileName__c + '.xls');
                }
                PageReference pageRef = new PageReference('/apex/' + ReportOutput + 'Report');
                pageRef.getParameters().put('id', CSVR.Id);
                if (req.RecordId != null) pageRef.getParameters().put('recordId', req.RecordId);
                Blob csvBlob;
                if(!test.isRunningTest()) csvBlob = pageRef.getContent();
                efa.setBody(csvBlob);
                fileAttachments.add(efa);
            }
            Messaging.SingleEmailMessage em = new Messaging.SingleEmailMessage();
            em.setPlainTextBody('');
            em.setSaveAsActivity(false);
            em.setSubject('Salesforce Automated CSV Generation');
            em.setTargetObjectId(req.UserId);
            em.setFileAttachments(fileAttachments);
            Emails.add(em);
        }
        if (!test.isRunningTest()) Messaging.sendEmail( Emails );
    }
    
    public class CSVRequest {
        
        @InvocableVariable(required=true)
        public Id UserId;
        
        @InvocableVariable(required=true)
        public String CSVReportIds;
        
        @InvocableVariable(required=false)
        public String RecordId;
        
    }
    
}