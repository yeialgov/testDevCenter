global class InstalmentPaymentRun_scheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        InstalmentPaymentRun b = new InstalmentPaymentRun(); 
        database.executebatch(b, 50);
    }
}