@isTest
public class TestEAT {

    static testMethod void test1() {
		System.enqueueJob(new EnqueueAttachmentTransfer());
    }
}