global class CCPD_Scheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        CCPD_Calculator b = new CCPD_Calculator(); 
        database.executebatch(b);
    }
}