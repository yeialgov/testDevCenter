/**
 * @author joern
 *
 * @todo integrate into lead handler (LeadTrigger)
 */
trigger LeadRegion on Lead (before insert, before update) {
    if(TriggerUtil.executeTrigger('LeadRegion')) {
        RegionManager rm = new RegionManager('Lead');
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