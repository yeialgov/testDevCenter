global class AccountStatus_Scheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        AccountStatus_Calculator b = new AccountStatus_Calculator(); 
        database.executebatch(b);
    }
}