trigger MyObVenueDeletePrevent on MyObVenue__c (before delete) {
    for (MyObVenue__c v : Trigger.old) {
        if(v.MyOrderbirdId__c != null) v.addError('Mapped records cannot be deleted.');
    }
}