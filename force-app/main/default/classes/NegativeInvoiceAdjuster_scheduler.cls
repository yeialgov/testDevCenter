global class NegativeInvoiceAdjuster_scheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        NegativeInvoiceAdjuster b = new NegativeInvoiceAdjuster(); 
        database.executebatch(b, 50);
    }
}