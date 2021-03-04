/*
* Autor: Diego Lima - Deloitte
* Data: 05/08/2019
* Descrição: [Nome do projeto/ID: CEC FASE 1] + [Time: SQUAD CTI - Sprint 9] + [Classe utilizada como controller da 
* VisualForce CEC_CTI_ControlSoftphone]
* Controle de Versão
* ---------------------------------------------------------------
* Data: 08/08/2019
* Autor: Diego Lima - Deloitte
* Alterações: Criação da classe e dos métodos checkRamal, checkClickDial, decryptDriverData, searchURL, decryptData]
*-----------------------------------------------------------------
* Data: 17/10/2019
* Autor: André Salgado - Claro
* Alterações: [US 32422 - Enriquecer os dados de telefonia da URA] Adequação dos metodos decryptDriverData e *searchURL para recebimento do novo formato de Json para EXT1 que realiza o mapping das classes genericas Data, *Customer, Ura e Driver.
*
* Data: 25/10/2019
* Autor: Diego Lima - Deloitte
* Alterações: Adequação para que conferência, espera e finalizar chamada fiquem ativas quando não há skill definido.
*-----------------------------------------------------------------
* Data: 06/12/2019
* Autor: Diego Lima - Deloitte
* Alterações: Adequação para que Transferência, Mudança na query de skill como 'string' para 'ID' para a montagem da matriz de transferência .
*-----------------------------------------------------------------
* Data: 28/07/2020
* Autor: Wanderson Viena - Deloitte
* Alterações: Adição do Metodo createIVRCustomerInteraction para criação do Customer Interaction
* [92254 - CTI -CRM CROSS - PROTOCOLO URA RESIDENCIAL + 92255 CTI - CRM CROSS - PROTOCOLO URA MÓVEL + 
* 92248 CTI - CRM CROSS - SCRIPT POINT NAVEGAÇÃO URA RESIDENCIAL].
*/

global with sharing class CEC_CTI_ControlSoftphoneController {
    
    global static CEC_CTI_SoftPhoneWrapper wrapperSoftphoneGlobal = new CEC_CTI_SoftPhoneWrapper();
    global static String varCrypto {get;set;}
    
    public CEC_CTI_ControlSoftphoneController()
    {
        //wrapperSoftphoneGlobal = new CEC_CTI_SoftPhoneWrapper();
        //wrapperSoftphoneGlobal.ramal = '293023';
    }
    
    /*
    * Autor: Diego Lima - Deloitte
    * Descrição: [Nome do projeto/ID: CEC FASE 1] + [Time: SQUAD CTI - Sprint 8] + [O método getContact 
    * cria um registro de contato para ser utilizado nas classes de testes]
    */
    @RemoteAction
    global static CEC_CTI_SoftPhoneWrapper checkRamal(String siteId, String numRamal) {
        
       
        String pageSiteId = siteId; 
        String pageRamal = numRamal;
                
        System.debug('pageSiteId = ' + pageSiteId );
        System.debug('numRamal = ' + numRamal );
        System.debug('wrapperSoftphoneGlobal => '+ wrapperSoftphoneGlobal);
        
        wrapperSoftphoneGlobal.ramal = pageRamal;    
        wrapperSoftphoneGlobal.siteId = pageSiteId;
        
        wrapperSoftphoneGlobal.mensagemErro = 'Nenhum erro ao atualizar os valores';
        wrapperSoftphoneGlobal.ligacaoExterna = checkClickDial(pageSiteId);
        system.debug('ligacao externa' + wrapperSoftphoneGlobal.ligacaoExterna);
        return wrapperSoftphoneGlobal;   
    }
    
    /*
    * Autor: Thamires Siman - Deloitte
    * Descrição: [Nome do projeto/ID: CEC FASE 1] + [Time: SQUAD CTI - Sprint 8] + [Verifica permissão para realizar 
    * ligações externas, e então clickToDial ser ativado via JS no front]
    */
    @RemoteAction
    global static Boolean checkClickDial(String siteId) {
        if(siteId != null)
        {            
            List<Site__c> lstSite = [SELECT Id, LigacaoExterna__c FROM Site__c WHERE CodSite__c = :siteId AND IsActive__c = true];
            if(lstSite.size() == 1)
            {
                Boolean ligacaoExterna;
                ligacaoExterna = lstSite[0].LigacaoExterna__c;
                return ligacaoExterna;
            }
            else
                return false;
        }
        else
            return false;
    }
    
    /*
    * Autor: Diego Lima - Deloitte
    * Descrição: [Nome do projeto/ID: CEC FASE 1] + [Time: SQUAD CTI - Sprint 10] + [Verifica permissão para realizar 
    * ligações transferências, e então o botão de transferência de chamada ser ativado via JS no front]
    */
    global static Boolean checkTransferCall(String numSkill, String siteId){
        
        System.debug('entrou transfercall');
        system.debug('numSkill = ' + numSkill );
        system.debug('siteId = ' + siteId );
                
        List<Skill__c> lstSkill = [SELECT Id,(
                                    SELECT Id,
                                    Name,
                                    DestinoVDNTC__c
                                    FROM Transferencias__r 
                                    WHERE DestinoVDNTC__c != '')
                                    FROM Skill__c 
                                   WHERE CodSkill__c =: numSkill AND
                                   Site__r.CodSite__c =: siteId
                                   AND IsActive__c = true
                                  ];
        if(lstSkill.size() == 1)
        {
            Boolean transferCall;
            transferCall = lstSkill[0].Transferencias__r.size() > 0;
            wrapperSoftphoneGlobal.skillId = lstSkill[0].Id;
            System.debug('Entrou IF checkTransferCall - transferCall =  ' + transferCall);
            return transferCall;
        }
        else
            return false;
    }
    
    /*
    * Autor: Diego Lima - Deloitte
    * Descrição: [Nome do projeto/ID: CEC FASE 1] + [Time: SQUAD CTI - Sprint 10] + [Verifica permissão para 
    * colocar chamada em espera, para então o botão de espera de chamada ser ativado via JS no front]
    */
    global static CEC_CTI_SoftphoneWrapper checkHoldAndFinishCall(String numSkill, String siteId){
        
        System.debug('entrou checkHoldAndFinishCall');
        system.debug('checkHoldAndFinishCall numSkill = ' + numSkill );
        system.debug('checkHoldAndFinishCall siteId = ' + siteId );

        //if(numSkill != null || numSkill != '' || numSkill != ' ')
        if(String.isNotEmpty(numSkill))
        {       
            
            system.debug('ENTROU IF CHECK SKILL 1 - skill = ' + numSkill + 'e siteId = ' + siteId);
                        
            List<Skill__c> lstSkill = [SELECT Id, 
                                       Espera__c, 
                                       Desliga__c,
                                       Conferencia__c
                                       FROM Skill__c 
                                       WHERE CodSkill__c = :numSkill
                                      AND Site__r.CodSite__c =: siteId
                                      AND IsActive__c = true];
            system.debug('checkHoldAndFinishCall - lstSkill.size() - ' + lstSkill.size());
            if(lstSkill.size() == 1){
                                
                //String skillSplit = numSkill.split('\\|')[1];
                //system.debug('ENTROU IF CHECK SKILL 2 === ' + skillSplit);
                //if(String.isNotEmpty(skillSplit)){
                    
                    system.debug('ENTROU IF CHECK SKILL 3');
                    
                    Boolean ligacaoEspera;
                    ligacaoEspera = lstSkill[0].Espera__c;
                    
                    wrapperSoftphoneGlobal.chamadaEspera = lstSkill[0].Espera__c;
                    wrapperSoftphoneGlobal.finalizarChamada = lstSkill[0].Desliga__c;
                    wrapperSoftphoneGlobal.conferenciaChamada = lstSkill[0].Conferencia__c;
                /*    
                } else {
                    
                    system.debug('ENTROU ELSE CHECK SKILL 1');
                    
                    wrapperSoftphoneGlobal.chamadaEspera = true;
                    wrapperSoftphoneGlobal.finalizarChamada = true;
                    wrapperSoftphoneGlobal.conferenciaChamada = true;
                }
				*/
            } else {
                
                system.debug('ENTROU ELSE CHECK SKILL 2');
                
                wrapperSoftphoneGlobal.chamadaEspera = false;
                wrapperSoftphoneGlobal.finalizarChamada = false;
                wrapperSoftphoneGlobal.conferenciaChamada = false;
            }
            
        } else {
		
            system.debug('ENTROU ELSE CHECK SKILL 3');
            
            System.debug('entrou no else checkHoldAndFinishCall (Skill em branco)');
            wrapperSoftphoneGlobal.chamadaEspera = false;
            wrapperSoftphoneGlobal.finalizarChamada = false;
            wrapperSoftphoneGlobal.conferenciaChamada = false;         
        }
        
        return wrapperSoftphoneGlobal;
    }
    
    /*
    * Autor: Diego Lima - Deloitte
    * Descrição: [Nome do projeto/ID: CEC FASE 1] + [Time: SQUAD CTI - Sprint 10] + [Verifica permissão para 
    * desligar a chamada, para então o botão de finalizar chamada ser ativado via JS no front]
    
    global static Boolean checkFinishCall(String numSkill){
        
        System.debug('entrou checkFinishCall');
        system.debug('numSkill = ' + numSkill );

        if(numSkill != null)
        {            
            List<Skill__c> lstSkill = [SELECT Id, Desliga__c FROM Skill__c WHERE CodSkill__c = :numSkill];
            if(lstSkill.size() == 1)
            {
                Boolean ligacaoDesliga;
                ligacaoDesliga = lstSkill[0].Desliga__c;
                return ligacaoDesliga;
            }
            else
                return false;
        }
        else
            return false;
      
    }
    */
    
    /*
    * Autor: Diego Lima - Deloitte
    * Descrição: [Nome do projeto/ID: CEC FASE 1] + [Time: SQUAD CTI - Sprint 10] + [Cria a arvore com
    * as opcoes para a trasnferencia da chamada]
    */
    @RemoteAction
    global static CEC_CTI_TransferCallWrapper createTreeToTransfer(String numSkill) {    
       
        System.debug('valorSkill createTreeToTransfer => ' + numSkill);
        Id idSkill;
                
        List<Skill__c> lstSkill = [SELECT Id, CodSkill__c, Name FROM Skill__c WHERE CodSkill__c =: numSkill];
        
        if(lstSkill.size() == 1){
            idSkill = lstSkill[0].Id;
        }
        
        CEC_CTI_TransferCallWrapper transferWrapper = new CEC_CTI_TransferCallWrapper();
        
        List<Transferencia__c> lstTransferencia = [SELECT Id, 
                                                   Name,
                                                   DestinoVDNTC__c,
                                                   NivelSuperior__r.Name, NivelSuperior__c,
                                                   NivelSuperior__r.NivelSuperior__r.Name, NivelSuperior__r.NivelSuperior__c,
                                                   NivelSuperior__r.NivelSuperior__r.NivelSuperior__r.Name, NivelSuperior__r.NivelSuperior__r.NivelSuperior__r.DestinoVDNTC__c
                                                   FROM Transferencia__c 
                                                   WHERE DestinoVDNTC__c != '' 
                                                   AND OrigemSkill__c =: idSkill    
                                                   AND IsActive__c = true
                                                  ];
        
        System.debug('lstTransferencia = ' + lstTransferencia);
        System.debug('lstTransferencia size = ' + lstTransferencia.size());
        List<CEC_CTI_TransferCallWrapper> lstTransferWrapper = new List<CEC_CTI_TransferCallWrapper>();
        Map<String, Transferencia__c> map1Nivel = new Map <String, Transferencia__c>();
        Map<String, Transferencia__c> map2Nivel = new Map <String, Transferencia__c>();
            
        for(Transferencia__c sObjTransferencia  : lstTransferencia){      
            
            if(sObjTransferencia.NivelSuperior__c != null){
                Transferencia__c auxTransferencia = new Transferencia__c();
                auxTransferencia.Id = sObjTransferencia.NivelSuperior__c;
                auxTransferencia.Name = sObjTransferencia.NivelSuperior__r.Name;
                auxTransferencia.NivelSuperior__c = sObjTransferencia.NivelSuperior__r.NivelSuperior__c;

                map2Nivel.put(auxTransferencia.Id, auxTransferencia);
                //transferWrapper.set2Nivel.add(auxTransferencia);
                //lstTransferWrapper.add(transferWrapper);
            }  
            
            if(sObjTransferencia.NivelSuperior__r.NivelSuperior__c != null){
                Transferencia__c auxTransferencia = new Transferencia__c();
                auxTransferencia.Id = sObjTransferencia.NivelSuperior__r.NivelSuperior__c;
                auxTransferencia.Name = sObjTransferencia.NivelSuperior__r.NivelSuperior__r.Name;
                
                map1Nivel.put(auxTransferencia.Id, auxTransferencia);
                //transferWrapper.set1Nivel.add(auxTransferencia);
            }
            transferWrapper.set3Nivel.add(sObjTransferencia);            
        }
        
        System.debug('Map1 antes do remove: ' + map1Nivel);
        map2Nivel.keySet().removeAll(map1Nivel.keySet());
        System.debug('Map1 depois do remove: ' + map1Nivel);
        transferWrapper.set1Nivel = map1Nivel.values();
        System.debug('set do wrapper' + transferWrapper.set1Nivel);
        transferWrapper.set2Nivel = map2Nivel.values();

        System.debug('transferWrapper = ' + transferWrapper);
        
        return transferWrapper;
    }
    

    /*
    * Autor: Diego Lima - Deloitte
    * Descrição: [Nome do projeto/ID: CEC FASE 1] + [Time: SQUAD CTI - Sprint 10] + [Efetuar a descriptografia
    * dos valores enviados ao drive]
    *
    * Modificado por: Leandro Cubas - Deloitte
    * Descrição: [Nome do projeto/ID: Solar FASE 2] + [Time: SQUAD CTI] + [Correção de disparo multiplo de tela ao atualizar a pagina e ajustar a criação
    * de Customer Interaction ao atualizar a pagina]
    */
    @RemoteAction

    global static CEC_CTI_SoftPhoneWrapper decryptDriverData(String varCrypto, String driverSiteId, String varCustomerInteraction, Boolean isDialExternalCall) {

        
        Id profileId = UserInfo.getProfileId();
        String profileName = [Select Id,Name from Profile where Id=:profileId].Name;
        
        String decryptedString = decryptData(varCrypto);
        CEC_CTI_SoftPhoneWrapper wrapperSoptphone = new CEC_CTI_SoftPhoneWrapper();
        CEC_CTI_SoftPhoneWrapper.DateCTI mapJson = (CEC_CTI_SoftPhoneWrapper.DateCTI) JSON.deserialize(decryptedString, CEC_CTI_SoftPhoneWrapper.DateCTI.class);
        
        if(mapJson != null){
            wrapperSoptphone = new CEC_CTI_SoftPhoneWrapper(mapJson);            
        }
        
        String driverSkill = wrapperSoptphone.skillId;
        
        wrapperSoptphone.ticketIVR = decryptedString;
        wrapperSoptphone.transferenciaChamada = checkTransferCall(driverSkill, driverSiteId);
        checkHoldAndFinishCall(driverSkill, driverSiteId);
        wrapperSoptphone.chamadaEspera = wrapperSoftphoneGlobal.chamadaEspera;
        wrapperSoptphone.finalizarChamada = wrapperSoftphoneGlobal.finalizarChamada;
        wrapperSoptphone.conferenciaChamada = wrapperSoftphoneGlobal.conferenciaChamada;
        wrapperSoptphone.skillId = driverSkill;//wrapperSoftphoneGlobal.skillId;
           
        System.debug('valor da skill do json = ' + driverSkill);
        System.debug('valor da skill = ' + wrapperSoptphone.skillId);
        System.debug('wrapperSoptphone.numeroTelefone = ' + wrapperSoptphone.numeroTelefone);
        System.debug('wrapperSoptphone.nomeCliente = ' + wrapperSoptphone.nomeCliente);
        System.debug('valor do site id = ' + driverSiteId);  
        System.debug('wrapperSoptphone.transferenciaChamada =  ' + wrapperSoptphone.transferenciaChamada);  
        System.debug('wrapperSoptphone.chamadaEspera = ' + wrapperSoptphone.chamadaEspera);
        System.debug('wrapperSoptphone.finalizarChamada = ' + wrapperSoptphone.finalizarChamada);
        System.debug('wrapperSoptphone.conferenciaChamada = ' + wrapperSoptphone.conferenciaChamada);
        System.debug('varCustomerInteraction = ' + varCustomerInteraction);
        
        if(wrapperSoptphone.tipoDocumento == 'CNPJ'){
            wrapperSoptphone.docIsCPF = false;
        } else if (wrapperSoptphone.tipoDocumento == 'CPF'){
            wrapperSoptphone.docIsCPF = true;
        } else {
            wrapperSoptphone.docIsNull = true;
        }
        

        if(isDialExternalCall == false){


            wrapperSoptphone.urlReturned = searchURL(wrapperSoptphone, profileName);
            /*
            * O método abaixo (updateWrapper) prepara a URL da tela que será aberta em contexto e cria um Customer Interaction. 
            * Esse método será executado, somente quando não encontrar um customer interaction com o ID recebido do driver.
            */
            if(String.isNotBlank(varCustomerInteraction)){
                List<vlocity_cmt__CustomerInteraction__c> listCustomerInteraction = [SELECT Id FROM vlocity_cmt__CustomerInteraction__c WHERE Id =: varCustomerInteraction LIMIT 1];
    
                if(listCustomerInteraction.isEmpty()){
                    wrapperSoptphone = updateWrapper(wrapperSoptphone, profileName);
                } else {
                    wrapperSoptphone.idCustomerInteraction = listCustomerInteraction[0].Id;
                }
            } else {
                wrapperSoptphone = updateWrapper(wrapperSoptphone, profileName);
            }
    
            wrapperSoptphone = updateUrlReturned(wrapperSoptphone);
        }

        System.debug('url => ' + wrapperSoptphone.urlReturned);

        return wrapperSoptphone;
    }
        
    /*
    * Autor: Leandro Cubas - Deloitte
    * Data: 01/12/2020
    * Descrição: [Nome do projeto/ID: Solar FASE 2] + [Time: SQUAD CTI] + [Atualiza os campos "idCustomerInteraction" e  
    * "urlReturned". Esse último somente se um caso for criado. ]
    */
    private static CEC_CTI_SoftPhoneWrapper updateWrapper(CEC_CTI_SoftPhoneWrapper wrapperSoptphone, String profileName){
        System.debug('Method updateWrapper');
        // Solução provisória feita para não gerar impacto com ME conforme acordado em 24/08/2020. Author: Wanderson Viena Deloitte
        if(profileName != 'CRN_ATENDIMENTO_ME_CEC'){ 
            wrapperSoptphone.idCustomerInteraction = createIVRCustomerInteraction(wrapperSoptphone);
            System.debug('idCustomerInteraction => ' + wrapperSoptphone.idCustomerInteraction);
        }
        

        // Tenta criar um caso se a url estiver em branco
        if(String.isBlank(wrapperSoptphone.urlReturned)){
            String casoId = createSolarManagementCase(wrapperSoptphone);
            System.debug('casoId: ' + casoId);

            if(String.isNotBlank(casoId)){
                wrapperSoptphone.urlReturned = '/lightning/r/Case/'+casoId+'/view';
            } else {
                // Se não conseguir criar um caso, busca a url padrão e substitui a tag <<newCase>>
                List <CEC_CTI_Disparador__mdt> listaDisparador = [SELECT URL__c FROM CEC_CTI_Disparador__mdt WHERE DeveloperName = 'CEC_CTI_PADRAO_360' limit 1];
                
                if(!listaDisparador.isEmpty()){
                    wrapperSoptphone.urlReturned = listaDisparador[0].URL__c;
                }
                System.debug('>>> Não conseguiu criar o caso');

            }

        } 

        return wrapperSoptphone;
    }



    /*
    * Autor: Leandro Cubas - Deloitte
    * Data: 23/12/2020
    * Descrição: [Nome do projeto/ID: Solar FASE 2] + [Time: SQUAD CTI] + [Atualiza o campo urlReturned 
    * trocando as tags <<xxxx>> pelos valores correspondentes ]
    */
    private static CEC_CTI_SoftPhoneWrapper updateUrlReturned(CEC_CTI_SoftPhoneWrapper wrapperSoptphone){
        System.debug('Method updateUrlReturned');
        if(wrapperSoptphone.urlReturned.contains('<<cpfcnpj>>')){ 
            wrapperSoptphone.urlReturned = wrapperSoptphone.urlReturned.replace('<<cpfcnpj>>', wrapperSoptphone.numeroDocumento);
        }

        if(wrapperSoptphone.urlReturned.contains('<<tipodoc>>')){ 
            wrapperSoptphone.urlReturned = wrapperSoptphone.urlReturned.replace('<<tipodoc>>', wrapperSoptphone.tipoDocumento);
        }

        if(wrapperSoptphone.urlReturned.contains('<<codnet>>')){
            wrapperSoptphone.urlReturned = wrapperSoptphone.urlReturned.replace('<<codnet>>', getCodigoNet(wrapperSoptphone));
        }

        if(wrapperSoptphone.urlReturned.contains('<<codcidade>>')){
            wrapperSoptphone.urlReturned = wrapperSoptphone.urlReturned.replace('<<codcidade>>', wrapperSoptphone.codCidade);
        }

        if(wrapperSoptphone.urlReturned.contains('<<protocolo>>')){
            wrapperSoptphone.urlReturned = wrapperSoptphone.urlReturned.replace('<<protocolo>>', wrapperSoptphone.protocolo);
        }   

        return wrapperSoptphone;
    }

    /*
    * Autor: Leandro Cubas - Deloitte
    * Descrição: [Nome do projeto/ID: Solar FASE 2] + [Time: SQUAD CTI] + [Realiza tratativa 
    * para numero do contrato que vem no parametro 'customerAccountId' do retorno do drive]
    */
    private static String getCodigoNet(CEC_CTI_SoftPhoneWrapper wrapperSoptphone){
        String customerAccountId = wrapperSoptphone.codigoNet;
        String cityId = wrapperSoptphone.codCidade;
        String codigoInicial = customerAccountId.substring(0,3);
        String codigoNet;
        
        if(codigoInicial.equals(cityId)){
            codigoNet = customerAccountId.substring(3, customerAccountId.length());
        } else {
            codigoNet = customerAccountId;
        }
        return codigoNet;
    }

    /*
    * Autor: Diego Lima - Deloitte
    * Descrição: [Nome do projeto/ID: CEC FASE 1] + [Time: SQUAD CTI - Sprint 10] + [Busca de URL
    * para descriptografia vinda do drive]
    */
    //public static String searchURL(String decryptedString){
    public static String searchURL(CEC_CTI_SoftPhoneWrapper wrapperSoptphone, String profileName){
        
        String mpl;
        String partyIdentificationNumber;
        String customerName;
        String protocolNumber;
        String contractNumber;
        String skillId;
        String vdnOrigin;
        String partyIdentificationType;
        String returnURL;
        String casoId;

        mpl = wrapperSoptphone.mpl;//String.valueof(mapJson.get('mpl'));
        
        contractNumber = checkContract(wrapperSoptphone.codigoNet);// String.valueof(mapJson.get('contrato')));
        customerName = checkCustomerName(wrapperSoptphone.nomeCliente);//String.valueof(mapJson.get('nome')));
        partyIdentificationNumber = checkPartyIdNumber(wrapperSoptphone.numeroDocumento); //String.valueof(mapJson.get('partyIdentificationNumber')));
        protocolNumber = checkProtocolNumber(wrapperSoptphone.protocolo);//String.valueof(mapJson.get('protocolo')));
        skillId = wrapperSoptphone.skillId;//String.valueof(mapJson.get('skill'));
        vdnOrigin = wrapperSoptphone.vdnOrigin; //String.valueof(mapJson.get('vdn'));
        partyIdentificationType = wrapperSoptphone.tipoDocumento;//String.valueof(mapJson.get('partyIdentificationType'));
        returnURL = '';
        
        // skillId = '3135';
        System.debug('skillId: ' + skillId);
        
       
        
        try{
            
            List <CEC_CTI_Disparador__mdt> listaDisparador = new List <CEC_CTI_Disparador__mdt>();
            
            if(Test.isRunningTest()){
              
                listaDisparador = CEC_CTI_GetListDisparadoresURL.generateListMetadata();
                
            } else {   
                listaDisparador = [SELECT URL__c,
                                   mpl__c,
                                   partyIdentificationNumber__c,
                                   customerName__c,
                                   protocolNumber__c,
                                   contractNumber__c,
                                   partyIdentificationType__c,
                                   skillId__c,
                                   vdnOrigin__c,
                                   Profile__c
                                   FROM CEC_CTI_Disparador__mdt
                                   WHERE skillId__c =: skillId
                                  ];  
            }
            
            Boolean controle = false;

			if(!listaDisparador.isEmpty()){
                system.debug('Skill encontrada no disparador');
                system.debug('listaDisparador =>' + listaDisparador);

                for(CEC_CTI_Disparador__mdt forDisparador : listaDisparador){
                    
                    if(String.isNotBlank(mpl)){
                        if(mpl != forDisparador.mpl__c && String.isnotBlank(forDisparador.mpl__c)){
                            System.debug('Continue 1');
                            continue;
                        } 
                    }

                    if(forDisparador.contractNumber__c != 'Indiferente' && forDisparador.contractNumber__c != 'Não Preenchido'){
                        if(forDisparador.contractNumber__c != contractNumber){
                            System.debug('Continue 2');
                            continue;
                        }                        
                    }

                    if(forDisparador.customerName__c != 'Indiferente' && forDisparador.customerName__c != 'Não Preenchido'){
                        if(forDisparador.customerName__c != customerName){
                            System.debug('Continue 3');
                            continue;
                        }
                    }

                    if(forDisparador.partyIdentificationNumber__c != 'Indiferente' && forDisparador.partyIdentificationNumber__c != 'Não Preenchido'){
                        if(forDisparador.partyIdentificationNumber__c != partyIdentificationNumber){
                            System.debug('Continue 4');
                            continue;
                        }
                    }
                    
                    if(forDisparador.protocolNumber__c != 'Indiferente' && forDisparador.protocolNumber__c != 'Não Preenchido'){
                        if(forDisparador.protocolNumber__c != protocolNumber){
                            System.debug('Continue 5');
                            continue;
                        }
                    }
   
                    if(String.isNotBlank(forDisparador.partyIdentificationType__c)){
                        if(partyIdentificationType != forDisparador.partyIdentificationType__c){
                            System.debug('Continue 6');
                            continue;
                        } 
                    }
                    
                    if(String.isNotBlank(forDisparador.vdnOrigin__c)){
                        if(vdnOrigin != forDisparador.vdnOrigin__c){
                            System.debug('Continue 7');
                            continue;
                            
                        } 
                    }
                    
                    if(String.isNotBlank(forDisparador.Profile__c)){
                        if(forDisparador.Profile__c != profileName){
                            System.debug('Continue 8');
                            continue;
                        } 
                    } 
                    
                    returnURL = forDisparador.URL__c;
                    system.debug('returnURL =>' +returnURL);
                    controle = true;
                    break; 
                    
                }
            }

            // Se não encontrar o Skill na lista de disparo
            if(!controle){
                System.debug('Skill NÃO ENCONTRADA no disparador');
                
                // Se o cliente não foi identificado no retorno da URA (CPF ou CNPJ = '');
                if(String.isBlank(wrapperSoptphone.numeroDocumento)){
                    listaDisparador = [SELECT URL__c FROM CEC_CTI_Disparador__mdt WHERE DeveloperName = 'CEC_CTI_PADRAO_360' limit 1];

                    if(!listaDisparador.isEmpty()){
                            System.debug('listaDisparador =>'+ listaDisparador);
                        returnURL = listaDisparador[0].URL__c;
                            System.debug('returnURL =>'+ returnURL);
                    }
                } else {
                    returnURL = '';
                }
             }

            if(Test.isRunningTest()){
                return returnURL;
            }

            System.debug('returnURL =>'+ returnURL);
            return returnURL;

        } catch(Exception e){
            List <CEC_CTI_Disparador__mdt> listaDisparador = [SELECT URL__c FROM CEC_CTI_Disparador__mdt WHERE DeveloperName = 'CEC_CTI_PADRAO_360' limit 1];

            if(!listaDisparador.isEmpty()){
                returnURL = listaDisparador[0].URL__c;
            }

            System.debug('Exception no metodo searchURL!');
            System.debug('StackTraceString: ' + e.getStackTraceString());
            System.debug('Message: ' + e.getMessage());
            return returnURL;
        }
        
    }
  
    /*
    * Autor: Wanderson Viena - Deloitte
    * Descrição: [Nome do projeto/ID: Solar FASE 2] + [Time: SQUAD CTI - Sprint 10] + [92254 - CTI - 
    * CRM CROSS - PROTOCOLO URA RESIDENCIAL + 92255 CTI - CRM CROSS - PROTOCOLO URA MÓVEL + 
    * 92248 CTI - CRM CROSS - SCRIPT POINT NAVEGAÇÃO URA RESIDENCIAL]
    *
    * Metodo que avalia se existe um customer interaction para o protocolo passado 
    * pelo Json da telfonia, caso exista o id do customer interaction é retornado, caso não exista,
    * será criado um novo com o Recordtype   
	*/
    public static id createIVRCustomerInteraction(CEC_CTI_SoftPhoneWrapper wrapperSoptphone){
       	String ProtocolNumber=wrapperSoptphone.protocolo;
        vlocity_cmt__CustomerInteraction__c varCustomerInteraction = new vlocity_cmt__CustomerInteraction__c();
		/*list<vlocity_cmt__CustomerInteraction__c> lstCustomerInteraction = new list<vlocity_cmt__CustomerInteraction__c>(); 
        list<vlocity_cmt__CustomerInteraction__c> lstCustomerInteractionUpsert = new list<vlocity_cmt__CustomerInteraction__c>(); 
        lstCustomerInteraction = [Select Id from vlocity_cmt__CustomerInteraction__c where ProtocolNumber__c=:ProtocolNumber and RecordType.DeveloperName='DadosURA'];
        */
        Id idRecordId = Schema.SObjectType.vlocity_cmt__CustomerInteraction__c.getRecordTypeInfosByDeveloperName().get('DadosURA').getRecordTypeId();
        //RecordType rctCustomerInteraction = [SELECT Id FROM RecordType WHERE DeveloperName = 'DadosURA' AND sObjectType = 'vlocity_cmt__CustomerInteraction__c'];
         try{
             varCustomerInteraction.Name = 'IVR - '+ ProtocolNumber;
             //CustomerInteraction.OwnerId =UserInfo.getUserId();
             varCustomerInteraction.Document_Number__c=wrapperSoptphone.numeroDocumento;
             varCustomerInteraction.Document_Type__c=wrapperSoptphone.tipoDocumento;
             varCustomerInteraction.ProtocolNumber__c = ProtocolNumber;
             varCustomerInteraction.CEP__c = wrapperSoptphone.postcode;
             varCustomerInteraction.RecordTypeId = idRecordId;

            // condição criada porque foram encontradas Strings com textos descritos como 'null'.
            if(String.isNotBlank(wrapperSoptphone.nomeCliente) && wrapperSoptphone.nomeCliente.toUpperCase() != 'NULL'){
             varCustomerInteraction.CustomerName__c=wrapperSoptphone.nomeCliente;
            }
            
            // condição criada porque foram encontradas Strings com textos descritos como 'null'.
            if(String.isNotBlank(wrapperSoptphone.codigoNet) && wrapperSoptphone.codigoNet.toUpperCase() != 'NULL') { 
             varCustomerInteraction.ContractNumber__c=wrapperSoptphone.codigoNet;
			}
             varCustomerInteraction.ScriptPointCode__c=wrapperSoptphone.scriptPointCode;
             varCustomerInteraction.TicketIVR__c = wrapperSoptphone.ticketIVR;
             varCustomerInteraction.TelephoneNumber__c =wrapperSoptphone.numeroTelefone;
            varCustomerInteraction.ScriptPointDescription__c = wrapperSoptphone.scriptPointDetail;
             
             /* Autor: Leandro Cubas - Deloitte - 10/09/2020
              * Descrição: solução temporaria para não impedir a abertura de tela em contexto, pois o campo protocolo ainda não pode ser exclusivo
             */             
             // upsert varCustomerInteraction  vlocity_cmt__CustomerInteraction__c.Fields.ProtocolNumber__c;
             insert varCustomerInteraction;
             System.debug('varCustomerInteraction.ScriptPointDescription__c: ' + varCustomerInteraction.ScriptPointDescription__c);
            }catch(DmlException e){
                System.debug('A DML exception has occurred: ' + e.getMessage());
            } 
        
        //Metodo que faz check se exite um customer Interaction criado.
        /*If (!lstCustomerInteraction.isEmpty()){
            try{
				for(vlocity_cmt__CustomerInteraction__c vlcustinter: lstCustomerInteraction){
					vlcustinter.Name = 'IVR - '+ ProtocolNumber;
                    //vlcustinter.OwnerId =UserInfo.getUserId();
                	vlcustinter.Document_Number__c=wrapperSoftphone.numeroDocumento;
                	vlcustinter.Document_Type__c=wrapperSoftphone.tipoDocumento;
                	vlcustinter.ProtocolNumber__c = ProtocolNumber;
                	vlcustinter.CEP__c = wrapperSoftphone.postcode;
                	vlcustinter.RecordTypeId = idRecordId;
                    lstCustomerInteractionUpsert.add(vlcustinter);
				}
                //Schema.SObjectField externalIdUpsert = vlocity_cmt__CustomerInteraction__c.Fields.ProtocolNumber__c;
            	upsert lstCustomerInteractionUpsert  vlocity_cmt__CustomerInteraction__c.Fields.ProtocolNumber__c;
                return lstCustomerInteractionUpsert[0].Id;
            }catch(DmlException e){
                System.debug('A DML exception has occurred: ' + e.getMessage());
            }
        }
        else{
            try{
                CustomerInteraction.Name = 'IVR - '+ ProtocolNumber;
                CustomerInteraction.OwnerId =UserInfo.getUserId();
                CustomerInteraction.Document_Number__c=wrapperSoftphone.numeroDocumento;
                CustomerInteraction.Document_Type__c=wrapperSoftphone.tipoDocumento;
                CustomerInteraction.ProtocolNumber__c = ProtocolNumber;
                CustomerInteraction.CEP__c = wrapperSoftphone.postcode;
                CustomerInteraction.RecordTypeId = idRecordId;
                insert CustomerInteraction;
            }catch(DmlException e){
                System.debug('A DML exception has occurred: ' + e.getMessage());
            }    
        }*/
        return varCustomerInteraction.Id;
    }
    
    /*
    * Autor: Diego Lima - Deloitte
    * Descrição: [Nome do projeto/ID: CEC FASE 1] + [Time: SQUAD CTI - Sprint 10] + [Descriptografa
    * dos valores enviados ao drive de acordo com o hash]
    */
    public static String decryptData(String varCrypto){ 
        
        Blob initVector = Blob.valueOf('B<QkzU@75$Pv#nPk');
        Blob key = Blob.valueOf('B<QkzU@75$Pv#nPk#?pK;mz2Xh_xbW]U');
        Blob dataEncrypted = EncodingUtil.base64Decode(varCrypto);
        Blob decrypted = Crypto.decrypt('AES256', key, initVector, dataEncrypted);
        String decryptedData = decrypted.toString();  
    
        return decryptedData;
    }
    
    /*
    * Autor: Diego Lima - Deloitte
    * Descrição: [Nome do projeto/ID: CEC FASE 1] + [Time: SQUAD CTI - Sprint 10] + [Verifica o contrato]
    */
    public static String checkContract(String contractNumber){
        
        String contractReturned;
        
        if(String.isNotBlank(String.valueof(contractNumber))){
            contractReturned = 'Preenchido';
        } 
        
        if(String.isBlank(String.valueof(contractNumber))){
            contractReturned = 'Indiferente / Não Preenchido';
        }
        
        return contractReturned;
    }
    
    /*
    * Autor: Diego Lima - Deloitte
    * Descrição: [Nome do projeto/ID: CEC FASE 1] + [Time: SQUAD CTI - Sprint 10] + [Verifica o nome
    * do cliente]
    */
    public static String checkCustomerName(String customerName){
        
        String nameReturned;
        
        if(String.isNotBlank(String.valueof(customerName))){
            nameReturned = 'Preenchido';
        } 
        
        if(String.isBlank(String.valueof(customerName))){
            nameReturned = 'Indiferente / Não Preenchido';
        }
        
        return nameReturned;
    }
    
    /*
    * Autor: Diego Lima - Deloitte
    * Descrição: [Nome do projeto/ID: CEC FASE 1] + [Time: SQUAD CTI - Sprint 10] + [Verifica o checkPartyIdNumber]
    */
    public static String checkPartyIdNumber(String partyIdentificationNumber){
        
        String partyIdReturned;
        
        if(String.isNotBlank(String.valueof(partyIdentificationNumber))){
            partyIdReturned = 'Preenchido';
        } 
        
        if(String.isBlank(String.valueof(partyIdentificationNumber))){
            partyIdReturned = 'Indiferente / Não Preenchido';
        }
                
        return partyIdReturned;
    }
    
    /*
    * Autor: Diego Lima - Deloitte
    * Descrição: [Nome do projeto/ID: CEC FASE 1] + [Time: SQUAD CTI - Sprint 10] + [Verifica o número de
    * protocolo]
    */
    public static String checkProtocolNumber(String protocolo){
        
        String protocolReturned;
        
        if(String.isNotBlank(String.valueof(protocolo))){
            protocolReturned = 'Preenchido';
        } 
        
        if(String.isBlank(String.valueof(protocolo))){
            protocolReturned = 'Indiferente / Não Preenchido';
        }
                
        return protocolReturned;
    }
    
    /*
    * Autor: Eduardo Marques - Deloitte
    * Descrição: [Nome do projeto/ID: CEC FASE 1] + [Time: SQUAD CTI - Sprint 11] + [O método makeAppointment é responsável
    * por guardar um agendamento dentro de uma task]
    */
    @RemoteAction
    global static String makeAppointment(String customerNameScheduling, String customerDocumentScheduling,
                                         String dayScheduling, String hourAppointmentScheduling,
                                         String titleReasonScheduling, String textReasonScheduling,
                                         String telefone1, String telefone2, String telefone3,
                                         String telefone4, String telefone5) {                                          
                                          
        String dataReplaced = dayScheduling;
        dataReplaced = dataReplaced.substring(6,10) + '-' + dataReplaced.substring(3,5) + '-' + dataReplaced.substring(0,2);
        Date dateFormated = Date.parse(dayScheduling);
        String inicialTimeFormated = hourAppointmentScheduling + ':00';
        String dateTimeFormated = dataReplaced + ' ' + inicialTimeFormated;   
                                             
                                             
        RecordType rctLembrete = [SELECT Id FROM RecordType WHERE DeveloperName = 'Agendamento_de_ligacao' AND sObjectType = 'Task'];
        
        Task tsk = New Task();
        tsk.Subject = titleReasonScheduling;
        tsk.OwnerId = UserInfo.getUserId();
        tsk.ActivityDate = date.parse(dayScheduling);
        tsk.IsReminderSet = true;
        tsk.ReminderDateTime = datetime.valueof(dateTimeFormated);
        tsk.NomeCliente__c = customerNameScheduling;
        tsk.Telefone1__c = telefone1;
        tsk.Telefone2__c = telefone2;
        tsk.Telefone3__c = telefone3;
        tsk.Telefone4__c = telefone4;
        tsk.Telefone5__c = telefone5;
        tsk.RecordTypeId = rctLembrete.Id;
        tsk.Description = textReasonScheduling;                                  
        tsk.DocumentoCliente__c = customerDocumentScheduling;
        tsk.NomeCliente__c = customerNameScheduling;
                                             
        System.debug('Tarefa a ser inserida: ' + tsk);
                                             
        if(System.now() > datetime.valueof(dateTimeFormated))
        {
            return 'Erro: Selecione um horário futuro.';
        }
        else                                     
        {                                     
            try {
                System.debug('sucessso tsk ' + tsk);
                insert tsk;
                return 'SUCCESS';
    
            } catch(Exception e) {
                System.debug('teste makeAppoiment(): ' + e.getMessage());
                return '' + e.getMessage();
            }
        }
    }
    
    /*
    * Autor: Eduardo Marques - Deloitte
    * Descrição: [Nome do projeto/ID: CEC FASE 1] + [Time: SQUAD CTI - Sprint 11] + [Retornar valores da picklist
    * dinâmica, campo Subject]
    */
    @RemoteAction
    global static List<String> getPickListValuesSubject(){
       List<String> pickListValuesList= new List<String>();
        Schema.DescribeFieldResult fieldResult = Task.Subject.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getLabel());
        }     
        System.debug(pickListValuesList);
        return pickListValuesList;
    }
    
    @RemoteAction
    global static String getReportId(){
        String reportId = [SELECT Id FROM Report WHERE DeveloperName = 'Ligaes_Pendentes_MX4'].get(0).Id;
        return reportId;
    }

    @RemoteAction
    global static CEC_CC_InteractionClientController.ReturnSaveCTI sendCallDataToCross(String str){
        return CEC_CC_InteractionClientController.createInteractionTopicByCTI(str);
    }

    @RemoteAction
    global static String maskPhone(String phoneNumber, Boolean isMascared){
        return CEC_CC_InteractionClientController.maskPhone(phoneNumber, isMascared);
    }

    /*
    * Autor: Diego Almeida - IBM
    * Descrição: [Claro SOLAR] [Sprint 0 - Task TU7] Criacao de caso quando derivado da URA
    */
    public static String createSolarManagementCase(CEC_CTI_SoftPhoneWrapper wrapperSoptphone){
        Solar_Cross_CasesController.SolarCaseRequestWrapper requestWrapper = new Solar_Cross_CasesController.SolarCaseRequestWrapper();
        requestWrapper.idCliente = wrapperSoptphone.nomeCliente;//Account.ExternalID__c
        requestWrapper.idContrato = wrapperSoptphone.idExternoContrato;//Account.ContractNumber__c


        requestWrapper.canal          =   'URA';//MappingCaseManagement__mdt.Channel__c
        requestWrapper.codigoProcesso = wrapperSoptphone.mpl;//MappingCaseManagement__mdt.ProcessCode__c
        requestWrapper.protocolo = wrapperSoptphone.protocolo;//ProtocolNumber__c
        requestWrapper.idExterno = wrapperSoptphone.idExterno;
        requestWrapper.motivoContato = wrapperSoptphone.mpl;//Case.CallReason__
        // requestWrapper.produto = 'Controle';//caso.Product__c
        requestWrapper.unidadeNegocios = 'Claro';//caso.BusinessUnit__c
        
        requestWrapper.telephoneNumber = wrapperSoptphone.phoneNumber;

        //Adição de campos TU29
        requestWrapper.serviceType = wrapperSoptphone.serviceType;
        requestWrapper.serviceSubType = wrapperSoptphone.serviceSubType;
        requestWrapper.financialSituation = wrapperSoptphone.financialSituation;
        requestWrapper.invoiceLateDays = wrapperSoptphone.invoiceLateDays;
        requestWrapper.isMovelType = wrapperSoptphone.isMovelType;
        requestWrapper.isNet = wrapperSoptphone.isNet;
        requestWrapper.scritpPointDetail = wrapperSoptphone.scriptPointDetail;
        requestWrapper.lastAccessedSystem = wrapperSoptphone.lastAccessedSystem;
        requestWrapper.systemResponse = wrapperSoptphone.systemResponse;

        Solar_Cross_CasesController.SolarCaseResponseWrapper response = Solar_Cross_CasesController.SolarCreateCase(requestWrapper);
        System.debug('createSolarManagementCase: ' + response);
        return response.casoId;
    }
}