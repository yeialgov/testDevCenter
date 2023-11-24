public class EmailSender {
  @InvocableMethod(label='Notify Open' description='Notifies Email Sender')
  public static void NotifyOpen(List<Id> EmailMessageIds) {
    List<EmailMessage> EmailMessages = [
      SELECT
        Id,
        MessageDate,
        Subject,
        CreatedbyId,
        ToAddress,
        Key__c,
        RelatedToId,
        RelatedTo.Name
      FROM EmailMessage
      WHERE Id IN :EmailMessageIds
    ];
    for (EmailMessage em : EmailMessages) {
      try {
        Contact c = [
          SELECT Id, Name, Account.Name, AccountId
          FROM Contact
          WHERE
            Id = :EncodingUtil.base64Decode(em.Key__c).toString().split(',')[1]
          LIMIT 1
        ];

        List<Messaging.Email> Emails = new List<Messaging.Email>();
        Messaging.SingleEmailMessage newEm = new Messaging.SingleEmailMessage();
        String rto = em.RelatedToId.getSObjectType()
          .getDescribe()
          .getName()
          .replace('__c', '');
        newEm.setPlainTextBody(
          JSON.serialize(new NotifyEmailWrapper(em, c, rto))
        );
        newEm.setSaveAsActivity(true);
        newEm.setSubject('test');
        newEm.setToAddresses(
          new List<String>{
            'email_open_notification@y-2cvzwzd1f09e71lzo37agq4q4jt7i9qvruv3g4600npclwdks5.58-pjmfeao.eu16.apex.salesforce.com'
          }
        );
        Emails.add(newEm);
        Messaging.sendEmail(Emails);
      } catch (exception e) {
      }
    }
  }

  public class NotifyEmailWrapper {
    public EmailMessage EmailMessage { get; set; }
    public Contact Contact { get; set; }
    public String RelatedToObject { get; set; }
    public NotifyEmailWrapper(EmailMessage em, Contact c, String rto) {
      EmailMessage = em;
      Contact = c;
      RelatedToObject = rto;
    }
  }

  @future
  public static void sendAsyncEmail(
    String RelatedToId,
    String WhoIdsString,
    String CCsString,
    String EmailSubject,
    String EmailText,
    String Attachments,
    String BCCAddresses,
    String OWEAId,
    String Language,
    Boolean OpenNotify
  ) {
    EmailSender.sendEmail(
      RelatedToId,
      WhoIdsString,
      CCsString,
      EmailSubject,
      EmailText,
      Attachments,
      BCCAddresses,
      OWEAId,
      Language,
      OpenNotify
    );
  }

  @AuraEnabled
  public static Boolean sendEmail(
    String RelatedToId,
    String WhoIdsString,
    String CCsString,
    String EmailSubject,
    String EmailText,
    String Attachments,
    String BCCAddresses,
    String OWEAId,
    String Language,
    Boolean OpenNotify
  ) {
    return EmailSender.sendEmail(
      RelatedToId,
      WhoIdsString,
      CCsString,
      EmailSubject,
      EmailText,
      Attachments,
      BCCAddresses,
      OWEAId,
      Language,
      OpenNotify,
      false
    );
  }

  @AuraEnabled
  public static Boolean sendEmail(
    String RelatedToId,
    String WhoIdsString,
    String CCsString,
    String EmailSubject,
    String EmailText,
    String Attachments,
    String OWEAId,
    String Language,
    Boolean OpenNotify
  ) {
    return EmailSender.sendEmail(
      RelatedToId,
      WhoIdsString,
      CCsString,
      EmailSubject,
      EmailText,
      Attachments,
      null,
      OWEAId,
      Language,
      OpenNotify,
      false
    );
  }

  @AuraEnabled
  public static Boolean sendCaseEmail(
    String RelatedToId,
    String WhoIdsString,
    String CCsString,
    String EmailSubject,
    String EmailText,
    String Attachments,
    String Language,
    Boolean OpenNotify,
    Boolean BCCMe
  ) {
    String MailingCountryCode = 'DE';
    try {
      MailingCountryCode = [
        SELECT Account.BillingCountryCode
        FROM Case
        WHERE Id = :RelatedToId
        LIMIT 1
      ]
      .Account.BillingCountryCode;
    } catch (exception e) {
    }
    String FromAddress = 'hilfe@orderbird.com';
    if (MailingCountryCode == 'GB')
      FromAddress = 'help@orderbird.com';
    if (MailingCountryCode == 'FR')
      FromAddress = 'assistance@orderbird.com';
    String OWEAId = [
      SELECT Id
      FROM OrgWideEmailAddress
      WHERE Address = :FromAddress
      LIMIT 1
    ]
    .Id;
    return sendEmail(
      RelatedToId,
      WhoIdsString,
      CCsString,
      EmailSubject,
      EmailText,
      Attachments,
      null,
      OWEAId,
      Language,
      OpenNotify,
      BCCMe
    );
  }

  @AuraEnabled
  public static Boolean sendEmail(
    String RelatedToId,
    String WhoIdsString,
    String CCsString,
    String EmailSubject,
    String EmailText,
    String Attachments,
    String BCCAddresses,
    String OWEAId,
    String Language,
    Boolean OpenNotify,
    Boolean BCCMe
  ) {
    List<String> RelatedToIds = new List<String>();
    String sObjectName;
    if (RelatedToId != null) {
      if (RelatedToId.contains('[')) {
        RelatedToIds = (List<String>) JSON.deserialize(
          RelatedToId,
          List<String>.class
        );
        RelatedToId = RelatedToIds[0];
      } else if (RelatedToId != null) {
        RelatedToIds.add(RelatedToId);
      }
    }
    system.debug(json.serialize(RelatedToIds));
    if (RelatedToId != null)
      sObjectName = Id.valueOf(RelatedToId)
        .getSObjectType()
        .getDescribe()
        .getName();
    Map<String, String> EmailTextMap = new Map<String, String>();
    Map<String, String> EmailSubjectMap = new Map<String, String>();
    Map<String, String> APIKeyMap = new Map<String, String>();
    List<String> WhoIds = (List<String>) JSON.deserialize(
      WhoIdsString,
      List<String>.class
    );
    system.debug(json.serialize(WhoIds));
    system.debug(json.serialize(CCsString));
    String sObjectPerson;
    try {
      sObjectPerson = Id.valueOf(WhoIds[0])
        .getSObjectType()
        .getDescribe()
        .getName();
    } catch (exception e) {
    }

    if (Language != 'English' && Language != 'French')
      Language = 'German';

    Map<String, String> TemplateMap = new Map<String, String>();
    for (StaticResource TSR : [
      SELECT Id, Name, Body
      FROM StaticResource
      WHERE Name LIKE 'ReplacementTemplate%'
      ORDER BY Name DESC
    ]) {
      TemplateMap.put(TSR.Name, TSR.Body.toString());
    }

    // MERGE FIELDS
    Set<String> setMergeSet = new Set<String>();
    Set<String> setMergeField = new Set<String>();
    Map<String, String> mapMergeSet = new Map<String, String>();
    Map<String, String> mapMergeValue = new Map<String, String>();
    Map<String, List<String>> CCMap = new Map<String, List<String>>();
    for (String sourceText : new List<String>{ EmailText, EmailSubject }) {
      for (String delimiter : new List<String>{ '%%!', '%%@', '%%#' }) {
        List<String> lstSplit = sourceText.split(delimiter);
        for (Integer x = 1; x < lstSplit.size(); x++) {
          if (lstSplit[x].contains('%%')) {
            setMergeSet.add(delimiter + lstSplit[x].split('%%')[0]);
            setMergeField.add(
              lstSplit[x].split('%%')[0].split(':')[0].toLowerCase()
            );
            mapMergeSet.put(
              delimiter + lstSplit[x].split('%%')[0],
              lstSplit[x].split('%%')[0].split(':')[0].toLowerCase()
            );
          }
        }
      }
    }
    if (setMergeField.size() > 0) {
      setMergeField.remove('id');
      String queryFieldsRelated = 'id';
      String queryFieldsRecipient = 'id';
      String queryFieldsSender = 'id';
      for (String MergeSet : setMergeSet) {
        if (mapMergeSet.get(MergeSet) != 'id') {
          if (MergeSet.contains('!'))
            queryFieldsRelated += ',' + mapMergeSet.get(MergeSet);
          if (MergeSet.contains('@'))
            queryFieldsRecipient += ',' + mapMergeSet.get(MergeSet);
          if (MergeSet.contains('#'))
            queryFieldsSender += ',' + mapMergeSet.get(MergeSet);
        }
      }
      String UserId = UserInfo.getUserId();
      System.debug(queryFieldsRelated);
      sObject MergeValuesRelatedTo = Database.query(
        'SELECT ' +
        queryFieldsRelated +
        ' FROM ' +
        sObjectName +
        ' WHERE Id=:RelatedToId LIMIT 1'
      );
      Map<Id, sObject> MergeValuesRecipient;
      if (sObjectPerson != null)
        MergeValuesRecipient = new Map<Id, sObject>(
          Database.query(
            'SELECT ' +
            queryFieldsRecipient +
            ' FROM ' +
            sObjectPerson +
            ' WHERE Id IN :WhoIds'
          )
        );
      sObject MergeValuesEmlSender = Database.query(
        'SELECT ' +
        queryFieldsSender +
        ' FROM User WHERE Id=:UserId LIMIT 1'
      );
      for (String MergeSet : setMergeSet) {
        String[] FieldParts = mapMergeSet.get(MergeSet).split('[.]');
        String[] SetParts = MergeSet.split(':');
        String OutputType = SetParts.size() == 2 ? SetParts[1] : 'String';
        sObject so = MergeValuesRelatedTo;
        if (MergeSet.contains('#'))
          so = MergeValuesEmlSender;
        if (MergeSet.contains('@')) {
          if (MergeValuesRecipient != null) {
            for (String RecipientId : MergeValuesRecipient.keySet()) {
              so = MergeValuesRecipient.get(RecipientId);
              String MergeValue;
              for (Integer x = 0; x < FieldParts.size(); x++) {
                if (x == FieldParts.size() - 1) {
                  MergeValue = formatter(
                    so.get(FieldParts[x]),
                    Id.valueOf((Id) so.get('Id'))
                      .getSObjectType()
                      .getDescribe()
                      .fields.getMap()
                      .get(FieldParts[x])
                      .getDescribe()
                      .getType(),
                    OutputType
                  );
                } else {
                  so = so.getSObject(FieldParts[x]);
                }
              }
              mapMergeValue.put(
                (MergeSet + '%%').replace('%%@', '%%@' + RecipientId + '@'),
                MergeValue
              );
            }
          }
        } else {
          String MergeValue;
          for (Integer x = 0; x < FieldParts.size(); x++) {
            if (x == FieldParts.size() - 1) {
              MergeValue = formatter(
                so.get(FieldParts[x]),
                Id.valueOf((Id) so.get('Id'))
                  .getSObjectType()
                  .getDescribe()
                  .fields.getMap()
                  .get(FieldParts[x])
                  .getDescribe()
                  .getType(),
                OutputType
              );
            } else {
              so = so.getSObject(FieldParts[x]);
            }
          }
          mapMergeValue.put(MergeSet + '%%', MergeValue);
        }
      }
    }

    String TemplateBrand = 'PRO';
    try {
      sObject so = Database.query(
        'SELECT Template_Branding__c FROM ' +
        sObjectName +
        ' WHERE Id=:RelatedToId LIMIT 1'
      );
      TemplateBrand = (String) so.get('Template_Branding__c');
      if (TemplateBrand == null)
        TemplateBrand = '';
    } catch (exception e) {
    }

    for (String WhoId : WhoIds) {
      String WhoEmailText = EmailText.replace('%%@', '%%@' + WhoId + '@');
      String WhoEmailSubject = EmailSubject.replace('%%@', '%%@' + WhoId + '@');
      String UnwrappedModifier = EmailText.contains('%%UNWRAPPED%%')
        ? 'UNWRAPPED'
        : '';
      system.debug('ReplacementTemplate' + TemplateBrand + Language);
      system.debug(json.serializePretty(TemplateMap));
      if (RelatedToId != null)
        WhoEmailText = TemplateMap.get(
            'ReplacementTemplate' +
            TemplateBrand +
            Language
          )
          .replace(
            '<!--%%REPLACE' +
            UnwrappedModifier +
            '%%-->',
            EmailText.replace('%%@', '%%@' + WhoId + '@')
          );
      String EmailImage = '';
      if (OpenNotify) {
        APIKeyMap.put(
          WhoId,
          EncodingUtil.base64Encode(
            Blob.valueOf(String.valueOf(Math.random()) + ',' + WhoId)
          )
        );
        EmailImage =
          '<p><img src="https://orderbird.secure.force.com/emailimage/services/apexrest/email_image?id=' +
          APIKeyMap.get(WhoId) +
          '" /></p>';
      }
      for (String MergeSet : mapMergeValue.keySet()) {
        WhoEmailSubject = WhoEmailSubject.replace(
          MergeSet,
          mapMergeValue.get(MergeSet)
        );
      }
      EmailSubjectMap.put(WhoId, WhoEmailSubject);

      WhoEmailText = WhoEmailText.replace('<!--%%EMAILIMAGE%%-->', EmailImage);
      WhoEmailText = WhoEmailText.replace(
        '<!--%%SUBJECTLINE%%-->',
        WhoEmailSubject
      );
      for (String MergeSet : mapMergeValue.keySet()) {
        WhoEmailText = WhoEmailText.replace(
          MergeSet,
          mapMergeValue.get(MergeSet)
        );
      }
      EmailTextMap.put(WhoId, WhoEmailText);

      CCMap.put(WhoId, new List<String>());
    }

    List<Id> CDIds = new List<Id>();
    List<String> ContentDocumentIds = (List<String>) JSON.deserialize(
      Attachments,
      List<String>.class
    );
    List<Messaging.Email> Emails = new List<Messaging.Email>();
    List<ContentVersion> insCVs = new List<ContentVersion>();
    List<ContentVersion> CVs = [
      SELECT Id, VersionData, Title, FileExtension
      FROM ContentVersion
      WHERE IsLatest = TRUE AND ContentDocumentId IN :ContentDocumentIds
    ];

    List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
    for (ContentVersion CV : CVs) {
      Messaging.Emailfileattachment efattach = new Messaging.Emailfileattachment();
      efattach.setFileName(CV.Title + '.' + CV.FileExtension);
      efattach.setBody(CV.VersionData);
      fileAttachments.add(efattach);
    }

    for (Invoice__c inv : [
      SELECT Id, Name
      FROM Invoice__c
      WHERE Id IN :RelatedToIds
    ]) {
      try {
        Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
        efa.setFileName(inv.Name + '.pdf');
        PageReference pageRef = new PageReference('/apex/InvoiceAttachment');
        pageRef.getParameters().put('id', inv.Id);
        Blob pdfBlob = null;
        if (!Test.isRunningTest())
          pdfBlob = pageRef.getContent();
        efa.setBody(pdfBlob);
        fileAttachments.add(efa);
        insCVs.add(
          new ContentVersion(
            ContentLocation = 'S',
            IsInvoice__c = true,
            VersionData = pdfBlob,
            Title = 'orderbird Invoice : ' +
              inv.Id +
              ' sent ' +
              String.valueOf(DateTime.now()),
            PathOnClient = '/Invoice.pdf'
          )
        );
      } catch (exception e) {
      }
    }

    for (OBInvoice__c inv : [
      SELECT Id, Name
      FROM OBInvoice__c
      WHERE Id IN :RelatedToIds
    ]) {
      try {
        Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
        efa.setFileName(inv.Name + '.pdf');
        PageReference pageRef = new PageReference('/apex/OBInvoiceAttachment');
        pageRef.getParameters().put('id', inv.Id);
        Blob pdfBlob = null;
        if (!Test.isRunningTest())
          pdfBlob = pageRef.getContent();
        efa.setBody(pdfBlob);
        fileAttachments.add(efa);
        insCVs.add(
          new ContentVersion(
            ContentLocation = 'S',
            IsInvoice__c = true,
            VersionData = pdfBlob,
            Title = 'orderbird Invoice : ' +
              inv.Id +
              ' sent ' +
              String.valueOf(DateTime.now()),
            PathOnClient = '/Invoice.pdf'
          )
        );
      } catch (exception e) {
      }
    }

    for (Quote quo : [
      SELECT Id, QuoteNumber
      FROM Quote
      WHERE Id IN :RelatedToIds
    ]) {
      try {
        Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
        efa.setFileName(quo.QuoteNumber + '.pdf');
        PageReference pageRef = new PageReference('/apex/QuoteAttachment');
        pageRef.getParameters().put('id', quo.Id);
        Blob pdfBlob = null;
        if (!Test.isRunningTest())
          pdfBlob = pageRef.getContent();
        efa.setBody(pdfBlob);
        fileAttachments.add(efa);
        insCVs.add(
          new ContentVersion(
            ContentLocation = 'S',
            IsInvoice__c = true,
            VersionData = pdfBlob,
            Title = 'orderbird Invoice : ' +
              quo.Id +
              ' sent ' +
              String.valueOf(DateTime.now()),
            PathOnClient = '/Quote.pdf'
          )
        );
      } catch (exception e) {
      }
    }

    for (
      CCObject CCObject : (List<CCObject>) JSON.deserialize(
        CCsString,
        List<CCObject>.class
      )
    ) {
      CCMap.get(CCObject.ContactId).add(CCObject.CCEmail);
    }

    List<String> lstBCCAddresses = new List<String>();
    if (BCCMe)
      lstBCCAddresses.add(UserInfo.getUserEmail());
    if (BCCAddresses != null) {
      for (String bccAddress : BCCAddresses.split(',')) {
        lstBCCAddresses.add(bccAddress);
      }
    }

    if (
      sObjectName == 'Event' ||
      sObjectName == 'Task' ||
      sObjectName == 'Contact' ||
      sObjectName == 'Lead'
    )
      RelatedToId = null;

    for (String WhoId : WhoIds) {
      Messaging.SingleEmailMessage em = new Messaging.SingleEmailMessage();
      em.setTreatBodiesAsTemplate(true);
      em.setHtmlBody(EmailTextMap.get(WhoId));
      em.setPlainTextBody(EmailTextMap.get(WhoId).stripHtmlTags());
      em.setSubject(EmailSubjectMap.get(WhoId));
      if (WhoId == null) {
        em.setToAddresses(CCMap.get(WhoId));
      } else {
        em.setTargetObjectID(WhoId);
        em.setCCAddresses(CCMap.get(WhoId));
      }
      // TODO define a rule that applies to lead emails to not set what id and document ticket
      if (
        RelatedToIds.size() == 1 &&
        sObjectPerson == 'Contact' //whatId can only be set when the receiver of the mail is a Contact
      )
        em.setWhatId(RelatedToId);

      em.setSaveAsActivity(RelatedToId != null);
      //em.setSaveAsActivity(false);
      em.setBccAddresses(lstBCCAddresses);
      if (OWEAId != null)
        em.setOrgWideEmailAddressId(OWEAId);
      em.setFileAttachments(fileAttachments);
      Emails.add(em);
    }

    if (!test.isRunningTest())
      Messaging.sendEmail(Emails);

    List<EmailMessageRelation> EMRs;

    try {
      EMRs = [
        SELECT EmailMessageId, RelationId
        FROM EmailMessageRelation
        WHERE RelationId IN :WhoIds
        ORDER BY CreatedDate DESC
        LIMIT :Emails.size()
      ];
    } catch (exception e) {
    }

    if (!test.isRunningTest())
      insert insCVs;

    Set<Id> CVIdSet = new Set<Id>();
    for (ContentVersion CV : insCVs) {
      CVIdSet.add(CV.Id);
    }

    for (ContentVersion newCV : [
      SELECT ContentDocumentId
      FROM ContentVersion
      WHERE Id IN :CVIdSet
    ]) {
      ContentDocumentIds.add(newCV.ContentDocumentId);
    }

    if (EMRs.size() > 0 && RelatedToId != null) {
      List<ContentDocumentLink> CDLs = new List<ContentDocumentLink>();
      List<EmailMessage> EmailMessages = new List<EmailMessage>();
      for (EmailMessageRelation EMR : EMRs) {
        EmailMessages.add(
          new EmailMessage(
            Id = EMR.EmailMessageId,
            Key__c = APIKeyMap.get(EMR.RelationId)
          )
        );
        for (String CDId : ContentDocumentIds) {
          CDLs.add(
            new ContentDocumentLink(
              ShareType = 'v',
              LinkedEntityId = EMR.EmailMessageId,
              ContentDocumentId = CDId
            )
          );
        }
      }
      if (!test.isRunningTest())
        insert CDLs;
      update EmailMessages;
    }

    return true;
  }

  @AuraEnabled
  public static String previewEmail(
    String RelatedToId,
    String WhoIdsString,
    String EmailSubject,
    String EmailText,
    String Language
  ) {
    List<String> RelatedToIds = new List<String>();
    String sObjectName;
    if (RelatedToId != null) {
      if (RelatedToId.contains('[')) {
        RelatedToIds = (List<String>) JSON.deserialize(
          RelatedToId,
          List<String>.class
        );
        RelatedToId = RelatedToIds[0];
      } else if (RelatedToId != null) {
        RelatedToIds.add(RelatedToId);
      }
    }
    if (RelatedToId != null)
      sObjectName = Id.valueOf(RelatedToId)
        .getSObjectType()
        .getDescribe()
        .getName();
    Map<String, String> EmailTextMap = new Map<String, String>();
    Map<String, String> EmailSubjectMap = new Map<String, String>();
    Map<String, String> APIKeyMap = new Map<String, String>();
    List<String> WhoIds = (List<String>) JSON.deserialize(
      WhoIdsString,
      List<String>.class
    );
    String sObjectPerson = Id.valueOf(WhoIds[0])
      .getSObjectType()
      .getDescribe()
      .getName();

    if (Language != 'English' && Language != 'French')
      Language = 'German';

    Map<String, String> TemplateMap = new Map<String, String>();
    for (StaticResource TSR : [
      SELECT Id, Name, Body
      FROM StaticResource
      WHERE Name LIKE 'ReplacementTemplate%'
      ORDER BY Name DESC
    ]) {
      TemplateMap.put(TSR.Name, TSR.Body.toString());
    }

    // MERGE FIELDS
    Set<String> setMergeSet = new Set<String>();
    Set<String> setMergeField = new Set<String>();
    Map<String, String> mapMergeSet = new Map<String, String>();
    Map<String, String> mapMergeValue = new Map<String, String>();
    Map<String, List<String>> CCMap = new Map<String, List<String>>();
    for (String sourceText : new List<String>{ EmailText, EmailSubject }) {
      for (String delimiter : new List<String>{ '%%!', '%%@', '%%#' }) {
        List<String> lstSplit = sourceText.split(delimiter);
        for (Integer x = 1; x < lstSplit.size(); x++) {
          if (lstSplit[x].contains('%%')) {
            setMergeSet.add(delimiter + lstSplit[x].split('%%')[0]);
            setMergeField.add(
              lstSplit[x].split('%%')[0].split(':')[0].toLowerCase()
            );
            mapMergeSet.put(
              delimiter + lstSplit[x].split('%%')[0],
              lstSplit[x].split('%%')[0].split(':')[0].toLowerCase()
            );
          }
        }
      }
    }
    if (setMergeField.size() > 0) {
      setMergeField.remove('id');
      String queryFieldsRelated = 'id';
      String queryFieldsRecipient = 'id';
      String queryFieldsSender = 'id';
      for (String MergeSet : setMergeSet) {
        if (mapMergeSet.get(MergeSet) != 'id') {
          if (MergeSet.contains('!'))
            queryFieldsRelated += ',' + mapMergeSet.get(MergeSet);
          if (MergeSet.contains('@'))
            queryFieldsRecipient += ',' + mapMergeSet.get(MergeSet);
          if (MergeSet.contains('#'))
            queryFieldsSender += ',' + mapMergeSet.get(MergeSet);
        }
      }
      String UserId = UserInfo.getUserId();
      sObject MergeValuesRelatedTo = Database.query(
        'SELECT ' +
        queryFieldsRelated +
        ' FROM ' +
        sObjectName +
        ' WHERE Id=:RelatedToId LIMIT 1'
      );
      Map<Id, sObject> MergeValuesRecipient = new Map<Id, sObject>(
        Database.query(
          'SELECT ' +
          queryFieldsRecipient +
          ' FROM ' +
          sObjectPerson +
          ' WHERE Id IN :WhoIds'
        )
      );
      sObject MergeValuesEmlSender = Database.query(
        'SELECT ' +
        queryFieldsSender +
        ' FROM User WHERE Id=:UserId LIMIT 1'
      );
      for (String MergeSet : setMergeSet) {
        String[] FieldParts = mapMergeSet.get(MergeSet).split('[.]');
        String[] SetParts = MergeSet.split(':');
        String OutputType = SetParts.size() == 2 ? SetParts[1] : 'String';
        sObject so = MergeValuesRelatedTo;
        if (MergeSet.contains('#'))
          so = MergeValuesEmlSender;
        if (MergeSet.contains('@')) {
          for (String RecipientId : MergeValuesRecipient.keySet()) {
            so = MergeValuesRecipient.get(RecipientId);
            String MergeValue;
            for (Integer x = 0; x < FieldParts.size(); x++) {
              if (x == FieldParts.size() - 1) {
                MergeValue = formatter(
                  so.get(FieldParts[x]),
                  Id.valueOf((Id) so.get('Id'))
                    .getSObjectType()
                    .getDescribe()
                    .fields.getMap()
                    .get(FieldParts[x])
                    .getDescribe()
                    .getType(),
                  OutputType
                );
              } else {
                so = so.getSObject(FieldParts[x]);
              }
            }
            mapMergeValue.put(
              (MergeSet + '%%').replace('%%@', '%%@' + RecipientId + '@'),
              MergeValue
            );
          }
        } else {
          String MergeValue;
          for (Integer x = 0; x < FieldParts.size(); x++) {
            if (x == FieldParts.size() - 1) {
              MergeValue = formatter(
                so.get(FieldParts[x]),
                Id.valueOf((Id) so.get('Id'))
                  .getSObjectType()
                  .getDescribe()
                  .fields.getMap()
                  .get(FieldParts[x])
                  .getDescribe()
                  .getType(),
                OutputType
              );
            } else {
              so = so.getSObject(FieldParts[x]);
            }
          }
          mapMergeValue.put(MergeSet + '%%', MergeValue);
        }
      }
    }

    String TemplateBrand = 'PRO';
    try {
      sObject so = Database.query(
        'SELECT Template_Branding__c FROM ' +
        sObjectName +
        ' WHERE Id=:RelatedToId LIMIT 1'
      );
      TemplateBrand = (String) so.get('Template_Branding__c');
      if (TemplateBrand == null)
        TemplateBrand = '';
    } catch (exception e) {
    }

    for (String WhoId : WhoIds) {
      String WhoEmailText = EmailText.replace('%%@', '%%@' + WhoId + '@');
      String WhoEmailSubject = EmailSubject.replace('%%@', '%%@' + WhoId + '@');
      String UnwrappedModifier = EmailText.contains('%%UNWRAPPED%%')
        ? 'UNWRAPPED'
        : '';
      if (RelatedToId != null)
        WhoEmailText = TemplateMap.get(
            'ReplacementTemplate' +
            TemplateBrand +
            Language
          )
          .replace(
            '<!--%%REPLACE' +
            UnwrappedModifier +
            '%%-->',
            EmailText.replace('%%@', '%%@' + WhoId + '@')
          );
      for (String MergeSet : mapMergeValue.keySet()) {
        WhoEmailSubject = WhoEmailSubject.replace(
          MergeSet,
          mapMergeValue.get(MergeSet)
        );
      }
      EmailSubjectMap.put(WhoId, WhoEmailSubject);
      for (String MergeSet : mapMergeValue.keySet()) {
        WhoEmailText = WhoEmailText.replace(
          MergeSet,
          mapMergeValue.get(MergeSet)
        );
        WhoEmailText = WhoEmailText.replace(
          '<!--%%SUBJECTLINE%%-->',
          WhoEmailSubject
        );
      }
      EmailTextMap.put(WhoId, WhoEmailText);
    }

    return JSON.serialize(
      new EmailPreview(
        EmailSubjectMap.get(WhoIds[0]),
        EmailTextMap.get(WhoIds[0])
      )
    );
  }

  @AuraEnabled
  public static String getContacts(String RecordId, String sObjectName) {
    return NewQuoteController.getContacts(RecordId, sObjectName);
  }

  @AuraEnabled
  public static String getAllTemplates(String ObjectName) {
    return JSON.serialize(
      [
        SELECT
          Id,
          Name,
          Message__c,
          Unwrapped_Message__c,
          Default__c,
          Subject__c,
          Unwrapped_Div__c,
          Folder__c
        FROM SendTemplate__c
        WHERE
          Object__c = :ObjectName
          AND (AdminName__c = NULL
          OR AdminName__c = '')
        ORDER BY Name
      ]
    );
  }

  @AuraEnabled(cacheable=true)
  public static List<LookupSearchResult> templateSearch(
    String searchTerm,
    List<String> selectedIds,
    List<String> WhereConditions
  ) {
    // Prepare query paramters
    searchTerm += '*';

    // Execute search query
    List<List<SObject>> searchResults = [
      FIND :searchTerm
      IN NAME FIELDS
      RETURNING
        SendTemplate__c(
          Id,
          Name,
          Folder__r.Name
          WHERE
            Object__c = :WhereConditions[0]
            AND (AdminName__c = NULL
            OR AdminName__c = '')
            AND (Language__c = :WhereConditions[1]
            OR Language__c = NULL
            OR Unlock__c = :WhereConditions[1]))
      LIMIT 20
    ];

    // Prepare results
    List<LookupSearchResult> results = new List<LookupSearchResult>();

    SendTemplate__c[] STs = ((List<SendTemplate__c>) searchResults[0]);
    for (SendTemplate__c ST : STs) {
      results.add(
        new LookupSearchResult(
          ST.Id,
          'SendTemplate__c',
          'standard:text_template',
          ST.Name,
          ST.Folder__r.Name,
          ST.Name
        )
      );
    }
    return results;
  }

  public static String formatter(
    Object o,
    Schema.DisplayType fieldType,
    String outputType
  ) {
    if (String.valueOf(fieldType) == 'DateTime') {
      if (outputType == 'DateTime')
        return ((DateTime) o).date().format() +
          ' um ' +
          String.valueOf(((DateTime) o).time()).substring(0, 5) +
          ' Uhr';
      return ((DateTime) o).date().format();
    }
    if (String.valueOf(fieldType) == 'Date') {
      if (outputType == 'Time')
        return String.valueOf(((DateTime) o).time()).substring(0, 5);
      return ((Date) o).format();
    }
    if (String.valueOf(fieldType) == 'Decimal') {
      if (outputType == 'Currency')
        return numFormatting((Decimal) o, 2, '.', ',');
      return numFormatting((Decimal) o, 0, '.', ',');
    }
    if (String.valueOf(fieldType) == 'Double') {
      if (outputType == 'Currency')
        return numFormatting((Decimal) o, 2, '.', ',');
      return numFormatting((Decimal) o, 0, '.', ',');
    }
    if (String.valueOf(fieldType) == 'Currency') {
      return numFormatting((Decimal) o, 2, '.', ',');
    }
    if (outputType == 'ConditionStart')
      return o == null ? '<!--' : '';
    if (outputType == 'ConditionEnd')
      return o == null ? '-->' : '';
    system.debug(
      json.serialize(o) +
      '|' +
      String.valueOf(fieldType) +
      '|' +
      outputType
    );
    return o == null ? '' : (String) o;
  }

  public static String numFormatting(
    Decimal val,
    integer dec,
    String tSep,
    String dSep
  ) {
    String s, tmp;
    Integer i = 4 + dec;

    // If the number of decimals is zero (0)... prevents the first 1000s seperator from being set at the 4th.
    if (dec == 0) {
      i--;
    }

    s = val.setScale(dec).toPlainString().replace(tSep, dSep);
    while (s.length() > i) {
      tmp = s.substring(0, s.length() - i) + tSep + s.substring(s.length() - i);
      s = tmp;
      i += 4;
    }

    // If the number is negative and has a number non-decimal digits divisible by 3, it prevents putting a comma before the 1st digit (ex -300,000.00  comes out -,300,000.00)
    if (s.substring(0, 1) == '-') {
      if (s.substring(1, 2) == tSep) {
        s = '-' + s.substring(2);
      }
    }

    return s;
  }

  public class CCObject {
    public String ContactId;
    public String CCEmail;
  }

  public class EmailPreview {
    public String Subject { get; set; }
    public String Message { get; set; }
    public EmailPreview(String iSubject, String iMessage) {
      Subject = iSubject;
      Message = iMessage;
    }
  }
}