public class SalesConsoleController {
    
    @AuraEnabled
    public static String getConsoleItems() {
        List<ConsoleItemWrapper> Items = new List<ConsoleItemWrapper>();
        DateTime TheTime = DateTime.now().addHours(-2);
        for (Lead l : [
            SELECT Id, Name, Company, CreatedDate
            FROM Lead
            WHERE IsConverted = false AND CreatedDate > :TheTime
        ]) {
            Items.add(new ConsoleItemWrapper(l));
        }
        /*for (Opportunity o : [
            SELECT Id, Name, Account.Name, Converted_Lead__r.Name, Converted_Lead__r.CreatedDate
            FROM Opportunity
            WHERE 
            CreatedDate > :TheTime
            AND Converted_Lead__c != null
            AND Reaction_Time__c = null
        ]) {
            Items.add(new ConsoleItemWrapper(o));
        }*/
        /*for (Task t : [
            SELECT Id, Who.Name, Opportunity__r.Account.Name, Opportunity__r.Converted_Lead__r.CreatedDate
            FROM Task
            WHERE Status != 'Completed' AND Opportunity__c != null
        ]) {
            Items.add(new ConsoleItemWrapper(t));
        }*/
        Items.sort();
        return JSON.serialize(Items);
    }
    
    public class ConsoleItemWrapper implements Comparable{
        public String Name { get; set; }
        public String Id { get; set; }
        public String Venue { get; set; }
        public String ObjectType { get; set; }
        public DateTime CreatedDate { get; set; }
        public Integer compareTo(Object compareTo) {
            ConsoleItemWrapper compareToCIW = (ConsoleItemWrapper)compareTo;
            if (CreatedDate == compareToCIW.CreatedDate) return 0;
            if (CreatedDate > compareToCIW.CreatedDate) return -1;
            return 1;        
        }
        /*public ConsoleItemWrapper (Opportunity o) {
            Name = o.Converted_Lead__r.Name;
            Id = o.Id;
            Venue = o.Account.Name;
            ObjectType = 'opportunity';
            CreatedDate = o.Converted_Lead__r.CreatedDate;
        }*/
        public ConsoleItemWrapper (Lead l) {
            Name = l.Name;
            Id = l.Id;
            Venue = l.Company;
            ObjectType = 'lead';
            CreatedDate = l.CreatedDate;
        }
        /*public ConsoleItemWrapper (Task t) {
            Name = t.Who.Name;
            Id = t.Id;
            Venue = t.Opportunity__r.Account.Name;
            ObjectType = 'task';
            CreatedDate = t.Opportunity__r.Converted_Lead__r.CreatedDate;
        }*/
    }
    
    /*
    @AuraEnabled
    public static String getTask(String TaskId) {
        Task Task = [
            SELECT Id, Subject, Description, ActivityDate, Opportunity__c, Type__c, Subtype__c, Outcome__c, Activity_Type__c
            FROM Task
            WHERE Id=:TaskId
            LIMIT 1
        ];
        return JSON.serialize(Task);
    }
    
    @AuraEnabled
    public static void saveTask(String jsonTask) {
        Task t = (Task)JSON.deserialize(jsonTask, Task.class);
        update t;
    }
    
    @AuraEnabled
    public static void saveTaskCallPlaced(String OpportunityId) {
        Opportunity o = [
            SELECT Id, First_Activity_Date_Time__c 
            FROM Opportunity 
            WHERE Id = :OpportunityId 
            LIMIT 1
        ];
        if (o.First_Activity_Date_Time__c == null) o.First_Activity_Date_Time__c = DateTime.now();
        update o;
    }

    @AuraEnabled
    public static void saveTaskCallSuccess(String OpportunityId, String TaskId) {
        Opportunity o = [
            SELECT Id, First_Activity_Date_Time__c, First_Successful_Activity_Date_Time__c
            FROM Opportunity 
            WHERE Id = :OpportunityId 
            LIMIT 1
        ];
        if (o.First_Activity_Date_Time__c == null) o.First_Activity_Date_Time__c = DateTime.now();
        if (o.First_Successful_Activity_Date_Time__c == null) o.First_Successful_Activity_Date_Time__c = DateTime.now();
        update o;
        Task t = [SELECT Id, Outcome__c FROM Task WHERE Id = :TaskId LIMIT 1];
        t.Outcome__c = 'Successful';
        update t;
    }*/

}