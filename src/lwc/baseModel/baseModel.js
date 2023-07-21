/**
 * Created by Jayakumar Mogenahall on 17/02/2023.
 */

import { LightningElement,api } from 'lwc';
import LightningModal from 'lightning/modal';

export default class baseModel extends LightningElement {
    @api firstName;

    handleOkay(){

         this.close(this.firstName);
    }

}