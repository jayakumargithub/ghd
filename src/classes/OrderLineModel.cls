/**
 * Created by Jayakumar Mogenahall on 15/03/2023.
 */

public with sharing class OrderLineModel {

        public Integer deliveryLine;
        public Integer OrderQty;
        public Integer quantity;
        public Double unitPrice;
        public String orderUom;
        public String productName;
        public String productCode;
        public Double unitTax;
        public Double taxRate;
        public String MaterialCode;
        public String materialNumber;
        public String Id;
        public String Category;
        public Integer promoFreeQty;
        public Integer promoOrderQty;
        public Integer FreeQty = 0;
        public String promotionName;
        public String promotionNameDescription;
        public String itemCategory;
        public String stockLocation;
        public String laserText;
        public String virtualWarehouse;
        public String promotionType;
        public String scrap;


}