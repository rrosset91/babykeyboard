@IsTest
private class NBA_WorkOrderSchedulesParserTest {
    
    @IsTest
    private static void validateAllValues() {
        //GIVEN a valid JSON response
        String j = '{"apiVersion":"1;2018-10-26","transactionId":"Id-e68b035f1d1ccf2165fa3976","data":{"schedule":[{"field":"IPA A","class":"3","periods":[{"description":"PERIODO 1","availableMinutes":"450","startHour":"08:00:00","endHour":"12:00:00","date":"2020-07-01","periodTypeId":"1","emergency":"0","isCapacityRegistration":"true"},{"description":"PERIODO 2","availableMinutes":"450","startHour":"08:00:00","endHour":"12:00:00","date":"2020-07-02","periodTypeId":"1","emergency":"0","isCapacityRegistration":"true"}]}]}}';
        
        //WHEN parser runs
        NBA_IntegrationModels.AgendamentoResponse response = NBA_WorkOrderSchedulesParser.parse(j);

        //THEN response should be correct
        validateBasicData(response, '1;2018-10-26', 'Id-e68b035f1d1ccf2165fa3976');
        
        System.assertEquals('IPA A', response.data.schedule[0].fieldSchedule);
        System.assertEquals('3', response.data.schedule[0].classSchedule);
        
        for (NBA_IntegrationModels.AgendamentoPeriods period : response.data.schedule[0].periods) {
            if (period.description == 'PERIODO 1') {
                System.assert(Date.newInstance(2020, 7, 1).isSameDay(period.dateSchedule));
            } else {
                System.assertEquals('PERIODO 2', period.description);
                System.assert(Date.newInstance(2020, 7, 2).isSameDay(period.dateSchedule));
            }
            
            System.assertEquals('450', period.availableMinutes);
            System.assertEquals('08:00:00', period.startHour);
            System.assertEquals('12:00:00', period.endHour);
            System.assertEquals('1', period.periodTypeId);
            System.assertEquals('0', period.emergency);
            System.assertEquals('true', period.isCapacityRegistration);
        }
    }
    
    @IsTest
    private static void validateNullValues() {
        //GIVEN a valid JSON response null fields ("null", "" and null are considered as null)
        String j = '{"apiVersion":"null","transactionId":"","data":{"schedule":[{"field":null,"class":"","periods":[{"description":"null","availableMinutes":null,"startHour":"","endHour":"null","date":null,"periodTypeId":"","emergency":"null","isCapacityRegistration":null},{"description":"null","availableMinutes":null,"startHour":"","endHour":"null","date":null,"periodTypeId":"","emergency":"null","isCapacityRegistration":null}]}]}}';
        
        //WHEN parser runs
        NBA_IntegrationModels.AgendamentoResponse response = NBA_WorkOrderSchedulesParser.parse(j);

        //THEN response should be correct
        validateBasicData(response, null, null);
        
        System.assertEquals(null, response.data.schedule[0].fieldSchedule);
        System.assertEquals(null, response.data.schedule[0].classSchedule);
        
        for (NBA_IntegrationModels.AgendamentoPeriods period : response.data.schedule[0].periods) {
            System.assertEquals(null, period.description);
            System.assertEquals(null, period.dateSchedule);
            System.assertEquals(null, period.availableMinutes);
            System.assertEquals(null, period.startHour);
            System.assertEquals(null, period.endHour);
            System.assertEquals(null, period.periodTypeId);
            System.assertEquals(null, period.emergency);
            System.assertEquals(null, period.isCapacityRegistration);
        }
    }
    
    @IsTest
    private static void validateSinglePeriod() {
        //GIVEN a valid JSON response with a single period available as JSON OBJECT - "periods" : {...}
        String j = '{"apiVersion":"1;2018-10-26","transactionId":"Id-34bf035f531cb742436a6108","data":{"schedule":[{"field":"IPA A","class":"3","periods":{"description":"NAO UTILIZAR 2","availableMinutes":"450","startHour":"08:00:00","endHour":"12:00:00","date":"2020-07-07","periodTypeId":"1","emergency":"0","isCapacityRegistration":"true"}}]}}';
        
        //WHEN parser runs
        NBA_IntegrationModels.AgendamentoResponse response = NBA_WorkOrderSchedulesParser.parse(j);

        //THEN response should be correct
        validateBasicData(response, '1;2018-10-26', 'Id-34bf035f531cb742436a6108');
        
        //AND should be 1 period
        System.assertEquals(1, response.data.schedule[0].periods.size());
    }
    
	@IsTest
    private static void validateMultiplePeriods() {
        //GIVEN a valid JSON response with four periods available as JSON ARRAY - "periods" : [...]
        String j = '{"apiVersion":"1;2018-10-26","transactionId":"Id-e68b035f1d1ccf2165fa3976","data":{"schedule":[{"field":"IPA A","class":"3","periods":[{"description":"NAO UTILIZAR 2","availableMinutes":"450","startHour":"08:00:00","endHour":"12:00:00","date":"2020-07-08","periodTypeId":"1","emergency":"0","isCapacityRegistration":"true"},{"description":"NAO UTILIZAR 2","availableMinutes":"450","startHour":"08:00:00","endHour":"12:00:00","date":"2020-07-09","periodTypeId":"1","emergency":"0","isCapacityRegistration":"true"},{"description":"NAO UTILIZAR 2","availableMinutes":"450","startHour":"08:00:00","endHour":"12:00:00","date":"2020-07-10","periodTypeId":"1","emergency":"0","isCapacityRegistration":"true"},{"description":"NAO UTILIZAR 2","availableMinutes":"450","startHour":"08:00:00","endHour":"12:00:00","date":"2020-07-11","periodTypeId":"1","emergency":"0","isCapacityRegistration":"true"}]}]}}';
        
        //WHEN parser runs
        NBA_IntegrationModels.AgendamentoResponse response = NBA_WorkOrderSchedulesParser.parse(j);

        //THEN response should be correct
        validateBasicData(response, '1;2018-10-26', 'Id-e68b035f1d1ccf2165fa3976');
        
        //AND should be 4 periods
        System.assertEquals(4, response.data.schedule[0].periods.size());
    }

    @IsTest
    private static void validateEmptySchedules() {
        //GIVEN a invalid JSON response containing a empty schedule array
        String j = '{"apiVersion":"1;2018-10-26","transactionId":"Id-1921b35f01bd0ea8ee7f5881","data":{"schedule":[null]}}';
        
        //WHEN parser runs
        NBA_IntegrationModels.AgendamentoResponse response = NBA_WorkOrderSchedulesParser.parse(j);

        //THEN schedule should be empty
        System.assert(response.data.schedule.isEmpty());
    }
    
    @IsTest
    private static void validateErrorResponse() {
        //GIVEN an error JSON response
        String j = '{"apiVersion":"1;2018-10-26","transactionId":"Id-b3ab035f491c6b91a98f0db3","error":{"httpCode":"500","errorCode":"API-API-WORKORDERSCHEDULESAVAILABILITY-010","message":"Internal Server Error","detailedMessage":"Internal Server Error","link":{"rel":"related","href":"https://apiuat.net.com.br/docs/error_codes.html","newProperty":"new"},"newProperty":"new"}}';
        
        //WHEN parser runs
        NBA_IntegrationModels.AgendamentoResponse response = NBA_WorkOrderSchedulesParser.parse(j);

        //THEN error should be present
		System.assertNotEquals(null, response);
        System.assertNotEquals(null, response.error);
        
        //AND all data should be correct
        System.assertEquals(null, response.data);
        
        //AND 500 status code should be returned
        System.assertEquals('500', response.error.httpCode);
    }
    
    @IsTest
    private static void validateUnrecognizedProperties() {
        //GIVEN a valid JSON response with some additional properties
        String j = '{"apiVersion":"1;2018-10-26","transactionId":"Id-34bf035f531cb742436a6108","data":{"schedule":[{"field":"IPA A","class":"3","periods":{"description":"NAO UTILIZAR 2","availableMinutes":"450","startHour":"08:00:00","endHour":"12:00:00","date":"2020-07-07","periodTypeId":"1","emergency":"0","isCapacityRegistration":"true","newProperty":{"newField":"newValue"}},"newProperty":"new"}],"newProperty":"new"},"newProperty":"new"}';
        
        //WHEN parser runs
        NBA_IntegrationModels.AgendamentoResponse response = NBA_WorkOrderSchedulesParser.parse(j);
        
        //THEN response should be correct
        validateBasicData(response, '1;2018-10-26', 'Id-34bf035f531cb742436a6108');
    }

    private static void validateBasicData(NBA_IntegrationModels.AgendamentoResponse response, String apiVersion, String transactionId) {
		System.assertNotEquals(null, response);
        System.assertNotEquals(null, response.data);
        System.assertNotEquals(null, response.data.schedule);
        System.assertNotEquals(null, response.data.schedule[0].periods);
        
        System.assertEquals(null, response.error);
        System.assertEquals(apiVersion, response.apiVersion);
        System.assertEquals(transactionId, response.transactionId);
        System.assertEquals(false, response.data.schedule.isEmpty());
        System.assertEquals(false, response.data.schedule[0].periods.isEmpty());
    }
}