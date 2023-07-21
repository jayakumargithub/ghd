@IsTest
public class RoyalMailCaseNumberControllerTest {

    @IsTest(SeeAllData=true)
    public static void testLoadCase() {
        Case testCase = [SELECT Id, RoyalMail1DTrackingNumber__c FROM Case WHERE RoyalMail1DTrackingNumber__c != null LIMIT 1];
        Case loadedCase = RoyalMailCaseNumberController.loadCase(testCase.Id);
        System.assertEquals(testCase.RoyalMail1DTrackingNumber__c, loadedCase.RoyalMail1DTrackingNumber__c);
    }
    
    @IsTest(SeeAllData=true)
    public static void testAssignToCase() {
        Case testCase = [SELECT Id FROM Case WHERE RoyalMail1DTrackingNumber__c = null LIMIT 1];
        RoyalMailCaseNumberController.assignCodeToCase(testCase.Id);
        Case afterCase = [SELECT Id, RoyalMail1DTrackingNumber__c, RoyalMail2DUniqueIdentifier__c FROM Case WHERE Id = :testCase.Id];
        System.assertNotEquals(null, afterCase.RoyalMail1DTrackingNumber__c);
        System.assertNotEquals(null, afterCase.RoyalMail2DUniqueIdentifier__c);
    }
}