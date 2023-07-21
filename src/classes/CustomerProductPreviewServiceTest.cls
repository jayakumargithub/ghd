/**
 * Created by Jayakumar Mogenahall on 28/06/2023.
 */

@IsTest
public  class CustomerProductPreviewServiceTest {

    @IsTest
    public static void createDraftOrderTest(){
        Account account =  TestFactory.createAccount('Doe',true);
        DraftOrder__c draftOrder = TestFactory.createDraftOrder(account.Id,true);
        Test.startTest();
        List<DraftOrder__c> output = CustomerProductPreviewService.getDraftViewForCustomer(account.Id);
        System.assert(output != null);
        Test.stopTest();

    }
}