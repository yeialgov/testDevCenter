global class CSVReportScheduler implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        CSVReportEmailer.EmailCSVs();
    }
    
}