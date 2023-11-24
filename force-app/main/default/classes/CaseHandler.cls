/**
 * @author Bart
 */
public class CaseHandler implements ITriggerHandler {

    private Set<Id> AccountsForOnboardingStatusUpdate = new Set<Id>();
    private Set<Id> CasesToDelete = new Set<Id>();
    private Id RTOnboardingCase;
    private BusinessHours bh;
    
    /**
     * bulkBefore
     *
     * This method is called prior to execution of a BEFORE trigger. Use this to cache
     * any data required into maps prior execution of the trigger.
     */
    public void bulkBefore(){
		bh = [SELECT Id FROM BusinessHours WHERE IsDefault=true];
    }
    
    /**
     * bulkAfter
     *
     * This method is called prior to execution of an AFTER trigger. Use this to cache
     * any data required into maps prior execution of the trigger.
     */
    public void bulkAfter(){
        try {
            RTOnboardingCase = [SELECT Id FROM RecordType WHERE SObjectType = 'Case' and Name = 'Case: Onboarding' LIMIT 1].Id;
        } catch(exception e) {
            system.debug(LoggingLevel.ERROR, 'Missing Onboarding case recordtype');
        }
    }
    
    /**
     * beforeInsert
     *
     * This method is called iteratively for each record to be inserted during a BEFORE
     * trigger. Never execute any SOQL/SOSL etc in this and other iterative methods.
     */
    public void beforeInsert(SObject so) {
        so.put('Opened_After_Hours__c', !BusinessHours.isWithin(bh.id, DateTime.now()));
    }

    /**
     * beforeUpdate
     *
     * This method is called iteratively for each record to be updated during a BEFORE
     * trigger.
     */
    public void beforeUpdate(SObject oldSo, SObject so) {
        if ((Boolean)so.get('Assign_Me__c')) {
            so.put('Assign_Me__c', false);
            so.put('OwnerId', UserInfo.getUserId());
        }
        Boolean WasClosed = ((String)oldSo.get('Status')).containsIgnoreCase('close');
        Boolean IsClosed = ((String)so.get('Status')).containsIgnoreCase('close');
        if (!WasClosed && IsClosed) {
            so.put('Closed_After_Hours__c', !BusinessHours.isWithin(bh.id, DateTime.now()));
        } else if (WasClosed && !IsClosed) {
            so.put('Closed_After_Hours__c', false);
        }
    }
    
    /**
     * beforeDelete
     *
     * This method is called iteratively for each record to be deleted during a BEFORE
     * trigger.
     */
    public void beforeDelete(SObject so){}

    /**
     * afterInsert
     *
     * This method is called iteratively for each record inserted during an AFTER
     * trigger. Always put field validation in the 'After' methods in case another trigger
     * has modified any values. The record is 'read only' by this point.
     */
    public void afterInsert(SObject so) {
        if ((Id)so.get('RecordTypeId') == RTOnboardingCase) {
            AccountsForOnboardingStatusUpdate.add((Id)so.get('AccountId'));
        }
    }

    /**
     * afterUpdate
     *
     * This method is called iteratively for each record updated during an AFTER
     * trigger.
     */
    public void afterUpdate(SObject oldSo, SObject so) {
        if (
            (Id)so.get('RecordTypeId') == RTOnboardingCase
            || (Id)oldSo.get('RecordTypeId') == RTOnboardingCase
        ) {
            AccountsForOnboardingStatusUpdate.add((Id)so.get('AccountId'));
        }
        
        if ((Boolean)so.get('Delete__c')) {
            CasesToDelete.add((Id)so.get('Id'));
        }
	}

    /**
     * afterDelete
     *
     * This method is called iteratively for each record deleted during an AFTER
     * trigger.
     */
    public void afterDelete(SObject so){
        if ((Id)so.get('RecordTypeId') == RTOnboardingCase) {
            AccountsForOnboardingStatusUpdate.add((Id)so.get('AccountId'));
        }
    }

    /**
     * andFinally
     *
     * This method is called once all records have been processed by the trigger. Use this 
     * method to accomplish any final operations such as creation or updates of other records.
     */
    public void andFinally(){
        AccountOnboardingStatus.process(AccountsForOnboardingStatusUpdate);
        delete [SELECT Id FROM Case WHERE Id IN :CasesToDelete];
    }

}