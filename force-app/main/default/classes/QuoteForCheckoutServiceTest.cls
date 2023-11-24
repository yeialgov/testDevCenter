/**
 * @author keylight
 */
@isTest
private class QuoteForCheckoutServiceTest {
	/*
	static zqu__Quote__c createTestQuote() {
		Account account = new Account();
		account.name = 'TestSalesCheckout';
		account.BillingCountry = 'Germany';
		account.Phone = '+491701948378';
		insert account;

		Contact contact = new Contact();
		contact.FirstName = 'Test';
		contact.LastName = 'Test';
		contact.MailingCountry = 'Germany';
		contact.AccountId = account.Id;
		contact.Email = 'fnsdnfldsf@email.de';
		contact.MailingStreet = 'TestStrasse \n 10625 Berlin';
		contact.Phone = '+491701948378';
		contact.MobilePhone = '+491701948378';
		contact.OtherPhone = '+491701948378';
		insert contact;

		Contact contact2 = new Contact();
		contact2.FirstName = 'Test';
		contact2.LastName = 'Test';
		contact2.MailingCountry = 'Germany';
		contact2.AccountId = account.Id;
		contact2.Email = 'fnsdnfldsf@email.de';
		contact2.MailingStreet = 'TestStrasse \n 10625 Berlin';
		contact2.Phone = '+491701948378';
		contact2.MobilePhone = '+491701948378';
		contact2.OtherPhone = '+491701948378';
		insert contact2;


		zqu__Quote__c quote = new zqu__Quote__c();
		quote.zqu__Account__c = account.Id;
		quote.zqu__BillToContact__c = contact.Id;
		quote.zqu__SoldToContact__c = contact2.Id;
		quote.zqu__StartDate__c = Date.newInstance(2017, 2, 17);
		insert quote;

		/*zqu__QuoteCharge__c charge = new zqu__QuoteCharge__c();
		charge.zqu__ProductName__c = 'Testproduct';
		charge.zqu__Quote__c = quote.id;
		insert charge;*/


		/*List<zqu__QuoteCharge__c> addedProducts = new List<zqu__QuoteCharge__c>();
		addedProducts.add(charge);
		System.debug('charge');
		System.debug(charge);
		System.debug('products');
		quote.addQuoteProducts(addedProducts);*/
		//System.debug(quote.getQuoteProducts() );
		/*List<zqu.Product> productsToAdd = zqu.Product.loadProductsWithChildren(new List<Id>{charge.id});
		zqu.Quote currentQuote = zqu.Quote.getInstance(quote.id);
		currentQuote.addQuoteProducts(productsToAdd);
		System.debug('productsToAdd');
		System.debug(productsToAdd);
		currentQuote.save();*/
		/*zqu__ZProduct__c product = new zqu__ZProduct__c();
		product.Name = 'Testproduct';
		insert product;



		zqu__ProductRatePlan__c prp1 = new zqu__ProductRatePlan__c();
		prp1.zqu__ZProduct__c = product.id;
		prp1.Name = 'SomeSampleRatePlan';
		insert prp1;

		zqu.zChargeGroup zcg = zqu.zQuoteUtil.getChargeGroup((ID) quote.Id, (ID)prp1.Id);
		System.debug('chargegroup');
		System.debug(zcg);

		zqu.zQuoteUtil.addChargeGroup(zcg);*

		return quote;
	}

	@isTest static void testGetError() {
		RestRequest req = new RestRequest(); 
	    RestResponse res = new RestResponse();

	    req.requestURI = URL.getSalesforceBaseUrl() + 'services/apexrest/QuoteForCheckout';  
	    req.params.put('quoteId','abc');
	    req.httpMethod = 'GET';

		RestContext.request = req;
	    RestContext.response = res;
	    QuoteForCheckoutService.QuoteResponse result = QuoteForCheckoutService.getQuoteForCheckout();
	    System.assertEquals(false, result.success);
	}
	
	@isTest static void testGetSuccess() {
		zqu__Quote__c quote = createTestQuote();

		RestRequest req = new RestRequest(); 
	    RestResponse res = new RestResponse();

	    req.requestURI = URL.getSalesforceBaseUrl() + 'services/apexrest/QuoteForCheckout';  
	    req.params.put('quoteId', quote.Id);
	    req.httpMethod = 'GET';

		RestContext.request = req;
	    RestContext.response = res;
	    QuoteForCheckoutService.QuoteResponse result = QuoteForCheckoutService.getQuoteForCheckout();
	    System.assertEquals(result.data.quote.Id, quote.Id);
	}

	@isTest static void testUpdateError() {
		Contact contact = new contact();
		contact.FirstName = 'Test';
		contact.LastName = 'Test';
		contact.MailingCountry = 'Germany';
		contact.Email = 'faffdsf@email.de';
		contact.Phone = '+491701948378';
		contact.MobilePhone = '+491701948378';
		contact.OtherPhone = '+491701948378';
		insert contact;

		RestRequest req = new RestRequest(); 
	    RestResponse res = new RestResponse();

	    req.requestURI = URL.getSalesforceBaseUrl() + 'services/apexrest/QuoteForCheckout';  
	    req.httpMethod = 'PUT';

		RestContext.request = req;
	    RestContext.response = res;

	    String result = QuoteForCheckoutService.updateQuote('abc', 'abc', contact, contact, 'abc', 'abc');
	    System.assertEquals('{"success":false}', result);
	}

	@isTest static void testUpdateSuccess() {
		Contact contact = new contact();
		contact.FirstName = 'Test';
		contact.LastName = 'Test';
		contact.MailingCountry = 'Germany';
		contact.Email = 'fasdfadsfasf@email.de';
		contact.Phone = '+491701948378';
		contact.MobilePhone = '+491701948378';
		contact.OtherPhone = '+491701948378';
		insert contact;

		zqu__Quote__c quote = createTestQuote();

		RestRequest req = new RestRequest(); 
	    RestResponse res = new RestResponse();

	    req.requestURI = URL.getSalesforceBaseUrl() + 'services/apexrest/QuoteForCheckout';
	    req.httpMethod = 'PUT';

		RestContext.request = req;
	    RestContext.response = res;

	    String result = QuoteForCheckoutService.updateQuote(quote.Id, 'abc', contact, contact, 'abc', 'abc');
	    System.assertEquals('{"success":true}', result);
	}

	@isTest static void testCheckoutError() {
		RestRequest req = new RestRequest(); 
	    RestResponse res = new RestResponse();

	    req.requestURI = URL.getSalesforceBaseUrl() + 'services/apexrest/QuoteForCheckout';  
	    req.httpMethod = 'POST';

		RestContext.request = req;
	    RestContext.response = res;

	    String result = QuoteForCheckoutService.checkoutQuote('abc', 'abc');
	    System.assertEquals('{"success":false}', result);
	}

	@isTest static void testCheckoutSuccess() {
		// ToDo fix test
		/*zqu__Quote__c quote = createTestQuote();

		RestRequest req = new RestRequest();
	    RestResponse res = new RestResponse();

	    req.requestURI = URL.getSalesforceBaseUrl() + 'services/apexrest/QuoteForCheckout';
	    req.httpMethod = 'POST';

		RestContext.request = req;
	    RestContext.response = res;

	    String result = QuoteForCheckoutService.checkoutQuote(quote.Id, 'abc');
	    System.assertEquals('{"success":true}', result);*/

		//zqu__Quote__c quote = createTestQuote();
		





		/*Account a = new Account();

		Datetime now = System.now();

		a.Name = 'New Account - '+now;

		insert a;

		//new Contact

		Contact c = new contact();

		c.firstname='Test Contact';
		c.lastname= ''+now;
		c.AccountId=a.id;
		c.email='test@email.com';
		c.MailingState = 'California';
		c.MailingPostalCode = '11111';
		c.MailingCountry = 'United States';

		insert c;

		//new Opportunity
		Opportunity o = new Opportunity();
		o.name = 'Opportunity - '+now;
		o.stagename = 'Closed Won';
		o.CloseDate = Date.newinstance(now.year(),now.month(),now.day());
		o.AccountId = a.id;

		insert o;

		System.debug(o);

		//new Quote

		zqu__Quote__c q = new zqu__Quote__c();
		q.name = 'Quote '+now;
		q.zqu__opportunity__c = o.id;
		q.zqu__ValidUntil__c = Date.newinstance(now.year(),now.month(),now.day());
		q.zqu__BillToContact__c = c.id;
		q.zqu__SoldToContact__c = c.id;
		q.zqu__StartDate__c = Date.newinstance(now.year(),now.month(),now.day());
		q.zqu__PaymentMethod__c = 'Credit Card';
		q.zqu__PaymentTerm__c = 'Net 30';
		q.zqu__Currency__c = 'USD';
		q.zqu__InitialTerm__c = 12;
		q.zqu__RenewalTerm__c = 12;
		q.zqu__GenerateInvoice__c = true;
		q.zqu__ProcessPayment__c = true;
		q.zqu__Account__c = a.id;

		insert q;

		//add existing product

		zqu.zChargeGroup newChargeGroup = zqu.zQuoteUtil.getChargeGroup(q.Id,'a0p41000001ota7');
		zqu.ZQuoteUtil.addChargeGroup(newChargeGroup);  
		String result = QuoteForCheckoutService.checkoutQuote(q.Id, 'abc');
	    System.assertEquals('{"success":true}', result);*
	}*/
}