/**
 * Created by Jayakumar Mogenahall on 14/02/2023.
 */

import { LightningElement,wire,track,api} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { RefreshEvent } from 'lightning/refresh';
import {loadStyle} from 'lightning/platformResourceLoader';
import dataTableStyles from '@salesforce/resourceUrl/dataTableStyles';
import getDraftViewForCustomer from '@salesforce/apex/OrderDraftService.getDraftViewForCustomer';
import createOrder from '@salesforce/apex/OrderService.createOrder';
import getMaterialsForAccount from '@salesforce/apex/CustomerProductService.getMaterialsForAccount';
import getAccount from '@salesforce/apex/AccountOrderQuery.createOrder';
import createDaft from '@salesforce/apex/CustomerProductService.create';
import {subscribe,publish,unsubscribe,APPLICATION_SCOPE,MessageContext} from 'lightning/messageService';
import promotionMessage from "@salesforce/messageChannel/promotionMessage__c";
import { NavigationMixin } from 'lightning/navigation';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import BillingAddress_FIELD from "@salesforce/schema/Account.BillingAddress";
import ShippingAddress_FIELD from "@salesforce/schema/Account.ShippingAddress";
import INDUSTRY_FIELD from "@salesforce/schema/Account.Industry";
import USER_LOCAL_CURRENCY from '@salesforce/i18n/currency';


const fields = [BillingAddress_FIELD, ShippingAddress_FIELD];

const columns = [
    { label: 'Product Name', fieldName: 'ProductName', editable: false },
    { label: 'Category', fieldName: 'Category', type: 'string', editable: false, hideDefaultActions:"true" },
    { label: 'Unit Price', fieldName: 'UnitPrice', type: 'currency', editable: false, hideDefaultActions:"true", typeAttributes:{ currencyCode: "GBP"}},
    { label: 'Order Qty', fieldName: 'OrderQty', type: 'number', editable: true, hideDefaultActions:"true" },
    { label: 'Free Qty', fieldName: 'FreeQty', type: 'number', editable: true, hideDefaultActions:"true" },
    { label: 'Promo Order Qty', fieldName: 'promoOrderQty', type: 'number', editable: true, hideDefaultActions:"true" },
    { label: 'Promo Free Qty', fieldName: 'promoFreeQty', type: 'number', editable: false, hideDefaultActions:"true",cellAttributes: { alignment: 'left' } },
];

const previewColumns = [
    { label: 'Product Name', fieldName: 'ProductName', editable: false },
       { label: 'Category', fieldName: 'Category', type: 'string', editable: false, hideDefaultActions:"true" },
    { label: 'Unit Price', fieldName: 'UnitPrice', type: 'currency', editable: false, hideDefaultActions:"true", typeAttributes:{currencyCode: 'GBP'}, cellAttributes:{iconName:{fieldName:'iconName'}, iconClass:"slds-current-color",iconPosition:'right'}},
    { label: 'Order Qty', fieldName: 'OrderQty', type: 'number', editable: false, hideDefaultActions:"true" },
    { label: 'Free Qty', fieldName: 'FreeQty', type: 'number', editable: false, hideDefaultActions:"true" },
    { label: 'Promo Order Qty', fieldName: 'promoOrderQty', type: 'number', editable: false, hideDefaultActions:"true" },
    { label: 'Promo Free Qty', fieldName: 'promoFreeQty', type: 'number', editable: false, hideDefaultActions:"true",cellAttributes: { alignment: 'left' } },
];

const draftColumns = [
	{ label: 'Draft Name', fieldName: 'DraftRecordName', editable: false,hideDefaultActions:"true"  },
	{label: 'Description', fieldName:'Description', editable: false,hideDefaultActions:"true"  },
	{ label: 'Total Value', fieldName: 'TotalAmount', type: 'currency', editable: false,hideDefaultActions:"true",  typeAttributes:{currencyCode: 'GBP'}},
	{label: 'Last Modified By', fieldName: 'LastModifiedBy', hideDefaultActions:"true", editable:false},
	{label: 'Last Modified Date', fieldName: 'LastModifiedDate',hideDefaultActions:"true",  editable:false}

];

export default class orderEditor extends NavigationMixin(LightningElement) {
	@api recordId;
	@track isShowModal = false;
	@track productNav = null;
	draftValues =[];
	data = [];
	masterData = [];
	columns = columns;
	previewColumns = previewColumns
	draftColumns = draftColumns;
	rowOffset = 0;
	selectedFamily = 'All';
	selectedOrderType = '';
	searchToken = '';
	family = '';
	wiredDataResult;
	@track totalAmount = 0.00;
	@track totalAmount2 = 0.00;
	@api firstName = 'John Doe';
	selectedRowData;
	totalOrderQty=[];
	selectedOrders =[]
	allSelectedOrderQty = [];
	selectedProducts = [];
	errors;
	isShowViewDraftModal = false;
	staticResourceLoaded = false;
	preSelectedRows ;// 'a0L2z000000p9o0EAA'
	selectedDraftRowDescription;
	draftFieldValues = [];
	viewDraftScreenData = [];
	draftName;
	isShowDraftModelName = false;
	selectedRows = [];
	draftDescription;
	name;
	draftItemSelectedCount = 0;
	dataSpinner = true;
	start = true;
	orderPreview = false;
	canOrderPreview = false;
	totalInclVat = 0.00;
	totalExclVat = 0.00;
	selectedDate = '';
	selectedReference = '';
	selectedLaserText = '';
	showPersonalisation = false;
	showReplacement = false;
	showFree = false;
	canShowOrderConsole = true;
	canShowPromotion = false;
	categories = [];
	//newMasterData = [];
	promoOrderQty = 0;
	freeQuantity = 0;
	productType= '';
	promotionExists = false;
	selectedPromoList = []
	qtyLeft = 0;
	selPromotionCopy = [];
	isPromotionOrderValid = false;
	totalPromoOrderQty = 0;
	message = {};
	previewProducts = [];
	orderQtyCount = 0;
	showErrorTab = false;
	errorMessage;
	messageType;
	testMessage=[];
	promotionToEdit=[];
	isOrderValid = true;
	@track disableSaveButton = true;
	disableSaveDraftButton = true;
	disableViewDraftButton = true;
	masterDraftValues=[];
	freeProducts = [];
	reference;
	deliveryDate;
	finalDraft = []
	orderQtyObj = []
	promoOrderCounts = []
	subscription = null;
	@api selectedPromotion = [];
	promotionOrderCount;
	newObj = {};
	qtySum = []
	testShow = false;
	materialWithCategory = []
	isDeliveryBlock = false;
	orderDraftValuesFromPromotion = []
	freeProductWrapper = []
	billingAddressStreet = '';
	billingAddressCity ='';
	billingAddressCounty ='';
	billingAddressCountry ='';
	billingAddressPostalCode ='';
	ShippingAddressStreet ='';
	ShippingAddressCity ='';
	ShippingAddressCounty ='';
	ShippingAddressCountry ='';
	ShippingAddressPostalCode ='';
	@track account;
    @track error;
    mainMasterData = [];
    selectedOrderItems = []
    discountPromotion = [];
    //discountPromotionArray = []
    discountedAmount = 0;
    totalWithoutDiscount;
    totalAfterDiscount;
    @api discountExists = false;
    disableAddPromotionButton = false

	@wire(MessageContext)
	messageContext;

	get categoryOptions() {
		return this.categories.map(item=> { return{label:item, value:item }} );
    }

    subscribeToMessageChannel() {
            if (!this.subscription) {
                this.subscription = subscribe(
                    this.messageContext,
                    promotionMessage,
                    (message) => this.handleSubscribe(message) ,
                    { scope: APPLICATION_SCOPE }
                );
            }
        }

	handleSubscribe(message){
	    debugger
	     console.log('###message:'+JSON.stringify(message))
        		this.canShowPromotion = false;

        		if(JSON.parse(message.selectedPromotion).length > 0 ){
        		    this.selectedPromotion = JSON.stringify(JSON.parse(message.selectedPromotion));
        		    this.promotionToEdit =  JSON.stringify(JSON.parse(message.selectedPromotion));
        		    this.promotionExists = true;

        		    console.log('### JSON.parse(JSON.stringify(this.selectedPromotion)):' +JSON.parse(JSON.stringify(this.selectedPromotion)))
        		    let promos =  JSON.parse(message.selectedPromotion)
        		    let myFilter = promos.filter(x => x.Discount !== undefined);
        		     this.discountPromotion = JSON.parse(JSON.stringify(myFilter))[0];
          		}else{
          		    let selOrder = this.selectedOrderItems.find(x => x.promoOrderQty !== undefined)
          		    let selOrderIdx = this.selectedOrderItems.findIndex(x => x.promoOrderQty !== undefined)
          		    if(selOrder !== undefined){
          		        if(selOrderIdx === -1){
          		            this.selectedOrderItems.splice(selOrderIdx,1)
                    	}else{
                    	    delete this.selectedOrderItems[selOrderIdx].promoOrderQty
                     	}
               		}
          		    this.discountedAmount = undefined;
          		    this.discountPromotion = undefined;
        			this.promotionExists = false;
        			this.selPromotionCopy = [];
        			this.promotionToEdit= [];
        			this.selectedPromotion = [];
            	}

        		try{
        		    if(this.promotionExists && this.selectedPromotion.length > 0){
        				 //copy the promotion array
        				this.selPromotionCopy = JSON.parse(this.selectedPromotion.slice());
        				this.freeProductWrapper = this.selPromotionCopy.map(item => item.FreeProductWrapper).flat()
        				if(this.selectedPromotion.length === 0) {
        					this.selPromotionCopy = [];
        					this.canShowOrderConsole = true;
        					return;
        				}
						//removing any left promoFreeQty from previous selection
						var tempData = this.data
						console.log('#tempData:'+JSON.stringify(tempData))
        				tempData.forEach(x => { x.promoFreeQty = "" })
        				this.data = [...tempData]
        				this.masterData = [...tempData]
        				console.log('#this.data:'+JSON.stringify(this.data))
        				//Count total Promotion Order quantity
        				this.totalPromoOrderQty =   this.selPromotionCopy.reduce((a,b) => a + b.OrderQuantity,0);
        				 //set the promotion / free quantity to main data set

        				this.freeProductWrapper.forEach( promo => {
						const idx = this.data.findIndex(item => item.MaterialCode === promo.materialCode)
							if(this.data[idx] !== undefined){
								this.data[idx].promoFreeQty = promo.FreeQuantity
								this.masterData[idx].promoFreeQty = promo.FreeQuantity
								this.mainMasterData[idx].promoFreeQty = promo.FreeQuantity
							}
						promo.qtyLeft = 0;
						promo.valid = '';
        				 })
        				 this.selPromotionCopy.forEach( promo => {
							promo.qtyLeft = 0;
							 })
        			}

        			 //in case user cancelled from Preview order screen then we need to retain all values
					if(message.orderDraftValues.length > 0){
					    //if orderQty and promoOrderQty exists remove only promoOrderQty
					    if((!Array.isArray(this.selectedPromotion) || this.selectedPromotion.length === 0)  && message.orderDraftValues !== undefined){
					    //deep clone the orderDraftValues so we can remove
						let d = JSON.parse(JSON.stringify(message.orderDraftValues))
						var a =[];
						d.forEach(x => {
						    let k = Object.keys(x)
						    if(k.includes('promoOrderQty') && k.length === 2){ //if only promoOrderQty exists in the array delete the element
						          a = d.splice(1,1)
								 }else{ // if OrderQty also exists delete only promoOrderQty property
								   delete d[0].promoOrderQty
								   a = d;
								 }
      					})

						//remove applied promoFreeQty
						var promoFreeQtyWithValue = this.data.filter(x => x.promoFreeQty !== undefined)
						if(promoFreeQtyWithValue.length > 0 && this.selPromotionCopy.length === 0){
						    //let workingData =  this.mainMasterData;//JSON.parse(JSON.stringify(this.data))
						   var idx = this.mainMasterData.findIndex(x => x.promoFreeQty !== undefined)

							//remove promoFreeQty
						   this.mainMasterData.map(x => { if(x.promoFreeQty !== "") { x.promoFreeQty = ""}})
						   var xTotal = 0;
						   var xCategoryWithQtyArray = []
						   a.forEach(b => {
						       console.log(b.Id)
						        var dataFound =  this.mainMasterData.find(y => y.Id === b.Id)
						          let xFound = xCategoryWithQtyArray.findIndex(x => x.Id == b.Id)
						           if(xFound === -1 && dataFound !== undefined){
									 let xCategoryWithQty = {}
						            xCategoryWithQty.Id = dataFound.Id
									xCategoryWithQty.Category =  dataFound.Category
									xCategoryWithQty.qtySum = b.OrderQty
									xCategoryWithQty.UnitPrice = dataFound.UnitPrice
									xCategoryWithQtyArray.push(xCategoryWithQty)
								 }
						       })
						       var xAmounts = []
						        xCategoryWithQtyArray.forEach(
						           x => { xAmounts.push(x.UnitPrice * x.qtySum)} )
								   if(this.selectedOrderType != 'Free Order'){
             				 this.totalAmount  = parseFloat(xAmounts.reduce((a,b) => a + parseInt(b),0)).toFixed(2)
								   }
							 this.totalAmount2  = parseFloat(xAmounts.reduce((a,b) => a + parseInt(b),0)).toFixed(2)
						}
						setTimeout(() => {
						    if(a !== undefined ||a.length > 0){
						        this.template.querySelector("[data-id='mainDatatable']").draftValues =  a;
         					 }else{
         					      this.template.querySelector("[data-id='mainDatatable']").draftValues =  null
              			 }

						},10);
						this.start = true;
						this.canShowOrderConsole = true;
						this.canShowPromotion = false;
        				}
        			}
        		}
        		catch(error){ alert(JSON.stringify('Error2:' + error))}
        		 this.canShowOrderConsole = true;
	}

	get objectProperties() {
		return Object.entries(this.freeProductWrapper).map(([key,value])=>({ key, value }));
	  }

	clearMainDatatable(){
	    this.selPromotionCopy.forEach( promo => {
					const idx = this.masterData.findIndex(item => item.MaterialCode === promo.MaterialCode)
					if(this.data[idx] !== undefined){
						this.data[idx].promoFreeQty = null
						this.masterData[idx].promoFreeQty = null
					}
					 promo.qtyLeft = 0;
	 })
	 this.data = this.masterData.slice()
 	}

	unsubscribeToMessageChannel() {
		if(this.subscription !== null){
			unsubscribe(this.subscription);
		}
		this.subscription = null;
	}

	disconnectedCallback() {
			this.unsubscribeToMessageChannel();
	}

	get optionsType() {
        return [
            {label:'Standard Order',value:'B'},
            {label: 'Replacement Order', value:'R'},
            {label: 'Personalisation Order', value:'P'},
            {label: 'Free Order', value:'Free Order'}
        ];
    }

	@wire(getAccount, { recordId: '$recordId' })

    wiredAccount({ error, data }) {
        if (data) {

            this.account = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.account = undefined;
        }
    }

	@wire(getMaterialsForAccount, {accountId:'$recordId',searchToken:'$searchToken',draftName:''})

	wiredResult({error,data}){
	this.wiredDataResult = data;
console.log('wired triggered')
	if(data){
	    console.log('####data:'+JSON.stringify(data))
//	    if(data.wrapperList.length === 0){
//	        this.showWarningToast('Materials or PriceList not found for the customer')
//	        return;
// 		}
	    debugger
			this.masterData = data.wrapperList
			this.dataSpinner = false;
			if(this.mainMasterData === undefined || this.mainMasterData.length === 0){
			    this.mainMasterData = data.wrapperList.map(item=> { return{...item, OrderQty: "", promoOrderQty:"",promoFreeQty:"", FreeQty:"" }} );;
   }

			//used to fill the dropdown list
			this.categories = data.categories;

			this.data = data.wrapperList.map(item=> { return{...item, OrderQty: "", promoOrderQty:"",promoFreeQty:"", FreeQty:"" }} );
			//this.masterData = this.masterData.map(item=> { return{...item, OrderQty: "",promoOrderQty:"",promoFreeQty:"", FreeQty:""}} );
			this.mainMasterData = this.masterData.map(item=> { return{...item, OrderQty: "",promoOrderQty:"",promoFreeQty:"", FreeQty:"" }} );
			var dataColumns = [...this.columns]
			var idx = dataColumns.findIndex(x => x.fieldName === 'UnitPrice')
			if(idx !== -1){
			    if(this.account.BillingAddress.country === "DE"){
			        dataColumns[idx].typeAttributes.currencyCode = 'EUR'
      			 }else if(this.account.BillingAddress.country === "GB"){
      			     dataColumns[idx].typeAttributes.currencyCode = 'GBP'
        		 }else if(this.account.BillingAddress.country === "AU"){
					 dataColumns[idx].typeAttributes.currencyCode = 'AUD'
				 }
				 else if(this.account.BillingAddress.country === "NZ"){
					 dataColumns[idx].typeAttributes.currencyCode = 'NZD'
				 }
  			}
			 this.columns = [...dataColumns]
		}
	else if(error){
 	    alert(JSON.stringify(error))
// 	  if(data === undefined || data === null){
// 	       this.showErrorToast(error.body.message)
//          	    this.dataSpinner = false;
//          	    return
//   	  }

	}
		if(data !== undefined && data === null){
			this.dataSpinner = false;
			this.showWarningToast('No materiels found for the customer');
			return;
		}

	}

	connectedCallback() {
	    const  icons =   this.template.querySelectorAll('lightning-icon[data-key="left"]')
	    loadStyle(this, dataTableStyles);
	    this.subscribeToMessageChannel();
	}

	handleProductCategoryChange(event){
		this.selectedFamily = event.detail.value;
		this.searchToken = '';
		this.template.querySelector("[data-id='searchField']").value = '';
		this.filterMaterials();
	}

	handleOrderTypeChange(event){
		let assignTotal2;
		this.selectedOrderType = event.detail.value;
		if(event.target.value === 'Free Order'){
			assignTotal2 = true;
			this.selPromotionCopy = []
			this.template.querySelector("[data-id='mainDatatable']").draftValues = [];
			this.totalValAmount = 0.0
			this.selectedOrderItems = []
			this.promotionExists = false
			this.disableAddPromotionButton = true;
		}else{
		    this.disableAddPromotionButton = false;
		}
		if(this.selectedOrderType =='Free Order'){
			this.totalAmount = 0;
		} else if(assignTotal2 == true){
			this.totalAmount = this.totalAmount2;
		}
	}

	handleSearch(event){
		this.searchToken = event.target.value;
		this.filterMaterials();
	}

	processFreeProducts(draftValue){
	    var dRow = this.mainMasterData.find(x => x.Id === draftValue[0].Id)
		debugger;
		if(draftValue[0].FreeQty === undefined){ return;}
		let foundItem = this.mainMasterData.find(x => x.Id == draftValue[0].Id)
		this.selPromotionCopy.forEach(x => {
        		let categories = this.materialWithCategory.filter(y => y.Category === x.Category)
        		let categoryCount = categories.reduce((a,b) => a + b,0)
		})

		let freePrdCategories =  this.selPromotionCopy.filter(item => (item.PromoCategories !== "") && (item.PromoCategories !== null)).map(item => item.PromoCategories).flat();
		var storedDraftValues = this.template.querySelector("[data-id='mainDatatable']").draftValues
		var promoCategoriesExists = this.selPromotionCopy.some(x => x.PromoCategories !== undefined)
		debugger

		 if (freePrdCategories[0] !== undefined ){
		     var dataRow = this.mainMasterData.find(x => x.Id === draftValue[0].Id)
		     var freeProducts = this.selPromotionCopy.map(x => x.FreeProductWrapper).flat()
		     freeProducts.find(x => x.Category === dataRow.Category)
		     var splitItems;
		   	if(freePrdCategories[0].split(',') !== undefined){
		       splitItems = freePrdCategories[0].split(',')
		       if(!splitItems.includes(foundItem.Category)){
		           let idx = storedDraftValues.findIndex(x => x.Id === draftValue[0].Id)
		           delete storedDraftValues.splice(idx,1)
		            this.showWarningToast('Wrong category for the promotion.')
		            if(storedDraftValues === null || storedDraftValues === undefined){
                    		    this.template.querySelector("[data-id='mainDatatable']").draftValues = null
                      		}else{
                      		    this.template.querySelector("[data-id='mainDatatable']").draftValues = storedDraftValues
                        }
					 return;
        		 }else{
        		    //find categories free quantity

        		    var freeProducts = this.selPromotionCopy.map(x => x.FreeProductWrapper).flat()
        		    //get the user entered quantity
        		    var orderedQty = storedDraftValues.filter(x => x.FreeQty !== undefined)
        		    console.log('#### freeProducts:' + JSON.stringify(freeProducts))
        		    console.log('#### orderedQty:' + JSON.stringify(orderedQty))
           }
    		 }
   		}
   		else{
			if(storedDraftValues === null || storedDraftValues === undefined){
				this.template.querySelector("[data-id='mainDatatable']").draftValues = null
			}else{
				this.template.querySelector("[data-id='mainDatatable']").draftValues = storedDraftValues
			}
			 return;
     }
	}

 	buildProductCategory(draftValue){
 	    debugger
 	    //this.materialWithCategory
 	    if(draftValue[0].OrderQty !== ""){
			let foundItem = this.masterData.find(x => x.Id === draftValue[0].Id)
			let foundRecord = this.materialWithCategory.find(x => x.Id === foundItem.Id)
			let foundRecordIdx = this.materialWithCategory.findIndex(x => x.Id === foundItem.Id)
			if(foundRecord === undefined){
				this.materialWithCategory.push({Id: foundItem.Id, Category: foundItem.Category, orderCount: draftValue[0].OrderQty})
			} else{
				this.materialWithCategory[foundRecordIdx].orderCount = draftValue[0].OrderQty
			}
     	 }
     	 console.log('#this.materialWithCategory:' + JSON.stringify(this.materialWithCategory))
  	}

	handleOnCellChange(event){
debugger
		const draftValue = event.detail.draftValues;
		 var selectedOrders = this.template.querySelector("[data-id='mainDatatable']").draftValues;
		 console.log('##selectedOrders:'+JSON.stringify(selectedOrders))
		 if(this.masterDraftValues.find(x => x.Id === draftValue[0].Id) === undefined){
		     	 this.masterDraftValues.push(draftValue[0])
  		 }else{
  		     let idx = this.masterDraftValues.findIndex(x => x.Id === draftValue[0].Id)
  		     console.log('#idx:'+idx)
  		     if(draftValue[0].promoOrderQty !== undefined){
  		          this.masterDraftValues[idx].promoOrderQty = draftValue[0].promoOrderQty
        	 }
        	 if(draftValue[0].OrderQty !== undefined){
				  this.masterDraftValues[idx].OrderQty = draftValue[0].OrderQty
			 }
			 if(draftValue[0].FreeQty !== undefined){
				  this.masterDraftValues[idx].FreeQty = draftValue[0].FreeQty
			 }
  		 }
  		 console.log('#this.masterDraftValues:'+JSON.stringify(this.masterDraftValues))
		this.buildProductCategory(draftValue)
		 this.removeEmptyCellValue(draftValue)
		this.calculateTotalAmount(draftValue)
		this.processFreeProducts(draftValue)
		this.setOrderStatus()
		this.displaySelectedOrderLine();
		if(this.selectedOrderType === 'Free Order'){
		    this.disableSaveButton = false;
 		 }
	}

	displaySelectedOrderLine(){
	    debugger
	    this.selectedOrderItems = []
	    var selectedOrders = this.template.querySelector("[data-id='mainDatatable']").draftValues;
 		console.log('#selectedOrders:'+JSON.stringify(selectedOrders))
	    selectedOrders.forEach(x => {
  				var displayItem = {}
			    var foundRec = this.selectedOrderItems.findIndex(k => k.Id === x.Id);
			    if(foundRec === -1){
			        var dataRow = this.mainMasterData.find(k => k.Id === x.Id)
					console.log('dataRow:'+JSON.stringify(dataRow))
					displayItem.ProductName = dataRow.ProductName
					if(x.OrderQty !== undefined){  displayItem.OrderQty = x.OrderQty }
					if(x.promoOrderQty !== undefined){  displayItem.promoOrderQty = x.promoOrderQty }
					if(x.FreeQty !== undefined) { displayItem.FreeQty = x.FreeQty}
					displayItem.Id = dataRow.Id
					this.selectedOrderItems.push(displayItem)
       			}
		})

    	 console.log('#this.selectedOrderItems:'+JSON.stringify(this.selectedOrderItems))

 	}

	countPromoQty(draftValue){
		if(this.selectedPromotion.length === 0){
			return;
		}
		var masterRow = this.data.find(masterData => masterData.Id === draftValue[0].Id)
		var draftValueItemValues = Object.values(draftValue[0])
		var draftValueItemKeys = Object.keys(draftValue[0])


		if(draftValueItemKeys.includes('promoOrderQty') !== false){
			var foundItem = this.orderQtyObj.find(x => x.Id === draftValue[0].Id);
			var foundItemIndex = this.orderQtyObj.findIndex(x => x.Id === draftValue[0].Id);
			if(foundItem){
				this.orderQtyObj[foundItemIndex].promoOrderQty = draftValue[0].promoOrderQty
			}else{
				this.orderQtyObj.push({Category: masterRow.Category, promoOrderQty: draftValue[0].promoOrderQty, Id:draftValue[0].Id})
			}
		}

		if(this.orderQtyObj.length > -1){
			var categories = [...new Set(this.orderQtyObj.map(x => x.Category))]
			categories.forEach(cat => {
				var filteredRows = this.orderQtyObj.filter(x => x.Category === cat && x.promoOrderQty !== "")
				var xx = filteredRows.reduce((a,b) => a + parseInt(b.promoOrderQty),0);
				var foundItem = this.promoOrderCounts.find(x => x.Category === masterRow.Category)
				var foundItemIndex = this.promoOrderCounts.findIndex(x => x.Category === masterRow.Category)
				if(foundItem){
					this.promoOrderCounts[foundItemIndex].Count = xx
				}
				else{
					var foundItem1 = this.promoOrderCounts.find(x => x.Category === cat)
					if(!foundItem1){
						this.promoOrderCounts.push({Category :cat , Count:xx })
					}
				}
			})
		}

	this.selPromotionCopy = testPromo.slice()
	}

	isValidOrder(){
	    var isValid = true
		this.masterDraftValues = this.template.querySelector("[data-id='mainDatatable']").draftValues
		console.log('#masterDraftValues:'+JSON.stringify(this.masterDraftValues))
		var promotionError = []
		var draftDetails =[]

console.log('#!# A ')
		this.selPromotionCopy.forEach(promo => {
		    console.log('#!# B ')
		    console.log('#!promo:'+JSON.stringify(promo))
			this.masterDraftValues.forEach( draft => {
			    console.log('#!# C ')
			    console.log('#!draft:'+JSON.stringify(draft))
				var draftDetail = {}
				var draftData = this.mainMasterData.find(x => x.Id === draft.Id)
				console.log('#!draftData:'+JSON.stringify(draftData))
				if(draftData !== undefined){
				      console.log('#!# D ')
				    if(promo.hasOwnProperty('MaterialCode')){
				          console.log('#!# F ')
				        if(promo.MaterialCode === draftData.MaterialCode){
				              console.log('#!# G ')
							 draftDetail.Id = draft.Id;
							 draftDetail.Category = draftData.Category
							 draftDetail.ProductName = draftData.Name
							 draftDetail.MaterialCode = draftData.MaterialCode;
								draftDetail.promoOrderQty = draft.promoOrderQty
							 draftDetail.PromotionName = promo.PromotionName
							 draftDetails.push(draftDetail)
						 }
       				}
				    else if(promo.hasOwnProperty('PromoCategories')){
				          console.log('#!# H ')
						 if(promo.PromoCategories.includes(',') && !draftDetails.includes(promo.PromotionName)){
						       console.log('#!# I ')
						 	if(promo.PromoCategories.includes(draftData.Category)){
						 	      console.log('#!# J ')
						 	     draftDetail.Id = draft.Id;
								 draftDetail.Category = promo.PromoCategories
								 draftDetail.ProductName = draftData.Name
								 draftDetail.MaterialCode = draftData.MaterialCode;
								 draftDetail.promoOrderQty = draft.promoOrderQty
								 draftDetail.PromotionName = promo.PromotionName
								 draftDetails.push(draftDetail)
       						}
						 }else{
						       console.log('#!# K ')
						     if(promo.PromoCategories === draftData.Category){
									 draftDetail.Id = draft.Id;
									 draftDetail.Category = promo.PromoCategories
									 draftDetail.ProductName = draftData.Name
									 draftDetail.MaterialCode = draftData.MaterialCode;
									 draftDetail.promoOrderQty = draft.promoOrderQty
									 draftDetail.PromotionName = promo.PromotionName
									 draftDetails.push(draftDetail)
          					 }
     					 }
     			    }
     			      console.log('#!# L ')
				 }
			})
		})
		console.log('#!draftDetails:'+JSON.stringify(draftDetails))
		this.selPromotionCopy.forEach(promo => {
		    var foundPromos = draftDetails.filter(draft => draft.PromotionName === promo.PromotionName)
		    console.log('#!foundPromos:'+JSON.stringify(foundPromos))
		    if(foundPromos === undefined){
		         promotionError.push(promo.PromotionName)
    		}
    		console.log('#!foundPromos:'+JSON.stringify(foundPromos))
		    var count = foundPromos.reduce((a,b) => a + parseInt(b.promoOrderQty),0)
		     console.log('#!count:'+ JSON.stringify(count))
		    //do validation only if OrderQuantity is greater than 0
		    console.log('#!promo.OrderQuantity:'+promo.OrderQuantity)
		    if(promo.OrderQuantity > 0){
		        if(count < promo.OrderQuantity){
					promotionError.push(promo.PromotionName)
				}
      		}

 		 })
 		 if(promotionError.length > 0){
 		     this.showWarningToast("Please enter valid order quantity to claim Promotion Offer/s: \n" + promotionError.join(' , ') )
 		     isValid = false;
    	 }
    	return isValid
    }

	handleShippingSave(event){
		this.ShippingAddressStreet = event.target.street;
		this.ShippingAddressCity =event.target.city;
		this.ShippingAddressCounty =event.target.province;
		this.ShippingAddressCountry =event.target.country;
		this.ShippingAddressPostalCode =event.target.postalCode;
     }

	handleBillingSave(event){
		this.billingAddressStreet = event.target.street;
		this.billingAddressCity =event.target.city;
		this.billingAddressCounty =event.target.province;
		this.billingAddressCountry =event.target.country;
		this.billingAddressPostalCode =event.target.postalCode;
     }

	processPromoFreeOrder(promoFreeItem){
		    console.log('promoFreeItem'+JSON.stringify(promoFreeItem))
		    var materialCode;
		 this.selPromotionCopy.forEach(item => {
              item.FreeProductWrapper.forEach(wrapper => {
                if (wrapper.materialCode === promoFreeItem.MaterialCode) {
                  materialCode = item.MaterialCode;
                }
              });
            });
            var promoQty = this.selPromotionCopy.find(x => x.MaterialCode === materialCode)
            var matSF = this.data.find(x => x.MaterialCode === materialCode)
            console.log('#!mtSF')
            if(matSF !== undefined){
                var userQuantity = this.masterDraftValues.find(x => x.Id === matSF.Id)
				console.log('#userQuantity.promoOrderQty:'+userQuantity.promoOrderQty + '   > promoQty.OrderQuantity:'+promoQty.OrderQuantity)

				  var newFreeQty = parseInt(parseInt(userQuantity.promoOrderQty) / parseInt(promoQty.OrderQuantity))
				 console.log('#newFreeQty:'+newFreeQty)
				  return newFreeQty;
            }
            else {
               return promoFreeItem.promoFreeQty
			}
		}

	handleOrderSave(event){
	     debugger
		 let BillingAddress = this.account.BillingAddress;
		 let ShippingAddress = this.account.ShippingAddress;
		 this.billingAddressStreet = BillingAddress.street;
		 this.billingAddressCity =BillingAddress.city;
		 this.billingAddressCounty =BillingAddress.state;
		 this.billingAddressCountry =BillingAddress.country;
		 this.billingAddressPostalCode =BillingAddress.postalCode;
		 this.ShippingAddressStreet =ShippingAddress.street;
		 this.ShippingAddressCity =ShippingAddress.city;
		 this.ShippingAddressCounty =ShippingAddress.state;
		 this.ShippingAddressCountry =ShippingAddress.country;
		 this.ShippingAddressPostalCode =ShippingAddress.postalCode;


	var orderRecords = []
	var promotionRow = {}
	var promotionRows = []
	this.masterDraftValues = this.template.querySelector("[data-id='mainDatatable']").draftValues
		if(this.promotionExists){
		    debugger
	        if(!this.isValidOrder()) return;
	        console.log('! 1')
	  		this.masterDraftValues.forEach( x=> {
	  		     console.log('! 2')
	  		    var keys = Object.keys(x);
	  		    if(keys.includes("OrderQty") && !keys.includes("promoOrderQty") && !keys.includes("FreeQty")){
	  		         console.log('! 3')
	  		        var item2 = this.mainMasterData.find(y => y.Id === x.Id)
					if(item2 !== undefined){
					     console.log('! 4')
						let item3 = JSON.parse(JSON.stringify(item2))
						item3.OrderQty= x.OrderQty
						item3.promoFreeQty = ''
						orderRecords.push(item3)
					}
				}
				else if(keys.includes("OrderQty") && keys.includes("promoOrderQty") && keys.includes("FreeQty")){
				     console.log('! 5')
					var item2 = this.mainMasterData.find(y => y.Id === x.Id)
					if(item2 !== undefined){
					     console.log('! 6')
						let item3 = JSON.parse(JSON.stringify(item2))
						item3.OrderQty= x.OrderQty
						item3.promoOrderQty = x.promoOrderQty
						item3.promoFreeQty = x.promoFreeQty
						item3.FreeQty = x.FreeQty
						orderRecords.push(item3)
					}
				}
				else if(keys.includes("promoOrderQty") && !keys.includes("OrderQty") && !keys.includes("FreeQty")){
				     console.log('! 7')
					var item2 = this.mainMasterData.find(y => y.Id === x.Id)
					if(item2 !== undefined){
					     console.log('! 8')
						let item3 = JSON.parse(JSON.stringify(item2))
						item3.promoOrderQty= x.promoOrderQty;
						item3.promoFreeQty = '';
						orderRecords.push(item3)
					}
				}

				else if( keys.includes('promoOrderQty') && keys.includes('OrderQty') && !keys.includes("FreeQty")){
					 console.log('! 9 A')
					var row = this.mainMasterData.find(y => y.Id === x.Id)
					if(row !== undefined){
						 console.log('! 10 A')
						let newRow = JSON.parse(JSON.stringify(row))
						newRow.OrderQty= x.OrderQty
						newRow.promoOrderQty = x.promoOrderQty
						newRow.promoFreeQty = '';
						orderRecords.push(newRow)
					}
				}
				 else if( keys.includes('FreeQty') && keys.includes('OrderQty')){
					 console.log('! 9')
					var row = this.mainMasterData.find(y => y.Id === x.Id)
					if(row !== undefined){
						 console.log('! 10')
						let newRow = JSON.parse(JSON.stringify(row))
						newRow.OrderQty= x.OrderQty
						newRow.FreeQty = x.FreeQty
						newRow.promoFreeQty = '';
						orderRecords.push(newRow)
					}
				}
				else if( keys.includes('FreeQty')){
				     console.log('! 11')
					var row = this.mainMasterData.find(y => y.Id === x.Id)
					if(row !== undefined){
					     console.log('! 12')
						let newRow = JSON.parse(JSON.stringify(row))
						newRow.FreeQty = x.FreeQty
						orderRecords.push(newRow)
					}
				}
				else if( keys.includes('OrderQty')){
				     console.log('! 13')
				var row = this.mainMasterData.find(y => y.Id === x.Id)
				if(row !== undefined){
				     console.log('! 14')
					let newRow = JSON.parse(JSON.stringify(row))
					newRow.OrderQty = x.OrderQty
					orderRecords.push(newRow)
				}
			}
	  		})
	  		 console.log('! 15')
	  		this.selPromotionCopy.forEach(x => {
	  		    console.log('### x:'+JSON.stringify(x))
	  		    console.log('### this.mainMasterData:' +JSON.stringify(this.mainMasterData))
				var row = this.mainMasterData.find(y => y.MaterialCode === x.MaterialCode)
				console.log('### row:'+JSON.stringify(row))
				 if(row !== undefined &&  x.FreeQty !== undefined){ //we already added FreeQty in the above
					promotionRow.Category = x.Category,
					promotionRow.Id = x.Id,
					promotionRow.MaterialCode = x.MaterialCode,
					promotionRow.UnitPrice = row.UnitPrice,
					promotionRow.promoFreeQty = this.selectedOrderType !== 'Free Order' ? x.FreeQuantity : '',
					promotionRow.ProductName = row.ProductName,
					promotionRow.quantity = x.promoFreeQty,
					promotionRow.FreeQty = x.FreeQty
					promotionRow.isFree = true
					promotionRows.push(promotionRow)
				}
			})
		}
		else{
		    console.log('### AA')
			this.masterDraftValues.forEach( x=> {
			    console.log('### x.promoOrderQty:'+x.promoOrderQty + '   x.OrderQty:'+x.OrderQty)
				if(x.promoOrderQty !== undefined &&  x.OrderQty === undefined){
					var item = this.mainMasterData.find(y => y.Id === x.Id)
					console.log('### item2:' +JSON.stringify(item))
					if(item !== undefined){
						let item1 = JSON.parse(JSON.stringify(item))
						item1.promoOrderQty= x.promoOrderQty
						orderRecords.push(item1)
					}
				}

				else if((x.OrderQty !== undefined) && (!x.promoOrderQty === undefined)){
				    console.log('### x.OrderQty:'+x.OrderQty + '   x.promoOrderQty:'+x.promoOrderQty)
					var item2 = this.mainMasterData.find(y => y.Id === x.Id)
					console.log('### item2:' +JSON.stringify(item2))
					if(item2 !== undefined){
						let item3 = JSON.parse(JSON.stringify(item2))
						item3.OrderQty= x.OrderQty
						orderRecords.push(item3)
					}
				}else if((x.OrderQty !== undefined) && (x.FreeQty !== undefined)){

				    var item2 = this.mainMasterData.find(y => y.Id === x.Id)
					if(item2 !== undefined){
						let item3 = JSON.parse(JSON.stringify(item2))
						item3.FreeQty = x.FreeQty
						orderRecords.push(item3)
					}
					var item4 = this.mainMasterData.find(y => y.Id === x.Id)
					if(item4 !== undefined){
						let item3 = JSON.parse(JSON.stringify(item2))
						item3.OrderQty = x.OrderQty
						orderRecords.push(item3)
					}
 				   }

				else if(x.hasOwnProperty('FreeQty')){
					var item2 = this.mainMasterData.find(y => y.Id === x.Id)
					if(item2 !== undefined){
						let item3 = JSON.parse(JSON.stringify(item2))
						item3.FreeQty = x.FreeQty
						orderRecords.push(item3)
					}
				}
				else if(x.hasOwnProperty('OrderQty')){
					var item2 = this.mainMasterData.find(y => y.Id === x.Id)
					if(item2 !== undefined){
						let item3 = JSON.parse(JSON.stringify(item2))
						item3.OrderQty = x.OrderQty
						orderRecords.push(item3)
					}
				}
			})
	  	}
console.log('### orderRecords:'+JSON.stringify(orderRecords))
console.log('### promotionRows:'+JSON.stringify())
	  	 const inputFields = [...this.template.querySelectorAll('.validate')].reduce((validSoFar,inputField) => {
        								inputField.reportValidity();
        								return validSoFar && inputField.checkValidity();
        							},true);
          	if(!inputFields) return;
	  	this.mainMasterData.forEach(x =>{
	  	    if(x.promoFreeQty !== ""){
	  	        let item1 = JSON.parse(JSON.stringify(x))
	  	        item1.promoFreeQty = this.processPromoFreeOrder(x)//x.promoFreeQty
				orderRecords.push(item1)
        }
    } )
		debugger
		var finalOrderList = []
		if(promotionRows.length > 0  && orderRecords.length > 0){
		    finalOrderList = promotionRows.concat(orderRecords)
  		}else{
  		     finalOrderList = orderRecords.slice()
   		 }
   		 this.selectedProducts = finalOrderList.slice()
	  	this.previewProducts = finalOrderList.slice();
		this.masterDraftValues = this.template.querySelector("[data-id='mainDatatable']").draftValues
		this.totalInclVat = parseFloat(this.totalAmount * 1.20).toFixed(2);
		this.totalExclVat = parseFloat(this.totalAmount).toFixed(2);
		if(this.discountPromotion !== undefined){
		    if(this.discountPromotion.Discount > 0 ){
				this.totalAfterDiscount =  parseFloat(this.totalExclVat - this.discountedAmount ).toFixed(2)
				this.totalInclVat =   parseFloat(this.totalAfterDiscount * 1.20).toFixed(2);

			}else{
				this.discountPromotion = undefined;
			}
  		}

		if(this.selectedOrderType == 'P'){ this.showPersonalisation = true; }
		else if(this.selectedOrderType == 'R'){ this.showReplacement = true; }
		else if(this.selectedOrderType == 'B'){  }
		else if(this.selectedOrderType == 'Free Order'){ this.showFree = true; }
		 this.orderPreview = true;
		 this.start = false;
	 }

    handleConfirmOrder(event) {
		const inputFields = [...this.template.querySelectorAll('.validate')].reduce((validSoFar,inputField) => {
							inputField.reportValidity();
							return validSoFar && inputField.checkValidity();
					 },true);
					 if(!inputFields) return;

		var jsonPayload = {};

		var myProd = this.selectedProducts.slice();
		this.selectedProducts.forEach(item => {if(item.promoFreeQty === "") { delete item.promoFreeQty}})
		this.selectedProducts.forEach(item => {if(item.OrderQty === "") { delete item.OrderQty}})
		this.selectedProducts.forEach(item => {if(item.promoOrderQty === "") { delete item.promoOrderQty}})
		this.selectedProducts.forEach(item => {if(item.FreeQty === "") { delete item.FreeQty}})

		jsonPayload.billingAddressStreet = this.billingAddressStreet;
		jsonPayload.billingAddressCity = this.billingAddressCity;
		jsonPayload.billingAddressCounty = this.billingAddressCounty;
		jsonPayload.billingAddressCountry = this.billingAddressCountry;
		jsonPayload.billingAddressPostalCode = this.billingAddressPostalCode;
		debugger

		jsonPayload.ShippingAddressStreet = this.ShippingAddressStreet;
		jsonPayload.ShippingAddressCity = this.ShippingAddressCity;
		jsonPayload.ShippingAddressCounty = this.ShippingAddressCounty;
		jsonPayload.ShippingAddressCountry = this.ShippingAddressCountry;
		jsonPayload.ShippingAddressPostalCode = this.ShippingAddressPostalCode;
		jsonPayload.totalInclVat =  this.totalInclVat;
		jsonPayload.totalExclVat =  this.totalExclVat;
		jsonPayload.poReference = this.selectedReference === '' ? '-' :  this.selectedReference ;
		jsonPayload.estimatedDeliveryDate = this.selectedDate === ''? '1975-01-01':  this.selectedDate;
		jsonPayload.products = this.selectedProducts.slice();
		//jsonPayload.freeProducts = this.freeProducts.flat().slice();
		jsonPayload.accountId = this.recordId;
		jsonPayload.deliveryBlock = this.isDeliveryBlock;
		console.log('#!jsonPayload2:+'+JSON.stringify(jsonPayload))
		console.log('#!jsonPayload2:+'+jsonPayload)
		if(this.showPersonalisation){ jsonPayload.orderType = 'P' }else{ jsonPayload.orderType = this.selectedOrderType}
		if(this.selectedLaserText){	jsonPayload.laserText = this.selectedLaserText;}
		createOrder({'jsonInput' : JSON.stringify(jsonPayload)}).then(result => {
		  this.start = true;
		  this.orderPreview = false;
		  this.showPersonalisation = false;
		  this.showReplacement = false;
		  this.showFree = false;
		  this.selectedProducts = [];
		  this.totalAmount = 0.0
		  this.navigateToViewAccountPage(result);
		}).catch(error => {
		  this.showErrorToast(error.body.message);
		})
     	}

	filterMaterials(){

	    console.log('this.data:' + JSON.stringify(this.data))
	    console.log('this.mainMasterData' + JSON.stringify(this.mainMasterData))
	    this.masterDraftValues =  this.template.querySelector("[data-id='mainDatatable']").draftValues
	    console.log('this.masterDraftValues:'+JSON.stringify(this.masterDraftValues))

		if( this.selectedFamily !== 'All' && this.searchToken === ''){
			const filteredDataByCategory = this.masterData.filter(item =>item.Category === this.selectedFamily);
			this.data = filteredDataByCategory.map(item=> { return{...item}} ); // this will enforce to refresh the data in datatable

		}else if(this.selectedFamily === 'All' && this.searchToken === ''){
			this.data = this.masterData.map(item=> { return{...item}} );
		}else if(this.selectedFamily === 'All' && this.searchToken ){
			const filteredDataByCategory = this.masterData.filter(item => item.ProductName.toLowerCase().includes(this.searchToken.toLowerCase()) && item.Category === this.selectedFamily)
			this.data = filteredDataByCategory.map(item=> { return{...item}} );
		}

	    this.template.querySelector("[data-id='mainDatatable']").draftValues = this.masterDraftValues;

		this.masterData.forEach(item => {
		 var dataRow = this.data.find(x => x.Id === item.Id);
		 if(dataRow !== undefined && dataRow.promoFreeQty !== undefined){
		     item.promoFreeQty = dataRow.promoFreeQty
  		 	}
		 })

}

	handleClear(event){
	    this.template.querySelector("[data-id='mainDatatable']").draftValues = [];
	     this.template.querySelector("[data-id='searchField']").value = [];
		this.data = this.masterData.slice()
		this.totalAmount = 0.00;
		this.totalAmount2 = 0.00;
		this.showErrorTab = false;
		this.promotionExists = false;
		this.materialWithCategory = []
		this.discountedAmount = undefined
		this.discountPromotion = undefined;
		this.selectedOrderType = this.categories.slice()
		this.discountExists = false;
		this.selectedOrderItems = undefined
		//this.template.querySelector("[data-id='category']").value = this.categories

		if(this.selectedPromotion.length > 0){
			this.selectedPromotion = JSON.parse(this.selectedPromotion).splice(0,this.selectedPromotion.length)
			this.selPromotionCopy = this.selPromotionCopy.splice(0,this.selectedPromotion.length);
		}

		if( this.selPromotionCopy.length > 0){
		     this.clearMainDatatable();
  			}
  			this.data.forEach(x => {
  			    x.OrderQty = '';
  			    x.promoOrderQty = '';
  			    x.FreeQty = '';
  			    x.promoFreeQty = ''
		 })
		 this.mainMasterData.forEach(x => {
           			    x.OrderQty = '';
           			    x.promoOrderQty = '';
           			    x.FreeQty = '';
           			    x.promoFreeQty = ''
         		 })
		 this.template.querySelector("[data-id='mainDatatable']").data = this.data 
		this.setOrderStatus()
		this.masterDraftValues = []
		this.qtySum = []
		this.defaultCategoryOption = 'All'
		this.promotionToEdit = [];
		this.selPromotionCopy = [];
		this.selectedOrderItems = undefined
		this.categoryOptions = this.categories.slice()

		this.dispatchEvent(new RefreshEvent(this.mainMasterData));
	}

	setOrderStatus(selectedProducts) {
	  	var storedDraftValues = this.template.querySelector("[data-id='mainDatatable']").draftValues
	  	console.log('@@storedDraftValues: '+JSON.stringify(storedDraftValues))
	  	var noOrderQtyFound  = storedDraftValues.forEach(x => x.OrderQty !== undefined || x.promoOrderQty !== undefined)
	  	console.log('@@noOrderQtyFound:'+JSON.stringify(noOrderQtyFound))
		console.log('@@this.totalAmount:'+this.totalAmount)
	    if(!parseInt(this.totalAmount) > 0){
			this.isOrderValid = false;
			this.disableSaveButton = true
			return;
		 }else{
			this.isOrderValid = true;
			this.disableSaveButton = false;
		}
 	}

	storeUniqueDraftValues(item){
		if(this.masterDraftValues.length > 0){
			if(this.masterDraftValues.find(x => x.Id == item.Id) !== undefined ){
				this.masterDraftValues.forEach(x => {if(x => x.Id == item.Id) {x.OrderQty = item.OrderQty}})
			}else{
			  this.masterDraftValues.push(item)
			}
		}else{
			this.masterDraftValues.push(item)
		}
 	}

 	getPromotionByMaterialCode(materialCode){
 	    debugger
 	   return  this.selPromotionCopy.filter(x => x.MaterialCode === materialCode);
	}

     getPromotionByCategory(categoryToMatch){
          const promo = this.selPromotionCopy.slice()
              console.log('###promo:'+JSON.stringify(promo))
                const record = promo.filter(item => item.PromoCategories && item.PromoCategories.split(",").map(category => category.trim()).includes(categoryToMatch.trim()));
                console.log('###record:'+JSON.stringify(record))
                return record || null;
              };

	calculateTotalAmount(draftValue){
		 debugger
		console.log('#draftValue:'+JSON.stringify(draftValue))
		if(draftValue[0].FreeQty !== undefined) return;
		this.qtySum = []
		var storedDraftValues = this.template.querySelector("[data-id='mainDatatable']").draftValues
		console.log('#storedDraftValues:'+JSON.stringify(storedDraftValues))
		var discountedPromotions = this.selPromotionCopy.filter(x => x.Discount !== undefined)
    	      console.log('#discountedPromotion:'+JSON.stringify(this.discountedPromotion))
		this.selPromotionCopy.forEach(promo => {
		    console.log('#promo:'+JSON.stringify(promo))
 		})

		const dataRow = this.mainMasterData.find(item => item.Id === draftValue[0].Id)
		var processedDrafts = []

		storedDraftValues.forEach( draft => {
		    var dataRow = this.mainMasterData.find(x => x.Id === draft.Id)
		     var promotions = [];
		  promotions = this.getPromotionByMaterialCode(dataRow.MaterialCode)
		  if(promotions.length === 0){
		      promotions = this.getPromotionByCategory(dataRow.Category)
			}

		    if(promotions.length > 0 ){
		        promotions.forEach( p =>  {
					if(draft.OrderQty !== undefined){
						var processedDraft = {}
						processedDraft.OrderQty = draft.OrderQty
						processedDraft.Id = draft.Id
						processedDraft.UnitPrice = dataRow.UnitPrice
						processedDraft.MaterialCode = dataRow.MaterialCode
						processedDraft.Category = dataRow.Category
						if(p.Discount !== undefined){
						    this.discountExists = true;
							processedDraft.Discount = p.Discount
						 }

						processedDrafts.push(processedDraft)
					}
					 if(draft.promoOrderQty !== undefined){
						var processedDraft = {}
						processedDraft.promoOrderQty = draft.promoOrderQty
						 processedDraft.Id = draft.Id
						processedDraft.UnitPrice = dataRow.UnitPrice
						processedDraft.MaterialCode = dataRow.MaterialCode
						processedDraft.Category = dataRow.Category
						 if(p.Discount !== undefined){
						     this.discountExists = true;
							processedDraft.Discount = p.Discount
						 }
						processedDrafts.push(processedDraft)
					}
				})
     		 }else{ // no promotion

					var processedDraft = {}
					processedDraft.OrderQty = draft.OrderQty
					processedDraft.Id = draft.Id
					processedDraft.UnitPrice = dataRow.UnitPrice
					processedDraft.MaterialCode = dataRow.MaterialCode
					processedDraft.Category = dataRow.Category
					processedDrafts.push(processedDraft)
      		  }
 		 })
 		 console.log('#processedDrafts:'+JSON.stringify(processedDrafts))
		var totalDiscount = [];
 		 processedDrafts.forEach(item => {

 		     console.log('#item:'+JSON.stringify(item))
 		     var quantity=0;
 		     var qtySumItemFound = this.qtySum.find(x => x.Id == item.Id);
             var qtySumItemFoundIdx = this.qtySum.findIndex(x => x.Id == item.Id);
             try{
                 if(item.Discount !== undefined){
                      if(item.OrderQty !== undefined){
                          var amt = (item.OrderQty * item.UnitPrice) * item.Discount / 100
                          console.log('#amt1:'+amt)
                          totalDiscount.push(amt)

                          if(qtySumItemFound === undefined){
                              this.qtySum.push({Id: item.Id, amount:item.UnitPrice * parseInt(item.OrderQty)})
                          }else{
                               this.qtySum[qtySumItemFoundIdx].amount += item.UnitPrice * parseInt(item.OrderQty)
                          }
                      }else if(item.promoOrderQty !== undefined){
                          var amt = (item.promoOrderQty * item.UnitPrice) * item.Discount / 100
                           totalDiscount.push(amt)
                            console.log('#amt2:'+amt)
							if(qtySumItemFound === undefined){
								this.qtySum.push({Id: item.Id, amount:item.UnitPrice * parseInt(item.promoOrderQty)})
							}else{
								this.qtySum[qtySumItemFoundIdx].amount += item.UnitPrice * parseInt(item.promoOrderQty)
							}
                      }
                 }else{
					   if(item.OrderQty !== undefined){
							if(qtySumItemFound === undefined){
								this.qtySum.push({Id: item.Id, amount:item.UnitPrice * parseInt(item.OrderQty)})
							}else{
								 this.qtySum[qtySumItemFoundIdx].amount = item.UnitPrice * parseInt(item.OrderQty)
							}
						}else if(item.promoOrderQty !== undefined){
							if(qtySumItemFound === undefined){
								this.qtySum.push({Id: item.Id, amount:item.UnitPrice * parseInt(item.promoOrderQty)})
							}else{
								this.qtySum[qtySumItemFoundIdx].amount = item.UnitPrice * parseInt(item.promoOrderQty)
							}
						}
                 }

             }catch(error){
                 console.log('ORDER CONSOLE ERROR: ' + JSON.stringify(error))
                 console.log('ORDER CONSOLE ERROR: ' + JSON.stringify(error))
             }
   		 })
   		 console.log('#totalDiscount:'+totalDiscount)
		this.discountedAmount = totalDiscount.reduce((a,b) => a + b,0).toFixed(2)
		console.log('#this.qtySum:'+JSON.stringify(this.qtySum))

 		//process all
 		debugger
		let amountArray = this.qtySum.map(x => x.amount)
		let processAmount = amountArray.filter(ele => ele !== undefined && ele !== "");
//		if(this.selectedOrderType != 'Free Order'){
			this.totalAmount = parseFloat(processAmount.reduce((a,b) => a + b,0)).toFixed(2)
//		}
		this.totalAmount2 = parseFloat(processAmount.reduce((a,b) => a + b,0)).toFixed(2)

		if(this.totalAmount > 0 ){
			this.disableSaveDraftButton = false
			this.disableViewDraftButton = false
		}else{
			this.disableSaveDraftButton = true
			this.disableViewDraftButton = true
		}

		if(this.selectedOrderType === 'Free Order'){
		    this.disableSaveButton = false
 		 }
	}

	removeEmptyCellValue(draftValue){
			 var promoData = []
			 var storedDraftValues = JSON.parse(JSON.stringify(this.template.querySelector("[data-id='mainDatatable']").draftValues))
			 //remove any 0 on the cell
			 var idx = storedDraftValues.findIndex(x => x.Id === draftValue[0].Id)
			 var idx1 = this.masterDraftValues.findIndex(x => x.Id === draftValue[0].Id)

				if(draftValue[0].OrderQty === "0" ){
					delete storedDraftValues[idx].OrderQty
					delete this.masterDraftValues[idx1].OrderQty

			}else  if(draftValue[0].FreeQty === "0" ){
					delete storedDraftValues[idx].FreeQty
					delete this.masterDraftValues[idx1].FreeQty
			} else if(draftValue[0].promoOrderQty === "0" ){
					delete storedDraftValues[idx].promoOrderQty
					delete this.masterDraftValues[idx1].promoOrderQty
			}

			this.selPromotionCopy.forEach( promo => {
				var promo1 = {}
				if(promo.PromoCategories !== undefined){
				   promo1.CategoryPromo = true
				   var splitCat;
				   if(promo.PromoCategories.includes(',')){
					   splitCat = promo.PromoCategories.split(',')
					   promo1.PromoCategories = splitCat.join().split(',')
					}else{
						 promo1.PromoCategories = promo.PromoCategories
				  }
				   promoData.push(promo1)
				}	else{
					 promo1.ProductPromo = true
					 promo1.MaterialCode = promo.MaterialCode
					 promoData.push(promo1)
			  }
			})

			if(this.selectedOrderType === 'Free Order' && (draftValue[0].FreeQty !== undefined || draftValue[0].promoOrderQty !== undefined)){
			    if(draftValue[0].FreeQty !== undefined){
			        var idx = storedDraftValues.findIndex(x => x.Id === draftValue[0].Id)
					  delete storedDraftValues[idx].FreeQty
					  delete this.masterDraftValues[idx].FreeQty
     			}else if(draftValue[0].promoOrderQty !== undefined){
     			      delete storedDraftValues[idx].promoOrderQty
					  delete this.masterDraftValues[idx].promoOrderQty
       			 }
       			 this.showWarningToast("Please use OrderQty column for the Free Order");
				  this.template.querySelector("[data-id='mainDatatable']").draftValues = storedDraftValues
				  return;
  			}
  			if(this.selPromotionCopy.length === 0 && draftValue[0].promoOrderQty !== undefined){
				 var idx = storedDraftValues.findIndex(x => x.Id === draftValue[0].Id)
				  delete storedDraftValues[idx].promoOrderQty
				  delete this.masterDraftValues[idx].promoOrderQty
				  this.showWarningToast("No promotion selected.");
				  this.template.querySelector("[data-id='mainDatatable']").draftValues = storedDraftValues
				  return;
			}

			var productsForPromo = []
			var categoriesForPromo = []
			let m = promoData.filter(x => x.MaterialCode !== undefined).map(x => x.MaterialCode)
			let c = promoData.filter(x => x.PromoCategories !== undefined).map(x => x.PromoCategories)

			m.forEach(x => {
			    let row = this.mainMasterData.find(k => k.MaterialCode === x)
			    productsForPromo.push(row)
  			 })
  			 c.flat().forEach(x => {
  			     let rows = this.mainMasterData.filter(k => k.Category === x && (k.Category !== null || k.Category !== undefined))
  			     if(rows.length > 1){
  			         rows.forEach(a => { categoriesForPromo.push(a)})
          		 }else{
          		   categoriesForPromo.push(rows)
            	 }
     		 })
       			let row1 = this.mainMasterData.find(k => k.Id === draftValue[0].Id)
                 var foundProd = productsForPromo.find(x => x.MaterialCode === row1.MaterialCode)
                 if(foundProd === undefined){
                     let row2 = this.mainMasterData.find(k => k.Category === row1.Category)
                    foundProd =  categoriesForPromo.find(x => x.Category === row2.Category)
                 }
                 if(foundProd === undefined && draftValue[0].promoOrderQty !== undefined){
                     var idx = storedDraftValues.findIndex(x => x.Id === draftValue[0].Id)
					var draftValues = storedDraftValues.find(x => x.Id === draftValue[0].Id)
					var keys = Object.keys(draftValues)
					if(keys.length === 2 && keys.includes('promoOrderQty')){
						delete storedDraftValues.splice(idx,1)
						delete this.masterDraftValues.splice(idx,1)
					}else{
					   delete storedDraftValues[idx].promoOrderQty
					   delete this.masterDraftValues[idx].promoOrderQty
					}
					this.showWarningToast("Wrong product/category for the promotion.");
                 }
		 	this.template.querySelector("[data-id='mainDatatable']").draftValues = storedDraftValues

		}

	addOrUpdateFields(draftValue){
	    if(this.selectedProducts.length !== 0){
	        this.selectedProducts.push(draftValue[0])
    	}else{
    	    let idx = this.selectedProducts.findIndex(item => item.Id === draftValue[0].Id)
			if(idx === -1){
				this.selectedProducts.push(draftValue[0])
			}else{
			    const dataItem = this.selectedProducts.find(item => item.Id === draftValue.Id);
			    if(dataItem && draftValue.OrderQty){
			       this.selectedProducts.map(item => { if(item.Id === draftValue[0].Id) { item.OrderQty = draftValue.OrderQty}})
       			}else if(dataItem && draftValue.promoOrderQty){
       			    this.selectedProducts.map(item => { if(item.Id === draftValue[0].Id) { item.promoOrderQty = draftValue.promoOrderQty}})
          		}
   			}
     	}
 	}

	handleSaveDraft(event){
	const mainDataTableSelectedData =	this.template.querySelector("[data-id='mainDatatable']").draftValues;
		if(!mainDataTableSelectedData){
			this.showWarningToast('Please make sure at-least one order exits to save as Draft');
		}else{
			this.isShowDraftModelName = true;
		}
		if(this.isShowModal){
			this.handleViewDraft();
		}
	}

	async handleViewDraft(){

		this.isShowViewDraftModal = true;
		await getDraftViewForCustomer({customerId:this.recordId,draftName:this.draftName }).then(result =>{
			if(result){
			this.viewDraftScreenData = result;
			}}).catch(error => {
				alert('Error1:'+JSON.stringify(error))
		});
    }

    handleDraftItemSelectSubmit(event){

        const draftDesc = this.selectedDraftRowDescription
		var dDraftValues = []

        if(this.draftFieldValues === undefined || this.draftFieldValues.length ===  0  || this.draftFieldValues.length > 1){
            this.showWarningToast('Please select at-least One and Only one draft.')
            return;
        }

		getMaterialsForAccount({accountId:this.recordId,searchToken:'',draftName:draftDesc}).then(result =>
		{
			this.isShowViewDraftModal = false;
			this.dataSpinner = true
		    dDraftValues = []
		    console.log('Before result1')
		    setTimeout(() => {
		        if(result){
		              const resultData = result;
		              resultData.wrapperList.forEach(x =>  {
					 var dValue = {}
					 dValue.Id = x.Id
					 if(x.OrderQty !== undefined){
						  dValue.OrderQty = x.OrderQty
					}
					if(x.promoOrderQty !== undefined){
						 dValue.promoOrderQty = x.promoOrderQty
					}
					if(x.FreeQty  != undefined){
						dValue.FreeQty = x.FreeQty
					 }
					 if(x.promoFreeQty !== undefined){
						  dValue.promoFreeQty = x.promoFreeQty
				   }
					dDraftValues.push(dValue)
				 })
          		}
          		 if(result && dDraftValues.length > 0) {
					 this.template.querySelector("[data-id='mainDatatable']").draftValues = dDraftValues.slice()
					 var draftValArray = []
                     		var totalValAmount = []
                     		if(dDraftValues.length > 0){
                     			dDraftValues.forEach(x => {
                     			    console.log('x:' + JSON.stringify(x))
                     				var foundItem = this.data.find(y => y.Id === x.Id )
                     				var draftVal = {}
                     				var d = draftValArray.find(k => k.Id === x.Id)

                     				if(d === undefined){
                     				draftVal.UnitPrice = foundItem.UnitPrice
                     				draftVal.Id = x.Id
                     				if(x.OrderQty !== undefined){
                     					draftVal.OrderQty = x.OrderQty
                     				}
                     				if(x.promoOrderQty !== undefined){
                     					draftVal.promoOrderQty = x.promoOrderQty
                     				}
                     				draftValArray.push(draftVal)
								}
                     			})
                     			if(draftValArray.length > 0){
                     			    draftValArray.forEach(a => {
										if(a.OrderQty !== undefined){
											totalValAmount.push(a.OrderQty * a.UnitPrice)
										}
										 if(a.promoOrderQty !== undefined){
											totalValAmount.push(a.promoOrderQty * a.UnitPrice)
										}
									})
									if(totalValAmount.length > 0){
										if(this.selectedOrderType != 'Free Order'){
									this.totalAmount =  parseFloat(totalValAmount.reduce((a,b) => a + b,0)).toFixed(2)
										}
									this.totalAmount2 =  parseFloat(totalValAmount.reduce((a,b) => a + b,0)).toFixed(2)
									}
						 	}

						}
					this.disableSaveButton = false;
					this.disableSaveDraftButton = false;
                     this.dataSpinner = false;
			   }
     		 },0)

  		})
    }

    handleSaveAsDraft(event){
		this.isShowViewDraftModal = false;
		 var draftValues = this.template.querySelector("[data-id='mainDatatable']").draftValues;
		 this.draftFieldValues = draftValues;
		 this.isShowDraftModelName = false;
		let draftDesc = event.detail.value;

		createDaft({jsonInput:JSON.stringify(this.draftFieldValues),accountId:this.recordId, draftDesc: this.draftName,totalAmount: this.totalAmount }).then(result =>{
		if(result){
				this.showSuccessToast();
				this.draftName = null;
			}else if(error){
				this.showErrorToast(error);
			}
		})
        this.isShowDraftModelName = false;
    }

    handleViewDraftRowSelected(event){
	 this.draftFieldValues = event.detail.selectedRows;

		if( this.draftFieldValues.length > 0){
		     this.selectedDraftRowDescription = this.draftFieldValues[0].Description;
  		}

    }

	showSuccessToast() {
		const event = new ShowToastEvent({
			title: 'Success!',
			message: 'Records Saved successfully',
			variant: 'success',
			mode: 'dismissable'
		});
		this.dispatchEvent(event);
	}

	showSuccessToast(msg) {
    		const event = new ShowToastEvent({
    			title: 'Success!',
    			message: msg,
    			variant: 'success',
    			mode: 'dismissable'
    		});
    		this.dispatchEvent(event);
    	}

	showErrorToast(ex) {
		const evt = new ShowToastEvent({
			title: 'Error',
			message: ex,
			variant: 'error',
			mode: 'dismissable'
		});
		this.dispatchEvent(evt);
	}

	showWarningToast(msg) {
    		const evt = new ShowToastEvent({
    			title: 'warning',
    			message: msg,
    			variant: 'warning',
    			mode: 'dismissable'
    		});
    		this.dispatchEvent(evt);
    	}

	showPromotionModel() {
	    this.canShowOrderConsole = false;
	    this.canShowPromotion = true;
	}

	hidePromotionModel() {
		this.isShowModal = false;
		if(this.isShowViewDraftModal == true){
		    	this.isShowViewDraftModal = false
  		}
  		if(this.isShowDraftModelName == true){
  		    this.isShowDraftModelName = false;
    	}
	}

	handlePromotionSubmit(){
		this.hidePromotionModel();
	}

	handleNameChange(event){
		this.name = event.detail.value;
	}

	handleDraftName(event){
	    this.draftName = event.detail.value;
 	}

 	selectedRowHandler(event){
     	this.isShowViewDraftModal = false;
 	}

	handleReferenceChange(event) {
	    this.reference = event.detail.value;
		this.selectedReference = event.detail.value;
		console.log('#!this.selectedReference:'+this.selectedReference)
		console.log('#!event.detail.value:'+event.detail.value)
		console.log('#!this.reference:'+this.reference)
	}

	handleDateChange(event) {
		this.selectedDate = event.detail.value;
		this.deliveryDate = event.detail.value
	}

	handleLaserTextChange(event) {
		this.selectedLaserText = event.detail.value;
	}

 	handleCancelOrder(event) {
		this.orderPreview = false;
		this.start = true;
		this.showPersonalisation = false;
		this.showReplacement = false;
		this.showFree = false;
		if(this.masterDraftValues.length > 0){
		setTimeout(() => {
			  this.template.querySelector("[data-id='mainDatatable']").draftValues =  this.masterDraftValues.slice();
		},0);

	}
	}

	handleDeliveryBlock(event){
	    this.isDeliveryBlock = event.target.checked;
 	}

 	navigateToViewAccountPage(recordId) {
		this[NavigationMixin.Navigate]({
			type: 'standard__recordPage',
			attributes: {
			recordId: recordId,
			objectApiName: 'ghdOrder__c',
			actionName: 'view'
			},
			});
		}
 	}