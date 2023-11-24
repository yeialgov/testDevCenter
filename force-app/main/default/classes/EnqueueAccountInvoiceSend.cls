public class EnqueueAccountInvoiceSend implements Queueable, Database.AllowsCallouts {
    
    public String AccountZId { get; set; }
    
    public EnqueueAccountInvoiceSend(String iAcctZId) {
        AccountZId = iAcctZId;
    }
    
    public void execute(QueueableContext context) {
        
        //Database.executeBatch(new InvoiceSender(AccountZId));
    }
}