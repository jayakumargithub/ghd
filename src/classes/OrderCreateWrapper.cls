/**
 * Created by Jayakumar Mogenahall on 15/03/2023.
 */

public class OrderCreateWrapper {
    OrderCreateWrapper(){
        products = new List<OrderLineModel>();
        freeProducts = new List<FreeProducts>();
    }
    public Decimal totalInclVat;
    public Decimal totalExclVat;
    public Date estimatedDeliveryDate;
    public List<OrderLineModel> products;
    public String poReference;
    public String accountId;
    public String laserText;
    public String orderType;
    public Boolean deliveryBlock;
    public List<FreeProducts> freeProducts;
    public String  BillingAddressStreet;
    public String  billingAddressCounty;
    public String  billingAddressCountry;
    public String  billingAddressPostalCode;
    public String  BillingAddressCity;
    public String  ShippingAddressStreet;
    public String  ShippingAddressCity;
    public String  ShippingAddressCounty;
    public String  ShippingAddressCountry;
    public String  ShippingAddressPostalCode;
    public String Id;
  

    public static OrderCreateWrapper parse(String json){
        system.debug('#json:'+ json);
        return (OrderCreateWrapper)System.JSON.deserialize(json, OrderCreateWrapper.class);
    }

    public class FreeProducts{
        public String Id;
        public String ProductName;
        public String MaterialCode;
        public String OrderQty;
        public String promoFreeQty;

    }
}