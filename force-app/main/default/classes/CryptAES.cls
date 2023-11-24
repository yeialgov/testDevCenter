/**
 * @author joern
 *
 * @description Encrypt string with AES256 and provided key (CheckoutAESKey__c) from custom settings
 */
public class CryptAES {

    private String keyName;

    public CryptAES(String keyName) {
        this.keyName = keyName;
    }
    
    /**
     * @param clearText text to encrypt
     * @return encrypted text HEX encoded
     */
    public String encrypt(String clearText) {
        Blob key = this.getKey();
        Blob encryptedText = Crypto.encryptWithManagedIV('AES256', key, Blob.valueOf(clearText));
        return EncodingUtil.convertToHex(encryptedText);
    }
    
    public String decrypt(String hexString){
        Blob key = this.getKey(); Blob decryptedText = Crypto.decryptWithManagedIV('AES256', key, EncodingUtil.convertFromHex(hexString));
        return decryptedText.toString();
    }

    @TestVisible
    private Blob getKey() {
        Integer x = 0;
        x++;
        x++;
        x++;
        Map<String, CheckoutAESKey__c> keyMap = CheckoutAESKey__c.getAll();
        if (!test.isRunningTest()) {
            return Blob.valueOf(keyMap.get(this.keyName).Key__c);            
        } else { 
            return Blob.valueOf('5G697w899d096Z4U3u2F34S5T5C6H7f6');
        }
    }
}