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

exports.sendNotification = onRequest(async (request, response) => {
  const notificationType = request.body.notificationType;
  const orderNumber = request.body.orderNumber;

  if (!notificationType || !orderNumber) {
    console.error("Missing parameters notificationType or orderNumber");
    response.status(400).send("Missing parameters notificationType or orderNumber");
    return;
  }

  let employeeId = request.body.employeeId;
  if (notificationType !== 'newTakeawayOrder' &&
      notificationType !== 'orderCanceled' &&
      notificationType !== 'orderReturned') {
    if (!employeeId) {
      console.error("Missing employeeId for this notificationType");
      response.status(400).send("Missing employeeId for this notificationType");
      return;
    }
  }

  let notificationsLang = "en";
  let tokens = [];
  let notificationsRefId;

  // Determine FCM tokens document and notifications reference
  switch(notificationType) {
    case 'newTakeawayOrder':
      const cashiersDoc = await firestore.collection("fcmTokens").doc("cashiersFcmTokens").get();
      if (!cashiersDoc.exists) {
        console.error("Cashiers FCM tokens document does not exist");
        response.status(500).send("Cashiers FCM document not found");
        return;
      }
      const cashiersData = cashiersDoc.data();
      tokens = cashiersData.tokens || [];
      notificationsLang = cashiersData.notificationsLang || "en";
      notificationsRefId = cashiersData.cashierNotificationsId || "cashierNotifications";
      break;

    case 'orderCanceled':
    case 'orderReturned':
      const ownersDoc = await firestore.collection("fcmTokens").doc("ownersFcmTokens").get();
      if (!ownersDoc.exists) {
        console.error("Owners FCM tokens document does not exist");
        response.status(500).send("Owners FCM document not found");
        return;
      }
      const ownersData = ownersDoc.data();
      tokens = ownersData.tokens || [];
      notificationsLang = ownersData.notificationsLang || "en";
      notificationsRefId = ownersData.notificationsRefId || "ownerNotifications";
      break;

    default:
      const employeeDoc = await firestore.collection("fcmTokens").doc(employeeId).get();
      if (!employeeDoc.exists) {
        console.error("Employee FCM tokens document does not exist");
        response.status(500).send("Employee FCM document not found");
        return;
      }
      const employeeData = employeeDoc.data();
      tokens.push(employeeData.fcmToken);
      notificationsLang = employeeData.notificationsLang || "en";
      notificationsRefId = employeeId;
  }

  if (tokens.length === 0) {
    console.error("No tokens available to send notifications to");
    response.status(200).send("No tokens available to send notifications to");
    return;
  }

  // Prepare notification content
  let notificationTitle, notificationBody;
  switch(notificationType) {
    case "newTakeawayOrder":
      notificationTitle = notificationsLang === "en" ?
        "New Takeaway order" : "طلب تيك اواي جديد";
      notificationBody = notificationsLang === "en" ?
        "A new takeaway order was created" : "تم إنشاء طلب تيك اواي جديد";
      break;
    case "takeawayOrderReady":
      notificationTitle = notificationsLang === "en" ?
        "Takeaway order ready" : "طلب التيك اواي جاهز";
      notificationBody = notificationsLang === "en" ?
        `Takeaway order number ${orderNumber} is ready for pickup` :
        `طلب التيك اواي رقم ${orderNumber} جاهز للاستلام`;
      break;
    case "orderCanceled":
      notificationTitle = notificationsLang === "en" ?
        "Order Canceled" : "تم إلغاء الطلب";
      notificationBody = notificationsLang === "en" ?
        `Order ${orderNumber} has been canceled.` :
        `تم إلغاء الطلب رقم ${orderNumber}.`;
      break;
    case "orderReturned":
      notificationTitle = notificationsLang === "en" ?
        "Order Returned" : "تم إرجاع الطلب";
      notificationBody = notificationsLang === "en" ?
        `Order ${orderNumber} has been returned.` :
        `تم إرجاع الطلب رقم ${orderNumber}.`;
      break;
    default:
      console.error("Invalid notification type");
      response.status(400).send("Invalid notification type");
      return;
  }

  // Save notification to Firestore
  const batch = firestore.batch();
  const notificationsRef = firestore.collection("notifications").doc(notificationsRefId);

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

  // Send FCM notifications
  const messaging = admin.messaging();
  const messagingPromises = tokens.map(async (token) => {
    const message = {
      token,
      notification: {
        title: notificationTitle,
        body: notificationBody,
      },
    };
    await messaging.send(message);
  });

  try {
    await Promise.all(messagingPromises);
    response.status(200).send("Notifications sent and saved successfully");
  } catch (error) {
    console.error("Error sending notifications:", error);
    response.status(500).send("Error sending notifications");
  }
});

exports.addEmployee = onRequest(async (data, context) => {
  try {
    const email = data.body.email;
    const password = data.body.password;
    const name = data.body.name;
    const phone = data.body.phone;
    const birthDate = data.body.birthDate;
    const gender = data.body.gender;
    const role = data.body.role;
    const permissions = data.body.permissions;
    // Ensure all required fields are present
    if (!email || !password || !name || !phone || !birthDate || !gender || !role || !permissions) {
      throw new functions.https.HttpsError("invalid-argument", "Missing required fields");
 }
    // Create the user in Firebase Authentication
    const user = await admin.auth().createUser({
      email,
      password,
 });
   // Save employee data in Firestore
    await admin.firestore().collection("employees").doc(user.uid).set({
      name,
      email,
      phone,
      birthDate: admin.firestore.Timestamp.fromDate(new Date(birthDate)),
      gender,
      role,
      permissions,
      profileImageUrl: '',
   });

    console.log("Employee added successfully");
    context.status(200).send("Employee added successfully.");
  } catch (error) {
    console.error("Error adding employee:", error);
    throw new functions.https.HttpsError("internal", error.message || "Failed to add employee");
  }
});

exports.deleteUserWithResources = functions.https.onRequest(async (req, res) => {
  const userId = req.body.userId;
  const role = req.body.role;

  if (!userId || !role) {
    res.status(400).send('The function must be called with a valid userId and role.');
    return;
  }

  const employeesCollection = 'employees';
  const fcmTokensCollection = 'fcmTokens';
  const notificationsCollection = 'notifications';
  const storageFolder = `users/${userId}`;

  try {
    await auth.deleteUser(userId);
    console.log(`Successfully deleted user with UID: ${userId}`);
    const employeeDocRef = firestore.collection(employeesCollection).doc(userId);
    await employeeDocRef.delete();
    console.log(`Firestore document deleted from '${employeesCollection}' for userId: ${userId}`);

    let fcmTokensDocId;

    switch (role) {
      case 'owner':
        fcmTokensDocId = 'ownersFcmTokens';
        break;
      case 'admin':
        fcmTokensDocId = 'adminsFcmTokens';
        break;
      case 'cashier':
        fcmTokensDocId = 'cashiersFcmTokens';
        break;
      default:
        fcmTokensDocId = userId;
        break;
    }

    const tokenDocRef = firestore.collection(fcmTokensCollection).doc(fcmTokensDocId);
    const tokenDocSnapshot = await tokenDocRef.get();

    if (tokenDocSnapshot.exists) {
      const data = tokenDocSnapshot.data();
      const tokensList = data.tokens || [];
      const updatedTokens = tokensList.filter(token => token.userId !== userId);

      await tokenDocRef.update({ tokens: updatedTokens });
      console.log(`FCM tokens updated for userId: ${userId}`);
    } else {
      console.log(`No FCM tokens document found for userId: ${userId}`);
    }

    const notificationsSnapshot = await firestore.collection(notificationsCollection).where('userId', '==', userId).get();
    if (!notificationsSnapshot.empty) {
      const deleteNotificationsPromises = notificationsSnapshot.docs.map((doc) => doc.ref.delete());
      await Promise.all(deleteNotificationsPromises);
      console.log(`Notifications deleted for userId: ${userId}`);
    } else {
      console.log(`No notifications found for userId: ${userId}`);
    }

    try {
      const [files] = await storage.getFiles({ prefix: storageFolder });
      if (files.length > 0) {
        const deleteFilesPromises = files.map((file) => file.delete());
        await Promise.all(deleteFilesPromises);
        console.log(`Storage folder '${storageFolder}' and its contents have been deleted.`);
      } else {
        console.log(`No storage folder found for userId: ${userId}, skipping deletion.`);
      }
    } catch (storageError) {
      console.warn(`Error deleting storage folder for userId: ${userId}. This may indicate the folder does not exist.`);
    }

    console.log('User, Firestore documents, and storage folder processed successfully.');
    res.status(200).send('Employee and related resources deleted successfully.');
  } catch (error) {
    console.error('Error during deletion:', error);
    res.status(500).send(`Failed to delete user and resources: ${error.message}`);
  }
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
