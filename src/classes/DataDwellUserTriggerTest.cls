@istest
public class DataDwellUserTriggerTest {

    @isTest
    public static void testAssignment() {
        
        Profile prof = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        
        List<String> permissionSetNames = new List<String>{'Sales_Athlete_Admin', 'Sales_Enablement_ghd'};
        Map<Id, PermissionSet> permSets = new Map<Id, PermissionSet>([SELECT Id FROM PermissionSet WHERE Name IN :permissionSetNames]);
        
        User testUser = new user(
            LastName = 'Test Code',
            Email = 'test@test.com',
            Alias = 'Tcode',
            Username = 'usernamethatshouldnotexist@datadwell.com',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'GMT',
            ProfileID = prof.Id,
            LanguageLocaleKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            Data_Dwell_User__c = true
        );
        
        insert testUser;
        
        List<PermissionSetAssignment> psaCheck = [SELECT Id, AssigneeId, PermissionSetId FROM PermissionSetAssignment WHERE PermissionSetId IN :permSets.keySet() AND AssigneeId = :testUser.Id];
        System.assertEquals(permSets.keySet().size(), psaCheck.size());
        
        testUser.Data_Dwell_User__c = false;
        update testUser;
        
        psaCheck = [SELECT Id, AssigneeId, PermissionSetId FROM PermissionSetAssignment WHERE PermissionSetId IN :permSets.keySet() AND AssigneeId = :testUser.Id];
        System.assertEquals(0, psaCheck.size());
        
        PermissionSetAssignment permAssign = new PermissionSetAssignment(PermissionSetId = permSets.values().get(0).Id, AssigneeId = testUser.Id);
        insert permAssign;
        testUser.Data_Dwell_User__c = true;
        update testUser;
        
        psaCheck = [SELECT Id, AssigneeId, PermissionSetId FROM PermissionSetAssignment WHERE PermissionSetId IN :permSets.keySet() AND AssigneeId = :testUser.Id];
        System.assertEquals(permSets.keySet().size(), psaCheck.size());
        
    }
    
}