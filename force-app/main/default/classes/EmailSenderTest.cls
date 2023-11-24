@isTest(seeAllData=true) public class EmailSenderTest {

    static TestMethod void test1() {
        EmailMessage EM = [SELECT Id, MessageDate, RelatedToId, CreatedById, Subject, Key__c FROM EmailMessage WHERE RelatedToId != null ORDER BY CreatedDate DESC LIMIT 1];
        Contact c = [SELECT Id FROM Contact ORDER BY CreatedDate LIMIT 1];
        EM.Key__c = EncodingUtil.base64Encode(Blob.valueOf(String.valueOf(Math.random())+','+c.Id));
        update EM;
        EmailSender.notifyOpen(new List<Id>{ EM.Id });
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        email.plainTextBody = JSON.serialize(new EmailSender.NotifyEmailWrapper(em, c, 'Opportunity'));
        EmailNotifyHandler catcher = new EmailNotifyHandler();
        Messaging.InboundEmailResult result = catcher.handleInboundEmail(email, envelope);
    }
    
    static TestMethod void test2() {
        Account a = new Account(name='test');
        insert a;
        Contact c = new Contact(lastname='test',accountid=a.id,email='test@test.com');
        insert c;
        Opportunity o = new Opportunity(LAC_Shorthand__c='Walk-in',name='test',closedate=date.today(),stagename='New',accountid=a.Id);
        insert o;
        Invoice__c i = new Invoice__c(Account__c=a.Id);
        insert i;
        OBInvoice__c n = new OBInvoice__c(ExternalId__c='x');
        insert n;
        Quote q = new Quote(OpportunityId=o.Id,name='test');
        insert q;
        Case cc = new Case(AccountId = a.Id);
        insert cc;
        EmailSender.sendAsyncEmail(o.Id, JSON.serialize(new List<String>{c.Id}), '[]', 'EmailSubject', 'Email %%!Account.Name%% Text', '[]', null, null, 'German', true);
        EmailSender.sendAsyncEmail(i.Id, JSON.serialize(new List<String>{c.Id}), '[]', 'EmailSubject', 'Email %%!Account__r.Name%% Text', '[]', null, null, 'German', true);
        EmailSender.sendAsyncEmail(n.Id, JSON.serialize(new List<String>{c.Id}), '[]', 'EmailSubject', 'Email %%!Name%% Text', '[]', null, null, 'German', true);
        EmailSender.sendAsyncEmail(q.Id, JSON.serialize(new List<String>{c.Id}), '[]', 'EmailSubject', 'Email %%!Account.Name%% Text', '[]', null, null, 'German', true);
        EmailSender.sendCaseEmail(cc.Id, JSON.serialize(new List<String>{c.Id}), '[]', 'EmailSubject', 'Email %%!Account.Name%% Text', '[]', 'German', true, true);
        system.debug(json.serialize(EmailSender.previewEmail(cc.Id, JSON.serialize(new List<String>{c.Id}), 'EmailSubject', 'Email %%!Account.Name%% Text', 'German')));
    }
    
    static TestMethod void test3() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.params.put('id','test');
        RestContext.request = req;
        RestContext.response = res;
        EmailImageAPI.emailOpen();
    }
    
    static TestMethod void test4() {
        Send_Template_Folder__c stf = new Send_Template_Folder__c(name='test');
        insert stf;
        SendTemplate__c st = new SendTemplate__c(folder__c=stf.id,adminname__c='test',subject__c='test',message__c='test',object__c='Opportunity');
        insert st;
        Account a = new Account(name='test');
        insert a;
        Contact c = new Contact(lastname='test',accountid=a.id,email='test@test.com');
        insert c;
        Opportunity o = new Opportunity(LAC_Shorthand__c='Walk-in',name='test',closedate=date.today(),stagename='New',accountid=a.Id);
        insert o;
        EmailAutomater.AutomatedTemplateEmail(new List<EmailAutomater.EmailAutomationRequest>{new EmailAutomater.EmailAutomationRequest(c.Id,o.Id,'test')});
        system.debug(json.serialize(EmailSender.templateSearch('te', null,new List<String>{'Opportunity','German'})));
        system.debug(EmailSender.getAllTemplates('Opportunity'));
    }
    
}