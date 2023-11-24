/**
 * @author Bart
 */
public class SubscriptionProductChargeHandler implements ITriggerHandler {
    
    private Set<Id> AccountsForOnboardingStatusUpdate = new Set<Id>();
    
    /**
     * bulkBefore
     *
     * This method is called prior to execution of a BEFORE trigger. Use this to cache
     * any data required into maps prior execution of the trigger.
     */
    public void bulkBefore(){}
    
    /**
     * bulkAfter
     *
     * This method is called prior to execution of an AFTER trigger. Use this to cache
     * any data required into maps prior execution of the trigger.
     */
    public void bulkAfter(){}
    
    /**
     * beforeInsert
     *
     * This method is called iteratively for each record to be inserted during a BEFORE
     * trigger. Never execute any SOQL/SOSL etc in this and other iterative methods.
     */
    public void beforeInsert(SObject so) {}

    /**
     * beforeUpdate
     *
     * This method is called iteratively for each record to be updated during a BEFORE
     * trigger.
     */
    public void beforeUpdate(SObject oldSo, SObject so) {}
    
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
        if (((String)so.get('Name')).containsIgnoreCase('onboard')) {
            AccountsForOnboardingStatusUpdate.add((Id)so.get('Zuora__Account__c'));
        }
    }

    /**
     * afterUpdate
     *
     * This method is called iteratively for each record updated during an AFTER
     * trigger.
     */
    public void afterUpdate(SObject oldSo, SObject so) {
        system.debug('test');
        system.debug((String)so.get('Name'));
        if (
            ((String)so.get('Name')).containsIgnoreCase('onboard')
            || ((String)oldSo.get('Name')).containsIgnoreCase('onboard')
        ) {
            AccountsForOnboardingStatusUpdate.add((Id)so.get('Zuora__Account__c'));
        }
    }

    /**
     * afterDelete
     *
     * This method is called iteratively for each record deleted during an AFTER
     * trigger.
     */
    public void afterDelete(SObject so){
        if (((String)so.get('Name')).containsIgnoreCase('onboard')) {
            AccountsForOnboardingStatusUpdate.add((Id)so.get('Zuora__Account__c'));
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
    }

}