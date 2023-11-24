public class EnqueueZuoraEmailUpdate implements Queueable, Database.AllowsCallouts {
    
    public List<String> InvoiceZIds { get; set; }
    
    public EnqueueZuoraEmailUpdate(List<String> iInvoiceZIds) {
        InvoiceZIds = iInvoiceZIds;
    }
    
    public void execute(QueueableContext context) {
        
        ZuoraSyncController.UpdateZInvoice(InvoiceZIds);
    }
}