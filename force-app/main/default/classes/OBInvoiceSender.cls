global class OBInvoiceSender implements Database.Batchable<sObject>{
    
    global String Query;
    global OrgWideEmailAddress[] owea;
    global Map<String,String> TemplateMap;
    global Map<String,SendTemplate__c> SendTemplateMap;
    global List<ContentVersion> insertCVs;
    global List<Messaging.Email> Emails;

    global OBInvoiceSender() {
        Id SysAdminId = [SELECT Id FROM Profile where Name = 'System Administrator' LIMIT 1].Id;
        String BatchLimit = InvoiceSending__c.getInstance(SysAdminId).BatchSize__c;
        if (test.isRunningTest()) BatchLimit = '10';
        Query = 'SELECT Id, Name, Template_Branding__c, HasBeenEmailed__c, InvoiceDate__c, Amount__c, Transaction_Label__c, Credit_Memo_Amount__c, Email__c, CurrencyIsoCode, Addressee__c, Correction_Invoice__c  '
            +   'FROM OBInvoice__c '
            +   'WHERE '
            +   '   HasBeenEmailed__c = FALSE '
            +   '   AND (Email__c != NULL OR (Account__r.SF_BillTo_Contact__c != NULL '
            +   '   AND Account__r.SF_BillTo_Contact__r.Email != NULL '
            +   '   AND Account__r.SF_BillTo_Contact__r.IsEmailBounced = FALSE)) '
            +   '   AND MismatchTotal__c = FALSE '
            +   'LIMIT ' + BatchLimit;
        setParams();
    }

    global void setParams() {

        owea = [select Id from OrgWideEmailAddress where Address = 'noreply@orderbird.com'];

        TemplateMap = new Map<String, String>();
        for (StaticResource TSR : [
            SELECT Id, Name, Body 
            FROM StaticResource 
            WHERE Name LIKE 'ReplacementTemplate%'
            ORDER BY Name DESC
        ]) {
            TemplateMap.put(TSR.Name, TSR.Body.toString());
        }

        SendTemplateMap = new Map<String, SendTemplate__c>();
        for (SendTemplate__c ST : [
            SELECT Id, Message__c, Default__c, Subject__c 
            FROM SendTemplate__c 
            WHERE Object__c = 'OBInvoice' AND Default__c != null
        ]) {
            SendTemplateMap.put(ST.Default__c, ST);
        }

        insertCVs = new List<ContentVersion>();
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(Query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        
        Set<String> EmailAddresses = new Set<String>();
        Map<String,String> MessageMap = new Map<String,String>();
        Map<String,String> DocumentMap = new Map<String,String>();
        Map<String,String> TitleMap = new Map<String,String>();
        List<String> ContentDocumentIds = new List<String>();
        
        // create list of emails to send at the end of the process
        Emails = new List<Messaging.Email>();
        
        // iterate through queried accounts
        for (SObject s : scope) {

            /*String Language = (String)s.getSObject('Account__r').get('PrimaryLanguage__c');
            if (Language != 'German' && Language != 'English' && Language != 'French') {
                if ((String)s.getSObject('Account__r').get('BillingCountry') == 'France') {
                    Language = 'French';
                } else {
                    Language = 'German';
                }
            }*/
            String Language = 'German';
            
            String TemplateBrand = 'PRO';
            try { 
                TemplateBrand = (String)s.get('Template_Branding__c');
                if (TemplateBrand == null) TemplateBrand = '';
            } catch(exception e){}

            Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
            List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
            efa.setFileName('Invoice.pdf');
            PageReference pageRef = new PageReference('/apex/OBInvoiceAttachment');
            pageRef.getParameters().put('id', (String)s.get('Id') );
            Blob pdfBlob;
            if(!test.isRunningTest()) pdfBlob = pageRef.getContent();
            efa.setBody(pdfBlob);
            fileAttachments.add(efa);

            insertCVs.add(new ContentVersion(
                ContentLocation = 'S',
                IsInvoice__c = true,
                VersionData = pdfBlob,
                Title = 'orderbird Invoice : ' + (String)s.get('Name') + ' : sent ' + String.valueOf(DateTime.now()),
                PathOnClient = '/Invoice.pdf'
            ));

            List<String> args = new String[]{'0','number','###,###,##0.00'};
                
            String EmailText = SendTemplateMap.get(Language).Message__c.replace('%%!Account__r.Name%%',(String)s.get('Addressee__c'))
                .replace('%%!Name%%',(String)s.get('Name'))
                .replace('%%!Transaction_Label__c%%',(String)s.get('Transaction_Label__c'))
                .replace('%%!InvoiceDate__c:Date%%',((Date)s.get('InvoiceDate__c')).format())
                .replace('%%!Amount__c:Currency%%',String.format((((Decimal)s.get('Amount__c')).setScale(2)).format(), args))
                .replace('%%!Credit_Memo_Amount__c:Currency%%',String.format((((Decimal)s.get('Credit_Memo_Amount__c')).setScale(2)).format(), args))
                .replace('%%!CurrencyIsoCode%%',(String)s.get('CurrencyIsoCode'));
        
            String TextBody = EmailText;
            TextBody = TextBody.replace('<p>','').replace('</p>','\n').replace('<br>','\n').replace('<br/>','\n');
            //TextBody = EncodingUtil.URLDecode(TextBody, 'UTF-8');
            
            EmailText = TemplateMap.get('ReplacementTemplate' + TemplateBrand + Language).replace('<!--%%REPLACE%%-->',EmailText);
            
            system.debug(json.serialize(s));
            
            String emailSubject = SendTemplateMap.get(Language).Subject__c.replace('%%!Name%%',(String)s.get('Name')).replace('%%!Transaction_Label__c%%',(String)s.get('Transaction_Label__c'));
            if ((Boolean)s.get('Correction_Invoice__c')) emailSubject = emailSubject.replace('Rechnung','Rechnungsberichtigung');
            TextBody = TextBody.replace('<!--%%SUBJECTLINE%%-->',emailSubject);
            
            Messaging.SingleEmailMessage em = new Messaging.SingleEmailMessage();
            em.setTreatBodiesAsTemplate(true);
            em.setHtmlBody(EmailText);
            em.setPlainTextBody(TextBody);
            em.setSubject(emailSubject);
            em.setWhatId((String)s.get('Id'));
            em.setSaveAsActivity(true);
            em.setToAddresses(new List<String> {(String)s.get('Email__c')});
            //em.setTargetObjectID((Id)s.getSObject('Account__r').get('SF_BillTo_Contact__c'));
            //em.setCCAddresses( new List<String>{} );
            em.setOrgWideEmailAddressId(owea.get(0).Id);
            em.setFileAttachments(fileAttachments);
            Emails.add(em);

            if (!test.isRunningTest()) s.put('Base64Pdf__c', EncodingUtil.base64Encode(pdfBlob));
            s.put('HasBeenEmailed__c', true);
            EmailAddresses.add((String)s.get('Email__c'));
            TitleMap.put(
                (String)s.get('Name'),
                (String)s.get('Id')
            );
        }
        
        if (!test.isRunningTest()) Messaging.sendEmail( Emails );
        
        for(EmailMessageRelation emr : [
            SELECT EmailMessageId, EmailMessage.RelatedToId
            FROM EmailMessageRelation 
            WHERE RelationAddress IN :EmailAddresses
            ORDER BY CreatedDate DESC
            LIMIT :Emails.size()
        ]) {
            MessageMap.put(emr.EmailMessage.RelatedToId, emr.EmailMessageId);
        }        
        update scope;
        if (!test.isRunningTest()) insert insertCVs;
        
        Set<Id> CVIdSet = new Set<Id>();
        for (ContentVersion CV : insertCVs) {
            CVIdSet.add(CV.Id);
        }

        for (ContentVersion newCV : [SELECT Title, ContentDocumentId FROM ContentVersion WHERE Id IN :CVIdSet]) {
            ContentDocumentIds.add(newCV.ContentDocumentId);
            DocumentMap.put(newCV.ContentDocumentId, newCV.Title.split(':')[1].replace(' ',''));
        }

        List<ContentDocumentLink> CDLs = new List<ContentDocumentLink>();
        for (String CDId : ContentDocumentIds) {
            CDLs.add(new ContentDocumentLink(
                ShareType = 'v',
                LinkedEntityId = MessageMap.get(TitleMap.get(DocumentMap.get(CDId))),
                ContentDocumentId = CDId
            ));
        }
        if (!test.isRunningTest()) insert CDLs;
        
    }

    global void finish(Database.BatchableContext BC){}
    
}