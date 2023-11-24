global class ScheduledNPSNewMonth implements Schedulable{
    global void execute(SchedulableContext SC) {
        SurveyMonkeyAPI.newMonthCollector();
    }
}