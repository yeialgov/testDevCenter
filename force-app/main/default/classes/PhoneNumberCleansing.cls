/**
 * @author joern
 */
public class PhoneNumberCleansing {

	public static void rewritePhoneNumber(SObject so, String fieldName) {
		so.put(fieldName, rewrite((String) so.get(fieldName)));
	}

	public static String rewrite(String phone) {
		if(String.isEmpty(phone)) {
			return phone;
		} else if(phone.equalsIgnoreCase('n/a')) {
			return phone;
		} else {
			return phone.replaceAll('[^+0-9]', '');
		}
	}
}