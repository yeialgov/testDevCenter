global class DunningBatch_Scheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        for (Integer x=0; x<4; x++) {
            database.executeBatch(new DunningBatch(x), 20);
            if (x != 3) database.executeBatch(new UpfrontPaymentFollowUp(x));
        }
        
    }
}