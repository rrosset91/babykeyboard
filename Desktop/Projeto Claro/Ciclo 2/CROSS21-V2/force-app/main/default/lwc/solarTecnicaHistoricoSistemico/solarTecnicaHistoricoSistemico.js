import { LightningElement, api } from 'lwc';
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';

export default class SolarTecnicaHistoricoSistemico extends OmniscriptBaseMixin(LightningElement)  {

    @api
    recordId;

    activeSections = [];

    handleToggleSection(event) {
        this.activeSectionMessage = event.detail.openSections;
        if(this.activeSectionMessage.includes('solics')) {
            this.template.querySelector('c-solar-tecnica-solics').callSolicsService(this.recordId);
        }
    }
}