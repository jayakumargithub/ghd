/**
 * Created by Jayakumar Mogenahall on 21/04/2023.
 */

public with sharing class MaterialQueueable implements Queueable{

    List<Material__c> materialList;
    List<Dimension__c> dimensionList;
    public MaterialQueueable(List<Material__c> materials,  List<Dimension__c> dimensions){
        this.materialList = materials;
        this.dimensionList = dimensions;
    }
    public void execute(QueueableContext param1) {
        try{
            Map<String, Dimension__c> dimensionMap = new  Map<String, Dimension__c>();
            for(Dimension__c d : this.dimensionList){
                dimensionMap.put(d.MaterialCode__c,d);
            }
            for(Material__c m: this.materialList){
                m.Dimension__c = dimensionMap.get(m.MaterialCode__c).Id;
            }

            if(materialList.size() > 0){
                Database.UpsertResult[] results = Database.upsert(materialList);
            }
        }catch (DmlException dmlEx){
            System.debug('#Error MaterialQueueable DML EX: '+ dmlEx.getMessage() + ' >>:' + dmlEx.getStackTraceString());
        }
        catch (Exception ex){
            System.debug('#Error MaterialQueueable DML EX: '+ ex.getMessage() + ' >>:' + ex.getStackTraceString());
        }
    }
}