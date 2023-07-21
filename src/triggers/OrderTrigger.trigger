trigger OrderTrigger on GhdOrder__c (after insert, after update) {
    List<GhdOrder__c> orders = Trigger.new;
    List<String> ids = new List<String>();
    for(GhdOrder__c order : orders){
        ids.add(order.Id);
    }
    System.debug(ids);
    if(!TriggerHelper.isTriggerExecuted) {
        TriggerHelper.isTriggerExecuted = true;

        if (Trigger.isInsert) {
            List<OrderLineItem__c> lines = [
                    SELECT Id, Name, GhdOrder__c, Material__r.MaterialCode__c, Quantity__c, TotalPrice__c, T_T_Product_Type__c, T_T_Product_Name__c
                    FROM OrderLineItem__c
                    WHERE GhdOrder__c IN :ids
            ];
            String jsonInput;

            for (GhdOrder__c order : orders) {
                if (order.CreatedSource__c != 'OrderConsole' && order.OrderType__c == 'R') {
                    try {
                        jsonInput = OrderService.createJsonFromOrder(order, lines);
                    } catch (Exception e) {
                        System.debug('CreateJsonFromOrder Error>>>' + e);
                    }

                    try {
                        OrderService.createOrder(jsonInput);
                    } catch (Exception e) {
                        System.debug('CreateOrder Error>>>' + e.getMessage() + ' stack:' + e.getStackTraceString());
                    } 
                }
            }

        } else if (Trigger.isUpdate) {
            List<OrderLineItem__c> lines = [
                    SELECT Id, Name, GhdOrder__c, Material__r.MaterialCode__c, Quantity__c, TotalPrice__c, T_T_Product_Type__c, T_T_Product_Name__c
                    FROM OrderLineItem__c
                    WHERE GhdOrder__c IN :ids
            ];
            String jsonInput;

            for (GhdOrder__c order : orders) {
                if ((order.ApprovalStatus__c == 'Approved') || (order.CreatedSource__c != 'OrderConsole') && order.Status__c == 'Created') {
                    try {
                        jsonInput = OrderService.createJsonFromOrder(order, lines);
                        System.debug('#jsonInput trigger after JSON map' + jsonInput);
                    } catch (Exception e) {
                        System.debug('CreateJsonFromOrder Error>>>' + e.getMessage() + ' stacktrace :' + e.getStackTraceString());
                    }

                    try {
                        OrderService.createOrder(jsonInput);
                    } catch (Exception e) {
                        System.debug('CreateOrder Error>>>' + e.getMessage() + ' stacktrace :' + e.getStackTraceString());
                    }
                }
            }

        }
    }
}