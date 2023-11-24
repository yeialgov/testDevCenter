global class BatchSLILinkage_Sched_P implements Schedulable {
    global void execute(SchedulableContext sc) {
        database.executebatch(new BatchSLILinkage(true));
    }
}