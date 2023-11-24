global class DailyBatcher_scheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        List<Batch_Object__mdt> Objects = [SELECT DeveloperName FROM Batch_Object__mdt];
        for (Batch_Object__mdt Obj : Objects) database.executeBatch(new dailybatcher(Obj.DeveloperName));
    }
}