/**
 * @author joern
 */
@isTest
private class PhoneNumberCleansingTest
{
	@isTest
	static void rewrite_should_return_correct_phonenumbers() {
		System.assertEquals(null, PhoneNumberCleansing.rewrite(null));
		System.assertEquals('', PhoneNumberCleansing.rewrite(''));
		System.assertEquals('+491752955188', PhoneNumberCleansing.rewrite('+49 175 2955188'));
		System.assertEquals('052579809975', PhoneNumberCleansing.rewrite('05257/980 9975'));
		System.assertEquals('03028470038', PhoneNumberCleansing.rewrite('030- 28470038'));
		System.assertEquals('+4930755494071', PhoneNumberCleansing.rewrite('+49 30 75549407-1'));
		System.assertEquals('+410793214433', PhoneNumberCleansing.rewrite('+41 (0)79 321 4433'));
		System.assertEquals('+41793582273', PhoneNumberCleansing.rewrite('\'+41 79 358 22 73'));
		System.assertEquals('+4930726208113', PhoneNumberCleansing.rewrite('+49.30.726 208-113'));
		System.assertEquals('n/a', PhoneNumberCleansing.rewrite('n/a'));
	}


	@isTest
	static void rewritePhoneNumber_should_set_phonenumber() {
		Account acc = new Account(Name='_Burger_', Phone='+49 175 2955188');
		PhoneNumberCleansing.rewritePhoneNumber((SObject) acc, 'Phone');
		System.assertEquals('+491752955188', acc.Phone);
	}
}