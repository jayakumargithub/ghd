public class RoyalMailCaseNumberController {

    @AuraEnabled
    public static Case loadCase(Id caseId) {
        return [SELECT RoyalMail1DTrackingNumber__c FROM Case WHERE Id = :caseId];
    }
    
    @AuraEnabled
    public static void assignCodeToCase(Id caseId) {
        Case theCase = [SELECT Id, RoyalMail1DTrackingNumber__c, RoyalMail2DUniqueIdentifier__c, RoyalMail2DUniqueIdentifierCheck__c FROM Case WHERE Id = :caseId];
        RoyalMail.assignTrackingToCase(theCase);
        update theCase;
    }
    
}