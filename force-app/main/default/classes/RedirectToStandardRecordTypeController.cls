public with sharing class RedirectToStandardRecordTypeController {

    @TestVisible private static final Schema.sObjectType globalStandardRecordTypeSetting = GlobalStandardRecordType__c.sObjectType; 
    @TestVisible private static final Schema.sObjectField sObjectNameField = GlobalStandardRecordType__c.Name.getDescribe().getSObjectField(); 
    @TestVisible private static final Schema.sObjectField standardRecordTypeDeveloperNameField = GlobalStandardRecordType__c.RecordTypeDeveloperName__c.getDescribe().getSObjectField(); 

    @TestVisible private static final Schema.sObjectType testSObjectContext = Case.sObjectType; 
    
    private SObject thisRecord; 
    private Schema.sObjectType thisSObject; 
    private Id standardRecordTypeId; 

    public RedirectToStandardRecordTypeController(ApexPages.StandardSetController stdController) {
        thisRecord = stdController.getRecord(); 
        thisSObject = thisRecord.getSObjectType(); 
        initContext(); 
    }
    
    public RedirectToStandardRecordTypeController(ApexPages.StandardController stdController) { 
        thisRecord = stdController.getRecord(); 
        thisSObject = thisRecord.getSObjectType(); 
        initContext(); 
    }   
    
    public void initContext() { 
        SObject[] globalStandardRecordType = Database.query(
            'SELECT ' + 
                 standardRecordTypeDeveloperNameField.getDescribe().getLocalName() + ' ' + 
            'FROM ' + 
                globalStandardRecordTypeSetting.getDescribe().getLocalName() + ' ' + 
            'WHERE ' + 
                sObjectNameField.getDescribe().getLocalName() + ' = \'' + thisSObject.getDescribe().getLocalName() + '\' ' + 
            'ORDER BY ' + standardRecordTypeDeveloperNameField.getDescribe().getLocalName() + ' NULLS FIRST ' + 
            'LIMIT 1 '
            ); 
        System.debug(globalStandardRecordType); 
        if (globalStandardRecordType != null && globalStandardRecordType.size() == 1 && globalStandardRecordType[0].get(standardRecordTypeDeveloperNameField) != null) { 
            String thisSObjectName = thisSObject.getDescribe().getLocalName(); 
            String globalStandardRecordTypeDeveloperName = (String)globalStandardRecordType[0].get(standardRecordTypeDeveloperNameField); 
            RecordType[] recordType = [
                SELECT 
                    Id 
                FROM 
                    RecordType 
                WHERE 
                    sObjectType = :thisSObjectName AND 
                    DeveloperName = :globalStandardRecordTypeDeveloperName AND 
                    IsActive = TRUE 
                LIMIT 1
                ];
            standardRecordTypeId = (recordType != null && recordType.size() == 1) ? recordType[0].Id : null; 
        } 
    }
    
    public PageReference doRedirect() {
            return new PageReference(
                '/' + 
                thisSObject.getDescribe().getKeyPrefix() + 
                '/e' + 
                (standardRecordTypeId != null ? 
                    '?RecordTypeId=' + standardRecordTypeId + '&' : '?'
                ) + 
                'retURL=/' + thisSObject.getDescribe().getKeyPrefix()
            ); 
    }
}