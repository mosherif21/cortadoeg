const {
  onRequest
} = require("firebase-functions/v2/https");
const admin = require("firebase-admin");

admin.initializeApp();

const firestore = admin.firestore();

exports.sendNotification = onRequest(async (request, response) => {
  const employeeId = request.body.employeeId;
  const notificationType = request.body.notificationType;
  const orderNumber = request.body.orderNumber;

  if (!notificationType || !employeeId || !orderNumber) {
    console.error("Missing parameters employeeId, notificationType, orderNumber");
    response.status(400).send("Missing parameters");
    return;
  }

  let notificationsLang = "en";
  let notificationTitle;
  let notificationBody;


  switch (notificationType) {
    case "newTakeawayOrder":
      notificationTitle =
        notificationsLang === "en" ?
        "New Takeaway order" :
        "طلب تيك اواي جديد";
      notificationBody =
        notificationsLang === "en" ?
        "A new takeaway order was created" :
        "تم إنشاء طلب تيك اواي جديد";
      break;
    case "takeawayOrderReady":
      notificationTitle =
        notificationsLang === "en" ?
        "Takeaway order ready" :
        "طلب التيك اواي جاهز";
      notificationBody =
        notificationsLang === "en" ?
        `Takeaway order number ${orderNumber} is ready for pickup` :
        `طلب التيك اواي رقم ${orderNumber} جاهز للاستلام`;
      break;
    default:
      console.error("Invalid notification type");
      response.status(400).send("Invalid notification type");
      return;
  }

  const fcmTokenRef = notificationType == "newTakeawayOrder" ? firestore.collection("fcmTokens").doc("cashierFcmToken") : firestore.collection("fcmTokens").doc(employeeId);
  const fcmTokenDoc = await fcmTokenRef.get();

  if (fcmTokenDoc.exists) {
    const fcmTokenData = fcmTokenDoc.data();
    if (fcmTokenData && fcmTokenData.notificationsLang) {
      notificationsLang = fcmTokenData.notificationsLang;
    }
  } else if (!fcmTokenDoc.exists && notificationType == "newTakeawayOrder") {
    console.log("FCM token doc not found");
    response.status(200).send("Cashier FCM token doc not found and notification not saved");
    return;
  }
  const batch = firestore.batch();
  const notificationsRef = firestore.collection("notifications").doc(notificationType == "newTakeawayOrder" ? fcmTokenDoc.data().cashierEmployeeId : employeeId);
  const notificationsDoc = await notificationsRef.get();

  if (notificationsDoc.exists) {
    batch.update(notificationsRef, {
      unseenCount: admin.firestore.FieldValue.increment(1),
    });
  } else {
    batch.set(notificationsRef, {
      unseenCount: 1,
    });
  }

  const messagesRef = notificationsRef.collection("messages").doc();
  batch.set(messagesRef, {
    title: notificationTitle,
    body: notificationBody,
    timestamp: admin.firestore.Timestamp.now(),
  });

  await batch.commit();

  if (!fcmTokenDoc.exists) {
    console.log("FCM token doc not found");
    response.status(200).send("FCM token doc not found but notification saved");
    return;
  }

  const fcmTokenData = fcmTokenDoc.data();
  const tokens = [];

  if (fcmTokenData.fcmToken) {
    tokens.push(fcmTokenData.fcmToken);
  }

  if (tokens.length === 0) {
    console.log("No tokens to send notification to");
    response.status(200).send("No tokens to send notification to but notification saved");
    return;
  }

  const message = admin.messaging.MessagingPayload = {
    token: tokens[0],
    notification: {
      title: notificationTitle,
      body: notificationBody,
    },
  };

  const messaging = admin.messaging();
  await messaging.send(message);

  response.status(200).send("Notifications sent and saved successfully");
});