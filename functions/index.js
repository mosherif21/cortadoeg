const {
  onRequest
} = require("firebase-functions/v2/https");
const functions = require('firebase-functions/v2');
const admin = require("firebase-admin");
const { initializeApp, cert } = require('firebase-admin/app');
const serviceAccount = require('./serviceAccountKey.json');
initializeApp({
  credential: cert(serviceAccount),
});
const { onSchedule } = require("firebase-functions/v2/scheduler");
const messaging = admin.messaging();
const firestore = admin.firestore();
const getAuth = admin.auth();
const getStorage = admin.storage();

exports.checkProductInventory = onSchedule("every 1 minutes", async (event) => {
  try {
    const productsSnapshot = await firestore.collection("products").get();
    const lowInventoryProducts = [];
    const emptyInventoryProducts = [];

    productsSnapshot.forEach((doc) => {
      const product = doc.data();
      const measuringUnit = product.measuringUnit;
      const availableQuantity = product.availableQuantity || 0;

      if (measuringUnit === "piece" && availableQuantity < 2) {
        if (availableQuantity <= 0) {
          emptyInventoryProducts.push({ id: doc.id, ...product });
        } else {
          lowInventoryProducts.push({ id: doc.id, ...product });
        }
      } else if ((measuringUnit === "ml" || measuringUnit === "gm") && availableQuantity < 100) {
        if (availableQuantity <= 0) {
          emptyInventoryProducts.push({ id: doc.id, ...product });
        } else {
          lowInventoryProducts.push({ id: doc.id, ...product });
        }
      }
    });

    if (lowInventoryProducts.length === 0 && emptyInventoryProducts.length === 0) {
      console.log("No low or empty inventory products found");
      return null;
    }

    const adminsTokensDoc = await firestore.collection("fcmTokens").doc("adminsFcmTokens").get();
    if (!adminsTokensDoc.exists) {
      console.error("Admin FCM tokens not found");
      return null;
    }

    const adminsTokensData = adminsTokensDoc.data();
    const tokens = adminsTokensData.tokens;

    if (!tokens || tokens.length === 0) {
      console.error("No admin FCM tokens available");
      return null;
    }

    const messages = [];

    tokens.forEach((admin) => {
      const notificationsLang = admin.notificationsLang || "en";
      const adminFcmToken = admin.fcmToken;

      lowInventoryProducts.forEach((product) => {
        const title = notificationsLang === "en" ? "Low Inventory Alert" : "تنبيه جرد منخفض";
        const body =
          notificationsLang === "en"
            ? `Product ${product.name} inventory is low. Only ${product.availableQuantity} ${product.measuringUnit} left.`
            : `المنتج ${product.name} جرده منخفض. فقط ${product.availableQuantity} ${product.measuringUnit} متبقية.`;

        messages.push({
          token: adminFcmToken,
          notification: {
            title,
            body,
          },
        });
      });

      emptyInventoryProducts.forEach((product) => {
        const title = notificationsLang === "en" ? "Out of Stock Alert" : "تنبيه نفاد المخزون";
        const body =
          notificationsLang === "en"
            ? `Product ${product.name} is out of stock.`
            : `المنتج ${product.name} نفد من المخزون.`;

        messages.push({
          token: adminFcmToken,
          notification: {
            title,
            body,
          },
        });
      });
    });

    const messagingPromises = messages.map((message) => messaging.send(message));
    await Promise.all(messagingPromises);

    console.log("Notifications sent successfully");
    return null;
  } catch (error) {
    console.error("Error checking product inventory:", error);
    return null;
  }
});


exports.checkProductInventory = onSchedule("every 1 minutes", async (event) => {
  try {
    const productsSnapshot = await firestore.collection("products").get();
    const lowInventoryProducts = [];
    const emptyInventoryProducts = [];

    productsSnapshot.forEach((doc) => {
      const product = doc.data();
      const measuringUnit = product.measuringUnit;
      const availableQuantity = product.availableQuantity || 0;

      if (measuringUnit === "piece" && availableQuantity < 2) {
        if (availableQuantity <= 0) {
          emptyInventoryProducts.push({ id: doc.id, ...product });
        } else {
          lowInventoryProducts.push({ id: doc.id, ...product });
        }
      } else if ((measuringUnit === "ml" || measuringUnit === "gm") && availableQuantity < 100) {
        if (availableQuantity <= 0) {
          emptyInventoryProducts.push({ id: doc.id, ...product });
        } else {
          lowInventoryProducts.push({ id: doc.id, ...product });
        }
      }
    });

    if (lowInventoryProducts.length === 0 && emptyInventoryProducts.length === 0) {
      console.log("No low or empty inventory products found");
      return;
    }
    const adminsTokensDoc = await firestore.collection("fcmTokens").doc("adminsFcmTokens").get();
    if (!adminsTokensDoc.exists) {
      console.error("Admin FCM tokens not found");
      return;
    }

    const adminsTokensData = adminsTokensDoc.data();
    const tokens = adminsTokensData.tokens;

    if (!tokens || tokens.length === 0) {
      console.error("No admin FCM tokens available");
      return;
    }
    const messages = [];

    tokens.forEach((admin) => {
      const notificationsLang = admin.notificationsLang || "en";
      const adminFcmToken = admin.fcmToken;

      lowInventoryProducts.forEach((product) => {
        const title = notificationsLang === "en" ? "Low Inventory Alert" : "تنبيه جرد منخفض";
        const body =
          notificationsLang === "en"
            ? `Product ${product.name} inventory is low. Only ${product.availableQuantity} ${product.measuringUnit} left.`
            : `المنتج ${product.name} جرده منخفض. فقط ${product.availableQuantity} ${product.measuringUnit} متبقية.`;

        messages.push({
          token: adminFcmToken,
          notification: {
            title,
            body,
          },
        });
      });

      emptyInventoryProducts.forEach((product) => {
        const title = notificationsLang === "en" ? "Out of Stock Alert" : "تنبيه نفاد المخزون";
        const body =
          notificationsLang === "en"
            ? `Product ${product.name} is out of stock.`
            : `المنتج ${product.name} نفد من المخزون.`;

        messages.push({
          token: adminFcmToken,
          notification: {
            title,
            body,
          },
        });
      });
    });
    const messagingPromises = messages.map((message) => messaging.send(message));
    await Promise.all(messagingPromises);

    console.log("Notifications sent successfully");
  } catch (error) {
    console.error("Error checking product inventory:", error);
  }
});

exports.deleteUserWithResources = onRequest(async (data, context) => {
  const userId = data.body.employeeId;

  if (!userId) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'The function must be called with a userId.'
    );
  }

  const storage = getStorage.bucket('gs://cortadoegypt.firebasestorage.app');
  const employeesCollection = 'employees';
  const storageFolder = `users/${userId}`;

  try {
    await getAuth.deleteUser(userId);
    console.log(`Successfully deleted user with UID: ${userId}`);

    const docRef = firestore.collection(employeesCollection).doc(userId);
    await docRef.delete();
    console.log(`Firestore document deleted from collection '${employeesCollection}' for userId: ${userId}`);

    try {
      const [files] = await storage.getFiles({ prefix: storageFolder });

      if (files.length > 0) {
        const deletionPromises = files.map((file) => file.delete());
        await Promise.all(deletionPromises);
        console.log(`Storage folder '${storageFolder}' and its contents have been deleted.`);
      } else {
        console.log(`No storage folder found for userId: ${userId}, skipping deletion.`);
      }
    } catch (storageError) {
      console.warn(`Error deleting storage folder for userId: ${userId}. This may indicate the folder does not exist.`);
    }
      console.log('User, Firestore document, and Storage folder processed successfully.');
      context.status(200).send("Employee deleted successfully.");
  } catch (error) {
    console.error('Error during deletion:', error);
    throw new functions.https.HttpsError(
      'internal',
      `Failed to process deletion for userId ${userId}: ${error.message}`
    );
  }
});

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


//  // Check for admin privileges
//  if (!context.auth || !context.auth.token.admin) {
//    throw new functions.https.HttpsError(
//      'permission-denied',
//      'Only authorized admins can perform this action.'
//    );
//  }
//async function setAdminClaim(userId) {
//  try {
//    await getAuth.setCustomUserClaims(userId, { admin: true });
//    console.log(`Admin claim set for user with UID: ${userId}`);
//  } catch (error) {
//    console.error('Error setting admin claim:', error);
//  }
//}
//
//// Replace 'USER_UID' with the actual UID of the user you want to make an admin
//setAdminClaim('BAdvXjCLP0cfa5BdItRkbx6sL4b2');

//// Callable function to set admin claim
//exports.setAdminClaim = onRequest(async (data, context) => {
//  // Check if the function was called by an authenticated user
//  if (!context.auth) {
//    throw new Error('Authentication required.');
//  }
//
//  // Check if the caller is an admin
//  const callerUid = context.auth.uid;
//  const callerUserRecord = await getAuth().getUser(callerUid);
//
//  if (!callerUserRecord.customClaims || !callerUserRecord.customClaims.admin) {
//    throw new Error('Permission denied. Only admins can perform this action.');
//  }
//
//  // Validate the input
//   const userId = data.body.employeeId;
//  if (!userId || typeof userId !== 'string') {
//    throw new Error('Invalid input. "userId" is required and must be a string.');
//  }
//
//  try {
//    // Set the admin claim
//    await getAuth.setCustomUserClaims(userId, { admin: true });
//    console.log(`Admin claim set for user with UID: ${userId}`);
//    return { success: true, message: `Admin claim set for user with UID: ${userId}` };
//  } catch (error) {
//    console.error('Error setting admin claim:', error);
//    throw new Error('Failed to set admin claim.');
//  }
//});
