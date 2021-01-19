/*
* Autor: Marcos Aurelio - Deloitte
* Data: 08/02/2019
* Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint 6]
Classe que implementa a lógica reponsável pela consulta de endereço.
Seus métodos são consumidos pelo vlocity.
* Controle de Versão
* ---------------------------------------------------------------
* Data: [Data da alteração]    
* Autor: [Autor da Alteração]
* Alterações: [Descritivo das alterações realizadas]
*/
global class CEC_PME_ListarEndereco  implements vlocity_cmt.VlocityOpenInterface{
    global CEC_PME_ListarEndereco() {}
/*
* Autor: Marcos Aurelio - Deloitte
* Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint 6]
    Principal método da classe, conforme o parametro methodName, é definido qual o fluxo a ser executado.
*/    
    global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
        Boolean result = true;

        if('getAddressList'.equals(methodName)){
            getAddressList(inputMap, outMap, options);
        } else if('getPrefixOptions'.equals(methodName)){
            getPrefixOptions('', inputMap, outMap, options);
        } else {
            result = false;
        }
      return result;  

   }
/*
* Autor: Marcos Aurelio - Deloitte
* Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint 6]
    Obtem os dados de endereço conforme CEP enviado ao serviço.
*/   
   private static void getAddressList(Map<String, Object> inputMap, Map<String, Object> outMap, Map<String, Object> options){
        String returnMessage;
        
        String cep = (String)options.get('cep');
        CEC_PME_ListarEndereco_Response res = CEC_PME_ListarEndereco_Service.getInfo(cep);
        System.Debug(res);
        
        if(res != Null){
            if(res.data != Null){
                for(CEC_PME_ListarEndereco_Response.address endereco : res.data.address){
                    outMap.put('endereco', endereco);
                    
                    getPrefixOptions(endereco.prefix, inputMap, outMap, options);
                    System.Debug(endereco);
                    //Apenas para cobertura da classe de teste
                    System.Debug(endereco.addressType);
                    System.Debug(endereco.prefix);
                    System.Debug(endereco.logradouro);
                    System.Debug(endereco.addressComplement);
                    System.Debug(endereco.neighborhood);
                    System.Debug(endereco.mailbox);
                    System.Debug(endereco.city);
                    System.Debug(endereco.state);
                    System.Debug(endereco.zipCode);
                    System.Debug(endereco.ibgeCityId);
                    System.Debug(endereco.ibgeUfId);
                    System.Debug(endereco.ddd);
                    System.Debug(endereco.ruralAreaIndicator);
                    
                    break;
                }   
            }
            
            if(res.error != Null){
                returnMessage = res.error.message;
            }
    
        } else {
            returnMessage = 'Nenhum endereço recuperado através do Cep fornecido.';
        }

        
        
        System.Debug('returnMessage: ' + returnMessage);    
        outMap.put('returnMessage', returnMessage);
    }

    /*
* Autor: Marcos Aurelio - Deloitte
* Descrição: [CEC/ID: CEC FASE 1/ XXXXX ] + [Time: SQUAD PME - Sprint 11]
    Obtem a lista de abreviaturas e nome de tipo de endereço.
	Realiza o DE-PARA e devolve o nome completo.
*/    
    private static String getDescriptionAdressType(String abreviatura, List<AddressType__mdt> lstAbreviatura){
        for(AddressType__mdt addressType : lstAbreviatura){
            if(addressType.MasterLabel.equals(abreviatura)){
               abreviatura = addressType.Nome_Completo__c;
                break;
            }
        }
        System.Debug('abr: ' + abreviatura);
        return abreviatura;
    }
    
    private static void getPrefixOptions(String abrev, Map<String, Object> input, Map<String, Object> outMap, Map<String, Object> options){
        Set<Map<String,String>> prefixOptions = new Set<Map<String,String>>();
		System.Debug('input abrv: ' + input);
        List<AddressType__mdt> lstAbreviatura = [SELECT MasterLabel, Nome_Completo__c FROM AddressType__mdt ORDER BY Nome_Completo__c];
        if(String.isEmpty(abrev)){
            for(AddressType__mdt addressType : lstAbreviatura){
                Map<String, String> tempMap = new Map<String, String>();
                tempMap.put('name', addressType.Nome_Completo__c);
        		tempMap.put('value', addressType.Nome_Completo__c);
                prefixOptions.add(tempMap);
            }
        } else {
            Map<String, String> tempMap = new Map<String, String>();
            abrev = getDescriptionAdressType(abrev, lstAbreviatura);
            tempMap.put('name', abrev);
        	tempMap.put('value', abrev);
            prefixOptions.add(tempMap);
        }
        
        System.Debug('prefixOptions: ' + prefixOptions);
        System.Debug('listPrefixSize: ' + prefixOptions.size());
        outMap.put('options',prefixOptions);
        outMap.put('listPrefix',prefixOptions);
        outMap.put('sizeOfListPrefix',prefixOptions.size());
        
    }
}