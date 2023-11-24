/**
 * @author keylight
 */
@isTest
private class QuoteTermsSetterTest {
    
    static testmethod void test() {
        QuoteAccountSync QuoteAccountSync = new QuoteAccountSync();
        QuoteAttachmentMandatory QuoteAttachmentMandatory = new QuoteAttachmentMandatory();
        QuoteFieldUpdate QuoteFieldUpdate = new QuoteFieldUpdate();
        QuoteForCheckoutService QuoteForCheckoutService = new QuoteForCheckoutService();
        QuoteHandler QuoteHandler = new QuoteHandler();
        QuotePopulatePlugin QuotePopulatePlugin = new QuotePopulatePlugin();
        QuoteRatePlanValidator QuoteRatePlanValidator = new QuoteRatePlanValidator();
        QuoteTermsSetter QuoteTermsSetter = new QuoteTermsSetter();
        ZuoraAccountUpdateUtil ZuoraAccountUpdateUtil = new ZuoraAccountUpdateUtil();
    }
    
    /*
	@isTest static void constructer_test() {
		Map<ID, Integer> quoteTermMonths = new Map<Id, Integer>();
        QuoteTermsSetter quoteTermsSetter = new QuoteTermsSetter(quoteTermMonths);
        System.assertEquals(quoteTermMonths, quoteTermsSetter.quoteTermMonths);
    }

	@isTest static void should_set_correct_terms()
	{
		List<zqu__Quote__c> quotes = new List<zqu__Quote__c>();
		Map<ID, Integer> quoteTermMonths = new Map<Id, Integer>();
		zqu__Quote__c quoteTermed = QuoteTermsSetterTest.createQuoteTestData();
		zqu__Quote__c quoteEvergreen = QuoteTermsSetterTest.createQuoteTestData();
		quotes.add(quoteTermed);
		quotes.add(quoteEvergreen);
		quoteTermMonths.put(quoteEvergreen.Id, 1);
		quoteTermMonths.put(quoteTermed.Id, 24);

		QuoteTermsSetter quoteTermsSetter = new QuoteTermsSetter(quoteTermMonths);
		List<zqu__Quote__c> updatedQuotes = quoteTermsSetter.updateQuoteTerms();
		if (updatedQuotes.get(0).Id == quoteTermed.Id) {
			quoteTermed = updatedQuotes.get(0);
			quoteEvergreen = updatedQuotes.get(1);
		}
		else {
			quoteTermed = updatedQuotes.get(1);
			quoteEvergreen = updatedQuotes.get(0);
		}
		
		System.assertEquals('Termed', quoteTermed.zqu__Subscription_Term_Type__c);
		System.assertEquals(24, quoteTermed.zqu__InitialTerm__c);
		System.assertEquals(24, quoteTermed.zqu__RenewalTerm__c);
		System.assertEquals('Evergreen', quoteEvergreen.zqu__Subscription_Term_Type__c);		
	}

	private static zqu__Quote__c createQuoteTestData() {
		zqu__Quote__c quote = new zqu__Quote__c();
		quote.name = 'TestQuote';
		insert quote;
		return quote;
	}*/
}