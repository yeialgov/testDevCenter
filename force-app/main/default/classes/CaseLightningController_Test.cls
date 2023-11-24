@isTest public class CaseLightningController_Test {

    static TestMethod void test() {
        Account a = new Account(Name='test');
        insert a;
        Contact c = new Contact(LastName='test',AccountId=a.Id);
        insert c;
        String s = CaseLightningController.getContacts(a.Id);
        Case cc = new Case();
        insert cc;
        Task t = new Task(Subject='test', WhatId=cc.Id);
        insert t;
        CaseLightningController.setCaseContact(cc.Id, c.Id, true);
        CaseLightningController.setCaseContact(cc.Id, c.Id, false);
        system.debug(CaseLightningController.getOpenTasks(cc.Id));
        CaseLightningController.closeOpenTask(t.Id);
    }
}