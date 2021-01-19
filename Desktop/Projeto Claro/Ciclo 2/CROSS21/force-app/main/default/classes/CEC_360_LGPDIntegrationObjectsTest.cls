@isTest
public class CEC_360_LGPDIntegrationObjectsTest {
		
    @isTest
    public static void testLGPDIntegrationObjects(){
        CEC_360_LGPDIntegrationObjects.getRightsHistory			getRightsHistory 		 = new CEC_360_LGPDIntegrationObjects.getRightsHistory();
    	CEC_360_LGPDIntegrationObjects.customerOrders			customerOrders 		 	 = new CEC_360_LGPDIntegrationObjects.customerOrders();
        CEC_360_LGPDIntegrationObjects.GetHistoricRightsDetails getHistoricRightsDetails = new CEC_360_LGPDIntegrationObjects.GetHistoricRightsDetails();
        CEC_360_LGPDIntegrationObjects.getHistoryRightsExtract  getHistoryRightsExtract  = new CEC_360_LGPDIntegrationObjects.getHistoryRightsExtract();
        CEC_360_LGPDIntegrationObjects.GetConsentsHistory		getConsentsHistory 		 = new CEC_360_LGPDIntegrationObjects.GetConsentsHistory();
        CEC_360_LGPDIntegrationObjects.GetDsarByStatus			getDsarByStatus 		 = new CEC_360_LGPDIntegrationObjects.GetDsarByStatus();
        CEC_360_LGPDIntegrationObjects.PostDsar					postDsar 				 = new CEC_360_LGPDIntegrationObjects.PostDsar();
        CEC_360_LGPDIntegrationObjects.DataPostDsar				dataPostDsar 			 = new CEC_360_LGPDIntegrationObjects.DataPostDsar();
        CEC_360_LGPDIntegrationObjects.DsarError				dsarError 				 = new CEC_360_LGPDIntegrationObjects.DsarError();
        CEC_360_LGPDIntegrationObjects.PutManagement			putManagement 			 = new CEC_360_LGPDIntegrationObjects.PutManagement();
        CEC_360_LGPDIntegrationObjects.PutOrdersStage			putOrdersStage 			 = new CEC_360_LGPDIntegrationObjects.PutOrdersStage();
        CEC_360_LGPDIntegrationObjects.DataOrdersStage			dataOrdersStage 		 = new CEC_360_LGPDIntegrationObjects.DataOrdersStage();
        CEC_360_LGPDIntegrationObjects.GetConsents				getConsents 			 = new CEC_360_LGPDIntegrationObjects.GetConsents();
        CEC_360_LGPDIntegrationObjects.PutConsents				putConsents 			 = new CEC_360_LGPDIntegrationObjects.PutConsents();
        CEC_360_LGPDIntegrationObjects.Purposes 				purposes 				 = new CEC_360_LGPDIntegrationObjects.Purposes();
        CEC_360_LGPDIntegrationObjects.Agreements			    agreements 				 = new CEC_360_LGPDIntegrationObjects.Agreements();
        CEC_360_LGPDIntegrationObjects.Options			    	options 				 = new CEC_360_LGPDIntegrationObjects.Options();
        
        options.id = 'test';
            
        agreements.id 	= 'test';
        agreements.options.add(options);
            
        purposes.id 	= 'test';
        purposes.agreements.add(agreements);
        
        putConsents.protocolNumber 		= '';
        putConsents.channel 			= '';
        putConsents.collectionPointId 	= ''; 
        putConsents.purposes.add( purposes );  
    }
}