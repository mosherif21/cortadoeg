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

const firestore = admin.firestore();
const getAuth = admin.auth();
const getStorage = admin.storage();

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

exports.deleteUserWithResources = onRequest(async (data, context) => {
  const userId = data.body.employeeId;
//  // Check for admin privileges
//  if (!context.auth || !context.auth.token.admin) {
//    throw new functions.https.HttpsError(
//      'permission-denied',
//      'Only authorized admins can perform this action.'
//    );
//  }

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
    // Step 1: Delete the user from Firebase Authentication
    await getAuth.deleteUser(userId);
    console.log(`Successfully deleted user with UID: ${userId}`);

    // Step 2: Delete the corresponding Firestore document
    const docRef = firestore.collection(employeesCollection).doc(userId);
    await docRef.delete();
    console.log(`Firestore document deleted from collection '${employeesCollection}' for userId: ${userId}`);

    // Step 3: Delete the Storage folder
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