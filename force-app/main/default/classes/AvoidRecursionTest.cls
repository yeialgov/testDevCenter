@isTest
private class AvoidRecursionTest
{
	@isTest
	static void itShould() {
		System.assertEquals(true, AvoidRecursion.isFirstRun());
		System.assertEquals(false, AvoidRecursion.isFirstRun());
		AvoidRecursion.unset();
		System.assertEquals(true, AvoidRecursion.isFirstRun());
	}
}