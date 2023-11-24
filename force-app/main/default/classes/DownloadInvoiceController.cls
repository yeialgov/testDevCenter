/**
 * Created by keylight; perfected by not-keylight
 */
public class DownloadInvoiceController {

	private Invoice__c invoice;
	private String body;

	private class InvoiceFileResponse {
        String Body;       
    }

	public DownloadInvoiceController(ApexPages.StandardController stdController) {
		this.invoice = (Invoice__c)stdController.getRecord();
		this.invoice = [SELECT Id, ZuoraId__c FROM Invoice__c WHERE Id =:this.invoice.Id];
		String zuoraInvoice = ZuoraManager.callZuoraAPI('object/invoice/' + this.invoice.ZuoraId__c, 'GET', null);
		if (zuoraInvoice == null ){
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'no invoice found'));
		} else {
			InvoiceFileResponse response = (InvoiceFileResponse)JSON.deserialize(zuoraInvoice, InvoiceFileResponse.class);
			if (response.body == null) {
				ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'no invoice found'));
			} else {
				this.body = response.body;
			}	
		}
	}

	public String getDisplay() {
		return this.body;
	}
}