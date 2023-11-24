global class BatchSLILinkage_Sched_S implements Schedulable {
    global void execute(SchedulableContext sc) {
        database.executebatch(new BatchSLILinkage(false));
    }
}