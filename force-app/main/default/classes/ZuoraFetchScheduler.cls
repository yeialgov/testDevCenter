global class ZuoraFetchScheduler implements Schedulable {
    
    private Final String FetchType;
    
    global ZuoraFetchScheduler(String iFetchType) {
        FetchType = iFetchType;
    }
    
    global void execute(SchedulableContext sc) {
        System.enqueueJob(new ZuoraFetchQueue(FetchType));
    }
}