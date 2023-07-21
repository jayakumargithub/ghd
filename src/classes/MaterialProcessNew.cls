/**
 * Created by Jayakumar Mogenahall on 20/04/2023.
 */

@RestResource(UrlMapping='/Material/*')
global with sharing class MaterialProcessNew {

    @HttpPut
    global static void doPut() {

        try{
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        RestResponseWrapper resWrapper;
        System.debug('#req.requestBody.toString():'+req.requestBody.toString());
        MaterialRequestListWrapper matWrapper = MaterialRequestWrapper.parse(req.requestBody.toString());
        System.debug('#matWrapper:'+matWrapper);
        Map<String, MaterialRequestWrapper> wrapperMap = new Map<String, MaterialRequestWrapper>();
        for (MaterialRequestWrapper wrap : matWrapper.wrappers) {
            wrapperMap.put(wrap.material, wrap);
        }

        List<Dimension__c> dimensions = [SELECT Id,MaterialCode__c FROM Dimension__c WHERE MaterialCode__c IN :wrapperMap.keySet()];
        Map<String, Dimension__c> dimensionMap = new Map<String, Dimension__c>();
        for (Dimension__c d : dimensions) {
            dimensionMap.put(d.MaterialCode__c, d);
        }

        List<Material__c> existingMaterials = [
                SELECT Id, Bundle__c, MaterialCode__c,
                        Inventory__c, MaterialDescription__c, Owner__c,
                        Units__c, UOM__c, ProductType__c, SerialisedProduct__c, DangerousGoodsFlag__c, CarrierBag__c, IsActive__c,
                        WetStock__c, CustomsDescription__c, DangerousGoodsClassification__c, Category__c,
                        DangerousGoodsShippingName__c, Dimension__r.Dimtype__c, Dimension__r.Weight__c, Dimension__r.Depth__c,
                        Dimension__r.Height__c, Dimension__r.Volume__c, Dimension__r.Width__c, Dimension__r.TotalCartoonInPallet__c,
                        Dimension__r.TotalUnitsInCartoon__c, Dimension__r.TotalUnitsInPallet__c
                FROM Material__c
        ];

        Map<String, Material__c> existingMaterialMap = new Map<String, Material__c>();
        for (Material__c mat : existingMaterials) {
            existingMaterialMap.put(mat.MaterialCode__c, mat);
        }

        //System.debug('#existingMaterials:'+existingMaterials);
        List<Dimension__c> dimensionToUpdate = new List<Dimension__c>();
        List<Material__c> materialsToUpdate = new List<Material__c>();
        List<Material__c> materialsToInsert = new List<Material__c>();
        List<Dimension__c> dimensionToInsert = new List<Dimension__c>();
        List<SObject> upsertObjectList = new List<SObject>();

        List<Dimension__c> dimensionList = new List<Dimension__c>();
        for (MaterialRequestWrapper wrap : matWrapper.wrappers) {
            Material__c m = existingMaterialMap.get(wrap.material);
            if (m != null) {
                m.MaterialDescription__c = wrap?.materialDescription;
                m.Name =  wrap?.materialDescription;
                m.ProductType__c = wrap?.productType;
                m.UOM__c = wrap?.uom;
                m.Owner__c = wrap?.owner;
                m.SerialisedProduct__c = wrap?.serialisedProduct;
                m.DangerousGoodsFlag__c = wrap?.dangerousGoodsFlag;
                m.CarrierBag__c = wrap?.carrierBag;
                m.WetStock__c = wrap?.wetStock;
                m.IsActive__c = wrap?.active == null ? false : true;
                m.CustomsDescription__c = wrap?.customsDescription;
                m.DangerousGoodsClassification__c = wrap?.dangerousGoodsClassification;
                m.Category__c = wrap?.category;
                m.DangerousGoodsShippingName__c = wrap?.dangerousGoodsShippingName;
                Dimension__c dimension = dimensionMap.get(m.MaterialCode__c);
                if (dimension != null) {
                    dimension.Id = dimensionMap.get(wrap.material).Id;
                    dimension.Dimtype__c = wrap.dimensions?.dimType;
                    dimension.Weight__c = wrap.dimensions?.weight != null ? Decimal.valueOf(wrap.dimensions?.weight) : 0;
                    dimension.Depth__c = wrap.dimensions?.depth != null? Decimal.valueOf(wrap.dimensions?.depth) :0;
                    dimension.Height__c = wrap.dimensions?.height != null ? Decimal.valueOf(wrap.dimensions?.height) :0;
                    dimension.Volume__c = wrap.dimensions?.volume != null ? Decimal.valueOf(wrap.dimensions?.volume):0;
                    dimension.TotalCartoonInPallet__c = wrap?.dimensions?.totalUnitsInCarton != null ? Decimal.valueOf(wrap.dimensions?.totalUnitsInCarton) : 0.0;
                    dimension.TotalUnitsInCartoon__c = wrap?.dimensions?.totalUnitsInCarton != null ? Decimal.valueOf(wrap.dimensions?.totalUnitsInCarton) : 0.0;
                    dimension.TotalUnitsInPallet__c = wrap?.dimensions?.totalUnitsInPallet != null ? Decimal.valueOf(wrap.dimensions?.totalUnitsInPallet) : 0.0;
                    dimension.MaterialCode__c = wrap.material;
                   // dimension.Material__c = m.Id;
                    m.Dimension__c = dimension.Id;
                    if(!dimensionToUpdate.contains(dimension)) {
                        dimensionToUpdate.add(dimension);
                    }
                }

                if (!materialsToUpdate.contains(m)) {
                    materialsToUpdate.add(m);
                }
            } else {
                Material__c m1 = new Material__c();
                m1.Name =  wrap?.materialDescription;
                m1.MaterialDescription__c = wrap?.materialDescription;
                m1.MaterialCode__c = wrap?.material;
                m1.ProductType__c = wrap?.productType;
                m1.UOM__c = wrap?.uom;
                m1.Owner__c = wrap?.owner;
                m1.SerialisedProduct__c = wrap?.serialisedProduct;
                m1.DangerousGoodsFlag__c = wrap?.dangerousGoodsFlag;
                m1.CarrierBag__c = wrap?.carrierBag;
                m1.WetStock__c = wrap?.wetStock;
                m1.IsActive__c = wrap?.active == null ? false : true;
                m1.CustomsDescription__c = wrap?.customsDescription;
                m1.DangerousGoodsClassification__c = wrap?.dangerousGoodsClassification;
                m1.Category__c = wrap?.category;
                m1.DangerousGoodsShippingName__c = wrap?.dangerousGoodsShippingName;
                if(wrap?.dimensions != null){
                    Dimension__c d = new Dimension__c();
                    d.Dimtype__c = wrap?.dimensions?.dimType;
                    d.Weight__c = wrap?.dimensions?.weight != null ? Decimal.valueOf(wrap.dimensions?.weight) : 0.0;
                    d.Depth__c = wrap?.dimensions?.depth != null ? Decimal.valueOf(wrap.dimensions?.depth) : 0.0;
                    d.Height__c = wrap?.dimensions?.height != null ? Decimal.valueOf(wrap.dimensions?.height) : 0.0;
                    d.Volume__c = wrap?.dimensions?.volume != null ? Decimal.valueOf(wrap.dimensions?.volume) : 0.0;
                    d.TotalCartoonInPallet__c = wrap?.dimensions?.totalCartonInPallet != null ? Decimal.valueOf(wrap.dimensions?.totalCartonInPallet) : 0.0;
                    d.TotalUnitsInCartoon__c = wrap?.dimensions?.totalUnitsInCarton != null ? Decimal.valueOf(wrap.dimensions?.totalUnitsInCarton) : 0.0;
                    d.TotalUnitsInPallet__c = wrap?.dimensions?.totalUnitsInPallet != null ? Decimal.valueOf(wrap.dimensions?.totalUnitsInPallet) : 0.0;
                    d.MaterialCode__c = wrap.material;
                    dimensionToInsert.add(d);
                }
                if (!materialsToInsert.contains(m1)) {
                    materialsToInsert.add(m1);
                }
            }
        }
        List<Material__c> materialsObjects = new  List<SObject>();
        List<Dimension__c> dimensionObjects = new  List<SObject>();
        materialsObjects.addAll(materialsToInsert);
        materialsObjects.addAll(materialsToUpdate);
        dimensionObjects.addAll(dimensionToInsert);
        dimensionObjects.addAll(dimensionToUpdate);
        Database.UpsertResult[] upsertResults;

        //if more than 150 then we process in Queueable Process
        if(materialsObjects.size() > 150){
            DimensionQueueable queueable = new DimensionQueueable(materialsObjects,dimensionObjects);
            String jobId =  System.enqueueJob(queueable);
            System.debug('JobId' + jobId);
        }else{
            upsertResults =  MaterialProcessHelper.ProcessMaterialAndDimension(materialsObjects,dimensionObjects);
            resWrapper = new RestResponseWrapper();
            resWrapper.result = 'OK';
            RestResponseWrapper.Data idsData = new RestResponseWrapper.data();

            String outputData;
            System.debug('#upsertResults:'+upsertResults);
            for (Database.UpsertResult result : upsertResults) {
                outputData += result.getId() + ',';
            }

            idsData.genericId = outputData.removeStart('null').removeEnd(',');
        }

            resWrapper = new RestResponseWrapper();
            resWrapper.result = 'OK';
            RestResponseWrapper.Data idsData = new RestResponseWrapper.data();
            resWrapper.data =   idsData;
            res.responseBody = Blob.valueOf(json.serialize(resWrapper));
            }
        catch (Exception ex){
            System.debug('Error:    MaterialProcessNew.doPut' + ex.getMessage()+ '-> stack: ' + ex.getStackTraceString());
        }
    }
}