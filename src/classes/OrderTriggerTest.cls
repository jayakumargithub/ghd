/**
 * Created by Jayakumar Mogenahall on 30/06/2023.
 */
@IsTest
public  class OrderTriggerTest {

    @TestSetup
    public static void Setup(){
        Account  acc = TestFactory.createAccount('Doe',false);
        GhdOrder__c order = new GhdOrder__c();
        order.RecordTypeId = TestFactory.getRecordTypeId('UK');
        order.OrderType__c = 'R';
        order.CreatedSource__c = 'Case';
        insert order;

        Material__c newMaterial = new Material__c(
                Name = 'Material',
                MaterialDescription__c = 'searchToken',
                ProductType__c = 'Type 1',
                Category__c = 'Combs',
                MaterialCode__c = 'CODE'
        );
        insert newMaterial;

        OrderLineItem__c oli = new OrderLineItem__c();
        oli.GhdOrder__c = order.Id;
        oli.Quantity__c = 1;
        oli.Material__c = newMaterial.Id;
        insert oli;

    }

    @IsTest
    public static void Test1(){
        Test.startTest();
        GhdOrder__c order = [SELECT Id FROM GhdOrder__c WHERE OrderType__c = 'R'];
        order.POReference__c = '001';
        update Order;
        Test.stopTest();
    }

}