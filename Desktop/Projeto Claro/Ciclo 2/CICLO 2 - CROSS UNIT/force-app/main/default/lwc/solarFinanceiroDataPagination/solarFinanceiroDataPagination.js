import { LightningElement, track, api } from "lwc";
import Utils from "c/solarUtils";

export default class SolarFinanceiroDataPagination extends LightningElement {
  @api paginationData = [];
  @track pages = [];
  @track dataToDisplay = [];
  @track loading = true;
  @track showData = false;
  //SAMPLE EXPECTED DATA ---> [{data:[{label: 'blabla', fieldName:'blablabla'},{label: 'blabla', fieldName:'blablabla'},{label: 'blabla', fieldName:'blablabla'}]}];
  connectedCallback() {
    for (let index = 1; index <= this.paginationData.length; index++) {
      let tempObject = { page: index, realIndex: index - 1 };
      this.pages.push(tempObject);
    }
    this.loading = false;
  }

  handlePageClick(event) {
    this.dataToDisplay = [];
    let selectedPage = event.target.innerHTML;
    let findIndex = selectedPage - 1;
    let fieldsData = this.paginationData[findIndex];
    this.dataToDisplay = fieldsData;
  }
}

//