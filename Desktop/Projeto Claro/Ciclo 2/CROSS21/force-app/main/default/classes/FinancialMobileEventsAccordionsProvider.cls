/**
 * @description       : Classe responsável por adicionar e gerenciar os accordions na aba de eventos
 * @author            : Roger Rosset
 * @group             : Financeiro-Eventos
 * @last modified on  : 30-12-2020
 * @last modified by  : Roger Rosset
 * Modifications Log
 * Ver   Date         Author         Modification
 * 1.0   26-10-2020   Roger Rosset   Initial Version
 **/
public with sharing class FinancialMobileEventsAccordionsProvider {
	@AuraEnabled
	public static List<FinancialMobileEventsWrapper.EventGroup> getAccordionsList() {
		List<FinancialMobileEventsWrapper.EventGroup> accordionsList = new List<FinancialMobileEventsWrapper.EventGroup>();

		AccordionProps accordionComprasProps = new AccordionProps();
		accordionComprasProps.accordionTitle = 'Compras e Movimentações';
		accordionComprasProps.namedCredential = 'OAGClaro';
		accordionComprasProps.customSetting = 'GetMobileHistory';
		accordionComprasProps.hasMultipleGroups = false;
		accordionComprasProps.groupBy = null;
		accordionComprasProps.hasModal = true;
		accordionComprasProps.isActive = true;
		accordionComprasProps.msisdn = false;
		accordionComprasProps.crmCustomerId = false;
		accordionComprasProps.callApiOnRowActions = false;
		accordionComprasProps.apiToCallOnRowAction = null;
		accordionComprasProps.implemented = true;
		accordionComprasProps.isMsisdnGroup = false;

		FinancialMobileEventsWrapper.EventGroup accordionCompras = accordionSectionAdder(accordionComprasProps);
		accordionsList.add(accordionCompras);

		AccordionProps accordionReajustesProps = new AccordionProps();
		accordionReajustesProps.accordionTitle = 'Reajustes';
		accordionReajustesProps.namedCredential = 'OAGClaro';
		accordionReajustesProps.customSetting = '';
		accordionReajustesProps.hasMultipleGroups = false;
		accordionReajustesProps.groupBy = null;
		accordionReajustesProps.hasModal = true;
		accordionReajustesProps.isActive = true;
		accordionReajustesProps.msisdn = false;
		accordionReajustesProps.crmCustomerId = false;
		accordionReajustesProps.callApiOnRowActions = false;
		accordionReajustesProps.apiToCallOnRowAction = null;
		accordionReajustesProps.implemented = false;
		accordionReajustesProps.isMsisdnGroup = false;

		FinancialMobileEventsWrapper.EventGroup accordionReajustes = accordionSectionAdder(accordionReajustesProps);
		accordionsList.add(accordionReajustes);

		AccordionProps accordionMigracoesProps = new AccordionProps();
		accordionMigracoesProps.accordionTitle = 'Migrações e Cancelamentos';
		accordionMigracoesProps.namedCredential = 'OAGClaro';
		accordionMigracoesProps.customSetting = 'GetMigrations';
		accordionMigracoesProps.hasMultipleGroups = false;
		accordionMigracoesProps.groupBy = null;
		accordionMigracoesProps.hasModal = false;
		accordionMigracoesProps.isActive = true;
		accordionMigracoesProps.msisdn = false;
		accordionMigracoesProps.crmCustomerId = false;
		accordionMigracoesProps.callApiOnRowActions = false;
		accordionMigracoesProps.apiToCallOnRowAction = null;
		accordionMigracoesProps.implemented = true;
		accordionMigracoesProps.isMsisdnGroup = false;

		FinancialMobileEventsWrapper.EventGroup accordionMigracoes = accordionSectionAdder(accordionMigracoesProps);
		accordionsList.add(accordionMigracoes);

		AccordionProps accordionAgregadoresProps = new AccordionProps();
		accordionAgregadoresProps.accordionTitle = 'Agregadores';
		accordionAgregadoresProps.namedCredential = 'OAGClaro';
		accordionAgregadoresProps.customSetting = 'GetSubscriberVas';
		accordionAgregadoresProps.hasMultipleGroups = false;
		accordionAgregadoresProps.groupBy = null;
		accordionAgregadoresProps.hasModal = false;
		accordionAgregadoresProps.isActive = true;
		accordionAgregadoresProps.msisdn = true;
		accordionAgregadoresProps.crmCustomerId = false;
		accordionAgregadoresProps.callApiOnRowActions = false;
		accordionAgregadoresProps.apiToCallOnRowAction = null;
		accordionAgregadoresProps.implemented = true;
		accordionAgregadoresProps.isMsisdnGroup = true;

		FinancialMobileEventsWrapper.EventGroup accordionAgregadores = accordionSectionAdder(accordionAgregadoresProps);
		accordionsList.add(accordionAgregadores);

		AccordionProps accordionRegistrosFinanceiroProps = new AccordionProps();
		accordionRegistrosFinanceiroProps.accordionTitle = 'Registros de Atendimento - Financeiro';
		accordionRegistrosFinanceiroProps.namedCredential = 'OAGClaro';
		accordionRegistrosFinanceiroProps.customSetting = 'GetInteractions';
		accordionRegistrosFinanceiroProps.hasMultipleGroups = true;
		accordionRegistrosFinanceiroProps.groupBy = 'financeiro';
		accordionRegistrosFinanceiroProps.hasModal = true;
		accordionRegistrosFinanceiroProps.isActive = true;
		accordionRegistrosFinanceiroProps.msisdn = false;
		accordionRegistrosFinanceiroProps.crmCustomerId = true;
		accordionRegistrosFinanceiroProps.callApiOnRowActions = true;
		accordionRegistrosFinanceiroProps.apiToCallOnRowAction = 'GetInteractionsProtocol';
		accordionRegistrosFinanceiroProps.implemented = true;
		accordionRegistrosFinanceiroProps.isMsisdnGroup = true;

		FinancialMobileEventsWrapper.EventGroup accordionRegistrosFinanceiro = accordionSectionAdder(accordionRegistrosFinanceiroProps);
		accordionsList.add(accordionRegistrosFinanceiro);

		AccordionProps accordionRegistrosCancelamentoProps = new AccordionProps();
		accordionRegistrosCancelamentoProps.accordionTitle = 'Registros de Atendimento - Cancelamento';
		accordionRegistrosCancelamentoProps.namedCredential = 'OAGClaro';
		accordionRegistrosCancelamentoProps.customSetting = 'GetInteractions';
		accordionRegistrosCancelamentoProps.hasMultipleGroups = true;
		accordionRegistrosCancelamentoProps.groupBy = 'cancelamento';
		accordionRegistrosCancelamentoProps.hasModal = true;
		accordionRegistrosCancelamentoProps.isActive = true;
		accordionRegistrosCancelamentoProps.msisdn = false;
		accordionRegistrosCancelamentoProps.crmCustomerId = true;
		accordionRegistrosCancelamentoProps.callApiOnRowActions = true;
		accordionRegistrosCancelamentoProps.apiToCallOnRowAction = 'GetInteractionsProtocol';
		accordionRegistrosCancelamentoProps.implemented = true;
		accordionRegistrosCancelamentoProps.isMsisdnGroup = true;

		FinancialMobileEventsWrapper.EventGroup accordionRegistrosCancelamento = accordionSectionAdder(accordionRegistrosCancelamentoProps);
		accordionsList.add(accordionRegistrosCancelamento);

		AccordionProps accordionTerminoOfertasProps = new AccordionProps();
		accordionTerminoOfertasProps.accordionTitle = 'Término de Ofertas';
		accordionTerminoOfertasProps.namedCredential = 'OAGClaro';
		accordionTerminoOfertasProps.customSetting = '';
		accordionTerminoOfertasProps.hasMultipleGroups = false;
		accordionTerminoOfertasProps.groupBy = null;
		accordionTerminoOfertasProps.hasModal = false;
		accordionTerminoOfertasProps.isActive = true;
		accordionTerminoOfertasProps.msisdn = false;
		accordionTerminoOfertasProps.crmCustomerId = false;
		accordionTerminoOfertasProps.callApiOnRowActions = false;
		accordionTerminoOfertasProps.apiToCallOnRowAction = null;
		accordionTerminoOfertasProps.implemented = false;
		accordionTerminoOfertasProps.isMsisdnGroup = false;

		FinancialMobileEventsWrapper.EventGroup accordionTerminoOfertas = accordionSectionAdder(accordionTerminoOfertasProps);
		accordionsList.add(accordionTerminoOfertas);

		AccordionProps accordionPortabilidadeProps = new AccordionProps();
		accordionPortabilidadeProps.accordionTitle = 'Portabilidade';
		accordionPortabilidadeProps.namedCredential = 'OAGClaro';
		accordionPortabilidadeProps.customSetting = '';
		accordionPortabilidadeProps.hasMultipleGroups = false;
		accordionPortabilidadeProps.groupBy = null;
		accordionPortabilidadeProps.hasModal = false;
		accordionPortabilidadeProps.isActive = true;
		accordionPortabilidadeProps.msisdn = false;
		accordionPortabilidadeProps.crmCustomerId = false;
		accordionPortabilidadeProps.callApiOnRowActions = false;
		accordionPortabilidadeProps.apiToCallOnRowAction = null;
		accordionPortabilidadeProps.implemented = false;
		accordionPortabilidadeProps.isMsisdnGroup = false;

		FinancialMobileEventsWrapper.EventGroup accordionPortabilidade = accordionSectionAdder(accordionPortabilidadeProps);
		accordionsList.add(accordionPortabilidade);

		return accordionsList;
	}

	private static FinancialMobileEventsWrapper.EventGroup accordionSectionAdder(AccordionProps props) {
		String accordionTitle = props.accordionTitle;
		String namedCredential = props.namedCredential;
		String customSetting = props.customSetting;
		Boolean hasMultipleGroups = props.hasMultipleGroups;
		String groupBy = props.groupBy;
		Boolean hasModal = props.hasModal;
		Boolean isActive = props.isActive;
		Boolean msisdn = props.msisdn;
		Boolean crmCustomerId = props.crmCustomerId;
		Boolean callApiOnRowActions = props.callApiOnRowActions;
		String apiToCallOnRowAction = props.apiToCallOnRowAction;
		Boolean implemented = props.implemented;
		Boolean isMsisdnGroup = props.isMsisdnGroup;

		FinancialMobileEventsWrapper.EventGroup accordionSection = new FinancialMobileEventsWrapper.EventGroup();
		FinancialMobileEventsWrapper.EventRequestAttributes accordionAttributes = new FinancialMobileEventsWrapper.EventRequestAttributes();

		//Instanciando os atributos do accordion
		accordionAttributes.namedCredential = namedCredential;
		accordionAttributes.implemented = implemented;
		accordionAttributes.customSetting = customSetting;
		accordionAttributes.hasMultipleGroups = hasMultipleGroups;
		accordionAttributes.groupBy = groupBy;
		accordionAttributes.accordionId = accordionTitle.replace(' ', '');
		accordionAttributes.accordionId = accordionAttributes.accordionId.replace('-', '');
		accordionAttributes.callApiOnRowAction = callApiOnRowActions;
		accordionAttributes.apiToCallOnRowAction = apiToCallOnRowAction;
		//Instanciando os parametros do accordion
		accordionSection.accordionTitle = accordionTitle;
		accordionSection.requireMsisdn = msisdn;
		accordionSection.requireCrmCustomerId = crmCustomerId;
		accordionSection.accordionId = accordionTitle.replace(' ', '');
		accordionSection.accordionId = accordionSection.accordionId.replace('-', '');
		accordionSection.attributes = accordionAttributes;
		accordionSection.hasModal = hasModal;
		accordionSection.active = isActive;
		accordionSection.isMsisdnGroup = isMsisdnGroup;

		return accordionSection;
	}
	private class AccordionProps {
		private String accordionTitle;
		private String namedCredential;
		private String customSetting;
		private Boolean hasMultipleGroups;
		private String groupBy;
		private Boolean hasModal;
		private Boolean isActive;
		private Boolean msisdn;
		private Boolean crmCustomerId;
		private Boolean callApiOnRowActions;
		private String apiToCallOnRowAction;
		private Boolean implemented;
		private Boolean isMsisdnGroup;
	}
}