public class ContactHandler implements ITriggerHandler {
    
    public void bulkBefore(){}

    public void bulkAfter() {}
    
    public void beforeInsert(SObject so) { this.setPhoneNumbers(so); }
    
    public void beforeUpdate(SObject oldSo, SObject so) { this.setPhoneNumbers(so); }

    public void beforeDelete(SObject so){}

    public void afterInsert(SObject so) {}

    public void afterUpdate(SObject oldSo, SObject so) {}

    public void afterDelete(SObject so){}

    public void andFinally(){}

    private void setPhoneNumbers(SObject so) {
        PhoneNumberCleansing.rewritePhoneNumber(so, 'AssistantPhone');
        PhoneNumberCleansing.rewritePhoneNumber(so, 'HomePhone');
        PhoneNumberCleansing.rewritePhoneNumber(so, 'MobilePhone');
        PhoneNumberCleansing.rewritePhoneNumber(so, 'OtherPhone');
        PhoneNumberCleansing.rewritePhoneNumber(so, 'Phone');
        PhoneNumberCleansing.rewritePhoneNumber(so, 'Fax');
    }
}