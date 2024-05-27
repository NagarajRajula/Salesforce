import { LightningElement, api, track } from 'lwc';
import searchResults from '@salesforce/apex/VideoSuggestionController.searchResults';
import sendEmail from '@salesforce/apex/VideoSuggestionController.sendEmail';

export default class VideoSuggestion extends LightningElement {

    searchString;
    @track superItemList = [];

    inputValue(event) {
        this.searchString = event.target.value;
    }

    handleSearch() {
        debugger;
        console.log('Search string value', this.searchString);
       
       searchResults({ keyValue: this.searchString })
        .then((result) => {
            this.superItemList = result;
            console.log('Successfully fetched data: ', result);
        })
        .catch((error) => {
            console.log('Error occurred', error);
        });
    }

    // handle send email functionality
    handleButtonClick(event) {
        // Retrieve the index from the data attribute
        const index = event.target.dataset.index;
        // Get the item details using the index
        const item = this.superItemList[index];
        // Do something with the item, for example, log it to the console
        console.log('Item details:', item);
        console.log('index details:', index);
        console.log('selected item f5: ', item.f5);
        const currentUrl = window.location.href;
        console.log('currentUrl : ', currentUrl);
        
        const regex = /\/Contact\/(\w+)\//;
        const match = currentUrl.match(regex);

        let conId;

        if (match) {
            conId = match[1];
            console.log("ID: ", conId);
        } else {
            console.log("ID not found in the URL.");
        }
        
        // Passing video Id and Contact record Id
        if(videoId != null || contactId != null ){
            sendEmail({ videoId: item.f5, contactId: conId })
            .then((result) => {
                this.superItemList = result;
                console.log('Successfully sent email!! ');
            })
            .catch((error) => {
                console.log('Error occurred', error);
            });
        }
    }
}
