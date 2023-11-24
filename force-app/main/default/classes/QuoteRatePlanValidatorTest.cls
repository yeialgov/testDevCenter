/**
 * @author keylight
 */
@isTest
private class QuoteRatePlanValidatorTest {/*
	@isTest static void constructor_test() {
		List<zqu__QuoteRatePlanCharge__c> quoteRatePlanCharges = new List<zqu__QuoteRatePlanCharge__c>();
        QuoteRatePlanValidator quoteRatePlanValidator = new QuoteRatePlanValidator(quoteRatePlanCharges);
        System.assertEquals(quoteRatePlanCharges, quoteRatePlanValidator.ratePlanCharges);
    }

    @isTest static void validateQuotes_validation_should_succeed() {
    	List<zqu__QuoteRatePlanCharge__c> quoteRatePlanCharges = new List<zqu__QuoteRatePlanCharge__c>();
    	zqu__Quote__c quote = QuoteRatePlanValidatorTest.createTestQuote();
    	quoteRatePlanCharges.add(QuoteRatePlanValidatorTest.createQuoteTestData('POS Base License', 12, quote));
    	quoteRatePlanCharges.add(QuoteRatePlanValidatorTest.createQuoteTestData('POS Add-on License', 12, quote));
    }

     @isTest static void validateQuotes_validation_should_fail() {
     	Boolean error = false;
     	try {
    	List<zqu__QuoteRatePlanCharge__c> quoteRatePlanCharges = new List<zqu__QuoteRatePlanCharge__c>();
    	zqu__Quote__c quote = QuoteRatePlanValidatorTest.createTestQuote();
    	quoteRatePlanCharges.add(QuoteRatePlanValidatorTest.createQuoteTestData('POS Base License', 12, quote));
    	quoteRatePlanCharges.add(QuoteRatePlanValidatorTest.createQuoteTestData('POS Add-on License', 24, quote));
    	} catch (Exception e) {
    		error = true;
    	}
    	System.assertEquals(true, error);
    }

    @isTest static void getQuoteTermMonths_should_return_id_integer_map() {
    	List<zqu__QuoteRatePlanCharge__c> quoteRatePlanCharges = new List<zqu__QuoteRatePlanCharge__c>();
    	zqu__Quote__c quote = QuoteRatePlanValidatorTest.createTestQuote();
    	quoteRatePlanCharges.add(QuoteRatePlanValidatorTest.createQuoteTestData('POS Base License', 12, quote));
    	QuoteRatePlanValidator quoteRatePlanValidator = new QuoteRatePlanValidator(quoteRatePlanCharges);
    	System.assertEquals(12, quoteRatePlanValidator.getQuoteTermMonths().get(quote.id));
    }

    @isTest static void findQuoteIds_should_return_set_of_quote_ids() {
    	List<zqu__QuoteRatePlanCharge__c> quoteRatePlanCharges = new List<zqu__QuoteRatePlanCharge__c>();
    	zqu__Quote__c quote = QuoteRatePlanValidatorTest.createTestQuote();
    	quoteRatePlanCharges.add(QuoteRatePlanValidatorTest.createQuoteTestData('POS Base License', 12, quote));
    	QuoteRatePlanValidator quoteRatePlanValidator = new QuoteRatePlanValidator(quoteRatePlanCharges);
    	System.assertEquals(true, quoteRatePlanValidator.findQuoteIds().contains(quote.id));
    }

    private static zqu__Quote__c createTestQuote() {
    	zqu__Quote__c quote = new zqu__Quote__c();
    	insert quote;
    	return quote;
    }

    private static zqu__QuoteRatePlanCharge__c createQuoteTestData(String ratePlanType, Integer billingPeriod, zqu__Quote__c quote) {    
    	zqu__ZProduct__c product = new zqu__ZProduct__c();
    	insert product;

    	zqu__QuoteAmendment__c amendment = new zqu__QuoteAmendment__c();
    	amendment.zqu__Quote__c = quote.id;
    	insert amendment;

    	zqu__ProductRatePlan__c productRatePlan = new zqu__ProductRatePlan__c();
    	productRatePlan.RatePlanType__c = ratePlanType;
    	productRatePlan.zqu__ZProduct__c = product.id;
    	insert productRatePlan;

    	zqu__QuoteRatePlan__c quoteRatePlan = new zqu__QuoteRatePlan__c();
    	quoteRatePlan.zqu__ProductRatePlan__c = productRatePlan.id;
    	quoteRatePlan.zqu__Quote__c = quote.id;
    	quoteRatePlan.zqu__QuoteAmendment__c = amendment.id;
    	insert quoteRatePlan;

		zqu__QuoteRatePlanCharge__c quoteRatePlanCharge = new zqu__QuoteRatePlanCharge__c();
		quoteRatePlanCharge.zqu__SpecificBillingPeriod__c = billingPeriod;
		quoteRatePlanCharge.zqu__QuoteRatePlan__c = quoteRatePlan.id;
		insert quoteRatePlanCharge;

		return quoteRatePlanCharge;
    }*/
}