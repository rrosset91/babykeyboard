/*-------------------------------------------------------------------------------------------------------
--- Company: Deloitte Brasil 
--- Author: Squad Canais Críticos 
--- Date: 18/09/2018
---
--- Controle de Versão
---------------------------------------------------------------------------------------------------------
--- Author: Squad Canais Críticos 
--- Description: Inclusão de parâmetros (errorMessage, errorCode e httpCode) para detalhar o erro
--- Date: 03/06/2018
-------------------------------------------------------------------------------------------------------*/
public class CEC_IntegrationException extends Exception 
{
    public String errorMessage {get;set;}  
    public String errorCode {get;set;}  
    public String httpCode {get;set;}  
}