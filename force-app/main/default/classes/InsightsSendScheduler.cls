global class InsightsSendScheduler implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        if (!test.isRunningTest()) Database.executeBatch(new InsightsSender());
    }
}