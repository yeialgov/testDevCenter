@isTest
public class RedirectToStandardRecordTypeCtrlTests {
    private static final Schema.SObjectType testSObjectContext = RedirectToStandardRecordTypeController.testSObjectContext;
    
    public static testMethod void testRedirectToStandardRecordTypeCtrl() {

        Schema.sObjectType globalStandardRecordTypeSetting = RedirectToStandardRecordTypeController.globalStandardRecordTypeSetting; 
        Schema.sObjectField sObjectNameField = RedirectToStandardRecordTypeController.sObjectNameField; 
        Schema.sObjectField standardRecordTypeDeveloperNameField = RedirectToStandardRecordTypeController.standardRecordTypeDeveloperNameField; 
    
        RecordType recordType = [SELECT DeveloperName FROM RecordType WHERE sObjectType = :testSObjectContext.getDescribe().getLocalName() AND IsActive = TRUE LIMIT 1]; 
        String recordTypeDeveloperName = recordType.DeveloperName; 
        Id recordTypeId = recordType.Id; 

        sObject globalStandardRecordTypeSettingRecord = globalStandardRecordTypeSetting.newSObject(); 
        globalStandardRecordTypeSettingRecord.put(sObjectNameField, testSObjectContext.getDescribe().getLocalName());
        globalStandardRecordTypeSettingRecord.put(standardRecordTypeDeveloperNameField, recordTypeDeveloperName); 
        System.debug(globalStandardRecordTypeSettingRecord);
        insert globalStandardRecordTypeSettingRecord;

        sObject controllerRecord = testSObjectContext.newSObject(); 
        List<SObject> setControllerRecords = (List<SObject>)JSON.deserialize('[]', Type.forName('List<' + testSObjectContext.getDescribe().getLocalName() + '>'));

        Test.startTest(); 
        
        RedirectToStandardRecordTypeController controller = new RedirectToStandardRecordTypeController(new ApexPages.StandardController(controllerRecord)); 
        PageReference controllerResult = controller.doRedirect(); 


        RedirectToStandardRecordTypeController setController = new RedirectToStandardRecordTypeController(new ApexPages.StandardSetController(setControllerRecords));  
        PageReference setControllerResult = setController.doRedirect(); 
        
        Test.stopTest(); 

        
    }
}