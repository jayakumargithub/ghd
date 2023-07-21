/**
 * Created by Jayakumar Mogenahall on 15/02/2023.
 */

public with sharing class ProductService {

    static string removeChar(String source, Integer index) {
        return source.left(index) + source.right(source.length() - index - 1);
    }
    @AuraEnabled
   public static Boolean create(String jsonInput, String accountId, String draftDesc, Decimal totalAmount) {
        Database.SaveResult[]  results;
        String jsonInput1 = jsonInput.remove('null,');
        jsonInput1 = jsonInput1.remove('null');
        Integer lastComPosition = jsonInput1.lastIndexOf(',');
        String finalString = removeChar(jsonInput1,lastComPosition);

        List<ProductTemp__c> productsTemps = [SELECT Id, Unit_Price__c,Name FROM ProductTemp__c];
        Map<String, Decimal> productsTempMap = new Map<String,Decimal>();
        for(ProductTemp__c temp : productsTemps){
            productsTempMap.put(temp.Name,temp.Unit_Price__c);
        }


        try{

           List<Object> listObject = (List<Object>)JSON.deserializeUntyped(finalString);
            List<DraftOrder__c> previewList  = new List<DraftOrder__c>();
            System.debug('#deserialized:'+listObject);
            for(Object obj: listObject){
                DraftOrder__c   preview = new DraftOrder__c();
                System.debug('v'+((Map<String,Object>)obj).get('OrderQty'));
                Boolean isValidOrderQty = ((Map<String,Object>)obj).get('OrderQty') == '';
                System.debug('#isValidOrderQty:'+isValidOrderQty);

                if(((Map<String,Object>)obj).get('OrderQty') != null || ((Map<String,Object>)obj).get('OrderQty') != ''){
                    System.debug('Integer.valueOf ((string)((Map<String,Object>)obj)'+Integer.valueOf ((string)((Map<String,Object>)obj).get('OrderQty')));
                    preview.OrderQty__c = Integer.valueOf ((string)((Map<String,Object>)obj).get('OrderQty'));
                    preview.ProductName__c = (string)((Map<String,Object>)obj).get('ProductName');
                    preview.Family__c = (string)((Map<String,Object>)obj).get('Family');
                    preview.Account__c = accountId;
                    preview.Description__c = draftDesc;
                    preview.Value__c = totalAmount;
                    preview.Description__c = draftDesc;
                    previewList.add(preview);
                }

              //  System.debug('>>:'+((Map<String,Object>)obj).get('AvailableStock'));
            }
            System.debug('#previewList:'+previewList);

            if(previewList.size() > 0){
                results = Database.insert(previewList);
            }
        }
        catch (AuraHandledException ex){
            System.debug('Error: ' + ex.getMessage() + ' ->  Stack:' + ex.getStackTraceString());
        }
        return  results[0]?.isSuccess() ;
    }


}