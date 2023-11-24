global class DOI_Sync_scheduler implements Schedulable {
    
    private Final String FetchType;
    
    global DOI_Sync_scheduler() {}
    
    global void execute(SchedulableContext sc) {
        System.enqueueJob(new DOI_Sync());
    }
}