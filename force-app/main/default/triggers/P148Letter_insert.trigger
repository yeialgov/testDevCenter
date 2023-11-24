trigger P148Letter_insert on P148Letter__c (after insert) {

    List<P148Letter__c> letters = new List<P148Letter__c>();
    for (P148Letter__c l : trigger.new) {
        letters.add(new P148Letter__c(
            Id = l.Id,
            Key__c = PortalToken.encryptPlain(l.Id)
        ));
    }
    update letters;
}