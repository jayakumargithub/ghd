/**
 * Created by Jayakumar Mogenahall on 10/03/2023.
 */

public with sharing class OrderService {

    @AuraEnabled
    public static String createOrder(String jsonInput) {
        System.debug('#jsonInput:'+jsonInput);
        if(String.isBlank(jsonInput) || jsonInput == null) {return '';}
        Savepoint savepoint;
        Database.SaveResult[] oliSaveResult;
        Database.SaveResult[]  orderLineSaveResult;
        String createdOrderId;
        try {
            if(!Test.isRunningTest()){
                savepoint = Database.setSavepoint();
            }
            OrderCreateWrapper orderWrapper = OrderCreateWrapper.parse(jsonInput);

            /*
            if(String.isNotBlank(orderWrapper.poReference)){
                List<GhdOrder__c> orders = [SELECT Id, POReference__c FROM GhdOrder__c WHERE POReference__c =: orderWrapper.poReference];
                if(orders.size() > 0 ){
                    if(String.isNotBlank(orders[0]?.POReference__c)){
                        AuraHandledException e = new  AuraHandledException('');
                        e.setMessage('PO Reference is already exists, please use different reference.');
                        throw e;
                    }
                }
            }

             */
            List<OrderLineModel> orderProducts = new List<OrderLineModel>();
            Set<String> materialCodes = new Set<String>();
            for(OrderLineModel model : orderWrapper.products){
                orderProducts.add(model);
                materialCodes.add(model.MaterialCode);
            }

            List<Material__c> materials = [SELECT Id, MaterialCode__c,MaterialDescription__c FROM Material__c WHERE MaterialCode__c IN : materialCodes];
            Map<String,Material__c> materialMap = new Map<String,Material__c>();
            for(Material__c m : materials){
                materialMap.put(m.MaterialCode__c,m);
            }


            String accountCustomerId = [SELECT Id, CustomerId__c FROM Account WHERE Id =: orderWrapper.accountId].CustomerId__c;
            Account account = [SELECT Id, FirstName__c, LastName__c,Type,Phone,CustomerId__c,Primary_Email__c,NationalNumber__c,CommercialName__c,CountryCurrency__c,
                    BillingStreet, BillingState,BillingCity,BillingCountry, BillingPostalCode,ShippingStreet,ShippingState,ShippingCity,ShippingCountry,ShippingPostalCode,Country_Code__c
            FROM Account WHERE CustomerId__c =: accountCustomerId];
           
       String custCurrency;
       String countryCode;
       custCurrency = account.CountryCurrency__c;
       
       countryCode = account.Country_Code__c;
    if (countryCode ==null){
       
      system.debug(custCurrency);
       switch on custCurrency {
  when 'AUD' {
     countryCode ='AU';
  }
  when 'EUR' {
      countryCode ='DE';
  }
  when 'GBP' {
      countryCode ='GB';
  }
  when 'NZD' {
     countryCode ='NZ';
  }
  when 'SEK' {
     countryCode ='SE';
  }
  when else {
     throw new SearchException('Country Code Not Recognised');
  }
}
}
            Origin__c origin = [SELECT CountryCode__c,Identifier__c,Application__c,eCommStore__c FROM Origin__c WHERE  CountryCode__c =: countryCode];
            VAT__mdt vat = [SELECT Id, VAT__c FROM VAT__mdt WHERE VATCountry__r.Masterlabel =: 'United Kingdom'];
            string orderId ;
            if(orderWrapper.Id == null) {
                GhdOrder__c order = new GhdOrder__c();
                 order.POReference__c = orderWrapper?.poReference;
                 order.OrderDate__c = orderWrapper.estimatedDeliveryDate == Date.newInstance(1975,01,01) ? null : orderWrapper.estimatedDeliveryDate;
                order.CountryCode__c = origin.CountryCode__c;
                order.Account__c = account.Id;
                if (orderWrapper.orderType == 'Free Order') {
                    order.OrderType__c = 'A';
                    system.debug('Free Order');
                } else {
                    order.OrderType__c = orderWrapper.orderType;
                }

                order.Laser_Text__c = orderWrapper.laserText;
                order.TotalAmount__c = orderWrapper.totalInclVat;
                order.Status__c = 'Draft';
                order.Vat__c = vat.VAT__c;
                order.CreatedSource__c = 'Order Console';
                order.BillingAddress__Street__s = orderWrapper.BillingAddressStreet == null ? '' : orderWrapper.BillingAddressStreet;
                order.BillingAddress__City__s = orderWrapper.BillingAddressCity == null ? '' : orderWrapper.BillingAddressCity;
                order.BillingAddress__StateCode__s = orderWrapper.billingAddressCounty == null ? '' : orderWrapper.billingAddressCounty;
                order.BillingAddress__CountryCode__s = orderWrapper.BillingAddressCountry == null ? '' : orderWrapper.BillingAddressCountry;
                order.BillingAddress__PostalCode__s = orderWrapper.BillingAddressPostalCode == null ? '' : orderWrapper.BillingAddressPostalCode;
                order.ShippingAddress__Street__s = orderWrapper.ShippingAddressStreet == null ? '' : orderWrapper.ShippingAddressStreet;
                order.ShippingAddress__City__s = orderWrapper.ShippingAddressCity == null ? '' : orderWrapper.ShippingAddressCity;
                order.ShippingAddress__StateCode__s = orderWrapper.ShippingAddressCounty == null ? '' : orderWrapper.ShippingAddressCounty;
                order.ShippingAddress__CountryCode__s = orderWrapper.ShippingAddressCountry == null ? '' : orderWrapper.ShippingAddressCountry;
                order.ShippingAddress__PostalCode__s = orderWrapper.ShippingAddressPostalCode == null ? '' : orderWrapper.ShippingAddressPostalCode;
                order.DeliveryBlock__c = false;//orderWrapper.deliveryBlock;
                order.RecordTypeId = Schema.SObjectType.GhdOrder__c.getRecordTypeInfosByName().get('UK').getRecordTypeId();
                Database.SaveResult orderSaveResult = Database.insert(order);
                createdOrderId = orderSaveResult.getId();
                orderId = orderSaveResult.getId();
                System.debug('#createdOrderId:' + createdOrderId);
            }else{
                orderId = orderWrapper.Id;
            }

            GhdOrder__c createdOrder = [SELECT Id, POReference__c,Account__c, CountryCode__c, OrderNumber__c, ApprovalStatus__c FROM GhdOrder__c where Id =: orderId];
            OrderRequestWrapper requestWrapper = new OrderRequestWrapper();

            Map<String,OrderLineModel> productsMap = new Map<String,OrderLineModel>();
            for(OrderLineModel o : orderWrapper.products){
                productsMap.put(o.MaterialCode, o);
            }

            //Order Mandatory fields starts
            system.debug(orderWrapper.orderType);
            if(orderWrapper.orderType == 'Free Order'){
                requestWrapper.orderType = 'A';
                system.debug('Free Order');
            }else{requestWrapper.orderType = orderWrapper.orderType;}

            requestWrapper.clientOrderNumber = createdOrder.OrderNumber__c;
            requestWrapper.countryCode = createdOrder.CountryCode__c;
            requestWrapper.currencyCode = account.CountryCurrency__c;
            requestWrapper.subTotal =orderWrapper.totalExclVat;
            requestWrapper.tax = vat.VAT__c;
            requestWrapper.totalValue = orderWrapper.totalInclVat;
            requestWrapper.orderDate = String.valueOf(Date.today());
            requestWrapper.approveStatus = createdOrder.ApprovalStatus__c;

            List<OrderLineModel> orderLine = new  List<OrderLineModel>();
            //build orderLine for JSON
            Set<String> orderIds = new Set<String>();
            for(string p : productsMap.keySet()){
                OrderLineModel ol = new OrderLineModel();
            }
            for(OrderLineModel olm : orderProducts){
                OrderLineModel ol = new OrderLineModel();
                Integer  orderQtyAndPromoOrderQty =0;
                if(olm.OrderQty > 0 && olm.promoOrderQty > 0) { orderQtyAndPromoOrderQty = olm.OrderQty + olm.promoOrderQty;}
                ol.quantity = orderQtyAndPromoOrderQty > 0 ? orderQtyAndPromoOrderQty :  olm.OrderQty  > 0  ?  olm.OrderQty : olm.promoOrderQty > 0 ? olm.promoOrderQty : olm.FreeQty > 0 ? olm.FreeQty : olm.promoFreeQty > 0 ? olm.promoFreeQty : 0 ;
                ol.taxRate = olm.taxRate;
                ol.unitPrice = olm.UnitPrice;
                ol.materialNumber = olm.MaterialCode;
                ol.productName =  olm.ProductName == null ? '': olm.ProductName ;
                ol.promotionName = '';
                ol.Category = olm.Category == null ? '': olm.Category;
                orderLine.add(ol);
            }
            requestWrapper.orderlines = orderLine;
            System.debug('#requestWrapper.orderlines:'+requestWrapper.orderlines);

            //insert order line
            List<OrderLineItem__c> orderItems = new List<OrderLineItem__c>();
            for(OrderLineModel ol :  requestWrapper.orderlines){
                OrderLineItem__c orderItem = new OrderLineItem__c();
                orderItem.ProductPrice__c = ol.unitPrice;
                orderItem.Quantity__c = ol.quantity > 0  ?  ol.quantity : ol.FreeQty > 0 ? ol.FreeQty : ol.promoFreeQty > 0 ? ol.promoFreeQty : 0 ;
                orderItem.UnitTax__c = ol.unitTax;
                orderItem.GhdOrder__c =orderId;
                orderItem.Material__c = materialMap.get(ol.materialNumber)?.Id;
                orderItems.add(orderItem);
            }
            if(orderItems.size() > 0){
                orderLineSaveResult = Database.insert(orderItems);
                for(Database.SaveResult o: orderLineSaveResult){
                    orderIds.add(o.getId());
                }
            }
            //customer mandatory fields starts
            requestWrapper.poReference = orderWrapper?.poReference;
            requestWrapper.manualIntervention = false;
            requestWrapper.orderingCustomer.customerType = account.Type;
            requestWrapper.orderingCustomer.fullName = account.FirstName__c + ' '+ account.LastName__c;
            requestWrapper.orderingCustomer.telephoneNumber = account.Phone;
            requestWrapper.orderingCustomer.clientCustomerId = account.CustomerId__c;
            //Customer mandatory fields ends
            requestWrapper.orderingCustomer.addressLine1 = orderWrapper.BillingAddressStreet == null ? '': orderWrapper.BillingAddressStreet;
            requestWrapper.orderingCustomer.addressLine2 = '';
            requestWrapper.orderingCustomer.addressLine3 = '';
            requestWrapper.orderingCustomer.town = orderWrapper.BillingAddressCity;
            requestWrapper.orderingCustomer.county =  orderWrapper.billingAddressCounty == null ? '': orderWrapper.billingAddressCounty;
            requestWrapper.orderingCustomer.postcode =orderWrapper.billingAddressPostalCode;

            requestWrapper.orderingCustomer.countryCode = orderWrapper.billingAddressCountry;

            requestWrapper.orderingCustomer.emailAddress = account.Primary_Email__c;
            requestWrapper.orderingCustomer.nationalNumber = account.NationalNumber__c;
            requestWrapper.orderingCustomer.company = account.CommercialName__c;
            requestWrapper.orderingCustomer.etage = '';
            requestWrapper.orderingCustomer.codePorte = '';



            requestWrapper.deliveryCustomer.customerType = account.Type;
            requestWrapper.deliveryCustomer.fullName = account.FirstName__c + ' '+ account.LastName__c;
            requestWrapper.deliveryCustomer.telephoneNumber = account.Phone;
            requestWrapper.deliveryCustomer.clientCustomerId = account.CustomerId__c;

            requestWrapper.deliveryCustomer.addressLine1 = orderWrapper.ShippingAddressStreet;
            requestWrapper.deliveryCustomer.addressLine2 = '';
            requestWrapper.deliveryCustomer.addressLine3 = '';
            requestWrapper.deliveryCustomer.town = orderWrapper.ShippingAddressCity;
            requestWrapper.deliveryCustomer.county = orderWrapper.ShippingAddressCounty == null ? '': orderWrapper.ShippingAddressCounty;
            requestWrapper.deliveryCustomer.postcode =orderWrapper.ShippingAddressPostalCode;
            requestWrapper.deliveryCustomer.countryCode = orderWrapper.ShippingAddressCountry;
            requestWrapper.deliveryCustomer.emailAddress = account.Primary_Email__c;
            requestWrapper.deliveryCustomer.nationalNumber = account.NationalNumber__c;
            requestWrapper.deliveryCustomer.company = account.CommercialName__c;
            requestWrapper.deliveryCustomer.etage = '';
            requestWrapper.deliveryCustomer.codePorte = '';

            requestWrapper.deliveryInfo.deliveryDate = String.valueOf(Date.today());
            requestWrapper.deliveryInfo.deliveryMethod = 'Standard';
            requestWrapper.deliveryInfo.deliveryInstructions = '';

            //Origin required field start here
            requestWrapper.origin.originApplication =origin.Application__c;
            requestWrapper.origin.originIdentifier = origin.Identifier__c;
            requestWrapper.origin.countryCode = origin.CountryCode__c;
            requestWrapper.origin.eCommStore = origin.eCommStore__c;
            orderIds.add(orderId);
            try{
                if((requestWrapper.orderType == 'A' &&  requestWrapper.approveStatus == 'Approved') || requestWrapper.orderType != 'A'){
                    System.debug('#requestWrapper:'+requestWrapper);
                    System.enqueueJob(new OrderCalloutQueueable(requestWrapper,orderIds),2);
                }
            }catch (System.CalloutException calloutException){
                System.debug('#OrderCalloutQueueable - CalloutException:'+ calloutException.getMessage());
            }
            System.debug('#4');
            return orderId;
        }
        catch (DmlException dmlException){
            System.debug('dmlException:'+dmlException);
            for(Database.SaveResult sr : oliSaveResult){
                if(!sr.isSuccess()){
                    for(Database.Error err : sr.getErrors()){
                        System.debug(err.getMessage() + ' -> ' + err.getFields());
                    }
                }
            }
            if(!Test.isRunningTest()){
                Database.rollback(savepoint);
            }
            throw new AuraHandledException(dmlException.getMessage());
        }
        catch (Exception ex){
            System.debug('#Error:' + ex.getMessage() + ' -> '+ ex.getStackTraceString());
            throw ex;
           // throw new AuraHandledException(ex.getMessage() );
        }
    }

    public static String createJsonFromOrder(GhdOrder__c order, List<OrderLineItem__c> lines){
System.debug('#createJsonFromOrder lines:'+lines);
        Object[] products = lines.size() > 0 ? new Object[lines.size()-1] : new Object[lines.size()];
        String result;
        try {
            for (OrderLineItem__c line : lines) {
                if (line.GhdOrder__c == order.Id) {
                    System.debug(line.Id);
                    Map<String, Object> product = new Map<String, Object>{
                            'Category' => line?.T_T_Product_Type__c,
                            'Id' => line.Id,
                            'MaterialCode' => line.Material__r?.MaterialCode__c,
                            'ProductName' => line?.T_T_Product_Name__c,
                            'UnitPrice' => line?.TotalPrice__c,
                            'OrderQty' => line?.Quantity__c
                    };

                    products.add(product);
                }
            }
            result = JSON.serialize(
                    new Map<String, Object>{
                            'billingAddressStreet' => order?.BillingAddress__Street__s,
                            'billingAddressCity' => order?.BillingAddress__City__s,
                            'billingAddressCounty' => order?.BillingAddress__StateCode__s,
                            'billingAddressCountry' => order?.BillingAddress__CountryCode__s,
                            'billingAddressPostalCode' => order?.BillingAddress__PostalCode__s,
                            'ShippingAddressStreet' => order?.ShippingAddress__Street__s,
                            'ShippingAddressCity' => order?.ShippingAddress__City__s,
                            'ShippingAddressCounty' => order?.ShippingAddress__StateCode__s,
                            'ShippingAddressCountry' => order?.ShippingAddress__CountryCode__s,
                            'ShippingAddressPostalCode' => order?.ShippingAddress__PostalCode__s,
                            'totalInclVat' => order?.TotalAmountIncTax__c,
                            'totalExclVat' => order?.TotalAmount__c,
                            'poReference' => order?.POReference__c,
                            'estimatedDeliveryDate' => System.TODAY() + 3,
                            'products' => products,
                            'accountId' => order?.Account__c,
                            'deliveryBlock' => order?.DeliveryBlock__c,
                            'orderType' => order?.OrderType__c,
                            'Id' => order?.Id

                    }
            );

        } catch(Exception ex){
            System.debug('#OrderService - createJsonFromOrder ' + ex.getMessage() + ' -> ' + ex.getStackTraceString());
        }
        return result;
    }
}