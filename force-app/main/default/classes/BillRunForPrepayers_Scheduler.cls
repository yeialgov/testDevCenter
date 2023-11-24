global class BillRunForPrepayers_Scheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        BillRunForPrepayers b = new BillRunForPrepayers(); 
        database.executebatch(b, 50);
    }
}