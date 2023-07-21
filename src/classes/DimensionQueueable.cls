/**
 * Created by Jayakumar Mogenahall on 25/04/2023.
 */

public with sharing class DimensionQueueable implements  Queueable{

    List<Material__c> materialList = new List<Material__c>();
    List<Dimension__c> dimensionList;
    public DimensionQueueable( List<Material__c> materials, List<Dimension__c> dimensions){
        this.materialList = materials;
        this.dimensionList = dimensions;
    }
    public void execute(QueueableContext param1) {


        Database.UpsertResult[] results =  MaterialProcessHelper.ProcessMaterialAndDimension(this.materialList,this.dimensionList);

        Set<String> materialCodeSet = new Set<String>();
        for(Dimension__c d: this.dimensionList){
            materialCodeSet.add(d.MaterialCode__c);
        }
        if(results[0].isSuccess()){
            List<Dimension__c> dimensionList = [SELECT Id,MaterialCode__c FROM Dimension__c WHERE MaterialCode__c IN : materialCodeSet];
            MaterialQueueable materialQueueable = new MaterialQueueable(this.materialList,dimensionList);
            System.enqueueJob(materialQueueable);
        }
    }

}