@istest
public class RoyalMailTest {

    @istest
    public static void testException() {
        String method = 'notExists';
        Boolean exceptionThrown = false;
        try {
        	RoyalMail.calculateCheckDigit('12220901', method);
        } catch (RoyalMailException e) {
            exceptionThrown = true;
            System.assertEquals('Could not find check digit method for \'' + method + '\'', e.getMessage());
        }
        System.assertEquals(true, exceptionThrown);
    }

    @istest
    public static void testMod11() {
        System.assertEquals('4', RoyalMail.calculateCheckDigit('12220901', 'mod11'));
        System.assertEquals('9', RoyalMail.calculateCheckDigit('12221000', 'mod11'));
        System.assertEquals('6', RoyalMail.calculateCheckDigit('12720901', 'mod11'));
        System.assertEquals('5', RoyalMail.calculateCheckDigit('12721000', 'mod11'));
    }
    
    @istest
    public static void testLuhn16() {
        System.assertEquals('1', RoyalMail.calculateCheckDigit('0B012722900021AC35B2', 'luhn16'));
        System.assertEquals('A', RoyalMail.calculateCheckDigit('0B021399600000928580', 'luhn16'));
    }
    
    @istest(SeeAllData=true)
    public static void testTriggerInsert() {
        // Record Type of UK
        Id caseRecordTypeUK = Schema.SObjectType.Case.getRecordTypeInfosByName().get('In Warranty').getRecordTypeId();
        
        // Creating a new case that requires a tracking number
        Case testCase = new Case(
            RecordTypeId = caseRecordTypeUK,
            Status = 'RMA Assigned',
            Replacement_Sent__c = 'No',
            Type ='Standard Return'
        );
        insert testCase;
        
        // Reloading the case
        testCase = [SELECT RoyalMail1DTrackingNumber__c, RoyalMail1D__c, RoyalMail2D__c, RoyalMail2DSecuritySegment__c,
                            RoyalMail2DRoyalMailSegment__c, RoyalMail2DChannelSpecificSegment__c, RoyalMail2DRegistrySegment__c,
                     		RoyalMail2DUniqueIdentifier__c, RoyalMail2DUniqueIdentifierCheck__c 
                    FROM Case WHERE Id = :testCase.Id];
        
        // Tracking number needs to be set
        System.assertNotEquals(null, testCase.RoyalMail1DTrackingNumber__c);
        
        // 1D barcode needs to be 13 characters
        System.assertEquals(13, testCase.RoyalMail1D__c.length(), '1D Barcode needs to be 13 characters. Generated code: \'' + testCase.RoyalMail1D__c + '\'');
        
        // 2D barcode segments need specific lengths;
        System.assertEquals(20, testCase.RoyalMail2DUniqueIdentifier__c .length(), 'Unique Identifier incorrect length');
        System.assertEquals(1, testCase.RoyalMail2DUniqueIdentifierCheck__c.length(), 'Unique Identifier check digit incorrect length');
        System.assertEquals(10, testCase.RoyalMail2DRoyalMailSegment__c.length(), 'Royal Mail Segment incorrect length');
        System.assertEquals(163, testCase.RoyalMail2DChannelSpecificSegment__c.length(), 'Channel Specific Segment incorrect length. Segment: \'' + testCase.RoyalMail2DChannelSpecificSegment__c + '\'');
        System.assertEquals(15, testCase.RoyalMail2DRegistrySegment__c.length(), 'Registry Segment incorrect length');
        System.assertEquals(16, testCase.RoyalMail2DSecuritySegment__c.length(), 'Security Segment incorrect length');
        
        // 2D barcode needs to be 204 characters
        System.assertEquals(204, testCase.RoyalMail2D__c.length(), '2D Barcode needs to be 204 characters. Generated code: \'' + testCase.RoyalMail2D__c + '\'');
    }
    
    @istest(SeeAllData=true)
    public static void testTriggerUpdate() {
        // Record Type of UK
        Id caseRecordTypeUK = Schema.SObjectType.Case.getRecordTypeInfosByName().get('In Warranty').getRecordTypeId();
        
        // Creating a new case that does not requires a tracking number
        Case testCase = new Case(
            RecordTypeId = caseRecordTypeUK,
            Status = 'RMA Assigned',
            Replacement_Sent__c = 'Yes',
            Type ='Complaint',
            Type_of_Complaint__c = 'Physical Damage'
        );
        insert testCase;
        
        // Reloading the case
        testCase = [SELECT Status, Replacement_Sent__c, Type, RoyalMail1DTrackingNumber__c FROM Case WHERE Id = :testCase.Id];
        
        // Tracking number must not be set
        System.assertEquals(null, testCase.RoyalMail1DTrackingNumber__c);
        
        // Updating case to require a tracking number
        testCase.Replacement_Sent__c = 'No';
        update testCase;
        
        // Reloading the case
        testCase = [SELECT RoyalMail1DTrackingNumber__c FROM Case WHERE Id = :testCase.Id];
        
        // Tracking number needs to be set
        System.assertNotEquals(null, testCase.RoyalMail1DTrackingNumber__c);
    }
    
    @istest(SeeAllData=true)
    public static void testTriggerInsertNotUK() {
        // Record Type of UK
        Id caseRecordTypeANZ = Schema.SObjectType.Case.getRecordTypeInfosByName().get('ANZ Case RecordType').getRecordTypeId();
        
        // Creating a new case that requires a tracking number
        Case testCase = new Case(
            RecordTypeId = caseRecordTypeANZ,
            Status = 'RMA Assigned',
            Replacement_Sent__c = 'No',
            Type ='Standard Return'
        );
        insert testCase;
        
        // Reloading the case
        testCase = [SELECT RoyalMail1DTrackingNumber__c FROM Case WHERE Id = :testCase.Id];
        
        // Tracking number must not be set
        System.assertEquals(null, testCase.RoyalMail1DTrackingNumber__c);
    }
}