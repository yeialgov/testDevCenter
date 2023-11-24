public class InvoicePDFSender implements Queueable, Database.AllowsCallouts {
    
    private List<Invoice__c> Invoices { get; set; }
    
    public InvoicePDFSender(List<Invoice__c> records) {
        Invoices = records;
    }
    
    public void execute(QueueableContext context) {
        List<String> ContactIds = new List<String>();
        List<String> InvoiceIds = new List<String>(); 
        List<String> InvoiceZIds = new List<String>();
        List<Messaging.Email> Emails = new List<Messaging.Email>();
        for (Invoice__c Inv : Invoices) {
            InvoiceIds.add(Inv.Id);
        }
        Map<Id, Invoice__c> InvMap = new Map<Id, Invoice__c>([SELECT Id, EmailContactId__c, ZuoraId__c FROM Invoice__c WHERE Id IN :InvoiceIds]);
        OrgWideEmailAddress owea = [select Id from OrgWideEmailAddress where Address = 'noreply@orderbird.com'];
        Id templateId = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'InvoiceSend' LIMIT 1].Id;
        List<ContentVersion> CVs = new List<ContentVersion>();
        for (Invoice__c Inv : Invoices) {
            Messaging.SingleEmailMessage em = new Messaging.SingleEmailMessage();
            em.setTemplateId(templateId);
            em.setTargetObjectID(InvMap.get(Inv.Id).EmailContactId__c);
            em.setWhatId(Inv.Id);
            em.setSaveAsActivity(true);
            em.setToAddresses( new List<String>{} );
            em.setBccAddresses( new List<String>{} );
            em.setOrgWideEmailAddressId(owea.Id);
            Emails.add(em);

            PageReference pageRef = new PageReference('/apex/InvoiceAttachment');
            pageRef.getParameters().put('id', Inv.Id );
            Blob pdfBlob = Blob.valueOf('test');
            if (!test.isRunningTest()) pdfBlob = pageRef.getContent();

            ContactIds.add(InvMap.get(Inv.Id).EmailContactId__c);

            String Subject = 'orderbird Invoice: ' + Inv.Name;
            CVs.add(new ContentVersion(
                ContentLocation = 'S',
                IsInvoice__c = true,
                VersionData = pdfBlob,
                Title = Subject + ' sent ' + String.valueOf(DateTime.now()),
                PathOnClient = '/Invoice.pdf'
            ));
            
            InvoiceZIds.add(Inv.ZuoraId__c);

        }
        if (!test.isRunningTest()) Messaging.sendEmail( Emails );
        
        ZuoraSyncController.UpdateZInvoice(InvoiceZIds);

        List<EmailMessageRelation> EMRs = [
            SELECT EmailMessageId 
            FROM EmailMessageRelation 
            WHERE RelationId IN :ContactIds
            ORDER BY CreatedDate DESC
            LIMIT :ContactIds.size()
        ];
        
        insert CVs;

        Set<Id> CVIdSet = new Set<Id>();
        for (ContentVersion CV : CVs) {
            CVIdSet.add(CV.Id);
        }

        List<ContentVersion> QCVs = [SELECT ContentDocumentId FROM ContentVersion WHERE Id IN :CVIdSet];

        List<ContentDocumentLink> CDLs = new List<ContentDocumentLink>();
        Integer x = 0;
        for (EmailMessageRelation EMR : EMRs) {
            CDLs.add(new ContentDocumentLink(
                ShareType = 'v',
                LinkedEntityId = EMR.EmailMessageId,
                ContentDocumentId = QCVs[x].ContentDocumentId
            ));
            x++;
        }
        if (!test.isRunningTest()) insert CDLs;

    }

}