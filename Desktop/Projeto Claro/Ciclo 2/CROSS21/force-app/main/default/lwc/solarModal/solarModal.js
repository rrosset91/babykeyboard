import { LightningElement, api, track } from "lwc";
export default class SolarModal extends LightningElement {
	@track
	showModal = false;
	@api
	showCloseButton = false;
	@api
	size = "large";
	@api
	header;
	sldsModalSize = "slds-modal_small";
	renderedCallback() {
		if (!this.showModal) return;
		if (this.size === "small") this.sldsModalSize = "slds-modal_small";
		else if (this.size === "medium") this.sldsModalSize = "slds-modal_medium";
		else if (this.size === "x-small") this.sldsModalSize = "slds-modal_x-small";
		else this.sldsModalSize = "slds-modal_large";
		this.template.querySelector("section").classList.add(this.sldsModalSize);
	}
	@api
	open() {
		this.showModal = true;
	}
	@api
	close() {
		this.showModal = false;
	}
}
