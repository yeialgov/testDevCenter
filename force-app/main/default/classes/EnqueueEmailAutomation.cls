public class EnqueueEmailAutomation implements Queueable, Database.AllowsCallouts {
    
    public Final String RelatedToId;
    public Final String WhoIdsString; 
    public Final String CCsString;
    public Final String EmailSubject;
    public Final String EmailText;
    public Final String Attachments;
    public Final String BCCAddresses;
    public Final String OWEAId;
    public Final String Language;
    public Final Boolean OpenNotify;
    
    public EnqueueEmailAutomation (
        String iRelatedToId, 
        String iWhoIdsString, 
        String iCCsString, 
        String iEmailSubject,
        String iEmailText,
        String iAttachments,
        String iBCCAddresses,
        String iOWEAId,
        String iLanguage,
        Boolean iOpenNotify
    ){
        RelatedToId = iRelatedToId; 
        WhoIdsString = iWhoIdsString; 
        CCsString = iCCsString; 
        EmailSubject = iEmailSubject;
        EmailText = iEmailText;
        Attachments = iAttachments;
        BCCAddresses = iBCCAddresses;
        OWEAId = iOWEAId;
        Language = iLanguage;
        OpenNotify = iOpenNotify;
    }
    
    public void execute(QueueableContext context) {
        if(!test.isRunningTest()) EmailSender.sendEmail(RelatedToId, WhoIdsString, CCsString, EmailSubject, EmailText, Attachments, BCCAddresses, OWEAId, Language, OpenNotify);
    }
}