/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 08-02-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class PortalToken {
    
    public static Blob PUBLIC_KEY = EncodingUtil.base64Decode('MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAoe5579yF36jW54JYo9Mg2c5Uh8aSecZsI84W0ry+9Ad5cDtF4Lr6S44DiTSi4bzKKNe11fvU4euTsuBERXg+PNH0uGGHWPYXOTI94BmYVpj30nZxzXbPIlzRyB5hLHBNrwLELghCiHNMmRiulIBuvvBXULE/N6Hl7uuOK8PCoSoNqo7CJ/030RTbBctfWs5cNXky7Lg2a5Uaoofu6F6HIK4n6u+qkhKub3/DYi4fFeMxwX0PhJlYxZ7JrYvnAEjJgg1BCsfJQ4fcM6aatFBM8ySwirIaWMSmldmAI1kNvWuSlB54zY2vNy1zPLeTyqEULwyWSIxAL2rZrVrXKRFfMQIDAQAB');
	public static Boolean USE_KEY = Test.isRunningTest() ? true : Portal__c.getAll().get('PortalKey').Use_Key__c;
    
    public static String encryptToken(String VenueId) {
        return EncodingUtil.base64encode(Crypto.encryptWithManagedIV(
            'AES256', Blob.valueOf(Test.isRunningTest() ? '6251655468576D5A7134743777397A24' : Portal__c.getAll().get('PortalKey').Key__c), 
            Blob.valueOf(JSON.serialize(new TokenWrapper(VenueId)))
        )).replace('=','').replace('/','-').replace('+','_');
    }

    public static String encryptEmailToken(String EmailIndex) {
        return EncodingUtil.base64encode(Crypto.encryptWithManagedIV(
            'AES256', Blob.valueOf(Test.isRunningTest() ? '6251655468576D5A7134743777397A24' : Portal__c.getAll().get('PortalKey').Key__c), 
            Blob.valueOf(JSON.serialize(new TokenEmailWrapper(EmailIndex)))
        )).replace('=','').replace('/','-').replace('+','_');
    }
    
    public static String encryptPlain(String text) {
        return EncodingUtil.base64encode(Crypto.encryptWithManagedIV(
            'AES256', Blob.valueOf(Test.isRunningTest() ? '6251655468576D5A7134743777397A24' : Portal__c.getAll().get('PortalKey').Key__c), 
            Blob.valueOf(text)
        )).replace('=','').replace('/','-').replace('+','_');
    }
    
    public static String decryptPlain(String text) {
        return Crypto.decryptWithManagedIV(
            'AES256', Blob.valueOf(Test.isRunningTest() ? '6251655468576D5A7134743777397A24' : Portal__c.getAll().get('PortalKey').Key__c), 
            EncodingUtil.base64decode(text.replace('-','/').replace('_','+'))
        ).toString();
    }
    
    public static String refreshToken(String Token, Boolean IsVerify) {
        System.debug('Token: ' + Token);
        System.debug('IsVerify: ' + IsVerify);
        String VenueId = decryptToken(Token, IsVerify).VenueId;
        if (VenueId != null) { return encryptToken(VenueId); } return Token;
    }
    
    public static String refreshToken(String Token) {
        return refreshToken(Token, false);
    }

    public static Boolean JWTVerify(List<String> jwt) {
        String payload = jwt[0] + '.' + jwt[1];
        Blob signature = EncodingUtil.base64Decode(jwt[2].replace('-', '+').replace('_', '/').rightPad(math.mod(jwt[2].length() + (math.mod(4 - jwt[2].length(), 4)), 4)).replace(' ','='));
        return !USE_KEY || Crypto.verify('RSA-SHA256', Blob.valueOf(payload), signature, PUBLIC_KEY);
    }
    
    public static TokenWrapper decryptToken(String Token) {
        System.debug('Token: ' + Token);
        return decryptToken(Token, false);
    }
    
    public static TokenWrapper decryptToken(String Token, Boolean IsVerify) {
        List<String> tokenParts = Token.split('[.]');
        system.debug('token parts size '+tokenParts.size());
        TokenWrapper tw;
        if (tokenParts.size() == 3) {
            JWTWrapper jw = (JWTWrapper)JSON.deserialize(EncodingUtil.base64decode(tokenParts[1].replace('-','+').replace('_','/')).toString(), JWTWrapper.class);
            if(JWTVerify(tokenParts)) { tw = new TokenWrapper(jw.venue_id, jw.exp);} else { return null; }
        } else {
            tw = (TokenWrapper)JSON.deserialize(Crypto.decryptWithManagedIV(
                'AES256', Blob.valueOf(Test.isRunningTest() ? '6251655468576D5A7134743777397A24' : Portal__c.getAll().get('PortalKey').Key__c), 
                EncodingUtil.base64decode(Token.replace('-','/').replace('_','+'))
            ).toString(), TokenWrapper.class);
        }
        system.debug(json.serializePretty(tw));
        try {
            MyObVenue__c venue = [SELECT Account__c, Token__c, Uncertainty__c FROM MyObVenue__c WHERE Hidden__c = FALSE AND MyOrderbirdId__c = :tw.VenueId AND MyOrderbirdId__c != null LIMIT 1];
            tw.AccountId = venue.Account__c;
            if (tw.Timestamp > Datetime.now().addYears(-2) && tw.AccountId != null) {
                if (venue.Token__c == null && venue.Uncertainty__c != 9 && !IsVerify) { return new TokenWrapper(false); }
                return tw; 
            } else { return new TokenWrapper(true); } } catch(exception e) { system.debug(e.getMessage()); return null; }
    }

    public static TokenEmailWrapper decryptEmailToken(String Token, Boolean IsVerify) {
        List<String> tokenParts = Token.split('[.]');
        system.debug('token parts size '+tokenParts.size());
        TokenEmailWrapper tw;
            tw = (TokenEmailWrapper)JSON.deserialize(Crypto.decryptWithManagedIV(
                'AES256', Blob.valueOf(Test.isRunningTest() ? '6251655468576D5A7134743777397A24' : Portal__c.getAll().get('PortalKey').Key__c), 
                EncodingUtil.base64decode(Token.replace('-','/').replace('_','+'))
            ).toString(), TokenEmailWrapper.class);
        system.debug(json.serializePretty(tw));
        try {
            MyObVenue__c venue = [SELECT Id, Account__c, Token__c, Uncertainty__c,Email_Index__c FROM MyObVenue__c WHERE Hidden__c = FALSE AND Email_Index__c = :tw.EmailIndex AND MyOrderbirdId__c != null LIMIT 1];
            tw.EmailIndex = venue.Email_Index__c;
            if(tw.Timestamp < Datetime.now().addDays(-1)){
                system.debug('entere here'+ new TokenEmailWrapper(true));
                return new TokenEmailWrapper(true);
            }
            if (tw.Timestamp >= Datetime.now().addDays(-1)) {
                if (venue.Token__c == null && venue.Uncertainty__c != 9 && !IsVerify) { return new TokenEmailWrapper(false); }
                return tw; 
            } else { return new TokenEmailWrapper(true); } } catch(exception e) { system.debug(e.getMessage()); return null; }
    }
    
    public class TokenWrapper {
        public String VenueId;
        public DateTime Timestamp;
        public String AccountId;
        public Boolean Expired;
        public Boolean Unconfirmed;
        public TokenWrapper(String iVenueId) {
            VenueId = iVenueId;
            Timestamp = DateTime.now();
        }
        public TokenWrapper(String iVenueId, Integer exp) { VenueId = iVenueId; Timestamp = Datetime.newInstanceGmt(1970, 1, 1, 0, 0, 0).addSeconds(exp); }

        public TokenWrapper(Boolean IsExpired) { Expired = IsExpired; Unconfirmed = !IsExpired; }
    }

    public class TokenEmailWrapper {
        public String EmailIndex;
        public DateTime Timestamp;
        public String AccountId;
        public Boolean Expired;
        public Boolean Unconfirmed;
        public TokenEmailWrapper(String iEmailIndx){
            EmailIndex = iEmailIndx;
            Timestamp = DateTime.now();
        }
      //  public TokenEmailWrapper(String iVenueId, Integer exp) { VenueId = iVenueId; Timestamp = Datetime.newInstanceGmt(1970, 1, 1, 0, 0, 0).addSeconds(exp); }

        public TokenEmailWrapper(Boolean IsExpired) { Expired = IsExpired; Unconfirmed = !IsExpired; }
    }
    
    public class JWTWrapper {
        public String venue_id;
        public Integer exp;
    }
}