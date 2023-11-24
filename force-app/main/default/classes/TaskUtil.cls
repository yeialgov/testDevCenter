public class TaskUtil {
    
    @future
    public static void updateTaskAcct(String s) {
        try{
            List<Task> upsTasks = new List<Task>();
            Map<String,Object> tasks = (Map<String,Object>)JSON.deserializeUntyped(s); 
            for (String taskId : tasks.keySet()) {
                
                upsTasks.add(new Task(Id=taskId, Account__c=(Id)(((Map<String,Object>)tasks.get(taskId)).get('AccountId'))));
            }
            upsert upsTasks;
        }catch(exception e){}
    }
    
}