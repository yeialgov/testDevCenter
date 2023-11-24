global class InvoiceSendScheduler implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new InvoiceSender(), 50);
    }
}