/*
 * author: @bart
 */ 
public class LeadTimeCalculator {
    
    public static Integer StartHour(DateTime dt) {
        return dt < DateTime.newInstance(2019,9,1) ? 9 : 10;
    }

    public static Integer CloseHour(DateTime dt) {
        return dt < DateTime.newInstance(2019,9,1) ? 19 : 18;
    }

    public static Integer HrsInDay(DateTime dt) {
        return CloseHour(dt) - StartHour(dt);
    }
    
    public static Integer DayStartWeek = 0; //Monday
    public static Integer DayEndWeek = 4; //Friday
    public static Integer DaysInWeek = DayEndWeek - DayStartWeek + 1;
    
    public static Integer MinInHour = 60;
    public static Integer SecInMin = 60;


    public static String BaseLineField = 'Lead_Created_Date_Time__c'; //This is the DateTime the timing is measured from
    
    //What DateTime the timing is measured to, and what resulting field the calculation is stored in
    public static Map<String, String> trackedFields = new Map<String, String>{
        'First_Activity_Date_Time__c' => 'Reaction_Time__c',
        'First_Successful_Activity_Date_Time__c' => 'Response_Time__c'
    };
        
    public void updateLeadTimeValues(sObject obj, sObject objOld) {
        for (String changedField : changedFields(obj, objOld)) {
            obj.put(trackedFields.get(changedField), calculate(obj, changedField));
        }
    }
    
    //Calculates time in seconds between baseline datetime and parameter field datetime 
    public static Double calculate(sObject obj, String fldName) {
        
        DateTime startDT = (DateTime)obj.get(BaseLineField);
        DateTime endDT = (DateTime)obj.get(fldName);
        
        //Calculation void if either datetime is missing or if end is before start
        if (startDT == null || endDT == null || endDT < startDT) return null;
        
        //If start datetime falls after last day of work week, consider start datetime 00:00:00 Monday
        while (dayOfWeek(startDT) > DayEndWeek) {
            startDT = DateTime.newInstance(
                Date.newInstance(startDT.year(), startDT.month(), startDT.day()).addDays(1), 
                Time.newInstance(0,0,0,0)
            );
        }
        
        //If end datetime falls before first day of work week, consider end datetime 23:59:59 Sunday
        //This solves a "theoretical" problem which would only exist if work week did not start on Monday
        //uncomment this if business rules change accordingly
        /*
         *  while (dayOfWeek(endDT) < DayStartWeek) endDT = DateTime.newInstance(
                Date.newInstance(endDT.year(), endDT.month(), endDT.day()).addDays(-1), 
                Time.newInstance(23,59,59,0)
            );
        **/

        //I don't think this logic is necessary, leaving it for now in case I'm wrong...
        /*
         *  while (dayOfWeek(startDT) < DayStartWeek) startDT = DateTime.newInstance(Date.newInstance(startDT.year(), startDT.month(), startDT.day()).addDays(-1), Time.newInstance(23,59,59,0));
            while (dayOfWeek(endDT) > DayEndWeek) endDT = DateTime.newInstance(Date.newInstance(endDT.year(), endDT.month(), endDT.day()).addDays(1), Time.newInstance(0,0,0,0));
        **/
        
        //Calculate number of seconds in every week that is in range
        Integer weekSeconds = weekSeconds(startDT, endDT);
        
        //Number of seconds in week before range begins
        Integer secBefore = secBefore(startDT);
        
        //Number of seconds in week after range ends
        Integer secAfter = secAfter(endDT);
        
        return math.max(0,weekSeconds - secBefore - secAfter);
    }
    
    //Method for use by BatchUtil to retro-fill
    public static void processBatch(list<sObject> scope) {
        for (sObject sObj : scope) {
            for (String fldName : trackedFields.keySet()) {
                sObj.put(trackedFields.get(fldName), calculate(sObj, fldName));
            }
        }
        update scope;
    }
    
    //Calculates (number of seconds in a week) * (number of weeks in the range)
    private static Integer weekSeconds(DateTime startDT, DateTime endDT) {
        return (1 + weekNumber(endDT) - weekNumber(startDT)) * (SecInMin * MinInHour * HrsInDay(endDT) * DaysInWeek);
    }

    //Calculates number of seconds in the week before the range begins
    public static Integer secBefore(DateTime DT) {
        return Math.min(Math.max((seconds(DT) - (StartHour(DT) * MinInHour * SecInMin)), 0), SecInMin * MinInHour * HrsInDay(DT)) 
            + (Math.max((Math.min(DayEndWeek, dayOfWeek(DT)) - DayStartWeek), 0) * SecInMin * MinInHour * HrsInDay(DT));
    }

    //Calculates number of seconds in the week after the range ends
    public static Integer secAfter(DateTime DT) {
        return Math.min(Math.max(((CloseHour(DT) * MinInHour * SecInMin) - seconds(DT)), 0), SecInMin * MinInHour * HrsInDay(DT)) 
            + (Math.max((DayEndWeek - Math.max(DayStartWeek, dayOfWeek(DT))), 0) * SecInMin * MinInHour * HrsInDay(DT));
    }
    
    //Converts a DateTime into seconds
    public static Integer seconds(DateTime DT) {
        return (DT.time().hour() * SecInMin * MinInHour + DT.time().minute() * SecInMin + DT.time().second());
    }
    
    //Converts a DateTime into an Integer represent "day of the week"
    //Monday => 0 ... Sunday => 6
    public static Integer dayOfWeek(DateTime DT) {
        return Math.mod(
            Date.newInstance(0001,1,3).daysBetween(Date.newInstance(
                DT.year(), DT.month(), DT.day()
            )), 7
        );
    }
    
    //Converts a DateTime to a week number
    //Weeks begin on Monday
    public static Integer weekNumber(DateTime DT) {
        return Date.newInstance(0001,1,3).daysBetween(Date.newInstance(
            DT.year(), DT.month(), DT.day()
        )) / 7;
    }
    
    //Returns a list of tracked fields that have changed
    public static List<String> changedFields(sObject obj, sObject objOld) {
        List<String> changedFields = new List<String>();
        for (String fldName : trackedFields.keySet()) {
            if (obj.get(fldName) != objOld.get(fldName)) changedFields.add(fldName);
        }
        return changedFields;
    }


}