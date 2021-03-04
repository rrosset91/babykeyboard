/**
 * Utilities class for CCM Integrations.
 *
 * @author Ümit Can Uçkan
 * @version 1.0
 * @since CCM Integrations 1.0
 */
public with sharing class CopadoCCMutilities {
    

    /**
     * HTTP method based on a named credential and current parameters
     * Project and UserStory are required parameters for log creation
     *
     * @param namedCredential
     * @param firstParam
     * @param secondParam
     * @param firstUrlpart
     * @param secondUrlpart
     * @param additionalHeader
     * @param methodType
     * @param bodyParam
     * @param userStory
     * @param project
     *
     * @return
     */
    public static String MakeCallout(String namedCredential,
                                     String firstParam,
                                     String secondParam,
                                     String firstUrlpart,
                                     String secondUrlpart,
            						 List<String> additionalHeader,
                                     String methodType,
                                     String bodyParam,
                                     sObject userStory,
                                     sObject project){
                                         
        HttpRequest req = new HttpRequest();
        //exp: callout: endpoint + projectExternalId + '/_apis/wit/wiql/' + workspaceId +'?api-version=4.1';
        req.setEndpoint('callout:'+namedCredential+'/'+firstParam+firstUrlpart+secondParam+secondUrlpart);
        for(String ahItem:additionalHeader) {
            req.setHeader(ahItem.split(':')[0], ahItem.split(':')[1]);
        }
        req.setMethod(String.valueOf(methodType));
        if(String.isNotBlank(bodyParam)) {
            req.setBody(bodyParam);
        }
        Http http = new Http();
        HTTPResponse res = http.send(req);
        
		System.debug('res.getStatusCode()==> '+res.getStatusCode());
		System.debug('res.getStatus()==> '+res.getStatus());
        System.debug('res.getBody()==> '+res.getBody());
        return res.getBody();
    }
    
    
    
}