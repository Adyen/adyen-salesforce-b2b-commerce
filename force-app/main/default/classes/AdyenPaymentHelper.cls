public with sharing class AdyenPaymentHelper {

  public static final Integer HTTP_SUCCESS_CODE = 200;
  public static final String APEX_RESERVED_CURRENCY_FIELD = 'currency_x'; // allows deserialization of reserved words.    

  @TestVisible private static final String NOTIFICATION_REQUEST_TYPE_CAPTURE = 'capture';
  @TestVisible private static final String NOTIFICATION_REQUEST_TYPE_REFUND = 'refund';
  @TestVisible private static final String NOTIFICATION_REQUEST_TYPE_CAPTURE_FAILED = 'capture-failed';
  @TestVisible private static final String NOTIFICATION_REQUEST_TYPE_CANCEL = 'cancel';
  @TestVisible private static final String NOTIFICATION_ACCEPTED_RESPONSE = '[accepted]';

  public static commercepayments.GatewayNotificationResponse handleAsyncNotificationCallback(
    commercepayments.PaymentGatewayNotificationContext gatewayNotificationContext,
    String apexName
  ) {
    System.debug('---->Entering AdyenPaymentHelper.handleAsyncNotificationCallback PaymentGatewayNotificationContext=' + gatewayNotificationContext);
    commercepayments.PaymentGatewayNotificationRequest paymentGatewayNotificationRequest = gatewayNotificationContext.getPaymentGatewayNotificationRequest();
    commercepayments.GatewayNotificationResponse gatewayNotificationResponse = new commercepayments.GatewayNotificationResponse();

    commercepayments.NotificationSaveResult notificationSaveResult;
    AdyenService.NotificationRequestItem notificationRequestItem;

    notificationRequestItem = parseAdyenNotificationRequest(paymentGatewayNotificationRequest);

    String apexAdapterId = AdyenPaymentUtility.retrieveApexAdapterId(notificationRequestItem.originalReference);
    System.debug('---->apexAdapterId =' + apexAdapterId);

    String nameSpacePrefix = '';
    List < ApexClass > adyenApexClass = [SELECT NamespacePrefix from ApexClass WHERE Name =: apexName];
    if (adyenApexClass.size() > 0) {
      nameSpacePrefix = adyenApexClass[0].NamespacePrefix;
    }
    String apexClassId = AdyenPaymentUtility.retrieveApexClassId(apexName, nameSpacePrefix);
    System.debug('---->apexClassId =' + apexClassId);

    if (apexAdapterId == apexClassId || Test.isRunningTest()) {

      notificationSaveResult = createNotificationSaveResult(notificationRequestItem);

      if (notificationSaveResult != null) {
        if (notificationSaveResult.isSuccess()) { // Notification is accepted by the platform
          gatewayNotificationResponse.setStatusCode(AdyenService.HTTP_SUCCESS_CODE);
          gatewayNotificationResponse.setResponseBody(Blob.valueOf(NOTIFICATION_ACCEPTED_RESPONSE));
          System.debug('---->Exiting AdyenPaymentHelper.handleAsyncNotificationCallback after the notification is accepted=' + gatewayNotificationResponse);
          return gatewayNotificationResponse;
        } else { // Notification is not accepted by the platform, generate system event
          gatewayNotificationResponse.setStatusCode(integer.valueOf(AdyenService.HTTP_SERVER_ERROR_CODE));
          String msg = '[accepted] ';
          if (notificationSaveResult != null && notificationSaveResult.getErrorMessage() != null) {
            msg += notificationSaveResult.getErrorMessage();
          }
          gatewayNotificationResponse.setResponseBody(Blob.valueOf(msg));
          return gatewayNotificationResponse;
        }
      } else {
        String msg = '';
        msg += '[accepted] But unsupported notification type = ' + notificationRequestItem.eventCode;
        gatewayNotificationResponse.setResponseBody(Blob.valueOf(msg));
        gatewayNotificationResponse.setStatusCode(AdyenService.HTTP_SUCCESS_CODE);
        return gatewayNotificationResponse;
      }

    } else {
      String msg = '';
      msg += '[accepted] But not processed - wrong payment adapter or wrong instance';
      gatewayNotificationResponse.setResponseBody(Blob.valueOf(msg));
      gatewayNotificationResponse.setStatusCode(AdyenService.HTTP_SUCCESS_CODE);
      System.debug('---->Exiting AdyenPaymentHelper.handleAsyncNotificationCallback after identifying that it was the wrong payment adapter=' + gatewayNotificationResponse);
      return gatewayNotificationResponse;
    }
  }

  /**
   * Take the http request from the async notification callback and deserializes it into AdyenNotificationResponse.
   *
   * @param adyenNotificationRequestPayload		The body of the Adyen notification request.
   * @return AdyenService.AdyenNotificationRequest		The deserialized version of the Adyen nodification request.
   *
   * @see https://docs.adyen.com/development-resources/webhooks/understand-notifications
   */
  public static AdyenService.NotificationRequestItem parseAdyenNotificationRequest(commercepayments.PaymentGatewayNotificationRequest notificationRequest) {
    String adyenNotificationRequestPayload = notificationRequest.getRequestBody().toString();
    adyenNotificationRequestPayload = adyenNotificationRequestPayload.replace('currency', APEX_RESERVED_CURRENCY_FIELD); //  necessary because currency is an apex reserved word.

    AdyenService.AdyenNotification adyenNotification = (AdyenService.AdyenNotification) JSON.deserialize(adyenNotificationRequestPayload, AdyenService.AdyenNotification.class);
    AdyenService.NotificationRequestItem notificationRequestItem = new AdyenService.NotificationRequestItem();
    if (adyenNotification != null) {
      for (AdyenService.NotificationItems notificationItem: adyenNotification.notificationItems) {
        if (notificationItem.NotificationRequestItem != null) {
          notificationRequestItem = notificationItem.NotificationRequestItem;
        }
      }
    }
    return notificationRequestItem;
  }

  /**
   * Creates and records (ie saves) the notificationsaveresult.
   *
   * @param adyenNotificationResponse
   * @return commercepayments.NotificationSaveResult.
   */
  private static commercepayments.NotificationSaveResult createNotificationSaveResult(AdyenService.NotificationRequestItem notificationRequestItem) {

    Boolean unsupportedNotificationType = false;
    commercepayments.BaseNotification notification = null;
    commercepayments.NotificationStatus notificationStatus = null;
    commercepayments.SalesforceResultCode notificationStatusSF = null;

    if (!Boolean.valueOf(notificationRequestItem.success)) {
      notificationStatus = commercepayments.NotificationStatus.Failed;
      notificationStatusSF = commercepayments.SalesforceResultCode.Decline;
    } else {
      notificationStatus = commercepayments.NotificationStatus.Success;
      notificationStatusSF = commercepayments.SalesforceResultCode.Success;
    }
    if (NOTIFICATION_REQUEST_TYPE_CAPTURE.equalsIgnoreCase(notificationRequestItem.eventCode)) {
      notification = new commercepayments.CaptureNotification();
    } else if (NOTIFICATION_REQUEST_TYPE_REFUND.equalsIgnoreCase(notificationRequestItem.eventCode)) {
      notification = new commercepayments.ReferencedRefundNotification();
    } else {
      if (NOTIFICATION_REQUEST_TYPE_CAPTURE_FAILED.equalsIgnoreCase(notificationRequestItem.eventCode)) {
        // process exception caught via platform event subscriber
      }
      unsupportedNotificationType = true;
    }

    commercepayments.NotificationSaveResult notificationSaveResult;
    if (!unsupportedNotificationType) {
      notification.setStatus(notificationStatus);
      notification.setSalesforceResultCodeInfo(new commercepayments.SalesforceResultCodeInfo(notificationStatusSF));
      notification.setGatewayReferenceNumber(notificationRequestItem.pspReference);
      notification.setGatewayResultCode(notificationRequestItem.eventCode);
      notification.setGatewayResultCodeDescription(notificationRequestItem.reason);
      if (String.isBlank(notificationRequestItem.reason) && notificationStatus == commercepayments.NotificationStatus.Success) {
        if (NOTIFICATION_REQUEST_TYPE_CAPTURE.equalsIgnoreCase(notificationRequestItem.eventCode)) {
          //notification.setGatewayMessage('[capture-complete]');
        } else if (NOTIFICATION_REQUEST_TYPE_REFUND.equalsIgnoreCase(notificationRequestItem.eventCode)) {
          //notification.setGatewayMessage('[refund-complete]');
        } else if (NOTIFICATION_REQUEST_TYPE_CANCEL.equalsIgnoreCase(notificationRequestItem.eventCode)) {
          //notification.setGatewayMessage('[cancel-complete]');
        }
      } else {
        notification.setGatewayMessage(notificationRequestItem.reason);
      }

      //notification.setGatewayDate(System.now());

      Decimal value;
      if (notificationRequestItem.amount != null) {
        value = notificationRequestItem.amount.value;
      }
      value = value / AdyenPaymentUtility.getAmountMultiplier(notificationRequestItem.amount.currency_x);

      Double dValue = value;
      notification.setAmount(dValue);
      notificationSaveResult = commercepayments.NotificationClient.record(notification);
      return notificationSaveResult;
    } else {
      notificationSaveResult = null;
      System.debug('---> Exiting AdyenPaymentHelper.createNotificationSaveResult after ignoring unsupported notification=' + notificationRequestItem.eventCode);
      return notificationSaveResult;
    }
  }

}