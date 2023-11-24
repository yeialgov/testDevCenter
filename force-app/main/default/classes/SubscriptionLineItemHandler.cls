public class SubscriptionLineItemHandler implements ITriggerHandler{

    private Set<Id> AccountsForOnboardingStatusUpdate = new Set<Id>();
    
    public void bulkBefore(){}

    public void bulkAfter(){}

    public void beforeInsert(SObject so) {}

    public void beforeUpdate(SObject oldSo, SObject so) {}

    public void beforeDelete(SObject so){}

    public void afterInsert(SObject so) {
        try{
            if (((String)so.get('ProductName__c')).containsIgnoreCase('onboard')) {
                AccountsForOnboardingStatusUpdate.add((Id)so.get('Account__c'));
            }
        } catch(exception e) {}
    }
    
    public void afterUpdate(SObject oldSo, SObject so) {
        try{
            if (
                ((String)so.get('ProductName__c')).containsIgnoreCase('onboard')
                || ((String)oldSo.get('ProductName__c')).containsIgnoreCase('onboard')
            ) {
                AccountsForOnboardingStatusUpdate.add((Id)so.get('Account__c'));
            }
        } catch(exception e) {}
    }
    
    public void afterDelete(SObject so){
        try{
            if (((String)so.get('ProductName__c')).containsIgnoreCase('onboard')) {
                AccountsForOnboardingStatusUpdate.add((Id)so.get('Account__c'));
            }
        } catch(exception e) {}
    }

    public void andFinally(){
        AccountOnboardingStatus.process(AccountsForOnboardingStatusUpdate);
    }

}