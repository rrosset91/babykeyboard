/**
 * Created by Bill Coppens as a set of helper functions for integration
**/

global without sharing class CEC_IntegrationHelper implements vlocity_cmt.VlocityOpenInterface
{
  global Boolean invokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outMap, Map<String, Object> options)
  {
    Boolean retval = false;

    if (methodName == 'BasicAuthorization') {
      retval = basicAuthorization(inputMap,outMap,options);
    }

    return retval;
  }

  /**
   *  Return an encrypted username / password combination.
   *  Claro uses an unsecured endpoint for dev.  IE http -vs- https
  **/
  public Boolean basicAuthorization(Map<String, Object> inputMap, Map<String, Object> outMap, Map<String, Object> options)
  {
    String username = (String)inputMap.get('username'), password = (String)inputMap.get('password');

    String lAuth = getBasicAuth(new String[]{ username, password });
    outMap.put('authentication', lAuth);
    return true;
  }

  public static String getBasicAuth(list<String> aArgs)
  {
    if (aArgs == null || aArgs.isEmpty()) return null;
    Blob lAuth = Blob.valueOf(String.join(aArgs, ':'));
    // Base 64 Encode the blob and prepend "Basic "
    return 'Basic ' + EncodingUtil.base64Encode(lAuth);
  }
}