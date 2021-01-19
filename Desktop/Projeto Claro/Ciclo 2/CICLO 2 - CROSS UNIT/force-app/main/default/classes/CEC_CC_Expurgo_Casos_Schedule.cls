global class CEC_CC_Expurgo_Casos_Schedule implements Schedulable {
    global void execute(SchedulableContext sc){
        CEC_CC_Expurgo_Casos batchCase = new CEC_CC_Expurgo_Casos('Configura_o_Expurgo_de_Casos');
        Database.executeBatch(batchCase, 200);
    }
}