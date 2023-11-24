global class EmailNotifyHandler implements Messaging.InboundEmailHandler {
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {

        String URL = URL.getSalesforceBaseUrl().toExternalForm();
        
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        
        EmailSender.NotifyEmailWrapper data = (EmailSender.NotifyEmailWrapper)json.deserialize(email.plainTextBody, EmailSender.NotifyEmailWrapper.class);
        
        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
        ConnectApi.EntityLinkSegmentInput entityLinkSegmentInput = new ConnectApi.EntityLinkSegmentInput();
        ConnectApi.TextSegmentInput textSegmentInput1 = new ConnectApi.TextSegmentInput();
        ConnectApi.EntityLinkSegmentInput entityLinkSegmentInput1 = new ConnectApi.EntityLinkSegmentInput();
        ConnectApi.TextSegmentInput textSegmentInput2 = new ConnectApi.TextSegmentInput();
        ConnectApi.EntityLinkSegmentInput entityLinkSegmentInput2 = new ConnectApi.EntityLinkSegmentInput();
        
        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
        
        textSegmentInput.text = 'Email from ' + data.EmailMessage.MessageDate.format() + ' opened by ';
        messageBodyInput.messageSegments.add(textSegmentInput);
        
        entityLinkSegmentInput.entityId = data.Contact.Id;
		messageBodyInput.messageSegments.add(entityLinkSegmentInput);    
        
        textSegmentInput1.text = '\n' + 'Email: ';
        messageBodyInput.messageSegments.add(textSegmentInput1);
        
        entityLinkSegmentInput1.entityId = data.EmailMessage.Id;
		messageBodyInput.messageSegments.add(entityLinkSegmentInput1);    
        
        textSegmentInput2.text = '\n' + data.RelatedToObject + ': ';
        messageBodyInput.messageSegments.add(textSegmentInput2);
        
        entityLinkSegmentInput2.entityId = data.EmailMessage.RelatedToId;
		messageBodyInput.messageSegments.add(entityLinkSegmentInput2);    
        
        feedItemInput.body = messageBodyInput;
        feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
        feedItemInput.subjectId = data.EmailMessage.CreatedById;
        
        ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), feedItemInput);
        
        String emailText = '<p>Email from ' + data.EmailMessage.MessageDate.format() 
            + ' opened by <a href="' + URL + '/' + data.Contact.Id + '">' + data.Contact.Name + '</a></p>'
            + '<p>Email: <a href="' + URL + '/' + data.EmailMessage.Id + '">' + data.EmailMessage.Subject + '</a></p>'
            + '<p>' + data.RelatedToObject + ': <a href="' + URL + '/' + data.EmailMessage.RelatedToId + '">' + data.EmailMessage.RelatedTo.Name + '</a></p>';
        
        EmailSender.sendEmail(null, JSON.serialize(new List<String>{data.EmailMessage.CreatedById}), '[]',
                              'Email opened by ' + data.Contact.Name + ' (' + data.Contact.Account.Name + ')', 
                              emailText, 
                              '[]', '0D258000000CdbkCAC', 'German', false);
        
        return result;
    }
}