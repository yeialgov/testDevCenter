/**
 * @author joern
 *
 */
public with sharing class InvoiceHandler {// implements ITriggerHandler {
    
    /**
    private List<SObjeforct> itemsToInsert = new List<SObject>();
    private List<SObject> itemsToUpdate = new List<SObject>();
    private List<SObject> itemsToDelete = new List<SObject>();

    private InvoicePaymentStatus ips;

    public void bulkBefore() {
        this.ips = new InvoicePaymentStatus(Trigger.newMap);
    }
    
    public void bulkAfter(){}
    
    public void beforeInsert(SObject so) {
        this.ips.setInvoicePaymentStatus((Zuora__ZInvoice__c)so);
    }
    
    public void beforeUpdate(SObject oldSo, SObject so) {
        this.ips.setInvoicePaymentStatus((Zuora__ZInvoice__c)so);
    }

    public void beforeDelete(SObject so){}

    public void afterInsert(SObject so) {}

    public void afterUpdate(SObject oldSo, SObject so) {}

    public void afterDelete(SObject so){}

    public void andFinally(){}
*/
}