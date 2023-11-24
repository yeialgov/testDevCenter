global class InvoicePayment_Scheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        InvoicePayment_Batch b = new InvoicePayment_Batch(); 
        database.executebatch(b);
    }
}