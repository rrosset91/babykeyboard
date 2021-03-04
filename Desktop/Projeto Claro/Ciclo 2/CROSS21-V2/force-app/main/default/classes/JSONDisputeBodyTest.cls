/**
* @author: 
* @company: IBM - Bluewolf
* @description: Teste para a classe JSONDisputeBody
*/

@isTest
public class JSONDisputeBodyTest {
		@isTest static void testDisputeConvert(){
        String jsonString = '{'+
		'    \"apiVersion\": \"1\",'+
		'    \"transactionId\": \"32132131\",'+
		'    \"data\": {'+
		'            \"type\": \"object\",'+
		'            \"properties\": {'+
		'              \"billId\": {'+
		'                \"type\": \"integer\",'+
		'                \"description\": \"Id do boleto.\",'+
		'                \"example\": 12078302'+
		'              },'+
		'              \"dueDate\": {'+
		'                \"type\": \"string\",'+
		'                \"description\": \"Data Vencimento do boleto\",'+
		'                \"maxLength\": 19,'+
		'                \"pattern\": \"^\\\\d{4}-\\\\d{2}-\\\\d{2}T\\\\d{2}:\\\\d{2}:\\\\d{2}$\",'+
		'                \"format\": \"date-time\",'+
		'                \"example\": \"2019-01-28T14:00:00\"'+
		'              },'+
		'              \"partners\": {'+
		'                \"type\": \"string\",'+
		'                \"description\": \"Nome do Parceiro\",'+
		'                \"example\": \"EMBRATEL / NET / CLARO\"'+
		'              },'+
		'              \"paymentMethod\": {'+
		'                \"type\": \"string\",'+
		'                \"description\": \"Modalidade de Cobrança do boleto\",'+
		'                \"example\": \"DEBITO EM CONTA\"'+
		'              },'+
		'              \"status\": {'+
		'                \"type\": \"string\",'+
		'                \"description\": \"Situação atual do boleto\",'+
		'                \"example\": \"Pago\"'+
		'              },'+
		'              \"paymentDate\": {'+
		'                \"type\": \"string\",'+
		'                \"description\": \"Data do pagamnto do boleto\",'+
		'                \"maxLength\": 19,'+
		'                \"pattern\": \"^\\\\d{4}-\\\\d{2}-\\\\d{2}T\\\\d{2}:\\\\d{2}:\\\\d{2}$\",'+
		'                \"format\": \"date-time\",'+
		'                \"example\": \"2019-01-28T14:00:00\"'+
		'              },'+
		'              \"executeDate\": {'+
		'                \"type\": \"string\",'+
		'                \"description\": \"Data Baixa do boleto\",'+
		'                \"maxLength\": 19,'+
		'                \"pattern\": \"^\\\\d{4}-\\\\d{2}-\\\\d{2}T\\\\d{2}:\\\\d{2}:\\\\d{2}$\",'+
		'                \"format\": \"date-time\",'+
		'                \"example\": \"2019-01-28T14:00:00\"'+
		'              },'+
		'              \"cancelDate\": {'+
		'                \"type\": \"string\",'+
		'                \"description\": \"Data do cancelamento do boleto\",'+
		'                \"maxLength\": 19,'+
		'                \"pattern\": \"^\\\\d{4}-\\\\d{2}-\\\\d{2}T\\\\d{2}:\\\\d{2}:\\\\d{2}$\",'+
		'                \"format\": \"date-time\",'+
		'                \"example\": \"2019-01-28T14:00:00\"'+
		'              },'+
		'              \"dueDay\": {'+
		'                \"type\": \"integer\",'+
		'                \"description\": \"Dia de vencimento do boleto.\",'+
		'                \"example\": 1'+
		'              },'+
		'              \"bestDayPaymentParameter\": {'+
		'                \"type\": \"integer\",'+
		'                \"description\": \"Quantidade de dias ideal para compras antes do vencimento.\",'+
		'                \"example\": 25'+
		'              },'+
		'              \"billCode\": {'+
		'                \"type\": \"string\",'+
		'                \"description\": \"Linha Digitável do código de barras.\",'+
		'                \"example\": 8.460000002494103e+45'+
		'              },'+
		'              \"formatedBillCode\": {'+
		'                \"type\": \"string\",'+
		'                \"description\": \"Linha Digitável do código de barras formatada.\",'+
		'                \"example\": \"84600000002-2 49410296201-1 30610055000-4 00057102314-2\"'+
		'              },'+
		'              \"amount\": {'+
		'                \"type\": \"number\",'+
		'                \"format\": \"float\",'+
		'                \"description\": \"Valor total da fatura.\",'+
		'                \"example\": \"9,99\"'+
		'              },'+
		'              \"totalTaxMessage\": {'+
		'                \"type\": \"integer\",'+
		'                \"description\": \"Mensagem total do imposto.\",'+
		'                \"example\": 1'+
		'              },'+
		'              \"invoiceItems\": {'+
		'                \"type\": \"array\",'+
		'                \"items\": {'+
		'                  \"type\": \"object\",'+
		'                  \"properties\": {'+
		'                    \"name\": {'+
		'                      \"type\": \"string\",'+
		'                      \"description\": \"Nome do item da fatura.\",'+
		'                      \"example\": \"TV POR ASSINATURA\"'+
		'                    },'+
		'                    \"description\": {'+
		'                      \"type\": \"string\",'+
		'                      \"description\": \"Descrição do item da fatura.\",'+
		'                      \"example\": \"01/08/17 A 31/08/17  MENSALIDADE TV PRINCIPAL SELEÇÃO NET MAIS TELECINE RET CONF FID\"'+
		'                    },'+
		'                    \"amount\": {'+
		'                      \"type\": \"number\",'+
		'                      \"format\": \"float\",'+
		'                      \"description\": \"Valor Bruto do item.\",'+
		'                      \"example\": \"123,34\"'+
		'                    },'+
		'                    \"taxes\": {'+
		'                      \"type\": \"array\",'+
		'                      \"items\": {'+
		'                        \"type\": \"object\",'+
		'                        \"properties\": {'+
		'                          \"taxType\": {'+
		'                            \"type\": \"string\",'+
		'                            \"description\": \"Tipo do imposto\",'+
		'                            \"example\": \"COFINS\",'+
		'                            \"enum\": ['+
		'                              \"PIS\",'+
		'                              \"COFINS\",'+
		'                              \"ISS\",'+
		'                              \"ICMS\",'+
		'                              \"FUST\",'+
		'                              \"FUNTEL\"'+
		'                            ]'+
		'                          },'+
		'                          \"value\": {'+
		'                            \"type\": \"number\",'+
		'                            \"format\": \"float\",'+
		'                            \"description\": \"Valor do imposto\",'+
		'                            \"example\": \"123,45\"'+
		'                          },'+
		'                          \"aliquot\": {'+
		'                            \"type\": \"number\",'+
		'                            \"format\": \"float\",'+
		'                            \"description\": \"Valor da aliquota do imposto\",'+
		'                            \"example\": \"123,45\"'+
		'                          }'+
		'                        }'+
		'                      }'+
		'                    }'+
		'                  }'+
		'                }'+
		'              },'+
		'              \"messages\": {'+
		'                \"type\": \"array\",'+
		'                \"items\": {'+
		'                  \"type\": \"object\",'+
		'                  \"properties\": {'+
		'                    \"text\": {'+
		'                      \"type\": \"string\",'+
		'                      \"description\": \"Descrição das mensagens da nota.\",'+
		'                      \"example\": \"Regime especial proc. Nº. E-04/079/1262/13. Retenção de 9,45%, conforme Lei 9430 - Total R$ -11,62 (IRPJ 4,80% - R$ 5,90, CSLL 1,00% - R$ 1,23, COFINS 3,00% - R$ 3,69, PIS/PASEP 0,65% - R$ 0,80).\"'+
		'                    }'+
		'                  }'+
		'                }'+
		'              },'+
		'              \"itemGroups\": {'+
		'                \"type\": \"array\",'+
		'                \"items\": {'+
		'                  \"type\": \"object\",'+
		'                  \"properties\": {'+
		'                    \"description\": {'+
		'                      \"type\": \"string\",'+
		'                      \"description\": \"Descrição do agrupamento de Produtos.\",'+
		'                      \"example\": \"TV POR ASSINATURA.\"'+
		'                    },'+
		'                    \"amount\": {'+
		'                      \"type\": \"string\",'+
		'                      \"description\": \"Valor total do agrupamento do produto.\",'+
		'                      \"example\": \"122,9.\"'+
		'                    }'+
		'                  }'+
		'                }'+
		'              },'+
		'              \"partnerDebts\": {'+
		'                \"type\": \"array\",'+
		'                \"items\": {'+
		'                  \"type\": \"object\",'+
		'                  \"properties\": {'+
		'                    \"partnerId\": {'+
		'                      \"type\": \"integer\",'+
		'                      \"description\": \"código do parceiro.\",'+
		'                      \"example\": 16'+
		'                    },'+
		'                    \"partnerName\": {'+
		'                      \"type\": \"string\",'+
		'                      \"description\": \"Nome do Parceiro.\",'+
		'                      \"example\": \"NET.\"'+
		'                    },'+
		'                    \"debtId\": {'+
		'                      \"type\": \"integer\",'+
		'                      \"description\": \"código da cobrança.\",'+
		'                      \"example\": 1234'+
		'                    },'+
		'                    \"generationDate\": {'+
		'                      \"type\": \"string\",'+
		'                      \"description\": \"Data da geração da cobrança\",'+
		'                      \"example\": \"2019-10-25T15:00:00.000Z\"'+
		'                    },'+
		'                    \"originalDueDate\": {'+
		'                      \"type\": \"string\",'+
		'                      \"description\": \"Data do vencimento original\",'+
		'                      \"example\": \"2019-10-25T15:00:00.000Z\"'+
		'                    },'+
		'                    \"dueDate\": {'+
		'                      \"type\": \"string\",'+
		'                      \"description\": \"Data do vencimento\",'+
		'                      \"example\": \"2019-10-25T15:00:00.000Z\"'+
		'                    },'+
		'                    \"amount\": {'+
		'                      \"type\": \"number\",'+
		'                      \"format\": \"float\",'+
		'                      \"description\": \"Valor Total.\",'+
		'                      \"example\": \"2,5.\"'+
		'                    },'+
		'                    \"amountPaid\": {'+
		'                      \"type\": \"number\",'+
		'                      \"format\": \"float\",'+
		'                      \"description\": \"Valor Pago.\",'+
		'                      \"example\": \"2,5.\"'+
		'                    },'+
		'                    \"balance\": {'+
		'                      \"type\": \"number\",'+
		'                      \"format\": \"float\",'+
		'                      \"description\": \"Saldo devedor.\",'+
		'                      \"example\": \"2,5.\"'+
		'                    },'+
		'                    \"isExternalCollecting\": {'+
		'                      \"type\": \"boolean\",'+
		'                      \"description\": \"Flag indicador para sistema externo de cobrança.\",'+
		'                      \"example\": true'+
		'                    },'+
		'                    \"statusId\": {'+
		'                      \"type\": \"integer\",'+
		'                      \"description\": \"Código da situação da Cobrança.\",'+
		'                      \"example\": 1'+
		'                    },'+
		'                    \"status\": {'+
		'                      \"type\": \"string\",'+
		'                      \"description\": \"Situação da Cobrança.\",'+
		'                      \"example\": \"EM ABERTO\"'+
		'                    },'+
		'                    \"debtGroup\": {'+
		'                      \"type\": \"array\",'+
		'                      \"items\": {'+
		'                        \"type\": \"object\",'+
		'                        \"properties\": {'+
		'                          \"groupId\": {'+
		'                            \"type\": \"integer\",'+
		'                            \"description\": \"Código do Grupo da nota fiscal.\",'+
		'                            \"example\": 1'+
		'                          },'+
		'                          \"groupdescription\": {'+
		'                            \"type\": \"string\",'+
		'                            \"description\": \"Descrição do Grupo da nota fiscal.\",'+
		'                            \"example\": \"TV POR ASSINATURA\"'+
		'                          },'+
		'                          \"amount\": {'+
		'                            \"type\": \"string\",'+
		'                            \"description\": \"Valor Total por grupo.\",'+
		'                            \"example\": 99.9'+
		'                          },'+
		'                          \"order\": {'+
		'                            \"type\": \"string\",'+
		'                            \"description\": \"Ordem de visualização.\",'+
		'                            \"example\": 1'+
		'                          },'+
		'                          \"extractItems\": {'+
		'                            \"type\": \"array\",'+
		'                            \"items\": {'+
		'                              \"type\": \"object\",'+
		'                              \"properties\": {'+
		'                                \"extractItemId\": {'+
		'                                  \"type\": \"integer\",'+
		'                                  \"description\": \"Código do item de extrato.\",'+
		'                                  \"example\": 123'+
		'                                },'+
		'                                \"extractItemTypeId\": {'+
		'                                  \"type\": \"string\",'+
		'                                  \"description\": \"Código do tipo do item de extrato.\",'+
		'                                  \"example\": 2'+
		'                                },'+
		'                                \"extractItemTypeDescription\": {'+
		'                                  \"type\": \"string\",'+
		'                                  \"description\": \"MENSALIDADE TV PRINCIPAL\",'+
		'                                  \"example\": \"Descrição do tipo do item de extrato\"'+
		'                                },'+
		'                                \"installmentNumber\": {'+
		'                                  \"type\": \"integer\",'+
		'                                  \"description\": \"Número da Parcela.\",'+
		'                                  \"example\": 2'+
		'                                },'+
		'                                \"totalInstallments\": {'+
		'                                  \"type\": \"integer\",'+
		'                                  \"description\": \"Quantidade de Parcelas.\",'+
		'                                  \"example\": 2'+
		'                                },'+
		'                                \"dueDate\": {'+
		'                                  \"type\": \"string\",'+
		'                                  \"description\": \"Data do vencimento\",'+
		'                                  \"example\": \"2019-10-25T15:00:00.000Z\"'+
		'                                },'+
		'                                \"entryDate\": {'+
		'                                  \"type\": \"string\",'+
		'                                  \"description\": \"Data do Lançamento\",'+
		'                                  \"example\": \"2019-10-25T15:00:00.000Z\"'+
		'                                },'+
		'                                \"amount\": {'+
		'                                  \"type\": \"number\",'+
		'                                  \"format\": \"float\",'+
		'                                  \"description\": \"Valor do Item de extrato.\",'+
		'                                  \"example\": 99.9'+
		'                                },'+
		'                                \"addressComplement\": {'+
		'                                  \"type\": \"string\",'+
		'                                  \"description\": \"Complemento do endereço ao qual o item se refere\",'+
		'                                  \"example\": \"APARTAMENTO 32\"'+
		'                                },'+
		'                                \"pointId\": {'+
		'                                  \"type\": \"integer\",'+
		'                                  \"description\": \"Código do Ponto\",'+
		'                                  \"example\": 321241'+
		'                                },'+
		'                                \"productId\": {'+
		'                                  \"type\": \"integer\",'+
		'                                  \"description\": \"Código do produto.\",'+
		'                                  \"example\": 14323'+
		'                                },'+
		'                                \"productDescription\": {'+
		'                                  \"type\": \"string\",'+
		'                                  \"description\": \"Descrição do Produto\",'+
		'                                  \"example\": \"ACESSO VIRTUA\"'+
		'                                },'+
		'                                \"proRataUnificationGroup\": {'+
		'                                  \"type\": \"integer\",'+
		'                                  \"description\": \"Agrupamento unificação de pró rata.\",'+
		'                                  \"example\": 1'+
		'                                },'+
		'                                \"proRataStartDate\": {'+
		'                                  \"type\": \"string\",'+
		'                                  \"description\": \"Data de início da proporcionalidade.\",'+
		'                                  \"example\": \"2019-10-25T15:00:00.000Z\"'+
		'                                },'+
		'                                \"order\": {'+
		'                                  \"type\": \"integer\",'+
		'                                  \"description\": \"Ordem de visualização\",'+
		'                                  \"example\": 1'+
		'                                }'+
		'                              }'+
		'                            }'+
		'                          }'+
		'                        }'+
		'                      }'+
		'                    },'+
		'                    \"serviceGroup\": {'+
		'                      \"type\": \"array\",'+
		'                      \"items\": {'+
		'                        \"type\": \"object\",'+
		'                        \"properties\": {'+
		'                          \"partnerServiceId\": {'+
		'                            \"type\": \"integer\",'+
		'                            \"description\": \"Código do Serviço do Parceiro CLARO\",'+
		'                            \"example\": 1'+
		'                          },'+
		'                          \"partnerServiceDescription\": {'+
		'                            \"type\": \"string\",'+
		'                            \"description\": \"Descrição do Serviço do Parceiro\",'+
		'                            \"example\": \"NET FONE VIA EMBRATEL\"'+
		'                          },'+
		'                          \"partnerServiceAmount\": {'+
		'                            \"type\": \"number\",'+
		'                            \"format\": \"float\",'+
		'                            \"description\": \"Valor do Serviço do parceiro\",'+
		'                            \"example\": \"99,9\"'+
		'                          },'+
		'                          \"partnerExtracts\": {'+
		'                            \"type\": \"array\",'+
		'                            \"items\": {'+
		'                              \"allOf\": ['+
		'                                {'+
		'                                  \"$ref\": \"#/components/schemas/partnerExtractObj\"'+
		'                                }'+
		'                              ]'+
		'                            }'+
		'                          },'+
		'                          \"partnerPhones\": {'+
		'                            \"type\": \"array\",'+
		'                            \"items\": {'+
		'                              \"type\": \"object\",'+
		'                              \"properties\": {'+
		'                                \"originTerminal\": {'+
		'                                  \"type\": \"string\",'+
		'                                  \"description\": \"Terminal Origem (Telefone).\",'+
		'                                  \"example\": \"1933421042--FRANQUIA 001\"'+
		'                                },'+
		'                                \"amount\": {'+
		'                                  \"type\": \"number\",'+
		'                                  \"format\": \"float\",'+
		'                                  \"description\": \"Valor terminal Origem do telefone.\",'+
		'                                  \"example\": \"25,64\"'+
		'                                },'+
		'                                \"partnerExtracts\": {'+
		'                                  \"type\": \"array\",'+
		'                                  \"items\": {'+
		'                                    \"type\": \"object\",'+
		'                                    \"allOf\": ['+
		'                                      {'+
		'                                        \"$ref\": \"#/components/schemas/partnerExtractObj\"'+
		'                                      },'+
		'                                      {'+
		'                                        \"type\": \"object\",'+
		'                                        \"properties\": {'+
		'                                          \"details\": {'+
		'                                            \"type\": \"array\",'+
		'                                            \"items\": {'+
		'                                              \"type\": \"object\",'+
		'                                              \"properties\": {'+
		'                                                \"itemDetailId\": {'+
		'                                                  \"type\": \"integer\",'+
		'                                                  \"description\": \"Código do detalhe do item de extrato parceiro.\",'+
		'                                                  \"example\": 312312123'+
		'                                                },'+
		'                                                \"sequenceNumber\": {'+
		'                                                  \"type\": \"integer\",'+
		'                                                  \"description\": \"Número sequencial.\",'+
		'                                                  \"example\": 15'+
		'                                                },'+
		'                                                \"startDate\": {'+
		'                                                  \"type\": \"string\",'+
		'                                                  \"description\": \"Data início do serviço\",'+
		'                                                  \"example\": \"2019-10-25T15:00:00.000Z\"'+
		'                                                },'+
		'                                                \"endDate\": {'+
		'                                                  \"type\": \"string\",'+
		'                                                  \"description\": \"Data fim do serviço\",'+
		'                                                  \"example\": \"2019-10-25T15:00:00.000Z\"'+
		'                                                },'+
		'                                                \"startTime\": {'+
		'                                                  \"type\": \"string\",'+
		'                                                  \"description\": \"Hora início do serviço.\",'+
		'                                                  \"example\": \"07:44:48\"'+
		'                                                },'+
		'                                                \"endTime\": {'+
		'                                                  \"type\": \"string\",'+
		'                                                  \"description\": \"Hora Fim do serviço.\",'+
		'                                                  \"example\": \"07:44:48\"'+
		'                                                },'+
		'                                                \"origin\": {'+
		'                                                  \"type\": \"string\",'+
		'                                                  \"description\": \"Origem da ligação.\",'+
		'                                                  \"example\": \"CAS SP\"'+
		'                                                },'+
		'                                                \"destination\": {'+
		'                                                  \"type\": \"string\",'+
		'                                                  \"description\": \"Destino da ligação\",'+
		'                                                  \"example\": \"Campinas\"'+
		'                                                },'+
		'                                                \"destinationCountry\": {'+
		'                                                  \"type\": \"string\",'+
		'                                                  \"description\": \"Pais da Ligação.\",'+
		'                                                  \"example\": \"BRA\"'+
		'                                                },'+
		'                                                \"callDuration\": {'+
		'                                                  \"type\": \"number\",'+
		'                                                  \"format\": \"float\",'+
		'                                                  \"description\": \"Duração da ligação.\",'+
		'                                                  \"example\": \"5,5\"'+
		'                                                },'+
		'                                                \"callDurationUnit\": {'+
		'                                                  \"type\": \"string\",'+
		'                                                  \"description\": \"Unidade de tempo.\",'+
		'                                                  \"example\": \"MINUTO\"'+
		'                                                },'+
		'                                                \"callValue\": {'+
		'                                                  \"type\": \"number\",'+
		'                                                  \"format\": \"float\",'+
		'                                                  \"description\": \"Valor Liquido.\",'+
		'                                                  \"example\": 15'+
		'                                                },'+
		'                                                \"callDetailValue\": {'+
		'                                                  \"type\": \"number\",'+
		'                                                  \"format\": \"float\",'+
		'                                                  \"description\": \"Valor Detalhado.\",'+
		'                                                  \"example\": 15'+
		'                                                },'+
		'                                                \"originTerminal\": {'+
		'                                                  \"type\": \"string\",'+
		'                                                  \"description\": \"Número Origem.\",'+
		'                                                  \"example\": \"1933421042--FRANQUIA 001\"'+
		'                                                },'+
		'                                                \"targetTerminal\": {'+
		'                                                  \"type\": \"string\",'+
		'                                                  \"description\": \"Número Destino.\",'+
		'                                                  \"example\": 1933887390'+
		'                                                },'+
		'                                                \"taxType\": {'+
		'                                                  \"type\": \"string\",'+
		'                                                  \"description\": \"Tipo de imposto.\",'+
		'                                                  \"example\": \"E\"'+
		'                                                },'+
		'                                                \"entryDate\": {'+
		'                                                  \"type\": \"string\",'+
		'                                                  \"description\": \"Data da Inclusão.\",'+
		'                                                  \"example\": \"2019-10-25T15:00:00.000Z\"'+
		'                                                }'+
		'                                              }'+
		'                                            }'+
		'                                          }'+
		'                                        }'+
		'                                      }'+
		'                                    ]'+
		'                                  }'+
		'                                }'+
		'                              }'+
		'                            }'+
		'                          }'+
		'                        }'+
		'                      }'+
		'                    }'+
		'                  }'+
		'                }'+
		'              }'+
		'            }'+
		'          }'+
		'        }'+
		'      },'+
		''+
		'    \"error\": {'+
		'        \"httpCode\": \"400\",'+
		'        \"errorCode\": \"API-3566\",'+
		'        \"message\": \"Mensagem de erro resumida\",'+
		'        \"detailedMessage\": \"Mensagem de erro detalhada\",'+
		'        \"link\": {'+
		'            \"rel\": \"related\",'+
		'            \"href\": \"https://claro.com.br/P06CEC/corp\"'+
		'        }'+
		'    }'+
		'}';
		JSONDisputeBody obj = JSONDisputeBody.parse(jsonString);
		System.assert(obj != null);
    }	
}