global class InstalmentBillRun_scheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        InstalmentBillRun b = new InstalmentBillRun(); 
        database.executebatch(b, 50);
    }
}