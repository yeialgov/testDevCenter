/**
 * @author keylight
 */
public class SendQuoteController {
/*
    @TestVisible
	private zqu__Quote__c quote;
	public Contact contact {get; set;}
    public Email email {get; set;}    
    public String selectedContact { get; set; }
    public String contactRecipientCcInput { get; set; }
    public Boolean attach { get; set; }
    public List<EmailTemplate> emailTemplates {get; set;}
    public String item {get;set;}

    public class Email {
        public string subject {get; set;}
        public string content {get;set;}
    }

	public SendQuoteController(ApexPages.StandardController stdController) {
		Folder folder = [SELECT Id FROM Folder WHERE Name = 'Quotes'];
		EmailTemplate[] emailTemplates = [SELECT Id, Name, Subject, Body from EmailTemplate WHERE folderId =: folder.Id];
		this.emailTemplates = emailTemplates;
		this.attach = true;
		this.email = new Email();
        zqu__Quote__c quote = (zqu__Quote__c)stdController.getRecord();	
		this.quote = [SELECT Id, CurrencyIsoCode, RecordTypeId, zqu__BillToContact__c, zqu__SoldToContact__c, zqu__Account__c, DecryptedQuoteLink__c
            FROM zqu__Quote__c WHERE Id =:quote.Id Limit 1];
		this.contact  = [Select Id, Email, Name from Contact Where Id =:this.quote.zqu__BillToContact__c Limit 1];
		if (contact != null && contact.Email != null) {
			this.selectedContact = contact.Email;
		} else {
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'No email associated to this contact.')); 
		}
	}

	public PageReference sendEmail() {
       	Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

		if (String.isBlank(this.selectedContact)) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please select at least a recipient.')); 
            return null;
        }
        email.toAddresses = new String[]{this.selectedContact};

        if (!String.isBlank(this.contactRecipientCcInput)) {
        	email.setCCAddresses(new String[]{this.contactRecipientCcInput});
    	}
        email.setSubject( this.email.subject );
        email.setPlainTextBody( this.email.content );
		zqu__Quote__c quote = [SELECT Id, zqu__BillToContact__c, zqu__SoldToContact__c, zqu__Number__c, zqu__Account__c FROM zqu__Quote__c WHERE Id =: quote.Id Limit 1];
		Blob pdf;
		String fileName = quote.zqu__Number__c + '.pdf';

		if (this.attach == true) {
			attachQuote(email, pdf, fileName, quote); 
	    }
	    email.setSaveAsActivity(false);

	    if (!Test.isRunningTest()) {
            Messaging.SendEmailResult [] result = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
            Boolean success = true;
            for (Messaging.SendEmailResult r : result) {
		        if (!r.isSuccess()) {
		        	success = false;
		            Messaging.SendEmailError[] errArr = r.getErrors();
		        }
		    }
            if (success == true) {
            	createTask(email, quote.Id, pdf, fileName, this.attach);
        	}
            
        }

        return new PageReference('/' + quote.Id);
    }

	public PageReference cancel() {
        return new PageReference('/' + quote.Id);
    }

    @TestVisible
	private void createTask(Messaging.SingleEmailMessage email, String quoteId, Blob pdf, String fileName, Boolean attach) {
		Task task = new Task();
		task.WhatId = quoteId;
		task.Description = email.plainTextBody;
		task.Subject = email.getSubject();
		task.ActivityDate = date.today();
		List<String> test =  new List<String>();
		test.add(this.contact.id);
		task.WhoId = this.contact.id;
		task.status = 'completed';	
		insert task;
		if (attach) {
			Attachment att = new Attachment();
			att.Body = pdf;
			att.name = fileName;
			att.parentId = task.Id;
			insert att;
		}
	}

	public void copyText() {
        this.setQuoteLink();
		EmailTemplate template = [Select Id, Name, Subject, Body from EmailTemplate WHERE Id =:this.item LIMIT 1];
        String myResult = MergeFieldUtility.replaceMergeFieldsWithValues('{!', '}', template.body, this.quote.id);
        this.email.subject = template.subject;
        this.email.content = myResult;
	}

	public List<SelectOption> getItems() {
	    List<SelectOption> options = new List<SelectOption>();
    	for (EmailTemplate template : this.emailTemplates) {
    		 options.add(new SelectOption(template.id,template.name));
    	}	     
        return options;
	}

	@TestVisible
    private void setQuoteLink() {
        String urlParam = 'acc=' + this.quote.zqu__Account__c + '&qId=' + this.quote.Id + '&email=' + this.selectedContact;
        CryptAES cr = new CryptAES('AES256');
        this.quote.DecryptedQuoteLink__c = cr.encrypt(urlParam);
        update this.quote;
    }

    private void attachQuote(Messaging.SingleEmailMessage email, Blob pdf, String fileName, zqu__Quote__c quote) {
    	List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
		Boolean quotePdfMissing = false;
		pdf = ZuoraManager.getQuotePDF(quote.Id);
		if (pdf == null) {
			quotePdfMissing = true;
		} else {
			Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();				
			efa.setFileName(fileName);
        	efa.setBody(pdf);
        	attachments.add(efa);
		}
		if (quotePdfMissing) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Quote template missing. Messages has not been sent.'));         
        }
        email.setFileAttachments(attachments);
    }
*/
}