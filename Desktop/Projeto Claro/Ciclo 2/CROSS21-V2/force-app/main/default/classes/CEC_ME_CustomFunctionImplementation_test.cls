@isTest
public class CEC_ME_CustomFunctionImplementation_test {
    @isTest
    static Void sum_test(){
    String methodName = 'sum';
        Map<String,Object> outMap = new Map<String, Object>();
        Map<String, Object> empty = new Map<String, Object>();
        Map<String,Object> options = new Map<String, Object>();
        Map<String,Object> inputMap = new Map<String, Object>();
        List<Object> argList = new List<Object>();
        argList.add(1);
        argList.add(2);
        argList.add(3);
        argList.add(4);
        inputMap.put('arguments',argList);
        CEC_ME_CustomFunctionImplementation testedClass = new CEC_ME_CustomFunctionImplementation();
        Test.startTest();
        testedClass.invokeMethod(methodName, inputMap, outMap, options);
        System.assertEquals(10, outMap.get('result'));
        Test.stopTest();
    }

    @isTest
    static void stringSplit_test(){
        String methodName = 'stringSplit';
        Map<String,Object> outMap = new Map<String, Object>();
        Map<String, Object> empty = new Map<String, Object>();
        Map<String,Object> options = new Map<String, Object>();
        Map<String,Object> inputMap = new Map<String, Object>();
        List<Object> argList = new List<Object>();
        argList.add('this;this;this');
        argList.add(';');
        inputMap.put('arguments',argList);
        CEC_ME_CustomFunctionImplementation testedClass = new CEC_ME_CustomFunctionImplementation();
        Test.startTest();
        testedClass.invokeMethod(methodName, inputMap, outMap, options);
        Map<String,String> res= (Map<String,String>) outMap.get('result');
        System.assertEquals(3, res.size());
        Test.stopTest();
    }

    @isTest
    static void stringSplitIndex_test(){
        String methodName = 'stringSplitIndex';
        Map<String,Object> outMap = new Map<String, Object>();
        Map<String, Object> empty = new Map<String, Object>();
        Map<String,Object> options = new Map<String, Object>();
        Map<String,Object> inputMap = new Map<String, Object>();
        List<Object> argList = new List<Object>();
        argList.add('this;this;this');
        argList.add(';');
        argList.add(1);
        inputMap.put('arguments',argList);
        CEC_ME_CustomFunctionImplementation testedClass = new CEC_ME_CustomFunctionImplementation();
        Test.startTest();
        testedClass.invokeMethod(methodName, inputMap, outMap, options);
        String res= (String) outMap.get('result');
        System.assertEquals('this',res);
        Test.stopTest();
    }

     @isTest
    static void listIsEmpty_test(){
        String methodName = 'listIsEmpty';
        Map<String,Object> outMap = new Map<String, Object>();
        Map<String, Object> empty = new Map<String, Object>();
        Map<String,Object> options = new Map<String, Object>();
        Map<String,Object> inputMap = new Map<String, Object>();
        List<Object> argList = new List<Object>();
        argList.add('this;this;this');
        inputMap.put('arguments',argList);
        CEC_ME_CustomFunctionImplementation testedClass = new CEC_ME_CustomFunctionImplementation();
        Test.startTest();
        testedClass.invokeMethod(methodName, inputMap, outMap, options);
        Boolean res= (Boolean) outMap.get('result');
        System.assertEquals(false,res);
        Test.stopTest();
    }

    @isTest
    static void now_test(){
        String methodname='now';
        Map<String,Object> outMap = new Map<String, Object>();
        Map<String, Object> empty = new Map<String, Object>();
        Map<String,Object> options = new Map<String, Object>();
        Map<String,Object> inputMap = new Map<String, Object>();
        List<Object> argList = new List<Object>();
        argList.add('test');
        inputMap.put('arguments',argList);
        CEC_ME_CustomFunctionImplementation testedClass = new CEC_ME_CustomFunctionImplementation();
        Test.startTest();
        testedClass.invokeMethod(methodName, inputMap, outMap, options);
        DateTime res= (DateTime) outMap.get('result');
        System.assertEquals(res,DateTime.now());
        Test.stopTest();
    }

    @isTest
    static void stringTranslate() {
        String methodName = 'stringTranslate';
        Map<String,Object> input = new Map<String, Object>();
        Map<String,Object> output = new Map<String, Object>();
        Map<String,Object> options = new Map<String, Object>();
        List<Object> arguments = new List<Object>();
        arguments.add('ãõ');
        input.put('arguments', arguments);
        CEC_ME_CustomFunctionImplementation CFI = new CEC_ME_CustomFunctionImplementation();

        Test.startTest();
        CFI.invokeMethod(methodName, input, output, options);
        String result = String.valueOf(output.get('result'));
        System.assertEquals('AO', result);
        Test.stopTest();
    }
}