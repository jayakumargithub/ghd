/**
 * Created by Jayakumar Mogenahall on 20/04/2023.
 */

import { LightningElement,api,wire,track } from 'lwc';
import { subscribe, publish, MessageContext, APPLICATION_SCOPE } from 'lightning/messageService';
import promotionMessage from "@salesforce/messageChannel/promotionMessage__c";
import getPromotions from "@salesforce/apex/PromotionService.getPromotions";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


const columns = [
    { label: 'Name', fieldName: 'PromotionName',  editable: false },
    { label: 'Category', fieldName: 'PromoCategories', editable: false },
    { label: 'Product', fieldName: 'ProductName', editable: false },
    { label: 'Free Quantity', fieldName: 'FreeQuantity', type: 'number', editable: false, hideDefaultActions:"true", typeAttributes:{currencyCode: 'GBP',variant:"Error"}, cellAttributes:{iconName:{fieldName:'iconName'}, iconClass:"slds-current-color",iconPosition:'right'}},
//    { label: 'Maximum Free Units', fieldName: 'MaximumFreeUnits', type: 'number', editable: true, hideDefaultActions:"true" },
    { label: 'Order Quantity', fieldName: 'OrderQuantity', editable: false },
//    { label: 'SAP Promotion Code', fieldName: 'ErpPromotionCode', editable: false }
];


export default class Promotion extends LightningElement {
@api recordId;
columns = columns;
promoData=[];
selectedRow = [];
message = {}
selectedPromotion;
@api pSelectedPromotion=[];
subscription = null;
@api hello = [];
@track xSelectedRows=[];
isProcessed = true;
deSelected = false;
preSelectedArray = [];
@api orderDraftValues = []


	@wire(getPromotions, {accountId:'$recordId'})
	wiredPromoResult({error,data}){
		if(data){
			console.log('#promotion data:'+JSON.stringify(data))
			const updatedJsonData = data.map(obj => {
				if (Array.isArray(obj.PromoCategories)) {
					return {
						...obj,
						PromoCategories: obj.PromoCategories.join(",")
					};
				}
				return obj;
			});
			this.promoData = updatedJsonData;
		}
	}


 	renderedCallback(){
	 if(this.isProcessed == true && this.pSelectedPromotion.length > 0){
     console.log('##orderDraftValues:'+JSON.stringify(this.orderDraftValues))
	     console.log('# promotion this.pSelectedPromotion:'+JSON.stringify(this.pSelectedPromotion))
	     var myArray = this.pSelectedPromotion.slice();
	     this.promoData = JSON.parse(myArray).map(item => item)
 		 const mCodes = JSON.parse(myArray).map(item => item.Id)
		 this.template.querySelector("[data-id='promotionDatatable']").selectedRows = mCodes;
		 this.isProcessed = false;
 	}
  }

	@wire(MessageContext)
	messageContext;

	handleCancel(){
		this.message = { showOrderConsole : true,selectedPromotion :JSON.stringify(this.selectedRow),orderDraftValues: this.orderDraftValues};
		publish(this.messageContext,promotionMessage,this.message);
	}

    handleClear(){
		var selectedRows = this.template.querySelector("[data-id='promotionDatatable']").selectedRows;

		if(selectedRows != undefined){
		    selectedRows = [];
 		 }
    }
	handleSearch(event){
	  let searchText = event.detail.value;
	  getPromotions({accountId: this.recordId,searchToken:searchText }).then(result => {
		 	this.promoData = result.map(item => { return {...item}});
	 	}).catch(error => {alert(error)})
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

	handleOnRowAction(event){

	    var selectedRows1 = this.template.querySelector("[data-id='promotionDatatable']").selectedRows;
	     console.log('#selectedRows1:'+JSON.stringify(selectedRows1))
		 this.selectedRow = event.detail.selectedRows;
		 console.log('#selectedRows:'+JSON.stringify(this.selectedRow))
	}
	handleAddPromotion(event){

	   var promotionList = []
		let draftValues = this.template.querySelector("[data-id='promotionDatatable']").selectedRows;

		console.log('this.promoData:'+ JSON.stringify(this.promoData))

		console.log('#draftValues:'+JSON.stringify(draftValues))
		this.selectedRow = this.promoData.filter(x => draftValues.includes(x.Id ))
		console.log('###this.selectedRow:'+JSON.stringify(this.selectedRow))
		this.message = { showOrderConsole : true, selectedPromotion : JSON.stringify(this.selectedRow),orderDraftValues: this.orderDraftValues};
		console.log('##publishing this.message :'+ JSON.stringify(this.message))
		publish(this.messageContext,promotionMessage,this.message);
  	}

  	unsubscribeToMessageChannel() {
		unsubscribe(this.subscription);
		this.subscription = null;
	}

	disconnectedCallback() {
		this.unsubscribeToMessageChannel();
	}
}