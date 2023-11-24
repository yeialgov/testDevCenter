global class BatchSubscriptionLinkage_Sched_P implements Schedulable {
    global void execute(SchedulableContext sc) {
        database.executebatch(new BatchSubscriptionLinkage(true));
    }
}