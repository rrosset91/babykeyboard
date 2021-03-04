import { LightningElement, wire, track } from "lwc";
import getRecentArticles from "@salesforce/apex/CEC_KB_NewsFooterController.getRecentArticles";
import getListViewId from "@salesforce/apex/CEC_KB_NewsFooterController.getListViewId";
import { NavigationMixin } from 'lightning/navigation';

export default class SolarKBNewsFooter extends NavigationMixin(LightningElement) {
    artToShow = 10;

    @track listView;
    @track data;
    @track obj;
    @track isLoading = false;


	@wire(getRecentArticles, { artToShow : '$artToShow' })
	wiredData({ error, data }) {
        this.isLoading = true;
		if (error) {
			console.log("erro ao obter os dados do backend");
		} else if (data) {
            this.data = JSON.parse(JSON.stringify(data));
            this.obj = JSON.parse(JSON.stringify(data));
            this.isLoading = false;
		}
    }

    @wire(getListViewId)
    wiredListView({error,data}){
        if(error){
            console.log("erro ao obter listview do backend");
        } else if(data){
            this.listView = JSON.parse(JSON.stringify(data))
        }
    }
    
    handleClick(event){
        this.artToShow += 10;
    }

    navigateToListView() {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url:"/lightning/o/Knowledge__kav/list?filterName=" + this.listView,
            },
        });
    }

    navigateToArticle(event){
        let articleId = event.target.title;
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url:"/lightning/r/Knowledge__kav/" + articleId + "/view"
            }
        });
    }
}