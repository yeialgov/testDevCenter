trigger CaseSolutionTrigger on CaseSolution__c (after insert, after update) {
    
    if (trigger.isAfter) {
        Map<Id, Id> MergeMap = new Map<Id, Id>();
        Map<String, CaseSolution__c> SolnMap = new Map<String, CaseSolution__c>();
        List<CaseSolutionTranslation__c> CSTs = new List<CaseSolutionTranslation__c>();
        List<CaseSolutionJunction__c> CSJs = new List<CaseSolutionJunction__c>();
        List<Case> updCases = new List<Case>();
        for (CaseSolution__c cs : trigger.new) {
            if (cs.Merge_Parent__c != null) {
                MergeMap.put(cs.Id, cs.Merge_Parent__c);
            } else {
                String Ap = ' __unapproved__';
                if (cs.Approved__c) Ap = '';
                String EN = cs.Name;
                String DE = cs.NameDE__c;
                String FR = cs.NameFR__c;
                if (DE == null) DE = '(needs translation)';
                if (FR == null) FR = '(needs translation)';
                String dscr = null;
                try{ dscr = cs.Description__c.mid(0,255); } catch(exception e) {}
                CSTs.add(new CaseSolutionTranslation__c(Description__c = dscr, CaseSolution__c = cs.Id, Language__c = 'EN', Name = EN + Ap, ExternalId__c = cs.Id + 'EN'));
                CSTs.add(new CaseSolutionTranslation__c(Description__c = dscr, CaseSolution__c = cs.Id, Language__c = 'DE', Name = DE + Ap, ExternalId__c = cs.Id + 'DE'));
                CSTs.add(new CaseSolutionTranslation__c(Description__c = dscr, CaseSolution__c = cs.Id, Language__c = 'FR', Name = FR + Ap, ExternalId__c = cs.Id + 'FR'));
            }
            if (trigger.isInsert && cs.Creator__c != null) {
                CSJs.add(new CaseSolutionJunction__c(CaseSolution__c = cs.Id, Case__c = cs.Creator__c));
                SolnMap.put(cs.Creator__c, cs);
            }
        }
        for (Case c : [
            SELECT Id, Subject, Contact.PrimaryLanguage__c, Account.PrimaryLanguage__c
            FROM Case
            WHERE Id IN :SolnMap.keySet() AND CaseSolutionCount__c =0 //Id NOT IN (SELECT Case__c FROM CaseSolutionJunction__c)
        ]) {
            CaseSolution__c cs = SolnMap.get(c.Id);
            String Subject = cs.NameDE__c;
            if (
                c.Contact.PrimaryLanguage__c == 'English' || (
                    c.Contact.PrimaryLanguage__c == null 
                    && c.Account.PrimaryLanguage__c == 'English'
                )
            ) {
                Subject = cs.Name;
            }
            if (
                c.Contact.PrimaryLanguage__c == 'French' || (
                    c.Contact.PrimaryLanguage__c == null 
                    && c.Account.PrimaryLanguage__c == 'French'
                )
            ) {
                Subject = cs.NameFR__c;
            }
            updCases.add(new Case(Id = c.Id, Subject = Subject));
        }
        
        //Set<String> setDupKeyCSJ = new set<String>();
        List<CaseSolutionJunction__c> mergedCSJs = [SELECT Id, Case__c, CaseSolution__c FROM CaseSolutionJunction__c WHERE CaseSolution__c IN :MergeMap.keySet()];
        for (CaseSolutionJunction__c csj : mergedCSJs) {
            csj.CaseSolution__c = MergeMap.get(csj.CaseSolution__c);
            system.debug(String.valueOf(csj.Case__c) + String.valueOf(csj.CaseSolution__c));
        //    setDupKeyCSJ.add(String.valueOf(csj.Case__c) + String.valueOf(csj.CaseSolution__c));
        }
        
        //delete [SELECT Id FROM CaseSolutionJunction__c WHERE Key__c IN :setDupKeyCSJ];
        update updCases;
        update mergedCSJs;
        upsert CSTs ExternalId__c;
        insert CSJs;
        delete [SELECT Id FROM CaseSolution__c WHERE Id IN :MergeMap.keySet()];
    }
    
}