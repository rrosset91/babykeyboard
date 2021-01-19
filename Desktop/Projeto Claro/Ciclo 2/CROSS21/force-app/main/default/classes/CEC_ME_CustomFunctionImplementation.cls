/*---------------------------------------------------------------------------------------
--- Company: Deloitte Brasil
--- Author: Squad Mudanca de Endereco = Jorge Seibert/Guilherme Cuencas
--- Description: Classe com metodos auxiliares de uso nos componentes Vlocity.
--- CreateDate: 01/03/2019
--- UpdateDate: 15/08/2019 - Add leftPad function.
--- Version: 1.1
---------------------------------------------------------------------------------------*/

global class CEC_ME_CustomFunctionImplementation implements vlocity_cmt.VlocityOpenInterface {
    /*
        inputs - arguments - List<Object> of passed in arguments
        output - result - The result of the Function being called. Supports single Object values, List<Object> or Map<String, Object>
    */

    global Boolean invokeMethod(String methodName, Map<String, Object> input, Map<String, Object> output, Map<String, Object> options) {
        switch on methodName {
            when 'sum' {
                output.put('result', sum((List<Object>) input.get('arguments')));
            }
            when 'stringSplit' {
                output.put('result', stringSplit((List<Object>) input.get('arguments')));
            }
            when 'stringSplitIndex' {
                output.put('result', stringSplitIndex((List<Object>) input.get('arguments')));
            }
            when 'listIsEmpty' {
                output.put('result', listIsEmpty((List<Object>) input.get('arguments')));
            }
            when 'now' {
                output.put('result', now((List<Object>) input.get('arguments')));
            }
            when 'stringTranslate' {
                output.put('result', stringTranslate((List<Object>) input.get('arguments')));
            }
            when 'leftPad' {
                output.put('result', leftPad((List<Object>) input.get('arguments')));
            }
        }

        return true;
    }

    Double sum(List<Object> arguments) {
        Double result = 0;

        for(Object token : arguments) {
            if (token != null) {
                result += (Double)token;
            }
        }

        return result;
    }

    Map<String, String> stringSplit(List<Object> arguments) {
        Map<String, String> result = new Map<String, String>();
        String toSplit = (String)arguments[0];
        String splitter = (String)arguments[1];
        List<String> splitList = toSplit.split(splitter);

        for (Integer i = 0; i < splitList.size(); i++) {
            if (arguments.size() > i+2) {
                result.put((String)arguments[i+2], splitList[i]);
            }
            else {
                result.put('Split'+i, splitList[i]);
            }
        }
        return result;
    }
    
    String stringSplitIndex(List<Object> arguments) {
        String toSplit = String.valueOf(arguments[0]);
        String splitter = String.valueOf(arguments[1]);
        Integer index = Integer.valueOf(arguments[2]);

        String result = toSplit.split(splitter)[index];

        return result;
    }

    Boolean listIsEmpty(List<Object> arguments) {
        Boolean result;
        if(arguments.size() <= 1) {
            if(String.isBlank(String.valueOf(arguments[0]))) {
                result = true;
            }
            else {
                result = false;
            }
        }
        else {
            result = false;
        }
        return result;
    }

    Datetime now(List<Object> arguments) {
        return Datetime.now();
    }

    String stringTranslate(List<Object> arguments) {
        String input = String.valueOf(arguments[0]);
        input = input.toUpperCase();
        if(input.contains('Ã')) {
            input = input.replace('Ã', 'A');
        }
        if(input.contains('Á')) {
            input = input.replace('Á', 'A');
        }
        if(input.contains('É')) {
            input = input.replace('É', 'E');
        }
        if(input.contains('Í')) {
            input = input.replace('Í', 'I');
        }
        if(input.contains('Ó')) {
            input = input.replace('Ó', 'O');
        }
        if(input.contains('Õ')) {
            input = input.replace('Õ', 'O');
        }
        if(input.contains('Ú')) {
            input = input.replace('Ú', 'U');
        }

        return input;
    }

    String leftPad(List<Object> arguments) {
        String input = String.valueOf(arguments[0]);
        Integer size = Integer.valueOf(arguments[1]);
        String padding = String.valueOf(arguments[2]);

        String result = input.leftPad(size, padding);
        return result;
    }
}