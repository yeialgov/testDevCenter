global class BatchInvoicePdfGetter implements Database.Batchable<sObject>{
    
    global String Query;
    
    global BatchInvoicePdfGetter(){
        Query = 'SELECT Id, RelatedToId FROM EmailMessage '
            + 'WHERE RelatedToId IN (SELECT Id FROM Invoice__c WHERE HasBase64Pdf__c = FALSE) '
            + 'ORDER BY CreatedDate';
        if (test.isRunningTest()) Query += ' LIMIT 10';
    }
    
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(Query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        Map<Id,Id> MapInvEm = new Map<Id,Id>();
        for (SObject s : scope) {
            MapInvEm.put((Id)s.get('RelatedToId'), (Id)s.get('Id'));
        }
        Map<Id,Id> MapEmCd = new Map<Id,Id>();
        for (ContentDocumentLink cdl : [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN :MapInvEm.values()]) {
            MapEmCd.put(cdl.LinkedEntityId, cdl.ContentDocumentId);
        }
        Map<Id,Blob> MapCdBlob = new Map<Id,Blob>();
        for (ContentVersion cv : [SELECT Id, ContentDocumentId, VersionData FROM ContentVersion WHERE ContentDocumentId IN :MapEmCd.values() AND IsLatest = TRUE]){
            MapCdBlob.put(cv.contentdocumentid, cv.versiondata);
        }
        List<Invoice__c> Invoices = [SELECT Id, Base64Pdf__c, HasBase64Pdf__c FROM Invoice__c WHERE Id IN :MapInvEm.keyset()];
        for (Invoice__c Invoice : Invoices) {
            Blob b = MapCdBlob.get(MapEmCd.get(MapInvEm.get(Invoice.id)));
            if (b != null) {
                Invoice.Base64Pdf__c = EncodingUtil.base64Encode(b);
                Invoice.HasBase64Pdf__c = TRUE;
            }
        }
        update Invoices;
    }
    
    global void finish(Database.BatchableContext BC){}
    
}