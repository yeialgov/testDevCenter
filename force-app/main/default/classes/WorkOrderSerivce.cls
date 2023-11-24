/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 08-16-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class WorkOrderSerivce {
    

    public static void startNegativeProcess (List<Work_Order__c> listRecordsToCreate){
       system.debug('lll '+listRecordsToCreate);
       for(Work_Order__c workOder :listRecordsToCreate){
           if(workOder.Message__c !=null){
               List<ParseJson.removeLicenceJson> listMessage = ParseJson.parseRemovingLicence(workOder.Message__c);
               licencesController(workOder.Id, listMessage, 'Negative',null,null);
           }
       }
    }

    public static void startPositiveProcess (List<Work_Order__c> listRecordsToCreate){
        for(Work_Order__c workOder :listRecordsToCreate){
            if(workOder.Message__c !=null){
                licencesController(workOder.Id, null, 'Positive',workOder.Token__c,workOder.Message__c);
            }
        }
    }

    public class addDevicesWrapper{
        public String productId;
        public String StartDate;
        public Integer Quantity;
        public String ProductName;
    }

    public static List<addDevicesWrapper> getProductsForMoreLicences (String productsToAddString){
        List<addDevicesWrapper> listOfDevicesToAdd = new List<addDevicesWrapper>();

        List<String> listOfProductsToAdd = productsToAddString.split('/');
        List<String> requestedProducts = new List<String>();

        List<String> Year3DeviceToAdd = listOfProductsToAdd[0].split(':');
        if(Integer.valueOf(Year3DeviceToAdd[1]) > 0){
            requestedProducts.add('Device license 3 years');

            addDevicesWrapper year3Wrapper = new addDevicesWrapper();
            year3Wrapper.ProductName = 'Device license 3 years';
            year3Wrapper.StartDate = listOfProductsToAdd[2].split(':')[1];
            year3Wrapper.Quantity = Integer.valueOf(Year3DeviceToAdd[1]);
            listOfDevicesToAdd.add(year3Wrapper);
        }

        List<String> MonthlyDeviceToAdd = listOfProductsToAdd[4].split(':');
        if(Integer.valueOf(MonthlyDeviceToAdd[1]) > 0){
            requestedProducts.add('Device license monthly');

            addDevicesWrapper monthlyWrapper = new addDevicesWrapper();
            monthlyWrapper.ProductName = 'Device license monthly';
            monthlyWrapper.StartDate = listOfProductsToAdd[5].split(':')[1];
            monthlyWrapper.Quantity = Integer.valueOf(MonthlyDeviceToAdd[1]);
            listOfDevicesToAdd.add(monthlyWrapper);
        }

        List<String> YearlyDeviceToAdd = listOfProductsToAdd[6].split(':');
        if(Integer.valueOf(YearlyDeviceToAdd[1]) > 0){
            requestedProducts.add('Device license 1 year');

            addDevicesWrapper yearlyWrapper = new addDevicesWrapper();
            yearlyWrapper.ProductName = 'Device license monthly';
            yearlyWrapper.StartDate = listOfProductsToAdd[8].split(':')[1];
            yearlyWrapper.Quantity = Integer.valueOf(YearlyDeviceToAdd[1]);
            listOfDevicesToAdd.add(yearlyWrapper);
        }
        
        for(Product2 currentProduct : [SELECT Id, Name FROM Product2 WHERE ProductCategory__r.ProductGeneration__c = 'G' AND Name IN: requestedProducts]){
            for(addDevicesWrapper currentDevice : listOfDevicesToAdd){
                if(currentDevice.ProductName == currentProduct.Name){
                    currentDevice.productId = currentProduct.Id;
                    break;
                }
            }
       }

       return listOfDevicesToAdd;
    }


    public static void licencesController(String woId, List<ParseJson.removeLicenceJson> removalList, String operationType, String currentToken, String productsToAddString){
        List<String> listAcctId = new List<String>();
        List<String> listProdId = new List<String>();
        List<Opportunity> listOpptyToInsert = new List<Opportunity>();
        List<Quote> listQuoteToInsert = new List<Quote>();
        List<QuoteLineItem> listOfQLIs = new List<QuoteLineItem>();
        List<Work_Order__c> listWoToComplete = new List<Work_Order__c>();
        Boolean opptySuccess = false;
        Boolean quoteSucess = false;
        Boolean processSuccess = false;


        String oppName = '';
        String quoteName = '';

        List<Product2> listOfProds  = new List<Product2>();

        if(removalList != null){
            for(ParseJson.removeLicenceJson param: removalList ){
                listAcctId.add(param.subLineItemAccount);
                listProdId.add(param.subLineItemProduct);
            }
            oppName = 'MYorderbird Cancel Opportunity'+'- '+system.today();
            quoteName = 'MYorderbird Cancel Quote';
        }else{
            String venueId = '';
            PortalToken.TokenWrapper tw = (PortalToken.TokenWrapper)JSON.deserialize(Crypto.decryptWithManagedIV('AES256', Blob.valueOf(Test.isRunningTest() ? '6251655468576D5A7134743777397A24' : Portal__c.getAll().get('PortalKey').Key__c), EncodingUtil.base64decode(currentToken.replace('-','/').replace('_','+'))).toString(), PortalToken.TokenWrapper.class);
            String accountId = [SELECT Id, Account__c FROM MyObVenue__c WHERE MyOrderbirdId__c =: tw.VenueId].Account__c;
            listAcctId.add(accountId);
            oppName = 'MYorderbird New Licence Opportunity'+'- '+system.today();
            quoteName = 'MYorderbird Adding Licence Quote';
        }

        //get products
        if(operationType == 'Positive'){
            getProductsForMoreLicences(productsToAddString);
        }else{
            listOfProds = [Select Id, Price_EUR__c, Name FROM Product2 WHERE Id =: listProdId];
        }
        
        //get the pricebook for the products
        List<PriceBookEntry> listOfPBEntries = [Select Id, Product2Id, Product2.Price_EUR__c FROM PriceBookEntry WHERE Product2Id =:listOfProds];
        Pricebook2 pb = [SELECT Id FROM Pricebook2 WHERE IsStandard = true];
        system.debug('pbentries are ==> ' + listOfPBEntries);
        system.debug('products are == > ' + listOfProds);

        //Possibly need to add Case Creation method here 
        //Possibly need to add Licence and Subscription creation methods here - future plan to remove this

        //Creates Opp, Quote and Line Iteam for Both adding and removing licences

        for(String accId :listAcctId){
            Opportunity newZuoraOpp = new Opportunity();
            newZuoraOpp.AccountId = accId;
            newZuoraOpp.Name = oppName;
            newZuoraOpp.CloseDate = Date.today().addDays(30);
            newZuoraOpp.StageName = 'Closed Won'; //needs to be changed to Potential
            newZuoraOpp.OppCategory__c = 'Account Management';
            newZuoraOpp.Opportunity_type_1__c = 'Cancellation';
            listOpptyToInsert.add(newZuoraOpp);
        }

        Database.SaveResult[] opportunityList = Database.insert(listOpptyToInsert, false);
        for (Database.SaveResult sr : opportunityList) {
            if (sr.isSuccess()) {
                opptySuccess = true;
                System.debug('Successfully inserted Opportunity. Opportunity ID: ' + sr.getId());
                
                Quote newZuroaQuote = new Quote();
                newZuroaQuote.OpportunityId=sr.getId();
                newZuroaQuote.name = quoteName;
                newZuroaQuote.Pricebook2ID = pb.Id;
                listQuoteToInsert.add(newZuroaQuote);
            }
            else {
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) {
                    opptySuccess = false;
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Opportunity fields that affected this error: ' + err.getFields());
                }
            }
        }
        if(opptySuccess == true){
            Database.SaveResult[] quoteList = Database.insert(listQuoteToInsert, false);
            
            for (Database.SaveResult sq : quoteList) {
                if (sq.isSuccess()) {
                    quoteSucess = true;

                    for(PriceBookEntry pbentry : listOfPBEntries){
                        QuoteLineItem qli = new QuoteLineItem();
                        qli.QuoteId = sq.Id;


                       
                        if(operationType == 'Positive'){ //Add 

                        }else{//Remove

                        }

                        listOfQLIs.add(qli);

                        qli.Product2Id = pbentry.Product2Id;
                        if(operationType =='Negative'){
                            qli.UnitPrice = pbentry.Product2.Price_EUR__c;
                        }
                        qli.Quantity = 1;
                        qli.PriceBookEntryId = pbentry.Id;
                        
                        
                    }
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sq.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Qoute fields that affected this error: ' + err.getFields());
                    }
                }
            }
        }
        if(quoteSucess == true){
            Database.SaveResult[] quoteLineItemList = Database.insert(listOfQLIs, false);
            for (Database.SaveResult sqLi : quoteLineItemList) {
                System.debug('Successfully inserted QLI. QLI ID: ' + sqLi.getId());
                processSuccess = true;
            }
        }

        //Should be an addtional task here to do something to the subscription i believe - Talk to team tomorrow

        if(processSuccess == true){
            List<Work_Order__c> workOrderToUpdate =[select id from Work_Order__c where id =:woId];
            for(Work_Order__c od :workOrderToUpdate ){
                od.Processed__c =true;
                listWoToComplete.add(od);
            }
            update listWoToComplete;
        }
    }
}