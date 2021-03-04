/**
 * Created by 93668256 on 04/11/2019.
 */

global with sharing class CEC_SalesOrder_Controller implements vlocity_cmt.VlocityOpenInterface {

    private final CEC_SalesOrder_Service service = new CEC_SalesOrder_Service();

    global Boolean invokeMethod(String methodName, Map<String, Object> inputMap,
            Map<String, Object> outMap, Map<String, Object> options) {
        try {
            if (methodName.equalsIgnoreCase('generateSalesOrder')) {
                return executeSalesOrder(inputMap, outMap, options);
            }
            else {
                return false;
            }
        } catch (Exception e) { 
            return false;
        }
    }

    global Boolean executeSalesOrder(Map<String, Object> inputMap, Map<String, Object> outMap, Map<String, Object> options) {
        try
        {
            system.debug(Json.serializePretty(inputMap));
            String PortabilityPreAnalysisObj = Json.serialize(inputMap.get('PorPreAnalysis')); 
            
            PortabilitiesPreAnalysisDTO.PortabilityPreAnalysis analysisDTO =
                    (PortabilitiesPreAnalysisDTO.PortabilityPreAnalysis) System.JSON.deserialize(PortabilityPreAnalysisObj, PortabilitiesPreAnalysisDTO.PortabilityPreAnalysis.class);
            String CreditAnalysisObj = Json.serialize(inputMap.get('CreditAnalysis')); 
            
            IntegrationCreditAnalysisMobileDTO.CredAnalysisResp creditAnalysisMobileDTO =
                    (IntegrationCreditAnalysisMobileDTO.CredAnalysisResp) System.JSON.deserialize(CreditAnalysisObj, IntegrationCreditAnalysisMobileDTO.CredAnalysisResp.class);
			
            String SalesManObj = Json.serialize(inputMap.get('SalesMan'));
            SalesManDTO.SalesMan salesManDTO = (SalesManDTO.SalesMan) System.JSON.deserialize(SalesManObj, SalesManDTO.SalesMan.class);
			
            //Mapeamento de parametro para THAB
            Map<String,Object> ResultChecarCredito = (Map<String,Object>)inputMap.get('ResultChecarCredito');
            Map<String,Object> creditAnalysis = (Map<String,Object>)ResultChecarCredito.get('creditAnalysis');
            Boolean thab = (Boolean)creditAnalysis.get('THAB');

            IntegrationCreditAnalysisMobileDTO.CredAnalisysMobileResp cred = (new IntegrationCreditAnalysisMobileDTO())
                    .CredAnalysisResp2CredAnalisysMobileResp(creditAnalysisMobileDTO);
            SalesOrderIntegrationDTO.SalesOrderMobileResponse retorno = service.executesOrderMobile(
                (String) inputMap.get('OrderId'), salesManDTO.data.salesman, cred, analysisDTO, thab);
            system.debug('retorno: ' + retorno);
            outMap.put('salesOrder', retorno);
            
            if(retorno.error != null)
            {
                return setError(outMap, retorno.error.detailedMessage);
            }
        }
        catch(SObjectException e)
        {
        	return setError(outMap, e.getMessage());   
        }
        catch(Exception en)
        {
        	return setError(outMap, Label.CEC_ServIndisponivel);   
        }

        return true;
    }
    private static Boolean setError(Map<String, Object> outMap, String aMsg)
    {
        if (outMap != null && String.isNotBlank(aMsg)) outMap.put('error', aMsg);
        return false;
    }    
}