global class SchedFetch_Account implements Schedulable, Database.AllowsCallouts {
    global void execute(SchedulableContext sc) {
        ZuoraSyncController.AccountFetch();
    }
}