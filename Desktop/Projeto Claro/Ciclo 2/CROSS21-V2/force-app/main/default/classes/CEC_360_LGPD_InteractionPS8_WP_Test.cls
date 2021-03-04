@isTest
public class CEC_360_LGPD_InteractionPS8_WP_Test {
	
    @isTest
    public static void testLGPDIntegrationObjects(){
    	CEC_360_LGPD_InteractionPS8_WP.InteractionPS8Request 	interactionPS8Request 	= new CEC_360_LGPD_InteractionPS8_WP.InteractionPS8Request();
        CEC_360_LGPD_InteractionPS8_WP.InteractionPS8response 	InteractionPS8response 	= new CEC_360_LGPD_InteractionPS8_WP.InteractionPS8response(); 
        
        interactionPS8Request.data.protocolnumber       =  'XJEET2346FhK'; 
        interactionPS8Request.data.status               =  'FECHADO'; 
        interactionPS8Request.data.details              =  'Codigo de rastreabilidade: 1234'; 
    /*  interactionPS8Request.data.severity             =  'MINIMA'; 
        interactionPS8Request.data.situation            =  'NOVO'; 
        interactionPS8Request.data.notes                =  'Incidente resolvido com sucesso e sem resalvas'; 
        interactionPS8Request.data.slaDueDate           =  '2018-01-12T12:10:30-03:00'; 
        interactionPS8Request.data.priority             =  'BAIXA';  
        interactionPS8Request.data.caseTypeId           =  '12345'; 
        interactionPS8Request.data.systemRelatedCaseId  =  'SalesForce'; 
    */
        InteractionPS8response.apiVersion    = '1;2020-06-11'; 
		InteractionPS8response.transactionId = 'e6e4e0f4-089d-4194-845e-78f45426f7c7'; 
        
        InteractionPS8response.data			 = new CEC_360_LGPD_InteractionPS8_WP.Data();
        InteractionPS8response.Error		 = new CEC_360_LGPD_InteractionPS8_WP.Error();
    }
}