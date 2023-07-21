/**
 * Created by Jayakumar Mogenahall on 21/03/2023.
 */

public  class CustomerProductService {

    @AuraEnabled(Cacheable=true)
    public static CpWrapper getMaterialsForAccount(String accountId, String searchToken, String draftName){

        List<CustomerProduct__c> customerProduct = [SELECT Id,PriceListRefreshedAt__c FROM CustomerProduct__c WHERE Account__c =: accountId];

        CpWrapper cpWrapper = new CpWrapper();
        System.debug('#customerProduct:'+customerProduct);
       

        Account account = [SELECT Id,CustomerId__c FROM Account WHERE Id =: accountId];
//        if(account.CustomerId__c != null || String.isBlank(account.CustomerId__c)){
//            throw new AuraHandledException('Customer Id not found for the Account.');
//        }
        PriceService.getPriceForCustomer(account.CustomerId__c);

        try {
            String token = '' + searchToken + '%';
            List<CustomerProduct__c> customerProducts;
            Map<Id, DraftOrder__c> draftOrderMap = new Map<Id, DraftOrder__c>();
            if (String.isNotBlank(draftName)) {
                List<DraftOrder__c> draftOrders = [SELECT CustomerProduct__c, OrderQty__c FROM DraftOrder__c WHERE Description__c = :draftName];
                Set<Id> customerProductIds = new Set<Id>();
                for (DraftOrder__c d : draftOrders) {
                    draftOrderMap.put(d.CustomerProduct__c, d);
                    customerProductIds.add(d.CustomerProduct__c);
                }
                customerProducts = [
                        SELECT Id, UnitPrice__c, MaterialCode__c
                        FROM CustomerProduct__c
                        WHERE Id IN :customerProductIds
                ];
            } else {
                customerProducts = [
                        SELECT Id, UnitPrice__c, MaterialCode__c
                        FROM CustomerProduct__c
                        WHERE Account__c = :accountId
                ];
            }


            Set<String> materialCodeSet = new Set<String>();

            for (CustomerProduct__c c : customerProducts) {
                materialCodeSet.add(c.MaterialCode__c);
            }
            List<Material__c> materials2 = MaterialService.getMaterials(materialCodeSet);
            Map<String, Material__c> materialMap = new Map<String, Material__c>();
            for (Material__c m : materials2) {
                materialMap.put(m.MaterialCode__c, m);
            }
            List<String> categories = new List<String>();


            // Map<String,Decimal> materialPriceMap = new Map<String,Decimal>();
            for (CustomerProduct__c cp : customerProducts) {
                CustomerProductWrapper wrapper = new CustomerProductWrapper();


                if(materialMap.get(cp?.MaterialCode__c) != null){
                    if (!categories.contains(materialMap.get(cp?.MaterialCode__c)?.ProductType__c)) {
                        categories.add(materialMap.get(cp?.MaterialCode__c)?.ProductType__c);
                    }
                    if (materialMap.get(cp.MaterialCode__c).MaterialDescription__c.toLowerCase().contains(searchToken.toLowerCase())) {
                        wrapper.ProductName = materialMap.get(cp.MaterialCode__c).MaterialDescription__c;
                        wrapper.UnitPrice = cp.UnitPrice__c;
                        wrapper.OrderQty = draftOrderMap.get(cp.Id)?.OrderQty__c;
                        wrapper.MaterialCode = cp.MaterialCode__c;
                        wrapper.Category = materialMap.get(cp.MaterialCode__c).ProductType__c;
                        wrapper.Id = materialMap.get(cp.MaterialCode__c).Id;
                        cpWrapper.wrapperList.add(wrapper);
                    }
                }
            }


            categories.sort();
            cpWrapper.categories.addAll(categories);
            if(cpWrapper != null){
                cpWrapper.categories[0] = 'All';
            }

            System.debug('#cpWrapper:' + cpWrapper);
        }catch (Exception ex){
            system.debug('Error  CustomerProductService.getMaterialsForAccount :' + ex.getMessage());
        }
        return cpWrapper;
    }

    @AuraEnabled
    public static Boolean create(String jsonInput, String accountId, String draftDesc, Decimal totalAmount) {
        System.debug('#jsonInput: ' + jsonInput);
        System.debug('#accountId:' + accountId + ' draftDesc:' + draftDesc + ' totalAmount:' + totalAmount);
        Database.SaveResult[] results;
        List<draftOrderWrapper> wrappers = (List<draftOrderWrapper>) JSON.deserialize(jsonInput, List<draftOrderWrapper>.class);
        System.debug('#wrappers:' + wrappers);

        Map<Id, draftOrderWrapper> customerProductMap = new Map<Id, draftOrderWrapper>();
        for (draftOrderWrapper wrapper : wrappers) {
            customerProductMap.put(wrapper.Id, wrapper);
        }
        System.debug('#customerProductMap:' + customerProductMap);
        List<CustomerProduct__c> customerProductList = [SELECT Id,UnitPrice__c, MaterialCode__c FROM CustomerProduct__c WHERE Id IN :customerProductMap.keySet()];
        System.debug('#customerProductList:' + customerProductList);
        Map<String, CustomerProduct__c> customerProductMap3 = new Map<String, CustomerProduct__c>();
        for (CustomerProduct__c cp : customerProductList) {
            customerProductMap3.put(cp.MaterialCode__c, cp);
        }
        System.debug('#customerProductMap3:' + customerProductMap3);
        List<Material__c> materials = [SELECT Id, Name, MaterialDescription__c, MaterialCode__c FROM Material__c WHERE MaterialCode__c IN :customerProductMap3.keySet()];
        System.debug('#materials:' + materials);
        Map<String, Material__c> materialMap = new  Map<String, Material__c>();
        for(Material__c m: materials){
            materialMap.put(m.MaterialCode__c,m);
        }
        System.debug('#materialMap:'+materialMap);
        Map<String, CustomerProduct__c> customerProductMap2 = new Map<String, CustomerProduct__c>();
        for (CustomerProduct__c cp : customerProductList) {
            customerProductMap2.put(cp.Id, cp);
        }
System.debug('#customerProductMap2:'+customerProductMap2);
        Set<DraftOrder__c> draftList = new Set<DraftOrder__c>();
        try {
            for (draftOrderWrapper w : wrappers) {
                DraftOrder__c draft = new DraftOrder__c();
                draft.OrderQty__c = Decimal.valueOf(w.OrderQty);
                draft.UnitPrice__c = customerProductMap2.get(w.Id).UnitPrice__c;
                draft.ProductName__c = materialMap.get(customerProductMap2.get(w.Id).MaterialCode__c).Name;
                draft.Family__c = null;
                draft.AccountId__c = accountId;
                draft.Description__c = draftDesc;
                draft.Value__c = totalAmount;
                draft.Description__c = draftDesc;
                draft.CustomerProduct__c = w.Id;
                draftList.add(draft);
            }
System.debug('#draftList:'+draftList);
            if(draftList.size() > 0){
                List<DraftOrder__c> draftOrders = new List<DraftOrder__c>();
                for(DraftOrder__c d : draftList){
                    draftOrders.add(d);
                }

                results = Database.insert(draftOrders);
            }
System.debug('#draftList:'+draftList);
    } catch  (AuraHandledException ex){
            System.debug('Error: ' + ex.getMessage() + ' ->  Stack:' + ex.getStackTraceString());
        }

            return true;

    }


    public class CpWrapper{
        CpWrapper(){
            wrapperList = new List<CustomerProductWrapper>();
            categories = new List<String>();
        }
        @AuraEnabled
        public List<CustomerProductWrapper> wrapperList;
        @AuraEnabled
        public List<String> categories;
    }
    public class CustomerProductWrapper{
        @AuraEnabled
        public String ProductName;
        @AuraEnabled
        public Decimal UnitPrice;
        @AuraEnabled
        public String Id;
        @AuraEnabled
        public Decimal OrderQty;
        @AuraEnabled
        public String MaterialCode;
        @AuraEnabled
        public String Category;
    }
    public class draftOrderWrapper
    {
        public String OrderQty;
        public String Id;
    }

}