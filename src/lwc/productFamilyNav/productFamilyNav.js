/**
 * Created by Jayakumar Mogenahall on 21/02/2023.
 */
 import { LightningElement,wire,track,api} from 'lwc';
import ImageResource from '@salesforce/resourceUrl/GHDImages';
import {publish,subscribe,unsubscribe,APPLICATION_SCOPE,MessageContext} from "lightning/messageService";
import productMessageService from "@salesforce/messageChannel/productFamilyNav__c"

export default class ProductFamilyNav extends LightningElement {

@track productNav = null;
hideNav = false;

@wire(MessageContext)
    messageContext;


    connectedCallback(){
        this.productNav = subscribe(
            this.messageContext,
            productMessageService,
            message => {
                this.handleMessage(message);
            },
            { scope: APPLICATION_SCOPE }
        );

    }

    handleMessage(message){

    this.hideNav = true;

    }

        subscribeToMessageChannel() {
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext,
                recordSelected,
                (message) => this.handleMessage(message),
                { scope: APPLICATION_SCOPE }
            );
        }
    }

 hairDryer = ImageResource+ '/small-images/airdryer-small.png';
}