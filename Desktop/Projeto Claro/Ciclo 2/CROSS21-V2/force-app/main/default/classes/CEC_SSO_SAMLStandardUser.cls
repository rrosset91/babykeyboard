global class CEC_SSO_SAMLStandardUser implements Auth.SamlJitHandler
{
  private class JitException extends Exception {}

  private void handleUser(boolean create, User u, Map < String, String > attributes, String federationIdentifier, boolean isStandard)
  {
    if (attributes.containsKey('User.UserName'))
    {
      u.Username = attributes.get('User.UserName');
    }

    if (create)
    {
      String lFedId = attributes.get('User.FederationIdentifier');
      u.FederationIdentifier = (String.isNotBlank(lFedId)) ? lFedId : federationIdentifier;
    }

    String profileId = attributes.get('User.ProfileId');
    list<Profile> lLstProf = (profileId == null) ? new list<Profile>() : [SELECT Id, UserLicense.LicenseDefinitionKey FROM Profile WHERE Id = :profileId];
    if (!lLstProf.isEmpty()) 
        u.ProfileId = lLstProf[0].Id;
    else
        throw new JitException('Id de perfil vazio ou inexistente.');   
        
    if(lLstProf[0].UserLicense.LicenseDefinitionKey.equals('SFDC'))
        u.UserPermissionsSupportUser = true;

    if (attributes.containsKey('User.Phone'))
    {
      u.Phone = attributes.get('User.Phone');
    }

    if (attributes.containsKey('User.CPF__c'))
    {
      u.CPF__c = attributes.get('User.CPF__c').replaceAll('[.-]', '');
    }

    if (attributes.containsKey('User.FirstName'))
    {
      u.FirstName = attributes.get('User.FirstName');
      if(u.FirstName == null)
          throw new JitException('FirstName vazio.');   
    }

    if (attributes.containsKey('User.LastName'))
    {
      u.LastName = attributes.get('User.LastName');
      if(u.LastName == null)
          throw new JitException('LastName vazio.');   
    }

    if (attributes.containsKey('User.Embratel__c'))
    {
      u.Embratel__c = attributes.get('User.Embratel__c');
    }

    if (attributes.containsKey('User.CompanyName'))
    {
      u.CompanyName = attributes.get('User.CompanyName');
    }
      
    if (attributes.containsKey('User.LoginClaro__c'))
    {
        u.Claro__c = attributes.get('User.LoginClaro__c');
    }

    if (attributes.containsKey('User.NetServicos__c'))
    {
      u.NetServicos__c = attributes.get('User.NetServicos__c');
    }
      String Idferencial; 
     String lFedId = attributes.get('User.FederationIdentifier');
     Idferencial = lFedId.length() > 40 ? lFedId.substring(0, 39) : lFedId;
    String email = attributes.get('User.Email__c');
    if (String.isBlank(email)) system.debug('Is Blank');
    u.Email = (String.isNotBlank(email)) ? email : 'sememail@claro.com.br';
    u.LanguageLocaleKey = 'pt_BR';
    u.EmailEncodingKey = 'ISO-8859-1';
    u.LocaleSidKey = 'pt_BR';
    u.TimeZoneSidKey = 'America/Sao_Paulo';
    u.CommunityNickname  =  Idferencial;
    u.IsActive = true;
    
    u.Alias = u.LastName.substring(0,3) + u.FirstName.substring(0,3);

    if (!create)
    {
      update(u);
    }
  }

  private void handleJit(boolean create, User u, Id samlSsoProviderId, Id communityId, Id portalId, String federationIdentifier, Map<String, String> attributes, String assertion)
  {
    handleUser(create, u, attributes, federationIdentifier, true);
  }

  global User createUser(Id samlSsoProviderId, Id communityId, Id portalId, String federationIdentifier, Map<String, String> attributes, String assertion)
  {
    User u = new User();
    handleJit(true, u, samlSsoProviderId, communityId, portalId, federationIdentifier, attributes, assertion);
    return u;
  }

  global void updateUser(Id userId, Id samlSsoProviderId, Id communityId, Id portalId,
    String federationIdentifier, Map<String, String> attributes, String assertion)
  {
    User u = [SELECT Id FROM User WHERE Id = :userId];
    handleJit(false, u, samlSsoProviderId, communityId, portalId, federationIdentifier, attributes, assertion);
  }
}