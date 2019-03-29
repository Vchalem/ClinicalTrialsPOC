import { LightningElement, track, api, wire } from 'lwc';
import getTrialsForRecord from '@salesforce/apex/CT_ClinicalTrialUtil.getTrialsForRecord';
import { NavigationMixin } from 'lightning/navigation';



export default class trialinfodisplay extends NavigationMixin(LightningElement) {
    @api recordId;
    @track trials;
    @track trialsString;
    @track url;
    @track selectedItem;
    @track url3;
 
   

    //when LWC loads - call apx class w/ contact ID
    @wire(getTrialsForRecord, {recordId: '$recordId'})
    wiredContact({ error, data }) {
        if (data) {
            this.trialsString = data;
            this.trials=JSON.parse(this.trialsString);
            this.error = undefined;
        } else if (error) {
            this.error = error;
            
            this.trialsString = undefined;
            this.trials=undefined
        }
    }

    handleItemClicked(event) {
        this.selectedItem = event.target.dataset.item;
        var url2 = "https://www.cancer.gov/about-cancer/treatment/clinical-trials/search/v?id=";
        var link = url2.concat(this.selectedItem);
        this.url=link;
    }

    navigateToWebPage() {
        // Navigate to a URL
        this.url3="https://lizzhc19.lightning.force.com/survey/runtimeApp.app?invitationId=0Ki1U000000Uwu5&surveyName=recommend_for_clinicals&UUID=e252d749-961c-4017-95a7-42bfe792e052";
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: this.url3
            }
        });
    }

}