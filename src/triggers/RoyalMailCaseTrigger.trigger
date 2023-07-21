trigger RoyalMailCaseTrigger on Case (before insert, before update) {
    if(Trigger.isInsert) {
        List<Case> caseList = Trigger.new;
        for(Case caseRow : caseList) {
            if(RoyalMail.doesCaseNeedTracking(caseRow) && caseRow.RoyalMail1DTrackingNumber__c == null) {
                RoyalMail.assignTrackingToCase(caseRow);
            }
        }
    } else if(Trigger.isUpdate) {
        Map<Id, Case> newCaseMap = Trigger.newMap;
        Map<Id, Case> oldCaseMap = Trigger.oldMap;
        for(Id caseId : oldCaseMap.keySet()) {
            if(
                RoyalMail.doesCaseNeedTracking(newCaseMap.get(caseId)) && 
               	(
                    !RoyalMail.doesCaseNeedTracking(oldCaseMap.get(caseId)) || 
                    newCaseMap.get(caseId).RoyalMail1DTrackingNumber__c == null
                )
              )
            {
                RoyalMail.assignTrackingToCase(newCaseMap.get(caseId));
            }
        }
    }
    RoyalMail.updateRangeChanges();
}