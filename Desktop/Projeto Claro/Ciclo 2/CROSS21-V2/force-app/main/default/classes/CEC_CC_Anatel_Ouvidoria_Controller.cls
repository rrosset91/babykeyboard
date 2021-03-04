/**
 * ---------------------------------------------------------------
 * Data: 13/10/2020
 * Autor: Squad Anatel/Ouvidoria - Sysmap Solutions [Ello Serafim/Guilherme Cuencas]
 * Descrição: ANATEL - Validação de protocolo - Controller para consulta do Caso
*/
global class CEC_CC_Anatel_Ouvidoria_Controller {
    
    /**
     * Valida se um protocolo de ouvidoria existe no Salesforce para consulta via Anatel
     */
    public static CEC_CC_Anatel_Ouvidoria_ProtocolResponse validateProtocol(String caseNumber){
        Id rtOuvidoriaId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CEC_CC_Ouvidoria').getRecordTypeId();
        CEC_CC_Anatel_Ouvidoria_ProtocolResponse response = new CEC_CC_Anatel_Ouvidoria_ProtocolResponse();
        RestRequest request = RestContext.request;
        Date dt180Days = system.today() - 180;
        Date dt10Days = system.today() - 10;
        RestResponse res = RestContext.response;
        // Buscar por casenumber
        // buyscar no caso pai

        String[] statuses = new String[]{ 'Closed', 'Answered', 'New', 'In Progress', 'Cancelled'};
        Case[] cases = [SELECT CaseNumber, Status, Account.DocumentNumber__c, AccountDocumentType__c , ParentCaseProtocol__c, CreatedDate, ClosedDate, Substatus__c,
        TermOfTreatmens__c, MilestoneDate__c, Product__c
                        FROM Case 
            			WHERE 
                        RecordTypeId = :rtOuvidoriaId 
                        AND CaseNumber = :caseNumber
                        AND Status IN :statuses
                        // AND (
                        //    ((Status = 'Closed' OR Status = 'Answered')
                        //         AND CreatedDate > :dt180Days)
                        //     OR
                        //     ((Status = 'New' OR Status = 'In Progress') 
                        //      	AND CreatedDate < :dt10Days)) 
                        LIMIT 1 
                       ];
        System.debug(cases);
       
        

        
        if(cases.size() == 0){
            response.statusWS = '10';
            response.statusProtocolo = '21'; //Protocolo inexistente
            response.numero = caseNumber;
            response.atendimento = new CEC_CC_Anatel_Ouvidoria_ProtocolResponse.AtendimentoResponse();
            res.statusCode = 200;
            return response;
        }
        Case c = cases[0];

        /*
        if(c.CreatedDate > dt10Days){
            response.statusWS = '10';
            response.statusProtocolo = '20';
            res.statusCode = 422;
            response.atendimento = new CEC_CC_Anatel_Ouvidoria_ProtocolResponse.AtendimentoResponse();
            return response;
        }
		*/
        System.debug(c);

        response.numero = c.CaseNumber;
        response.statusWS = '10';
        response.statusProtocolo = '10';
        response.atendimento = new CEC_CC_Anatel_Ouvidoria_ProtocolResponse.AtendimentoResponse();
        response.atendimento.tipoDocumento = (c.AccountDocumentType__c == 'CPF'? '1': (c.AccountDocumentType__c == 'CNPJ'? '2':''));
        response.atendimento.cpfCnpjConsumidor = c.Account.DocumentNumber__c;
        

        response.atendimento.dataHoraRegistro = c.CreatedDate.format('yyyy-MM-dd')+'T'+c.CreatedDate.format('HH:mm:ss') + 'Z';
        response.atendimento.respondido = (c.SubStatus__c == 'Encerrado' || c.SubStatus__c == 'Respondido e Aguardando Avaliação'? '1' : '2');
  	    response.atendimento.telContato = '08007010180';
        response.atendimento.servicoReclamado =  getServicoReclamado(c.Product__c);

        
        Datetime prazoResposta = c.CreatedDate.addDays(10);
        // Se for fechado, o prazo de resposta é até 180 dias após abertura
        // Datetime prazoResposta;
        // if(c.Status == 'Closed' || c.Status == 'Answered'){
        //      prazoResposta = c.CreatedDate.addDays(180);
        // }
        // //Se for aberto, após 10 dias
        // else if(c.Status == 'New' || c.Status == 'In Progress'){
        //      prazoResposta = c.CreatedDate.addDays(10);
        // }
        response.atendimento.prazoResposta = prazoResposta.format('yyyy-MM-dd')+'T'+prazoResposta.format('HH:mm:ss') + 'Z';
       
        // -----------------------------------------------
        //*/

        res.statusCode = 200;
        return response;
    }
    
    private static String getServicoReclamado(string product){
        Map<String, String> productToServiceMap = new Map<String, String>{
            'Banda Larga' => '2',
                'Controle'=> '2',
                'Claro Fixo' => '3',
                'Claro Flex' => '1',
                'Claro Fone' => '3',
                'Grandes Empresas' => '2',
                'Claro Internet Casa' => '2',
                'Claro NET Fone' => '3',
                'Claro NET Vírtua' => '4',
                'Claro PME' => '2',
                'Pós Pago' => '2',
                'Pré' => '1',
                'Claro TV' => '5',
                'Claro TV Livre' => '5',
                'Controle Fácil' => '2',
                'Corp TB' => '3',
                'Corp' => '3',
                'LD' => 	'3',
                'Sem Produto' => '20',
                'TUP' => '3'
                };
         return productToServiceMap.get(product);
    }
    
}