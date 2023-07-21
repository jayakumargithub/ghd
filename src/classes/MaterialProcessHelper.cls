/**
 * Created by Jayakumar Mogenahall on 26/04/2023.
 */

public with sharing class MaterialProcessHelper {


    public static Database.UpsertResult[] ProcessMaterialAndDimension(List<Material__c> materials,  List<Dimension__c> dimensions){

        Database.UpsertResult[] mResult;

        if(dimensions.size() > 0){
            Database.UpsertResult[] dimensionUpsertResult = Database.upsert(dimensions);
            Set<String> dimensionIds = new Set<String>();
            for(Database.UpsertResult r :  dimensionUpsertResult){
               if(r.isSuccess() && r.isCreated()){
                   dimensionIds.add(r.getId());
               }else{
                   for(Dimension__c d: dimensions){
                       dimensionIds.add(d.Id);
                   }
            }
            }
            List<Dimension__c> insertedDimension = [SELECT Id,MaterialCode__c FROM Dimension__c WHERE Id IN : dimensionIds];
            Map<String, Dimension__c> dimensionMap = new Map<String,Dimension__c>();
            for(Dimension__c d : insertedDimension){
                dimensionMap.put(d.MaterialCode__c,d);
            }
            for(SObject m : materials){
                if(String.valueOf(m.getSObjectType()) == 'Material__c'){
                    Material__c mat = (Material__c)m;
                    System.debug('#dimensionMap:'+dimensionMap);
                    if(dimensionMap.get(mat.MaterialCode__c) != null){
                        mat.Dimension__c = dimensionMap.get(mat.MaterialCode__c).Id;
                    }
                }
            }

            if(materials.size() > 0){
               mResult = Database.upsert(materials);
            }
        }
        return mResult;
    }
}