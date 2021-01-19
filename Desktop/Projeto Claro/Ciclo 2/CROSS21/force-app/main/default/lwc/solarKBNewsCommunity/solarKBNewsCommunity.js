import { LightningElement, wire, track } from "lwc";
import getRecentArticles from "@salesforce/apex/CEC_KB_NewsFooterController.getRecentArticles";
import getListViewId from "@salesforce/apex/CEC_KB_NewsFooterController.getListViewId";
import { NavigationMixin } from 'lightning/navigation';


export default class SolarKBNewsCommunity extends NavigationMixin(LightningElement) {
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
	wiredData2({ error, data }) {
		if (error) {
			console.log("erro ao obter os dados do backend");
		} else if (data) {
            this.listView = JSON.parse(JSON.stringify(data))
		}
    }

    navigateToArticle(event){
        let articleId = event.target.title;
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url:"/comunidadesolar/s/article/" + articleId,
            }
        });
    }

    navigateToListView() {
        // Navigate to the Contact object's Recent list view.
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Knowledge__kav',
                actionName: 'list'
            },
            state: {
                // 'filterName' is a property on the page 'state'
                // and identifies the target list view.
                // It may also be an 18 character list view id.
                filterName: this.listView // or by 18 char '00BT0000002TONQMA4'
            }
        });
    }
}