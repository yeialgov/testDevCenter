/**
 * @author keylight
 */
@isTest
private class QuoteRatePlanChargeHandlerTest {/*
	@isTest static void should_set_sepcific_quote_terms()
	{
		zqu__Quote__c quote = QuoteRatePlanChargeHandlerTest.createQuoteTestData();
		zqu__QuoteAmendment__c quoteAmendment = QuoteRatePlanChargeHandlerTest.createQuoteAmendmentTestData(quote);
		QuoteRatePlanChargeHandlerTest.createChargeTestData(quote, quoteAmendment, 'POS Base License', 24);
		zqu__Quote__c quoteTest = [SELECT Id, Name, zqu__Subscription_Term_Type__c, zqu__InitialTerm__c, zqu__RenewalTerm__c FROM zqu__Quote__c WHERE id =: quote.Id];
		System.assertEquals('Termed', quoteTest.zqu__Subscription_Term_Type__c);
		System.assertEquals(24, quoteTest.zqu__InitialTerm__c);
		System.assertEquals(24, quoteTest.zqu__RenewalTerm__c);		
	}

	@isTest static void should_set_evergreen_terms()
	{
		zqu__Quote__c quote = QuoteRatePlanChargeHandlerTest.createQuoteTestData();
		zqu__QuoteAmendment__c quoteAmendment = QuoteRatePlanChargeHandlerTest.createQuoteAmendmentTestData(quote);
		QuoteRatePlanChargeHandlerTest.createChargeTestData(quote, quoteAmendment, 'POS Base License', 1);
		zqu__Quote__c quoteTest = [SELECT Id, Name, zqu__Subscription_Term_Type__c, zqu__InitialTerm__c, zqu__RenewalTerm__c FROM zqu__Quote__c WHERE id =: quote.Id];
		System.assertEquals('Evergreen', quoteTest.zqu__Subscription_Term_Type__c);	
	}

	@isTest static void should_allow_same_term_add_on() {
		zqu__Quote__c quote = QuoteRatePlanChargeHandlerTest.createQuoteTestData();
		zqu__QuoteAmendment__c quoteAmendment = QuoteRatePlanChargeHandlerTest.createQuoteAmendmentTestData(quote);
		QuoteRatePlanChargeHandlerTest.createChargeTestData(quote, quoteAmendment, 'POS Base License', 12);
		Boolean hasError = false;
		try {
			QuoteRatePlanChargeHandlerTest.createChargeTestData(quote, quoteAmendment, 'POS Add-on License', 12);
		} catch (DmlException e) {
			hasError = true;
		}
		System.assertEquals(false, hasError);
	}

	@isTest static void should_allow_monthly_add_on() {
		zqu__Quote__c quote = QuoteRatePlanChargeHandlerTest.createQuoteTestData();
		zqu__QuoteAmendment__c quoteAmendment = QuoteRatePlanChargeHandlerTest.createQuoteAmendmentTestData(quote);
		QuoteRatePlanChargeHandlerTest.createChargeTestData(quote, quoteAmendment, 'POS Base License', 24);
		Boolean hasError = false;
		try {
			QuoteRatePlanChargeHandlerTest.createChargeTestData(quote, quoteAmendment, 'POS Add-on License', 1);
		} catch (DmlException e) {
			hasError = true;
		}
		System.assertEquals(false, hasError);
	}

	@isTest static void should_throw_error() {
		zqu__Quote__c quote = QuoteRatePlanChargeHandlerTest.createQuoteTestData();
		zqu__QuoteAmendment__c quoteAmendment = QuoteRatePlanChargeHandlerTest.createQuoteAmendmentTestData(quote);
		QuoteRatePlanChargeHandlerTest.createChargeTestData(quote, quoteAmendment, 'POS Base License', 12);
		Boolean hasError = false;
		try {
			QuoteRatePlanChargeHandlerTest.createChargeTestData(quote, quoteAmendment, 'POS Add-on License', 24);
		} catch (DmlException e) {
			hasError = true;
		}
		System.assertEquals(true, hasError);
	}

	private static zqu__Quote__c createQuoteTestData() {
		zqu__Quote__c quote = new zqu__Quote__c();
		quote.name = 'TestQuote';
		insert quote;
		return quote;
	}

	private static zqu__QuoteAmendment__c createQuoteAmendmentTestData(zqu__Quote__c quote) {
		zqu__QuoteAmendment__c quoteAmendment = new zqu__QuoteAmendment__c();
		quoteAmendment.zqu__Quote__c = quote.id;
		insert quoteAmendment;
		return quoteAmendment;
	}

	private static void createChargeTestData(zqu__Quote__c quote, zqu__QuoteAmendment__c quoteAmendment, String ratePlanType, Integer month) {
		zqu__ZProduct__c product = new zqu__ZProduct__c();
		product.name = 'TestProduct';
		insert product;

		zqu__ProductRatePlan__c productRatePlan = new zqu__ProductRatePlan__c();
		productRatePlan.RatePlanType__c = ratePlanType;
		productRatePlan.zqu__ZProduct__c = product.id;
		insert productRatePlan;

		zqu__QuoteRatePlan__c quoteRatePlan = new zqu__QuoteRatePlan__c();
		quoteRatePlan.name = 'TestRatePlan';
		quoteRatePlan.zqu__Quote__c = quote.id;
		quoteRatePlan.zqu__QuoteAmendment__c = quoteAmendment.id;
		quoteRatePlan.zqu__ProductRatePlan__c = productRatePlan.id;
		insert quoteRatePlan;

		zqu__QuoteRatePlanCharge__c charge = new zqu__QuoteRatePlanCharge__c();
		charge.zqu__QuoteRatePlan__c = quoteRatePlan.id;
		if (month == 1) {
			charge.zqu__Period__c = 'Month';
		} else if (month == 1) {
			charge.zqu__Period__c = 'Annual';
		} else {
			charge.zqu__SpecificBillingPeriod__c = month;
		}
		insert charge;
		update charge;
	}


	@isTest static void should_delete_quote_rate_plan_charge() {
		zqu__Quote__c quote = QuoteRatePlanChargeHandlerTest.createQuoteTestData();
		zqu__QuoteAmendment__c quoteAmendment = QuoteRatePlanChargeHandlerTest.createQuoteAmendmentTestData(quote);

		zqu__QuoteRatePlan__c quoteRatePlan = new zqu__QuoteRatePlan__c();
		quoteRatePlan.name = 'TestRatePlan';
		quoteRatePlan.zqu__Quote__c = quote.id;
		quoteRatePlan.zqu__QuoteAmendment__c = quoteAmendment.id;
		//quoteRatePlan.zqu__ProductRatePlan__c = productRatePlan.id;
		insert quoteRatePlan;

		zqu__QuoteRatePlanCharge__c charge = new zqu__QuoteRatePlanCharge__c();
		charge.zqu__QuoteRatePlan__c = quoteRatePlan.id;
		insert charge;

		delete charge;
	}*/
}