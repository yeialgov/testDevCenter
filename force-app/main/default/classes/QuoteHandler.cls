/**
 * @author keylight
 */
public class QuoteHandler {// implements ITriggerHandler {
    
    /*
     * Use this lists for dml operations
     *
    private List<SObject> itemsToInsert = new List<SObject>();
    private List<SObject> itemsToUpdate = new List<SObject>();
    private List<SObject> itemsToDelete = new List<SObject>();
       
    private QuoteAccountSync quoteAccountSync;
    private QuoteFieldUpdate quoteFieldUpdate;

    /**
     * bulkBefore
     *
     * This method is called prior to execution of a BEFORE trigger. Use this to cache
     * any data required into maps prior execution of the trigger.
     *
    public void bulkBefore(){
        if (Trigger.isUpdate || Trigger.isInsert) {
            this.quoteAccountSync = new QuoteAccountSync(Trigger.new);
        	this.itemsToUpdate.addAll((List<SObject>) this.quoteAccountSync.updateAccounts());
            this.quoteFieldUpdate = new QuoteFieldUpdate(this.quoteAccountSync.getAccounts());
        }
    }
    
    /**
     * bulkAfter
     *
     * This method is called prior to execution of an AFTER trigger. Use this to cache
     * any data required into maps prior execution of the trigger.
     *
    public void bulkAfter(){}
    
    /**
     * beforeInsert
     *
     * This method is called iteratively for each record to be inserted during a BEFORE
     * trigger. Never execute any SOQL/SOSL etc in this and other iterative methods.
     *
    public void beforeInsert(SObject so) {
        this.quoteFieldUpdate.updateFields((zqu__Quote__c) so);
    }
    
    /**
     * beforeUpdate
     *
     * This method is called iteratively for each record to be updated during a BEFORE
     * trigger.
     *
    public void beforeUpdate(SObject oldSo, SObject so) {
        this.quoteFieldUpdate.updateFields((zqu__Quote__c) so);
    }

    /**
     * beforeDelete
     *
     * This method is called iteratively for each record to be deleted during a BEFORE
     * trigger.
     *
    public void beforeDelete(SObject so){}

    /**
     * afterInsert
     *
     * This method is called iteratively for each record inserted during an AFTER
     * trigger. Always put field validation in the 'After' methods in case another trigger
     * has modified any values. The record is 'read only' by this point.
     *
    public void afterInsert(SObject so) {}

    /**
     * afterUpdate
     *
     * This method is called iteratively for each record updated during an AFTER
     * trigger.
     *
    public void afterUpdate(SObject oldSo, SObject so) { }

    /**
     * afterDelete
     *
     * This method is called iteratively for each record deleted during an AFTER
     * trigger.
     *
    public void afterDelete(SObject so){}

    /**
     * andFinally
     *
     * This method is called once all records have been processed by the trigger. Use this 
     * method to accomplish any final operations such as creation or updates of other records.
     *
    public void andFinally(){
        //insert itemsToInsert;
        update this.itemsToUpdate;
        //delete itemsToDelete;
    }*/
}