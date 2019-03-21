import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

const FIELDS = [
    'Contact.Name',
    'Contact.Email',
    'Contact.HealthCloudGA__Gender__c',
    'Contact.HealthCloudGA__Age__c',
    //'Contact.CleanStatus',
    //'Contact.MailingAddress'

];


export default class trialinfodisplay extends LightningElement {
    @api recordId;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    contact;

    get name() {
        return this.contact.data.fields.Name.value;
    }
    get email() {
        return this.contact.data.fields.Email.value;
    }
    get title() {
        return this.contact.data.fields.Title.value;
    }
    get gender() {
        return this.contact.data.fields.HealthCloudGA__Gender__c.value;
    }
    get age(){
        return this.contact.data.fields.HealthCloudGA__Age__c.value;
    } 


}