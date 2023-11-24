/**
 * @author joern
 *
 * @todo remove because is integrated in AccountHandler and deactivated via custom setting
 */

trigger AccountRegion on Account (before insert, before update) {
    if(TriggerUtil.executeTrigger('AccountRegion')) {
        RegionManager rm = new RegionManager('Account');
        if (Trigger.isBefore && Trigger.isInsert) {
            for (sObject so : Trigger.new) {
                rm.setRegionValues(so);
            }
        }
        if (Trigger.isBefore && Trigger.isUpdate) {
            for (SObject so : Trigger.old) {
                rm.updateRegionValues(Trigger.newMap.get(so.Id), so);
            }
        }
    }
}