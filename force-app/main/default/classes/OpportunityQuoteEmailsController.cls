public class OpportunityQuoteEmailsController {

    @AuraEnabled
    public static List<EmailMessage> getEmails(String OpportunityId) {
        return [
            SELECT Id, FromAddress, FromName, HasAttachment, IsOpened, IsTracked, LastOpenedDate, MessageDate,
            	RelatedToId, RelatedTo.Name, Status, Subject,  TextBody, ToAddress, ValidatedFromAddress, (
                    SELECT Id, Relation.Name, RelationId, RelationType, RelationAddress, RelationObjectType 
                    FROM EmailMessageRelations
                    WHERE RelationObjectType = 'Contact'
                )
            FROM EmailMessage 
            WHERE RelatedToId IN (SELECT Id FROM Quote WHERE OpportunityId = :OpportunityId)
            ORDER BY MessageDate DESC
        ];
    }
}