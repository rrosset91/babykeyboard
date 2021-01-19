/*
* Autor: Diego Lima - Deloitte
* Data: 08/11/2019
* Descrição: [Nome do projeto/ID: CEC FASE 1] + [Time: SQUAD CTI - Sprint 6] + [Classe utilizada como Wrapper das classe
* CEC_CTI_SyncSite, CEC_CTI_SyncPausa, CEC_CTI_SyncTransfer e CEC_CTI_SyncSkill]
* 
*/
global class CEC_CTI_SyncObjectsWrapper {
    public Id idObject {get; set;}
    public Boolean successOperation {get; set;}
    public String errorOperation {get; set;}
    public String descriptionError {get; set;}
    
    public String externalId {get;set;}   
}