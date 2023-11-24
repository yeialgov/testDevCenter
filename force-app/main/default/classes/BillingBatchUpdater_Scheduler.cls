global class BillingBatchUpdater_Scheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        BillingBatchUpdater b = new BillingBatchUpdater(); 
        database.executebatch(b, 50);
    }
}