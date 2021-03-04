/**************************************************************************************************************
* IBM - Bluewolf
* @author           Lucas Soldi (lucas.soldi@ibm.com)
* Project:          Solar
* Description:     
*
* Changes (Version)
* -------------------------------------
*           No.     Date            Author                  Description     
*           -----   ----------      --------------------    ---------------   
* @version   1.0    2020-08-17      Lucas Soldi          	class created 
**************************************************************************************************************/
public  class Solar_Cross_PriorityRoutingController {


    @AuraEnabled
    public static Boolean verifyAssinc(){
        Boolean strReturn;
        List<AsyncApexJob> lstJobs = [SELECT Id, Status, CreatedDate, ExtendedStatus FROM AsyncApexJob WHERE ApexClass.Name='Solar_Cross_PriorityRoutingBatch' AND JobType='BatchApex' AND CreatedDate = TODAY Order By CreatedDate desc];
        if(!lstJobs.isEmpty()){
           if(String.isBlank(lstJobs[0].ExtendedStatus) && lstJobs[0].Status == 'Completed'){
             strReturn = true;
           }else if(!String.isBlank(lstJobs[0].ExtendedStatus)){strReturn = false;}

        }else{
            strReturn = false;
        }

        return strReturn;
    }

    @AuraEnabled
    public static void callBatchClass(String minDate, String maxDate,String priority){

        List<String> minDates = minDate.split('-');
        List<String> maxDates = maxDate.split('-');

        Datetime minimunDate = Datetime.newInstance(Integer.valueOf(minDates[0]),Integer.valueOf(minDates[1]),Integer.valueOf(minDates[2]));
        System.debug('minimunDate: ' + minimunDate);
        Datetime maximunDate = Datetime.newInstance(Integer.valueOf(maxDates[0]),Integer.valueOf(maxDates[1]),Integer.valueOf(maxDates[2])).addDays(1);
        System.debug('maximunDate: ' + maximunDate);
        Database.executeBatch(new Solar_Cross_PriorityRoutingBatch(minimunDate,maximunDate,priority),2000);
       
    }

}