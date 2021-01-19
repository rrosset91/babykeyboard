/**
Parser criado para deserializar a estrutura do serviço /workorderschedules/availability, 
pois este retorna as informações de periodos no JSON ora como lista, ora como objeto, 
ou seja, a estrutura do JSON é mutável
**/
public class NBA_WorkOrderSchedulesParser {

	public String apiVersion;
	public String transactionId;
	public Data data;
    public Error error;
	
	public NBA_WorkOrderSchedulesParser(JSONParser parser) {
		while (parser.nextToken() != System.JSONToken.END_OBJECT) {
			if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
				String text = parser.getText();
				if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                    String value = handleNullValue(parser.getText());
					if (text == 'apiVersion') {
						apiVersion = value;
					} else if (text == 'transactionId') {
						transactionId = value;
					} else if (text == 'data') {
						data = new Data(parser);
                    } else if (text == 'error') {
						error = new Error(parser);
					} else {
						System.debug(LoggingLevel.WARN, 'WorkOrderSchedulesAvailabilityParser consuming unrecognized property: ' + text);
						consumeObject(parser);
					}
				}
			}
		}
	}
	
	public static NBA_IntegrationModels.AgendamentoResponse parse(String json) {
		System.JSONParser parser = System.JSON.createParser(json);
        
        NBA_WorkOrderSchedulesParser workOrderParser = new NBA_WorkOrderSchedulesParser(parser);
        
        NBA_IntegrationModels.AgendamentoResponse response = 
            (NBA_IntegrationModels.AgendamentoResponse) 
            System.JSON.deserialize(System.JSON.serialize(workOrderParser), NBA_IntegrationModels.AgendamentoResponse.class);

		return response;
	}
    
    public class Data {
		public List<Schedule> schedule; 

		public Data(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'schedule') {
							schedule = getSchedules(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'Data consuming unrecognized property: ' + text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Schedule {
		public String fieldSchedule; // in json: field
		public String classSchedule; // in json: class
		public List<Periods> periods;

		public Schedule(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        String value = handleNullValue(parser.getText());
						if (text == 'field') {
							fieldSchedule = value;
						} else if (text == 'class') {
							classSchedule = value;
						} else if (text == 'periods') {
							periods = getPeriods(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'Schedule consuming unrecognized property: ' + text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
    
    public class Periods {
		public String description;
		public String availableMinutes;
		public String startHour;
		public String endHour;
		public String dateSchedule; // in json: date
		public String periodTypeId;
		public String emergency;
		public String isCapacityRegistration;

		public Periods(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        String value = handleNullValue(parser.getText());
						if (text == 'description') {
							description = value;
						} else if (text == 'availableMinutes') {
							availableMinutes = value;
						} else if (text == 'startHour') {
							startHour = value;
						} else if (text == 'endHour') {
							endHour = value;
						} else if (text == 'date') {
							dateSchedule = value;
						} else if (text == 'periodTypeId') {
							periodTypeId = value;
						} else if (text == 'emergency') {
							emergency = value;
						} else if (text == 'isCapacityRegistration') {
							isCapacityRegistration = value;
						} else {
							System.debug(LoggingLevel.WARN, 'Periods consuming unrecognized property: ' + text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
    
    public class Error {
		public String httpCode;
		public String errorCode;
		public String message;
		public String detailedMessage;
		public Link link;

		public Error(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        String value = handleNullValue(parser.getText());
						if (text == 'httpCode') {
							httpCode = value;
						} else if (text == 'errorCode') {
							errorCode = value;
						} else if (text == 'message') {
							message = value;
						} else if (text == 'detailedMessage') {
							detailedMessage = value;
						} else if (text == 'link') {
							link = new Link(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'Error consuming unrecognized property: ' + text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Link {
		public String rel;
		public String href;

		public Link(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        String value = handleNullValue(parser.getText());
						if (text == 'rel') {
							rel = value;
						} else if (text == 'href') {
							href = value;
						} else {
							System.debug(LoggingLevel.WARN, 'Link consuming unrecognized property: ' + text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
    
    private static List<Schedule> getSchedules(System.JSONParser parser) {
        List<Schedule> result = new List<Schedule>();
        if (parser.getCurrentToken() == null) parser.nextToken();
        while (parser.nextToken() != System.JSONToken.END_ARRAY) {
			if (parser.getCurrentToken() == System.JSONToken.VALUE_NULL) {
				break;
			}
            result.add(new Schedule(parser));
        }
        return result;
    }
    
    private static List<Periods> getPeriods(System.JSONParser parser) {
        List<Periods> result = new List<Periods>();
        if (parser.getCurrentToken() == null) parser.nextToken();
        
        // "periods" : {...}
        if (parser.getCurrentToken() == System.JSONToken.START_OBJECT) {
            result.add(new Periods(parser));
            
        // "periods" : [...]
        } else if (parser.getCurrentToken() == System.JSONToken.START_ARRAY){
            while (parser.nextToken() != System.JSONToken.END_ARRAY) {
                result.add(new Periods(parser));
            }
        }
        return result;
    }
    
    private static void consumeObject(System.JSONParser parser) {
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
	
	private static String handleNullValue(String value) {
        return String.isBlank(value) || value == 'null' ? null : value;
    }
}