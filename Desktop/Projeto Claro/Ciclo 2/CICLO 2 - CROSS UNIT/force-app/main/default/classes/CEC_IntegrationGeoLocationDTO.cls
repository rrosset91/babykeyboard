global with sharing class CEC_IntegrationGeoLocationDTO {
    global CEC_IntegrationGeoLocationDTO(){
        
    }

    global class Availability {
		global String technicalSituation {get;set;} 
		global String commercialSituation {get;set;} 
		global String technicalSituationNote {get;set;} 
		global String commercialSituationNote {get;set;} 
		global BusinessLine businessLine {get;set;} 

		global Availability(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'technicalSituation') {
							technicalSituation = parser.getText();
						} else if (text == 'commercialSituation') {
							commercialSituation = parser.getText();
						} else if (text == 'technicalSituationNote') {
							technicalSituationNote = parser.getText();
						} else if (text == 'commercialSituationNote') {
							commercialSituationNote = parser.getText();
						} else if (text == 'businessLine') {
							businessLine = new BusinessLine(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'Availability consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	global class Domiciles {
		global String id {get;set;} 
		global String description {get;set;} 
		global String noteDomicile {get;set;} 
		global String nodeCharacteristic {get;set;} 
		global String number_Z {get;set;} // in json: number
		global String domicileType {get;set;} 
		global String domicileTypeDescription {get;set;} 
		global List<Availability> availability {get;set;} 
		global String node {get;set;} 

		global Domiciles(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'id') {
							id = parser.getText();
						} else if (text == 'description') {
							description = parser.getText();
						} else if (text == 'noteDomicile') {
							noteDomicile = parser.getText();
						} else if (text == 'nodeCharacteristic') {
							nodeCharacteristic = parser.getText();
						} else if (text == 'number') {
							number_Z = parser.getText();
						} else if (text == 'domicileType') {
							domicileType = parser.getText();
						} else if (text == 'domicileTypeDescription') {
							domicileTypeDescription = parser.getText();
						} else if (text == 'availability') {
							availability = arrayOfAvailability(parser);
						} else if (text == 'node') {
							node = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Domiciles consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	global class BusinessLineFeatures {
		global String description {get;set;} 

		global BusinessLineFeatures(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'description') {
							description = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'BusinessLineFeatures consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	global class BusinessLine {
		global Integer id {get;set;} 
		global String description {get;set;} 
		global BusinessLineFeatures businessLineFeatures {get;set;} 

		global BusinessLine(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'id') {
							id = parser.getIntegerValue();
						} else if (text == 'description') {
							description = parser.getText();
						} else if (text == 'businessLineFeatures') {
							businessLineFeatures = new BusinessLineFeatures(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'BusinessLine consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	global class Data {
		global List<Domiciles> domiciles {get;set;} 

		global Data(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'domiciles') {
							domiciles = arrayOfDomiciles(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'Data consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	global String apiVersion {get;set;} 
	global String transactionId {get;set;} 
	global Data data {get;set;} 

	global CEC_IntegrationGeoLocationDTO(JSONParser parser) {
		while (parser.nextToken() != System.JSONToken.END_OBJECT) {
			if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
				String text = parser.getText();
				if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
					if (text == 'apiVersion') {
						apiVersion = parser.getText();
					} else if (text == 'transactionId') {
						transactionId = parser.getText();
					} else if (text == 'data') {
						data = new Data(parser);
					} else {
						System.debug(LoggingLevel.WARN, 'CEC_IntegrationGeoLocationDTO consuming unrecognized property: '+text);
						consumeObject(parser);
					}
				}
			}
		}
	}
	
	
	global static CEC_IntegrationGeoLocationDTO parse(String json) {
		System.JSONParser parser = System.JSON.createParser(json);
		return new CEC_IntegrationGeoLocationDTO(parser);
	}
	
	global static void consumeObject(System.JSONParser parser) {
		Integer depth = 0;
		do {
			System.JSONToken curr = parser.getCurrentToken();
			if (curr == System.JSONToken.START_OBJECT || 
				curr == System.JSONToken.START_ARRAY) {
				depth++;
			} else if (curr == System.JSONToken.END_OBJECT ||
				curr == System.JSONToken.END_ARRAY) {
				depth--;
			}
		} while (depth > 0 && parser.nextToken() != null);
	}
	





    private static List<Domiciles> arrayOfDomiciles(System.JSONParser p) {
        List<Domiciles> res = new List<Domiciles>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Domiciles(p));
        }
        return res;
    }



    private static List<Availability> arrayOfAvailability(System.JSONParser p) {
        List<Availability> res = new List<Availability>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Availability(p));
        }
        return res;
    }


}