global class InvoiceUpdater_Scheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        InvoiceUpdater b = new InvoiceUpdater(); 
        database.executebatch(b, 50);
    }
}