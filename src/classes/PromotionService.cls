public with sharing class PromotionService {

    @AuraEnabled(Cacheable=true)

    public static List<PromotionWrapper> getPromotions(String accountId,String searchToken) {
        List<PromotionWrapper> wrappers = new List<PromotionWrapper>();
        System.debug('accountId:'+accountId + '   searchToken:'+searchToken);
        Map<String,Promotion__c>   promotionMap = new  Map<String,Promotion__c>();
        Map<String,PromotionProduct__c> promotionProductMap =new Map<String,PromotionProduct__c>();
        Map<String,FreeProduct__c> freeProductMap = new  Map<String,FreeProduct__c>();
        List<FreeProduct__c> freeProductList = new List<FreeProduct__c>();
        List<PromotionWrapper> nonProductWrappers = new List<PromotionWrapper>();
        Map<Id,Material__c> materials  = new Map<Id,Material__c>();
        Map<String,FreeProduct__c> freeProductMap1;

        List<GhdOrder__c> orders = [SELECT Id FROM GhdOrder__c WHERE Account__c =: accountId];
        System.debug('orders:'+orders);
        Account account = [SELECT Id, PartnershipLevel__c, Salon_Group__c FROM Account WHERE Id = :accountId];
        if(orders.size() == 0 || orders == null){

            promotionMap = new Map<String,Promotion__c>([
                    SELECT Id, StartDate__c, EndDate__c,Name, IsActive__c, SalonGroup__c, AvailableTier__c, SAPPromotionCode__c, (
                            SELECT Id, MaximumFreeUnits__c, OrderQuantity__c, Currency__c,
                                    Material__c, Material__r.MaterialDescription__c, Material__r.MaterialCode__c,Material__r.Category__c
                            from Promotion_Products__r
                    )
                    FROM Promotion__c
                    WHERE StartDate__c <= TODAY AND EndDate__c >= TODAY AND IsActive__c = TRUE
            ]);

            promotionProductMap = new Map<String,PromotionProduct__c>([SELECT Id,Currency__c,Material__c,MaximumFreeUnits__c,Category__c,Name,Promotion__r.Name,
                    Material__r.Category__c,Material__r.MaterialDescription__c, Material__r.MaterialCode__c,OrderQuantity__c,Promotion__c,Promotion__r.Discount__c
            FROM PromotionProduct__c WHERE Promotion__c IN :promotionMap.keySet()]);
            Set<String> promoProductIds = new Set<String>();
            for(String id: promotionProductMap.keySet()){
                promoProductIds.add(promotionProductMap.get(id).Id);
            }

            System.debug('#promoProductIds 1:'+promoProductIds);
            Set<String> materialsIds = new Set<String>();

            freeProductMap = new Map<String,FreeProduct__c>([SELECT Id,FreeQuantity__c,MaximumFreeUnits__c,Material__r.Category__c, Material__r.MaterialCode__c,PromotionProduct__c, Currency__c,
                    Material__r.MaterialDescription__c FROM FreeProduct__c
            WHERE PromotionProduct__c IN : promoProductIds]);
            if(freeProductMap?.size() > 0){
                freeProductMap1 = new Map<String,FreeProduct__c>();
                System.debug('#freeProductMap 1:'+freeProductMap);
                for(String p : freeProductMap.keySet()){
                    FreeProduct__c f = freeProductMap.get(p);
                    materialsIds.add(freeProductMap.get(p).Material__c);
                    freeProductMap1.put(f.Material__c,f);
                }
                System.debug('freeProductMap1:'+freeProductMap1);
            }

            System.debug('#materialsIds 1:'+materialsIds);
            materials = new Map<Id,Material__c>([SELECT Id, Name, MaterialCode__c, MaterialDescription__c, Category__c FROM Material__c WHERE Id IN : materialsIds]);
            System.debug('v'+materials);
            PromotionWrapper nonProdWrapper;
            FreeProduct__c fP;
            for(String id: promotionProductMap.keySet()){
                PromotionProduct__c pp = promotionProductMap.get(id);
                System.debug('pp:'+pp);
                //promotion on products
                if(String.isNotEmpty(pp.Material__c)){
                    nonProdWrapper = new PromotionWrapper();
                    nonProdWrapper.PromotionName = pp.Promotion__r.Name;
                    nonProdWrapper.OrderQuantity = pp.OrderQuantity__c;
                    nonProdWrapper.MaximumFreeUnits = pp.MaximumFreeUnits__c;
                    nonProdWrapper.MaterialCode =  materials.get(pp.Material__c).MaterialCode__c;
                    nonProdWrapper.Category =  materials.get(pp.Material__r.MaterialCode__c).Name;
                    nonProdWrapper.ProductName = materials.get(pp.Material__c).Name;
                    nonProdWrapper.Discount = pp.Promotion__r.Discount__c;
                    // nonProdWrapper.MaterialCode = materials.get(pp.Material__r.Id).MaterialCode__c;
                    if(freeProductMap?.size() > 0) {
                        System.debug('#freeProductMap1:' + freeProductMap1);
                        System.debug('##freeProductMap1.values():' + freeProductMap1.values());
                        for (FreeProduct__c f : freeProductMap1.values()) {
                            System.debug('##f:' + f);
                            if (f.PromotionProduct__c == pp.Id) {
                                PromotionService.FreeProductWrapper pWrapper = new PromotionService.FreeProductWrapper();
                                pWrapper.countryCurrency = f.Currency__c;
                                pWrapper.FreeQuantity = Integer.valueOf(f.FreeQuantity__c);
                                pWrapper.materialCode = materials.get(f.Material__c).MaterialCode__c;
                                pWrapper.maximumFreeUnits = Integer.valueOf(f.MaximumFreeUnits__c);
                                pWrapper.ProductName = materials.get(f.Material__r.Id).Name;
                                nonProdWrapper.FreeProductWrapper.add(pWrapper);
                            }

                        }
                    }
                    nonProdWrapper.Id = pp.Id;
                    nonProductWrappers.add(nonProdWrapper);

                }else { //promotion on Categories
                    Set<Id> freeProdIds = new Set<Id>();
                    for(String p : freeProductMap.keySet()) {
                        freeProdIds.add(freeProductMap.get(p).Material__c);
                    }
                    materials = new Map<Id,Material__c>([SELECT Id, Name, MaterialCode__c,Category__c, MaterialDescription__c FROM Material__c WHERE Id IN : freeProdIds]);

                    nonProdWrapper = new PromotionWrapper();
                    nonProdWrapper.PromotionName = promotionMap.get(pp.Promotion__c).Name;
                    nonProdWrapper.OrderQuantity = pp.OrderQuantity__c;
                    nonProdWrapper.MaximumFreeUnits = pp.MaximumFreeUnits__c;
                    nonProdWrapper.Category =  pp.Promotion__r.Name ;
                    nonProdWrapper.Id = pp.Id;
                    nonProdWrapper.Discount = pp.Promotion__r.Discount__c;
                    for(FreeProduct__c ff : freeProductList){
                        PromotionService.FreeProductWrapper pWrapper = new PromotionService.FreeProductWrapper();
                        pWrapper.countryCurrency = ff.Currency__c;
                        pWrapper.FreeQuantity = Integer.valueOf(ff.FreeQuantity__c);
                        pWrapper.materialCode = materials.get(ff.Material__c).MaterialCode__c;
                        pWrapper.maximumFreeUnits = Integer.valueOf(ff.MaximumFreeUnits__c);
                        pWrapper.ProductName = materials.get(ff.Material__c).Name;
                        pWrapper.Id = ff.Id;
                        pWrapper.Category = materials.get(ff.Material__c).Category__c;

                        if(fp != null){
                            nonProdWrapper.FreeProductWrapper.add(pWrapper);
                        }
                    }
                }
            }
        }else{
            promotionMap = new Map<String,Promotion__c>([
                    SELECT Id, StartDate__c, EndDate__c, Name,IsActive__c, SalonGroup__c, AvailableTier__c, SAPPromotionCode__c, (
                            SELECT Id, MaximumFreeUnits__c, OrderQuantity__c, Currency__c,
                                    Material__c, Material__r.MaterialDescription__c, Material__r.MaterialCode__c,Material__r.Category__c
                            from Promotion_Products__r
                    )
                    FROM Promotion__c
                    WHERE AvailableTier__c INCLUDES (:account.PartnershipLevel__c) AND SalonGroup__c INCLUDES (:account.Salon_Group__c)
                    AND StartDate__c <= TODAY AND EndDate__c >= TODAY AND IsActive__c = TRUE
            ]);

            promotionProductMap = new Map<String,PromotionProduct__c>([SELECT Id,Currency__c,Material__c,MaximumFreeUnits__c,Category__c,Promotion__r.Discount__c,
                    Material__r.Category__c,Material__r.MaterialDescription__c, Material__r.MaterialCode__c,OrderQuantity__c,Promotion__c
            FROM PromotionProduct__c WHERE Promotion__c IN :promotionMap.keySet()]);
            Set<String> ppIds = new Set<String>();
            Set<String> materialsIds = new Set<String>();
            for(string p : promotionProductMap.keySet()){
                ppIds.add(promotionProductMap.get(p).Id);
                materialsIds.add(promotionProductMap.get(p).Material__c);
            }
            freeProductMap = new  Map<String,FreeProduct__c>();
            List<FreeProduct__c> freeProducts = [SELECT Id, Name,Currency__c, FreeQuantity__c,Material__c, MaximumFreeUnits__c, PromotionProduct__c FROM FreeProduct__c WHERE PromotionProduct__c IN : ppIds ];
            for(FreeProduct__c p : freeProducts){
                freeProductMap.put(p.PromotionProduct__c, p);
                materialsIds.add(p.Material__c);

            }
            System.debug('#freeProductMap:'+freeProductMap);
            System.debug('#materialsIds:'+materialsIds);
            Set<String> freeProdIds = new Set<String>();
            FreeProduct__c fP;
            PromotionWrapper nonProdWrapper;
            for(String p : freeProductMap.keySet()) {
                freeProdIds.add(freeProductMap.get(p).Material__c);
            }

            materials = new Map<Id,Material__c>([SELECT Id, Name, MaterialCode__c,Category__c, MaterialDescription__c FROM Material__c WHERE Id IN : materialsIds]);
            System.debug('#materials 2:'+materials);
            System.debug('#promotionProductMap:'+promotionProductMap);
            List<FreeProductWrapper> freeProductWrappers = new  List<FreeProductWrapper>();
            PromotionService.FreeProductWrapper pWrapper;
            Set<FreeProduct__c> pfSet = new Set<FreeProduct__c>();
            for(String id: promotionProductMap.keySet()) {
                PromotionProduct__c pp = promotionProductMap.get(id);
                System.debug('#####pp:'+pp);
                nonProdWrapper = new PromotionWrapper();
                nonProdWrapper.PromotionName = promotionMap.get(pp.Promotion__c).Name;
                nonProdWrapper.OrderQuantity = pp.OrderQuantity__c;
                nonProdWrapper.MaximumFreeUnits = pp.MaximumFreeUnits__c;
                nonProdWrapper.PromoCategories = pp.Category__c?.split(';');
                nonProdWrapper.Id = pp.Id;
                nonProdWrapper.ProductName = materials.get(pp.Material__c)?.Name;
                nonProdWrapper.MaterialCode = materials.get(pp.Material__c)?.MaterialCode__c;
                nonProdWrapper.Category =  materials.get(pp.Material__c)?.Category__c;
                nonProdWrapper.Discount = pp.Promotion__r.Discount__c;
                Set<String> freeProdIds2 = new Set<String>();
                for(FreeProduct__c fpl : freeProducts ){
                    pfSet.add(fpl);
                    if(fpl.PromotionProduct__c == pp.Id){
                        pWrapper = new PromotionService.FreeProductWrapper();
                        pWrapper.countryCurrency = fpl.Currency__c;
                        pWrapper.FreeQuantity = Integer.valueOf(fpl.FreeQuantity__c);
                        pWrapper.materialCode = materials.get(fpl.Material__c).MaterialCode__c;
                        pWrapper.maximumFreeUnits = Integer.valueOf(fpl.MaximumFreeUnits__c);
                        pWrapper.ProductName = materials.get(fpl.Material__c).Name;
                        pWrapper.Id = fpl.Id;
                        pWrapper.PromotionProductId = fpl.PromotionProduct__c;
                        pWrapper.Category = materials.get(fpl.Material__c).Category__c;
                        nonProdWrapper.FreeProductWrapper.add(pWrapper);
                    }
                }
                System.debug('#nonProdWrapper:'+nonProdWrapper);

                nonProductWrappers.add(nonProdWrapper);

            }
            System.debug('#>> pfSet:' + pfSet);
        }
        System.debug('nonProdWrapper:'+ JSON.serialize(nonProductWrappers));
        return nonProductWrappers;
    }


    @AuraEnabled(Cacheable=true)
    public static void search(String accountId, String key){

        List<GhdOrder__c> orders = [SELECT Id FROM GhdOrder__c WHERE Account__c =: accountId];
        Account account = [SELECT Id, PartnershipLevel__c, Salon_Group__c FROM Account WHERE Id = :accountId];


        string keyLike = '%'+key+'%';
        List<PromotionWrapper> wrappers = new List<PromotionWrapper>();
        List<Promotion__c> promotions = [
                SELECT Id, StartDate__c, EndDate__c, IsActive__c, SalonGroup__c, AvailableTier__c, SAPPromotionCode__c, (
                        SELECT Id, MaximumFreeUnits__c, OrderQuantity__c, Currency__c,
                                Material__c, Material__r.MaterialDescription__c, Material__r.MaterialCode__c, Material__r.Id
                        from Promotion_Products__r
                )
                FROM Promotion__c
                WHERE StartDate__c <= TODAY AND EndDate__c >= TODAY AND IsActive__c = TRUE
        ];

        for(Promotion__c p : promotions){
            PromotionProduct__c pp = p.Promotion_Products__r;
            if(pp.Material__r.MaterialDescription__c.contains(key)){
                FreeProductWrapper freeProduct = new FreeProductWrapper();
                PromotionWrapper wrapper = new PromotionWrapper();
                wrapper.OrderQuantity = pp.OrderQuantity__c;
                wrapper.ProductName  = pp.Material__r.MaterialDescription__c;
                wrapper.MaximumFreeUnits = pp.MaximumFreeUnits__c;
                wrapper.ErpPromotionCode = p.SAPPromotionCode__c;
                wrapper.PromotionName = p.Name;
                wrapper.MaterialId = pp.Material__r.Id;
                //wrapper.FreeProductWrapper.add(freeProduct);
                wrappers.add(wrapper);
            }
        }

        System.debug('#filtered wrappers ' +wrappers);
    }



    public class PromotionWrapper {
        PromotionWrapper(){
            PromoCategories = new List<String>();
            FreeProductWrapper = new List<FreeProductWrapper>();
        }
        @AuraEnabled
        public String ProductName;
        @AuraEnabled
        public Decimal OrderQuantity;
        @AuraEnabled
        public Decimal FreeQuantity;
        @AuraEnabled
        public Decimal MaximumFreeUnits;
        @AuraEnabled
        public String ErpPromotionCode;
        @AuraEnabled
        public String MaterialCode;
        @AuraEnabled
        public String MaterialId;
        @AuraEnabled
        public String Category;
        @AuraEnabled
        public String PromotionName;
        @AuraEnabled
        public List<String> PromoCategories;
        @AuraEnabled
        public List<FreeProductWrapper> FreeProductWrapper;
        @AuraEnabled
        public String Id;
        @AuraEnabled
        public Decimal Discount;

    }

    public class FreeProductWrapper
    {
        @AuraEnabled
        public String ProductName;
        @AuraEnabled
        public String Id;
        @AuraEnabled
        public String Category;
        @AuraEnabled
        public String materialCode;
        @AuraEnabled
        public string countryCurrency;
        @AuraEnabled
        public Integer FreeQuantity;
        @AuraEnabled
        public Integer maximumFreeUnits;
        public String PromotionProductId;
    }
}