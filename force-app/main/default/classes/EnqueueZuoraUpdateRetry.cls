public class EnqueueZuoraUpdateRetry implements Queueable, Database.AllowsCallouts {
    
    public List<sObject> lstSObj;
    public List<QueryMoreZuora__c> lstQMZ;
    public Boolean RunQMZ;
    public String sObjName;
    
    public EnqueueZuoraUpdateRetry(String iSObjName, List<sObject> iLstSObj, List<QueryMoreZuora__c> iLstQMZ, Boolean iRunQMZ) {
        lstSObj = iLstSObj;
        lstQMZ = iLstQMZ;
        RunQMZ = iRunQMZ;
        sObjName = iSObjName;
    }
    
    public void execute(QueueableContext context) {
        
        if (!test.isRunningTest()) ZuoraSyncController.ZuoraUpsert(sObjName, lstSObj, lstQMZ, RunQMZ);
    }
    
}