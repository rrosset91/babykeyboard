public class Solar_Cross_SendEmailIntegration {


    @InvocableMethod(label='Send Email')
    public static void sendStatusEmail(list<processBuilderVariables> lstPBVariable){
        
        String serviceName = 'OAG_NET_SendEmail';
        RequestData request = new requestData();
        request.data = new RequestEmailWrapper();
        List<SolarEmailConfig__mdt> lstMetaEmail = [SELECT 
                                                        Id, EmailCase__c, EmailContent__c , EmailSendType__c, EmailSubject__c, EmailDescription__c
                                                    FROM 
                                                        SolarEmailConfig__mdt 
                                                    WHERE  
                                                        EmailCase__c = :lstPBVariable[0].keyCenario 
                                                    AND 
                                                        Active__c = true];

        List<ReceiverWrapper> lstReceiver = new List<ReceiverWrapper>();
        String conteudo = lstMetaEmail[0].EmailContent__c;
        //System.debug('conteudo: ' + conteudo);
        if(lstMetaEmail[0].EmailContent__c.contains('<$protocolo$>')){
            conteudo = lstMetaEmail[0].EmailContent__c.replace('<$protocolo$>',lstPBVariable[0].protocolNumber);
        }
       // System.debug('conteudo: ' + conteudo);
        request.data.content = conteudo.replace('<$nome$>',lstPBVariable[0].accountName).unescapeHtml4();
       // System.debug('request.data.content: ' + request.data.content);
        request.data.description= lstMetaEmail[0].EmailDescription__c;
       // System.debug('request.data.description: ' + request.data.description);
        request.data.subject= lstMetaEmail[0].EmailSubject__c;
        request.data.type= lstMetaEmail[0].EmailSendType__c;
       // System.debug('request.data.type: ' + request.data.type);
        for(processBuilderVariables pbVar: lstPBVariable){
            ReceiverWrapper objReceiver = new ReceiverWrapper(pbVar.contactEmail);
            lstReceiver.add(objReceiver); 
        }
        request.data.receiver = lstReceiver;
        request.data.sender = new SenderWrapper();

        String strRequest = JSON.serialize(request);

        if(!Test.isRunningTest())  makeCallout(serviceName,strRequest);

        
    }

    @future(callout=true)
    public static void makeCallout(String serviceName, String body){
        RequestData requestBody = (RequestData) JSON.deserialize(body, RequestData.class);
        HttpResponse response = CEC_HttpReq.sendReq(serviceName,requestBody);
    }

    public class RequestData{
        public requestEmailWrapper data;

        public requestData(){

        }
    }

    public class RequestEmailWrapper{
        public String content;
        public String description;
        public String subject;
        public String type;
        public List<receiverWrapper> receiver;
        public senderWrapper sender;

        public RequestEmailWrapper(){

        }
    }

    public class ReceiverWrapper{
        public String email;
        public String phoneNumber;
        public String type;

        public ReceiverWrapper(String email){
            this.email = email;
            this.phoneNumber = '';
            this.type = '';
        }
    }

    public class SenderWrapper{
        public String email;
        public String id;
        public String phoneNumber;

        public SenderWrapper(){
            this.email = 'nao-responda@claro.com.br';
            this.phoneNumber = '1129285598';
            this.id = 'string';
        }
    }

    public class processBuilderVariables{
        @InvocableVariable 
        public String contactEmail;
        @InvocableVariable
        public String keyCenario;
        @InvocableVariable
        public String accountName; 
        @InvocableVariable 
        public String subject;
        @InvocableVariable
        public String protocolNumber;
    }
}