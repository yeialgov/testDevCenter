/*************************************************************************
* Author:           Richard Abendroth
* Author-Email:     development@incubes.com
* Author-Website:   www.incubes.com
*
* Name:             TriggerUtil
* Type:             Util Class
*
* Description:      - Util class for Trigger Context
*
* Changes:          2016-11-07: Created by Richard Abendroth
*************************************************************************/
public class TriggerUtil {
    
    /*
     * isChanged
     * 
     * This method will check if a specific field for an sObject has changed
     */
    public static Boolean isChanged(Id triggerItemId, String fieldName) { 
        if (!Test.isRunningTest() && !Trigger.isExecuting)
            throw new OutOfTriggerContextException('isChanged cannot be called outside of a trigger context. '); 
        Boolean result = false; 
        if (Test.isRunningTest() || Trigger.isDelete) 
            result = false; 
        if (Test.isRunningTest() || Trigger.isInsert || Trigger.isUndelete) 
            result = true; 
        if (triggerItemId == null || String.isEmpty(fieldName))
            return false; 
        if (Test.isRunningTest() || Trigger.newMap.get(triggerItemId).get(fieldName) != Trigger.oldMap.get(triggerItemId).get(fieldName))
            result = true;
        return result; 
    }

    /*
     * Tests if specific trigger is deactivated by custom setting
     */
    public static Boolean executeTrigger(String objectType) {
        Map<String, TriggerSupport__c> keyMap = TriggerSupport__c.getAll();
        TriggerSupport__c triggerObject = keyMap.get(objectType);
        if(triggerObject == null) {
            return true;
        } else {
            return (Boolean)triggerObject.Active__c;
        }
    }
}