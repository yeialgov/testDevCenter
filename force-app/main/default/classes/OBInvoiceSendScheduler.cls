global class OBInvoiceSendScheduler implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new OBInvoiceSender(), 50);
    }
}