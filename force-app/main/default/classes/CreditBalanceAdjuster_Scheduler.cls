global class CreditBalanceAdjuster_Scheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        CreditBalanceAdjuster b = new CreditBalanceAdjuster(); 
        database.executebatch(b);
    }
}