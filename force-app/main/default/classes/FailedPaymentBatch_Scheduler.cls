global class FailedPaymentBatch_Scheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        FailedPaymentBatch b = new FailedPaymentBatch(); 
        database.executebatch(b, 10);
    }
}