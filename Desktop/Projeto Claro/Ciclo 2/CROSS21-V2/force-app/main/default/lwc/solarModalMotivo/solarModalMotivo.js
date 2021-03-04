import { LightningElement, api, track } from "lwc";

export default class SolarModalMotivo extends LightningElement {
	@track
	showModal = false;
	@api
	size = "small";
	@api
	header;
	sldsModalSize = "slds-modal_small";

	renderedCallback() {
		if (!this.showModal) return;

		if (this.size === "small") this.sldsModalSize = "slds-modal_small";
		else if (this.size === "medium") this.sldsModalSize = "slds-modal_medium";
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