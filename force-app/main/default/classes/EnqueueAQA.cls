public class EnqueueAQA implements Queueable, Database.AllowsCallouts {
    
    public void execute(QueueableContext context) {
        
        AutoQuoteAccept.doNowAutoQuoteAccept();
    }
}