trigger ContentVersionCreation on ContentVersion(before insert, before update, before delete, after insert, after update, after delete, after undelete) {
        switch on Trigger.operationType {
            when BEFORE_INSERT {
                // handler.beforeInsert(Trigger.new);
            }
            when BEFORE_UPDATE {
                // handler.beforeUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
            }
            when BEFORE_DELETE {
                // handler.beforeDelete(Trigger.old, Trigger.oldMap);
            }
            when AFTER_INSERT {
                List<Id> firstPublishLocationIds = new List<ID>();
    for (ContentVersion contentVersion : Trigger.new) {
        if (contentVersion.FirstPublishLocationId != null) {
            firstPublishLocationIds.add(contentVersion.FirstPublishLocationId);
        }
    }
    List<Account> accountFiles = new List<Account>(
        [SELECT Id, Contract__c FROM Account WHERE Id IN :firstPublishLocationIds]);
    for (Account accFile : accountFiles) {
        accFile.Contract__c = true;
    }
               
    update accountFiles;
                // handler.afterInsert(Trigger.new, Trigger.newMap);
            }
            when AFTER_UPDATE {
                // handler.afterUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
            }
            when AFTER_DELETE {
                // handler.afterDelete(Trigger.old, Trigger.oldMap);
            }
            when AFTER_UNDELETE {
                // handler.afterUndelete(Trigger.new, Trigger.newMap);
            }
        }
    }