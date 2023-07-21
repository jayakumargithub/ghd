trigger DataDwellUserTrigger on User (before insert, after insert, before update, after update) {
    
    // Make sure the user has Salesforce CRM Content enabled
    if(Trigger.isBefore) {
        for(Integer i = 0; i < Trigger.New.size(); i++) {
            User currentUser = Trigger.New[i];
            if(currentUser.Data_Dwell_User__c == true && currentUser.USERPERMISSIONSSFCONTENTUSER != true) {
                Trigger.New[i].USERPERMISSIONSSFCONTENTUSER = true;
            }
        }
    }
    
    if(Trigger.isAfter) {
    
        Set<Id> usersAdd = new Set<Id>();
        Set<Id> usersRemove = new Set<Id>();
        Map<Id, PermissionSet> permSets = null;
        Group publicGroup = null;
        PackageLicense license = null;
        
        List<String> permissionSetNames = new List<String>{'Sales_Athlete_Admin', 'Sales_Enablement_ghd'};
            
        // Collect all newly created users with Data Dwell User turned on
        if (Trigger.isInsert) {
            for(Integer i = 0; i < Trigger.New.size(); i++) {
                User currentUser = Trigger.New[i];
                if(currentUser.Data_Dwell_User__c == true) {
                    usersAdd.add(currentUser.Id);
                }
            }
        }
        
        // Collect all updated users with Data Dwell User value changed
        if (Trigger.isUpdate) {
            for(Integer i = 0; i < Trigger.New.size(); i++) {
                User currentUserNew = Trigger.New[i];
                User currentUserOld = Trigger.Old[i];
                if(currentUserOld.Data_Dwell_User__c != true && currentUserNew.Data_Dwell_User__c == true) {
                    usersAdd.add(currentUserNew.Id);
                }
                if(currentUserOld.Data_Dwell_User__c == true && currentUserNew.Data_Dwell_User__c != true) {
                    usersRemove.add(currentUserNew.Id);
                }
            }
        }
        
        // If there are users to add or remove
        if(usersAdd.size() > 0 || usersRemove.size() > 0) {
            
            // Prepare permission set
            permSets = new Map<Id, PermissionSet>([SELECT Id FROM PermissionSet WHERE Name IN :permissionSetNames]);
            
            // Prepare public group
            List<Group> groupList = [SELECT Id FROM Group WHERE DeveloperName = 'Data_Dwell_Documents'];
            if(groupList.size() == 1) {
                publicGroup = groupList.get(0);
            }
            
            // Prepare package
            List<PackageLicense> packageList = [SELECT Id FROM PackageLicense WHERE NamespacePrefix = 'datadwell'];
            if(packageList.size() == 1) {
                license = packageList.get(0);
            }
            
            // If everything was found and prepared
            if(permSets.size() == permissionSetNames.size() && license != null) { //publicGroup != null && 
                
                if(usersAdd.size() > 0) {
                    
                    // Prevent duplicates if the user already has the permission set
                    Map<Id, Set<Id>> psaExistingUserId = new Map<Id, Set<Id>>();
                    List<PermissionSetAssignment> psaExisting = [SELECT Id, AssigneeId, PermissionSetId FROM PermissionSetAssignment WHERE PermissionSetId IN :permSets.keySet() AND AssigneeId IN :usersAdd];
                    for(PermissionSetAssignment psa : psaExisting) {
                        if(!psaExistingUserId.containsKey(psa.AssigneeId)) {
                            psaExistingUserId.put(psa.AssigneeId, new Set<Id>());
                        }
                        Set<Id> assigneeSet = psaExistingUserId.get(psa.AssigneeId);
                        assigneeSet.add(psa.PermissionSetId);
                        psaExistingUserId.put(psa.AssigneeId, assigneeSet);
                    }
                    
                    // Prevent duplicates if the user already has group membership
                    Set<Id> gmExistingUserId = new Set<Id>();
                    List<GroupMember> gmExisting = [SELECT Id, UserOrGroupId FROM GroupMember WHERE GroupId = :publicGroup.Id AND UserOrGroupId IN :usersAdd];
                    for(GroupMember gm : gmExisting) {
                        gmExistingUserId.add(gm.UserOrGroupId);
                    }
                    
                    // Prevent duplicates if the user already has the package license
                    Set<Id> uplExistingUserId = new Set<Id>();
                    List<UserPackageLicense> uplExisting = [SELECT Id, UserId FROM UserPackageLicense WHERE PackageLicenseId = :license.Id AND UserId IN :usersAdd];
                    for(UserPackageLicense upl : uplExisting) {
                        uplExistingUserId.add(upl.UserId);
                    }
                    
                    // Prepare insert lists
                    List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
                    List<GroupMember> gmList = new List<GroupMember>();
                    List<UserPackageLicense> uplList = new List<UserPackageLicense>();
                    for(Id userId : usersAdd) {
                        for(Id permSetId : permSets.keySet()) {
                          if(!psaExistingUserId.containsKey(userId) || !psaExistingUserId.get(userId).contains(permSetId)) {
                            psaList.add(new PermissionSetAssignment(PermissionSetId = permSetId, AssigneeId = userId));
                          }
                        }
                        if(!gmExistingUserId.contains(userId)) {
                          gmList.add(new GroupMember(GroupId = publicGroup.Id, UserOrGroupId = userId));
                        }
                        if(!uplExistingUserId.contains(userId)) {
                          uplList.add(new UserPackageLicense(PackageLicenseId = license.Id, UserId = userId));
                        }
                    }
                    if(psaList.size() > 0) {
                      insert psaList;
                    }
                    if(gmList.size() > 0) {
                      insert gmList;
                    }
                    if(uplList.size() > 0) {
                      insert uplList;
                    }
                }
                
                // Remove settings
                if(usersRemove.size() > 0) {
                    delete [SELECT Id FROM PermissionSetAssignment WHERE PermissionSetId IN :permSets.keySet() AND AssigneeId IN :usersRemove];
                    //delete [SELECT Id FROM GroupMember WHERE GroupId = :publicGroup.Id AND UserOrGroupId IN :usersRemove];
                    delete [SELECT Id FROM UserPackageLicense WHERE PackageLicenseId = :license.Id AND UserId IN :usersRemove];
                }
            }
        }
    }
}