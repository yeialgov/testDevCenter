/**
 * @author keylight
 */
global class ZuoraContactUpdate {
	public Contact contact;
	public String zuoraId;

	global ZuoraContactUpdate(Contact contact, String zuoraId) {
		this.contact = contact;
		this.zuoraId = zuoraId;
	}

    @TestVisible
	private String toJson() {
		String[] addresses = new List<String>();
        String description;
        if (contact.MailingStreet != null) addresses = contact.MailingStreet.split('\n');
        if (contact.Addressee__c != null) {
            description = contact.Addressee__c;
        }
        if (contact.Attention__c != null) {
            description = description + '\n' + contact.Attention__c;
        }
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        if (this.contact.Attention__c != null) gen.writeStringField('Attention__c', this.contact.Attention__c);
        if (this.contact.Addressee__c != null) gen.writeStringField('Addressee__c', this.contact.Addressee__c);
        if (description != null) {
            gen.writeStringField('Description', description);
        } else {
            gen.writeStringField('Description', '');
        }
        if (this.contact.FirstName != null) gen.writeStringField('FirstName', this.contact.FirstName);
        if (this.contact.LastName != null) gen.writeStringField('LastName', this.contact.LastName);
        if (addresses.size() > 0) {
            gen.writeStringField('Address1', addresses.get(0));
            gen.writeStringField('Address2', '');
        }
        if (addresses.size() > 1) gen.writeStringField('Address2', addresses[1]);
        if (this.contact.MailingPostalCode != null) gen.writeStringField('PostalCode', this.contact.MailingPostalCode);
        if (this.contact.MailingCity != null) gen.writeStringField('City', this.contact.MailingCity);
        if (this.contact.MailingCountry != null) gen.writeStringField('Country', this.contact.MailingCountry);
        if (this.contact.Email != null) gen.writeStringField('WorkEmail', this.contact.Email);
        gen.writeEndObject();
        return gen.getAsString();
    }

	global String send() {
		String data = this.toJson();
		String path = 'object/contact/' + this.zuoraId;
        String res = ZuoraManager.callZuoraAPI(path, 'PUT', data);
		return res;
	}
}