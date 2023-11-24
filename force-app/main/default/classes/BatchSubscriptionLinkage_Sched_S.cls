global class BatchSubscriptionLinkage_Sched_S implements Schedulable {
    global void execute(SchedulableContext sc) {
        database.executebatch(new BatchSubscriptionLinkage(false));
    }
}