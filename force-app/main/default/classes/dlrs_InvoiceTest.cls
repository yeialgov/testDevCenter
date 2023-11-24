/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_InvoiceTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_InvoiceTrigger to be invoked, fails the test if org config or other Apex code prevents this.
      Account a = new Account(name='test');  
        insert a;
      dlrs.RollupService.testHandler(new Invoice__c(Account__c = a.Id));
    }
}