trigger TaskTrigger on Task (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    if(TriggerUtil.executeTrigger('Task')) {
        if (Trigger.isAfter && Trigger.isInsert) {
            TaskNextRollup tnr = new TaskNextRollup(Trigger.newMap, Trigger.oldMap);
            tnr.execute();
            //TaskUtil.updateTaskAcct(JSON.serialize(trigger.newmap));
        }

        if (Trigger.isAfter && Trigger.isUpdate) {
            TaskNextRollup tnr = new TaskNextRollup(Trigger.newMap, Trigger.oldMap);
            tnr.execute();
        }
        
        if (Trigger.isBefore && Trigger.isUpdate) {
            for (Task t : trigger.new) {
                t.Account__c = t.AccountId;
            }
        }
        
        if (Trigger.isBefore && (Trigger.isUpdate || Trigger.isInsert)) {
            for (Task t : trigger.new) {
                if (t.Description != null) {
                    Integer len = t.Description.length();
                    t.Preview__c = t.Description.substring(0,Math.min(254,len));
                }
            }
        }
        
    }
}