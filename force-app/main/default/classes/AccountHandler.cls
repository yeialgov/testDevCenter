public class AccountHandler implements ITriggerHandler {
    
    //private AddressSync addressSync;
    private RegionManager regionManager;
    
    public void bulkBefore(){
    	//this.addressSync = new AddressSync(Trigger.new);
    	//this.addressSync.loadRelatedContactAddresses();
        this.regionManager = new RegionManager('Account');
    }

    public void bulkAfter(){}

    public void beforeInsert(SObject so) {
        PhoneNumberCleansing.rewritePhoneNumber(so, 'Phone');
        PhoneNumberCleansing.rewritePhoneNumber(so, 'Fax');
        this.regionManager.setRegionValues(so);
    }
    
    public void beforeUpdate(SObject oldSo, SObject so) {
        //if(AvoidRecursion.isFirstRun()) {
        //    this.addressSync.updateAccountAddresses((Account)so);
        //}
        PhoneNumberCleansing.rewritePhoneNumber(so, 'Phone');
        PhoneNumberCleansing.rewritePhoneNumber(so, 'Fax');
        this.regionManager.updateRegionValues(so, oldSo);
        if ((String)oldSo.get('Account_Status__c') != (String)so.get('Account_Status__c')) so.put('Last_Status_Update__c', DateTime.now());
    }

    public void beforeDelete(SObject so){
        if((String)so.get('ZuoraId__c') != null) so.addError('Accounts with a Zuora link cannot be deleted.');
    }

    public void afterInsert(SObject so) {}

    public void afterUpdate(SObject oldSo, SObject so) {}

    public void afterDelete(SObject so){}

    public void andFinally(){}
}