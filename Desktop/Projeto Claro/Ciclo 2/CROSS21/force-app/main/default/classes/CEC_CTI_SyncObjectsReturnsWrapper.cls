/*
* Autor: Diego Lima - Deloitte
* Data: 22/11/2019
* Descrição: [Nome do projeto/ID: CEC FASE 1] + [Classe utilizada como Wrapper da classe de integração de upsert
* CEC_CTI_SyncObjectsReturns]
* 
*/
public class CEC_CTI_SyncObjectsReturnsWrapper {
    public Database.UpsertResult [] upsertResults {get; set;}
    public List<String> listIdExterno {get; set;}
}