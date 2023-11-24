/**
 * @author joern
 */
@isTest
public class CryptAESTest {

    @isTest static void getKey() {
        CheckoutAESKey__c aes256 =  new CheckoutAESKey__c();
        aes256.name = 'AES256_TEST';
        aes256.Key__c = '5G697w899d096Z4U3u2F34S5T5C6H7f6';
        insert aes256;

        CryptAES ec = new CryptAES('AES256_TEST');
        System.assertEquals(Blob.valueOf(aes256.Key__c), ec.getKey());
    }

    @isTest static void encrypt() {
        CheckoutAESKey__c aes256 =  new CheckoutAESKey__c();
        aes256.name = 'AES256_TEST';
        aes256.Key__c = '5G697w899d096Z4U3u2F34S5T5C6H7f6';
        insert aes256;
        String tt = 'TEXTtext TEXTtext TEXTtext TEXTtext TEXTtext TEXTtext ';

        CryptAES ec = new CryptAES('AES256_TEST');
        String en = ec.encrypt(tt);
        Blob de = Crypto.decryptWithManagedIV(
                'AES256',
                Blob.valueOf('5G697w899d096Z4U3u2F34S5T5C6H7f6'), EncodingUtil.convertFromHex(en));
        System.assertEquals(de, Blob.valueOf(tt));
    }
}