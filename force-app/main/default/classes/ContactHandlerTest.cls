@isTest
private class ContactHandlerTest
{
	@isTest
	static void should_rewrite_wrong_formated_phonenumbers() {
		Account acc = new Account(
			Name='_Muster1234');
		insert acc;
		ID acctID = acc.ID;
		Contact cont = new Contact(LastName='_Burger_', AccountId=acctID,
			Phone='+49 175 2955188',
			HomePhone='+49 175 2955288',
			MobilePhone='+49 175 2955388',
			OtherPhone='+49 175 2955488',
			AssistantPhone='+49 175 2955588',
			Fax='+49 175 2955588'
		);
		insert cont;
		cont = [SELECT Phone, HomePhone, MobilePhone, OtherPhone, AssistantPhone, Fax FROM Contact WHERE Name='_Burger_'];
		System.assertEquals('+491752955188', cont.Phone);
		System.assertEquals('+491752955288', cont.HomePhone);
		System.assertEquals('+491752955388', cont.MobilePhone);
		System.assertEquals('+491752955488', cont.OtherPhone);
		System.assertEquals('+491752955588', cont.AssistantPhone);
		System.assertEquals('+491752955588', cont.Fax);

		cont.Phone = '+49 175 2955188';
		cont.HomePhone = '+49 175 2955288';
		cont.MobilePhone = '+49 175 2955388';
		cont.OtherPhone = '+49 175 2955488';
		cont.AssistantPhone = '+49 175 2955588';
		cont.Fax = '+49 175 2955188';
		update cont;
		cont = [SELECT Phone, HomePhone, MobilePhone, OtherPhone, AssistantPhone, Fax FROM Contact WHERE Name='_Burger_'];
		System.assertEquals('+491752955188', cont.Phone);
		System.assertEquals('+491752955288', cont.HomePhone);
		System.assertEquals('+491752955388', cont.MobilePhone);
		System.assertEquals('+491752955488', cont.OtherPhone);
		System.assertEquals('+491752955588', cont.AssistantPhone);
		System.assertEquals('+491752955188', cont.Fax);
	}

	@isTest static void should_delete_contact() {
		Contact contact = new Contact();
		contact.LastName = 'LastName';
		insert contact;

		delete contact;
	}
}