public class EnqueueQueryMoreZuora implements Queueable, Database.AllowsCallouts {
    
    public void execute(QueueableContext context) {
        
        ZuoraSyncController.ProcessNextQMZ();
    }
}