/*
* Autor: Diego Lima - Deloitte
* Data: 29/11/2019
* Descrição: [Nome do projeto/ID: CEC FASE 1] + [Classe utilizada para integração de upsert
* do objeto Transferencia__c]
* 
*/

public class CEC_CTI_SyncTransferBO {
    private Map<String, Skill__c> mapSkill = new Map<String, Skill__c>();
    private Set<String> setCodSkill = new Set<String>();

    private Set<String> setCodTransfers = new Set<String>();
    private Map<String, Transferencia__c> mapFoundTransfers = new Map<String, Transferencia__c>();
    private List<Transfer> lstTransfers = new List<Transfer>();
    private List<Database.UpsertResult> lstUpsertLevel = new List<Database.UpsertResult>();
    private Map<Integer, List<Transfer>> mapNiveisTransferencias = new Map<Integer, List<Transfer>>();
    private List<String> mapAllIdExternoTransfer = new List<String>();
    private List<Transfer> lstTransferFirstLvl = new List<Transfer>();
    private List<Transfer> lstTransferSecondLvl = new List<Transfer>();
    private List<Transfer> lstTransferThirdLvl = new List<Transfer>();
    private List<Transfer> lstTransferAuxLvl = new List<Transfer>();
    
    public class SyncTransfer400Exception extends Exception {}
    
    public CEC_CTI_SyncObjectsReturnsWrapper proccessRequest() {
        RestRequest restRequest = RestContext.request;
        Blob body = restRequest.requestBody;
        
        // Recebe transferencias
        this.lstTransfers = getListTransfers(body.toString());

        // Prepara Map de Skill__c
        genCodSkillSet(this.lstTransfers);
        this.mapSkill = assemblyMapExtIdSkill();

        //Prepara Map de Transferencia
        this.prepareLevelsMap(this.lstTransfers);
		
        System.debug('this.mapNiveisTransferencias ==> ' + JSON.serialize(this.mapNiveisTransferencias));
        
        for(Transferencia__c transferencia : [SELECT Id, CodTransferencia__c FROM Transferencia__c WHERE CodTransferencia__c IN :this.setCodTransfers])
        {
            this.mapFoundTransfers.put(transferencia.CodTransferencia__c, transferencia);
        }

        this.separeLevels();
        
        upsertLevelTransferencia(lstTransferFirstLvl);
        upsertLevelTransferencia(lstTransferSecondLvl);
        upsertLevelTransferencia(lstTransferThirdLvl);
        upsertLevelTransferencia(lstTransferAuxLvl);
        
        System.debug('LISTA 1 ====> ' + lstTransferFirstLvl);
        System.debug('LISTA 2 ====> ' + lstTransferSecondLvl);
        System.debug('LISTA 3 ====> ' + lstTransferThirdLvl);
       
        /*
        // Primeira insercao e atualizacao do map
        if(!lstTransferFirstLvl.isEmpty()){
            List<Transferencia__c> lstTransferenciaFirstLvl = updateNivelSuperior(lstTransferFirstLvl);
            this.lstUpsertLevel.addAll(Database.upsert(lstTransferenciaFirstLvl , Transferencia__c.Fields.CodTransferencia__c, false));
            updateMapFoundTransfer(lstTransferenciaFirstLvl);
        }
        
        // Segunda insercao e atualizacao do map
        if(!lstTransferSecondLvl.isEmpty()){
            List<Transferencia__c> lstTransferenciaSecondLvl = updateNivelSuperior(lstTransferSecondLvl);
            this.lstUpsertLevel.addAll(Database.upsert(lstTransferenciaSecondLvl , Transferencia__c.Fields.CodTransferencia__c, false));
            updateMapFoundTransfer(lstTransferenciaSecondLvl);
        }
        
        // Terceira insercao e atualizacao do map
        if(!lstTransferThirdLvl.isEmpty()){
            List<Transferencia__c> lstTransferenciaThirdLvl = updateNivelSuperior(lstTransferThirdLvl);
            this.lstUpsertLevel.addAll(Database.upsert(lstTransferenciaThirdLvl , Transferencia__c.Fields.CodTransferencia__c, false));
            updateMapFoundTransfer(lstTransferenciaThirdLvl);
        }
		*/
        
        CEC_CTI_SyncObjectsReturnsWrapper dataReturn = new CEC_CTI_SyncObjectsReturnsWrapper();
        
        System.debug('mapAllIdExternoTransfer ====> ' + mapAllIdExternoTransfer);
        dataReturn.listIdExterno = mapAllIdExternoTransfer;
        dataReturn.upsertResults = this.lstUpsertLevel;
        
        return dataReturn;
       

    }

    private void upsertLevelTransferencia(List<Transfer> lstTransfer){
        if(!lstTransfer.isEmpty()){
            List<Transferencia__c> lstTransferenciaToUpsert = updateNivelSuperior(lstTransfer);
            this.lstUpsertLevel.addAll(Database.upsert(lstTransferenciaToUpsert , Transferencia__c.Fields.CodTransferencia__c, false));
            updateMapFoundTransfer(lstTransferenciaToUpsert);
        }
    }
    
    private void separeLevels()
    {
        Integer loopCount = 0;

        for(List<Transfer> lstTransfers : mapNiveisTransferencias.values())
        {
            loopCount++;
            
            List<Transferencia__c> lstTransferencias = new List<Transferencia__c>();
            
            for(Transfer iTransfer : lstTransfers)
            {
                /*
                Transferencia__c transferencia = convertTransferToTransferencia(iTransfer);

                if(String.isNotBlank(iTransfer.nivelSuperior))
                {
                    transferencia.NivelSuperior__c = mapFoundTransfers.get(iTransfer.nivelSuperior).Id;
                }

                lstTransferencias.add(transferencia);
                
				*/
                
                if(loopCount == 1){
                    this.lstTransferFirstLvl.add(iTransfer);
                } else if(loopCount == 2){
                    this.lstTransferSecondLvl.add(iTransfer);
                }else if(loopCount == 3){
                    this.lstTransferThirdLvl.add(iTransfer);
                } else {
                    this.lstTransferAuxLvl.add(iTransfer);
                }
                                   
            }

            
            
            //this.lstUpsertLevel.addAll(Database.upsert(lstTransferencias , Transferencia__c.Fields.CodTransferencia__c, false));

            /*
            for(Transferencia__c transferencia : lstTransferencias)
            {
                mapFoundTransfers.put(transferencia.CodTransferencia__c, transferencia);
            }
			*/
        }
                
    }
    
    private List<Transferencia__c> updateNivelSuperior(List<Transfer> lstTransfers){
        
        List <Transferencia__c> lstTransferencia = new List <Transferencia__c>();
        
        for(Transfer iTransfer : lstTransfers)
        {
            Transferencia__c transferencia = convertTransferToTransferencia(iTransfer);

            if(String.isNotBlank(iTransfer.nivelSuperior)){             
                
                String nivelSuperiorTransf = iTransfer.nivelSuperior;
				String nivelSuperiorMap = mapFoundTransfers.get(iTransfer.nivelSuperior).Id;
                
                System.debug('nivelSuperiorTransf = > ' + nivelSuperiorTransf);
                System.debug('nivelSuperiorMap = > ' + nivelSuperiorMap);
                
                if(nivelSuperiorTransf != null && nivelSuperiorMap != null){ 
                	transferencia.NivelSuperior__c = mapFoundTransfers.get(iTransfer.nivelSuperior).Id;
                } else {
                    System.debug('entrou no else do map');
                    //## forca um ID invalido para gerar erro nos filhos quando o nivel acima não tenha sido carregado
                    // O 
                    transferencia.NivelSUperior__c = UserInfo.getUserId();
                    System.debug('## passou no else do map');
                }
            }
            lstTransferencia.add(transferencia);
        }
        return lstTransferencia;
    }
    
    private void updateMapFoundTransfer(List<Transferencia__c> lstTransfers){
        for(Transferencia__c transferencia : lstTransfers){
            mapFoundTransfers.put(transferencia.CodTransferencia__c, transferencia);
        }
    }

    private void prepareLevelsMap(List<Transfer> lstTransfers)
    {
        for(Transfer transfer : lstTransfers)
        {
            List<Transfer> lstTransferencia = new List<Transfer>();
            lstTransferencia.add(transfer);

            this.setCodTransfers.add(transfer.nivelSuperior);

            Integer qtdLevels = this.mapNiveisTransferencias.values().size() + 1;

            this.mapNiveisTransferencias.put(qtdLevels, lstTransferencia);
            
            mapAllIdExternoTransfer.add(transfer.transferId);

            if(transfer.transfers != null)
            {
                prepareLevelsMap(transfer.transfers);
            }
        }
    }
    
    private List<Transfer> getListTransfers(String transferStr) {
        try {
            //('Json Request' + transferStr);
            Transfer requestTransfers = (Transfer) JSON.deserialize(transferStr , Transfer.class);
            return  requestTransfers.transfers;
        } catch(Exception e) {
            throw new SyncTransfer400Exception('Formato incorreto');
        }
    } 
    
    private Map<String, Skill__c> assemblyMapExtIdSkill() {
        Map<String, Skill__c> mapExtIdSkill = new Map<String, Skill__c>();
        
        List<Skill__c> listSkills = [SELECT Id, CodSkill__c
                                     FROM Skill__c
                                     WHERE CodSkill__c IN :this.setCodSkill];
        
        for(Skill__c iSkill : listSkills) {
            mapExtIdSkill.put(iSkill.CodSkill__c, iSkill);
        }
        
        return mapExtIdSkill;
    }

    private void genCodSkillSet(List<Transfer> lstTranfers){
        for(Transfer iTransfer : lstTranfers){
            this.setCodSkill.add(iTransfer.skillId);
            if(iTransfer.transfers != null){
                genCodSkillSet(iTransfer.transfers);
            }
        }
    }
    
    private Transferencia__c convertTransferToTransferencia(Transfer iTransfer) {
        Transferencia__c newTransferencia = new Transferencia__c();
        newTransferencia.CodTransferencia__c = iTransfer.transferId;
        newTransferencia.Name = iTransfer.label;
        newTransferencia.IsActive__c = iTransfer.isActive;
        newTransferencia.DestinoVDNTC__c = iTransfer.destinoVDNTC;
        if(this.mapSkill.containsKey(iTransfer.skillId)) {
            newTransferencia.OrigemSkill__c = this.mapSkill.get(iTransfer.skillId).Id;
        }
        
        return newTransferencia;
    }
   
    private class Transfer {
        //public String nivelSuperiorName {get; set;}
        
        public String transferId {get; set;}
        public String label {get; set;} 
        public String nivelSuperior {get; set;} 
        Public String skillId {get; set;}
        Public String destinoVDNTC {get; set;}
        public Boolean isActive {get; set;}
        public List<Transfer> transfers {get; set;}
    }
}