import 'package:get/get.dart';

class Languages extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'ar_SA': {
          'skip': 'تخطي',
          'continueApp': 'متابعة التطبيق',
          'privacyPolicy': 'سياسة الخصوصية',
          'onBoardingTitle1': 'إدارة الطلبات بسهولة',
          'onBoardingDescription1':
              'قم بمعالجة الطلبات بسلاسة من البداية إلى النهاية، وضمان خدمة فعالة ومنظمة.',
          'onBoardingTitle2': 'تحديثات المخزون في الوقت الفعلي',
          'onBoardingDescription2':
              'ابق على اطلاع بمستويات المخزون مع التحديثات التلقائية وتنبيهات انخفاض المخزون.',
          'onBoardingTitle3': 'رؤى مبيعات قوية',
          'onBoardingDescription3':
              'اطلع على بيانات المبيعات والمخزون القيمة لاتخاذ قرارات تجارية أكثر ذكاءً.',
          'onBoardingTitle4': 'الدفع والخصومات بسهولة',
          'onBoardingDescription4':
              'بسّط عملية الدفع مع خيارات الدفع المرنة والخصومات والكوبونات.',
          'chooseLanguage': 'اختر اللغة المفضلة لديك',
          'english': 'الإنجليزية',
          'arabic': 'العربية',
          'settings': 'الإعدادات',
          'qrcodeNotFound': 'لم يتم العثور على رمز QR، يرجى المحاولة مرة أخرى',
          'noImageChosen': 'لم تقم باختيار أي صورة، يرجى المحاولة مرة أخرى',
          'errorOccurred': 'حدث خطأ، يرجى المحاولة مرة أخرى',
          'cameraPermission': 'تصريح الكاميرا',
          'cameraPermissionDeniedForever':
              'تم رفض إذن الكاميرا بشكل دائم، يرجى تمكينه من الإعدادات',
          'storagePermission': 'تصريح التخزين',
          'storagePermissionDeniedForever':
              'تم رفض إذن التخزين بشكل دائم، يرجى تمكينه من الإعدادات',
          'callPermission': 'تصريح الاتصال',
          'callPermissionDeniedForever':
              'تم رفض إذن الاتصال بشكل دائم، يرجى تمكينه من الإعدادات',
          'micPermission': 'تصريح الميكروفون',
          'micPermissionDeniedForever':
              'تم رفض إذن الميكروفون بشكل دائم، يرجى تمكينه من الإعدادات',
          'contactsPermission': 'تصريح جهات الاتصال',
          'contactsPermissionDeniedForever':
              'تم رفض إذن جهات الاتصال بشكل دائم، يرجى تمكينه من الإعدادات',
          'enableLocationPermission': 'يرجى قبول إذن الموقع',
          'enableCameraPermission': 'يرجى قبول إذن الكاميرا',
          'enableStoragePermission': 'يرجى قبول إذن التخزين',
          'goToSettings': 'انتقل إلى الإعدادات',
          'qrcode': 'رمز QR',
          'wifi': 'واي فاي',
          'contact': 'جهة اتصال',
          'sms': 'رسالة نصية',
          'email': 'البريد الإلكتروني',
          'website': 'الموقع الإلكتروني',
          'number': 'الرقم',
          'available': 'متاح',
          'occupied': 'مشغول',
          'billed': 'مدفوع',
          'unavailable': 'غير متاح',
          'takeawayOrder': 'طلب خارج الكافيه',
          'takeaway': 'خارج الكافيه',
          'dineInOrder': 'طلب داخل الكافيه',
          'tableSameOrderId': 'تخدم هذه الطاولات نفس الطلب',
          'tableUnavailable': 'هذه الطاولة غير متاحة',
          'tablesOrdersSwitched': 'تم تبديل طلبات الطاولات بنجاح',
          'noOrderToSwitch': 'لا توجد طلبات على أي من الطاولتين',
          'door': 'الباب',
          'counter': 'الكاونتر',
          'launchUrlFailed': 'فشل إطلاق الرابط، يرجى المحاولة مرة أخرى',
          'copiedSuccess': 'تم النسخ إلى الحافظة!',
          'copy': 'نسخ',
          'share': 'مشاركة',
          'open': 'فتح',
          'save': 'حفظ',
          'password': 'كلمة المرور',
          'yes': 'نعم',
          'no': 'لا',
          'home': 'الرئيسية',
          'tables': 'الطاولات',
          'table': 'طاولة',
          'orders': 'الطلبات',
          'ordersNoNew': 'الطلب #جديد',
          'reports': 'التقارير',
          'account': 'الحساب',
          'invalidEmailEntered': 'البريد الإلكتروني المدخل غير صحيح',
          'emailAlreadyExists': 'هذا البريد الإلكتروني موجود بالفعل',
          'missingEmail': 'لم يتم إدخال البريد الإلكتروني',
          'requireRecentLoginError':
              'هذه العملية حساسة وتتطلب المصادقة الحديثة',
          'unknownError': 'حدث خطأ غير معروف. حاول مرة أخرى',
          'failedGoogleAuth': 'فشلت مصادقة Google، يرجى المحاولة مرة أخرى',
          'successGoogleLink': 'تم ربط حساب Google بنجاح',
          'googleAccountInUse':
              'تم استخدام حساب Google هذا بالفعل من قبلك أو مستخدم آخر',
          'failedGoogleLink': 'فشل ربط حساب Google، يرجى المحاولة مرة أخرى',
          'googleMapsNavigation': 'ملاحة خرائط Google',
          'failedToChangeSetting': 'فشل تغيير الإعداد، يرجى المحاولة مرة أخرى',
          'deleteAccountBody':
              'إذا كنت تحذف حسابك لأنك لا تستخدمه، فلا داعي للقلق لأننا لا نشارك أيًا من معلوماتك مع أي منظمة خارجية. يرجى العلم أن بياناتك آمنة.',
          'emailChangedSuccess': 'تم تغيير بريدك الإلكتروني بنجاح',
          'enterChangeEmailData':
              'يرجى إدخال البريد الإلكتروني الجديد وكلمة المرور لتغيير بريدك الإلكتروني',
          'linkEmailPassword': 'ربط البريد الإلكتروني وكلمة المرور',
          'verificationSent': 'تم إرسال التحقق',
          'verifyEmailSent': 'تم إرسال رابط التحقق عبر البريد الإلكتروني بنجاح',
          'verifyEmailSendFailed':
              'فشل إرسال رابط التحقق عبر البريد الإلكتروني',
          'timedOut': 'انتهت المهلة',
          'welcome': 'أهلاً بك',
          'changeGoogleAccount': 'تغيير حساب Google',
          'loadingFailed': 'فشل التحميل، انقر فوق إعادة المحاولة',
          'welcomeTitle': 'تسجيل الدخول أو إنشاء حساب',
          'loginTextTitle': 'تسجيل الدخول',
          'registerTextTitle': 'التسجيل',
          'skipLabel': 'تخطي',
          'delete': 'حذف',
          'successFacebookLink': 'تم ربط حساب Facebook بنجاح',
          'notAvailableErrorTitle': 'غير متوفر حاليًا',
          'notAvailableErrorSubTitle': 'نحن نعمل على ذلك ...',
          'noConnectionAlertTitle': 'لا يوجد اتصال بالإنترنت',
          'connectionRestored': 'تم استعادة اتصال الإنترنت',
          'noConnectionAlertContent': 'يرجى التحقق من اتصال الإنترنت الخاص بك',
          'ok': 'موافق',
          'addContact': 'إضافة جهة اتصال',
          'loginWithGoogle': 'متابعة مع Google',
          'loginWithFacebook': 'متابعة مع Facebook',
          'loginWithMobile': 'متابعة برقم الهاتف',
          'emailLabel': 'البريد الإلكتروني',
          'newEmailLabel': 'البريد الإلكتروني الجديد',
          'emailHintLabel': 'أدخل بريدك الإلكتروني',
          'newEmailHintLabel': 'أدخل بريدك الإلكتروني الجديد',
          'tryAgain': 'حاول مرة أخرى',
          'passwordLabel': 'كلمة المرور',
          'passwordHintLabel': 'أدخل كلمة المرور',
          'forgotPassword': 'نسيت كلمة المرور؟',
          'or': 'أو',
          'noEmailAccount':
              'ليس لديك حساب بريد إلكتروني؟ سجل باستخدام البريد الإلكتروني',
          'chooseForgetPasswordMethod': 'اختر طريقة إعادة تعيين كلمة المرور',
          'emailReset': 'إعادة تعيين كلمة المرور عبر رابط البريد الإلكتروني',
          'numberReset': 'إعادة تعيين كلمة المرور عبر التحقق برقم الهاتف',
          'phoneLabel': 'رقم الهاتف',
          'phoneFieldLabel': 'أدخل رقم هاتفك',
          'passwordResetLink':
              'أدخل بريدك الإلكتروني للحصول على رابط إعادة تعيين كلمة المرور',
          'loggedInPasswordResetLink':
              'اضغط على زر الإرسال للحصول على رابط إعادة تعيين كلمة المرور',
          'continue': 'متابعة',
          'confirm': 'تأكيد',
          'confirmPassword': 'تأكيد كلمة المرور',
          'passwordNotMatch': 'كلمتا المرور غير متطابقتين',
          'enterStrongerPassword': 'يرجى إدخال كلمة مرور أقوى',
          'operationNotAllowed': 'العملية غير مسموح بها. اتصل بالدعم',
          'userDisabled': 'تم تعطيل هذا المستخدم',
          'invalidPhoneNumber': 'رقم الهاتف المدخل غير صحيح',
          'failedFacebookLink': 'فشل ربط حساب Facebook، يرجى المحاولة مرة أخرى',
          'facebookAccountInUse':
              'تم استخدام حساب Facebook هذا بالفعل من قبلك أو مستخدم آخر',
          'failedFacebookAuth': 'فشلت مصادقة Facebook، يرجى المحاولة مرة أخرى',
          'failedAuth': 'فشلت المصادقة',
          'success': 'نجاح',
          'warning': 'تحذير',
          'info': 'معلومات',
          'completed': 'مكتمل',
          'canceled': 'ملغي',
          'error': 'خطأ',
          'search': 'بحث',
          'passwordResetSuccess':
              'تم إرسال بريد إلكتروني إعادة تعيين كلمة المرور بنجاح',
          'emptyFields': 'لا يمكن أن تكون الحقول فارغة',
          'smallPass': 'لا يمكن أن تكون كلمة المرور أقل من 8 أحرف',
          'lang': 'اللغة',
          'logout': 'تسجيل الخروج',
          'logoutConfirm': 'هل أنت متأكد أنك تريد تسجيل الخروج؟',
          'emailPasswordAccountSuccess':
              'تم ربط حساب البريد الإلكتروني وكلمة المرور بنجاح',
          'viewAll': 'عرض الكل',
          'status': 'الحالة',
          'payment': 'الدفع',
          'newOrder': 'طلب جديد',
          'back': 'الرجوع',
          'notifications': 'الإشعارات',
          'noActiveOrdersTitle': 'لا توجد طلبات نشطة',
          'noActiveOrdersBody': 'لا توجد طلبات نشطة في الوقت الحالي',
          'activeOrders': 'الطلبات النشطة',
          'tablesView': 'عرض الطاولات',
          'ordersHistory': 'تاريخ الطلبات',
          'aboutUs': 'من نحن',
          'locationService': 'خدمة الموقع',
          'enableLocationService': 'يرجى تمكين خدمة الموقع لاستخدام هذه الميزة',
          'acceptLocationPermission':
              'يرجى تمكين إذن الموقع لاستخدام هذه الميزة',
          'locationPermission': 'إذن الموقع',
          'locationPermissionDeniedForever':
              'تم رفض إذن الموقع بشكل دائم، يرجى تمكينه من الإعدادات',
          'enableCallPermission': 'يرجى قبول إذن الاتصال',
          'enableMicPermission': 'يرجى قبول إذن الميكروفون',
          'enableContactsPermission': 'يرجى قبول إذن جهات الاتصال',
          'accountDetailSavedSuccess': 'تم حفظ معلومات الحساب بنجاح',
          'phoneChangeSuccess': 'تم تغيير رقم الهاتف بنجاح',
          'pullToRefresh': 'اسحب للأسفل للتحديث',
          'releaseToRefresh': 'أطلق للتحديث',
          'refreshing': 'جاري التحديث',
          'refreshCompleted': 'تم التحديث',
          'pullToLoad': 'اسحب لأعلى لتحميل المزيد',
          'releaseToLoad': 'أطلق لتحميل المزيد',
          'loadingCompleted': 'تم الانتهاء من التحميل',
          'fullName': 'الاسم الكامل',
          'enterEmailPasswordDetails':
              'يرجى إدخال تفاصيل حساب البريد الإلكتروني وكلمة المرور',
          'signOutFailed': 'فشل تسجيل الخروج، يرجى المحاولة مرة أخرى',
          'enterFullName': 'أدخل اسمك الكامل',
          'enterYourInfo': 'يرجى إدخال معلوماتك الشخصية لإكمال تسجيل حسابك',
          'enterBirthDate': 'اختر تاريخ ميلادك',
          'birthDate': 'تاريخ الميلاد',
          'enterGender': 'اختر جنسك',
          'enterPhoto': 'يرجى إضافة صورتك',
          'addPhoto': 'إضافة صورة',
          'changePhoto': 'تغيير الصورة',
          'choosePicMethod': 'يرجى اختيار طريقة لإضافة صورتك',
          'selectValue': 'اختر',
          'pickGallery': 'اختر من المعرض',
          'capturePhoto': 'التقاط صورة',
          'smsPermission': 'إذن الرسائل النصية',
          'notificationsPermission': 'إذن الإشعارات',
          'smsPermissionDeniedForever':
              'تم رفض إذن الرسائل النصية بشكل دائم، يرجى تمكينه من الإعدادات',
          'notificationsPermissionDeniedForever':
              'تم رفض إذن الإشعارات بشكل دائم، يرجى تمكينه من الإعدادات',
          'enableSmsPermission': 'يرجى قبول إذن الرسائل النصية',
          'enableNotificationPermission': 'يرجى قبول إذن الإشعارات',
          'enableSpeechPermission': 'يرجى قبول إذن الكلام',
          'speechPermissionDeniedForever':
              'تم رفض إذن الكلام بشكل دائم، يرجى تمكينه من الإعدادات',
          'speechPermission': 'إذن الكلام',
          'don\'tKnow': 'لا أعرف',
          'requiredFields':
              'يرجى تقديم جميع المعلومات الموضحة باللون الأحمر بشكل صحيح',
          'saveUserInfoError': 'فشل حفظ معلوماتك، يرجى المحاولة مرة أخرى',
          'loginFailed': 'فشل تسجيل الدخول، يرجى المحاولة مرة أخرى',
          'add': 'إضافة',
          'confirmPermanentDelete':
              'يرجى ملاحظة أن عملية الحذف دائمة، ولا يمكن استرداد حسابك مرة أخرى',
          'cancel': 'إلغاء',
          'loading': 'جار التحميل',
          'notAllowed': 'غير مسموح',
          'enterRequestInfo': 'يرجى ملء معلومات طلب الإسعاف',
          'cancelReason': 'سبب الإلغاء',
          'egp': 'جنيه مصري',
          'editUserInfo': 'يمكنك تعديل تفاصيل حسابك هنا',
          'linkGoogleAccount': 'ربط حساب Google',
          'linkFacebookAccount': 'ربط حساب Facebook',
          'verify': 'التحقق',
          'send': 'إرسال',
          'userInformation': 'معلومات المستخدم',
          'personalInformation': 'المعلومات الشخصية',
          'phoneNumber': 'رقم الهاتف',
          'unknown': 'غير معروف',
          'noAdditionalInformation': 'لا توجد معلومات إضافية',
          'edit': 'تعديل',
          'noNotification': 'ليس لديك إشعارات حاليًا',
          'textEmpty': 'لا يمكن أن يكون هذا فارغًا',
          'charactersOnly': 'لا يمكنك استخدام أحرف خاصة هنا',
          'resetUnlinkSocial':
              'يرجى ملاحظة أن إعادة تعيين كلمة المرور ستؤدي إلى إلغاء ربط جميع حسابات الوسائط الاجتماعية الخاصة بك',
          'passwordRequired': 'كلمة المرور مطلوبة',
          'password8long': 'يجب أن تكون كلمة المرور 8 أحرف على الأقل',
          'passwordUpperCase':
              'يجب أن تحتوي كلمة المرور على حرف كبير واحد على الأقل',
          'passwordNumber': 'يجب أن تحتوي كلمة المرور على رقم واحد على الأقل',
          'emailRequired': 'البريد الإلكتروني مطلوب',
          'emailValid': 'يرجى إدخال بريد إلكتروني صالح',
          'invalidNumberMsg': 'رقم الهاتف المحمول غير صالح',
          'invalidNumber': 'يرجى إدخال رقم هاتف صالح',
          'name': 'الاسم:',
          'deleteAccountTitle': 'حذف حسابك',
          'deleteAccount': 'حذف الحساب',
          'placeOrder': 'تنفيذ الطلب',
          'tableNumber': 'ط-@number',
          'tableNumberD': 'ط@number',
          'orderNumber': 'طلب #@number',
          'searchItemsHint': 'ابحث عن جميع العناصر هنا...',
          'chooseSize': 'اختر الحجم',
          'chooseSugar': 'اختر مستوى السكر',
          'chooseOptions': 'اختر من الخيارات',
          'selectSize': 'حدد الحجم',
          'addToOrder': 'أضف إلى الطلب',
          'notes': 'ملاحظات',
          'note': 'ملاحظة',
          'subtotal': 'المجموع الفرعي',
          'totalSalesTax': 'إجمالي ضريبة المبيعات',
          'discountSales': 'تخفيض المبيعات',
          'total': 'الإجمالي',
          'typeNotes': 'يمكن إدخال أي ملاحظات للعنصر هنا',
          'itemNote': 'ملاحظات العنصر',
          'currentOrder': 'الطلب الحالي',
          'addCustomer': 'إضافة عميل',
          'noCustomer': 'لا يوجد عميل',
          'itemDetails': 'تفاصيل العنصر',
          'sugarItemReveal': 'السكر - @sugarLevel',
          'charge': 'ادفع',
          'holdCart': 'تعليق السلة',
          'updateOrder': 'تحديث الطلب',
          'chooseCustomer': 'اختر العميل',
          'addDiscount': 'إضافة خصم',
          'editDiscount': 'تعديل الخصم',
          'enterDiscountValue': 'يرجى إدخال قيمة الخصم',
          'enterNumber': 'يرجى إدخال الأرقام فقط',
          'searchCountry': 'ابحث عن البلد',
          'customerInformation': 'معلومات العميل',
          'orderCart': 'سلة الطلب',
          'noItemsCart': 'السلة فارغة حاليًا',
          'checkOut': 'الدفع',
          'paymentDetails': 'تفاصيل الدفع',
          'size': 'الحجم',
          'customers': 'العملاء',
          'noCompletedOrdersTitle': 'لا توجد طلبات مكتملة',
          'noCompletedOrdersBody': 'لا توجد طلبات مكتملة حاليًا',
          'noCanceledOrdersTitle': 'لا توجد طلبات ملغاة',
          'noCanceledOrdersBody': 'لا توجد طلبات ملغاة حاليًا',
          'noReturnedOrdersTitle': 'لا توجد طلبات مرتجعة',
          'noReturnedOrdersBody': 'لا توجد طلبات مرتجعة حاليًا',
          'noOrdersTitle': 'لا توجد طلبات',
          'noOrdersBody': 'لا توجد طلبات حاليًا',
          'guest': 'زائر',
          'customer': 'عميل',
          'allMenu': 'جميع القوائم',
          'enterPasscode': 'أدخل رمز المرور',
          'tableNotAvailable': 'الطاولة رقم @tableNo غير متوفرة',
          'orderItemDeletedSuccess': 'تم حذف عنصر الطلب بنجاح',
          'functionNotAllowed': 'ليس لديك الصلاحية للقيام بذلك',
          'searchCustomersHint': 'ابحث عن جميع العملاء هنا...',
          'chooseCustomerViewOrdersTitle': 'لم يتم اختيار عميل',
          'noOrdersCustomerTitle': 'لا توجد طلبات',
          'noOrdersCustomerBody': 'هذا العميل ليس لديه أي طلبات',
          'noCustomersTitle': 'لا يوجد عملاء',
          'noCustomerBody': 'أضف عملاء لإدارتهم هنا',
          'editCustomerSuccess': 'تم تعديل بيانات العميل بنجاح',
          'deleteCustomerSuccess': 'تم حذف العميل بنجاح',
          'addCustomerSuccess': 'تم إضافة العميل بنجاح',
          'returned': 'مرتجع',
          'active': 'نشط',
          'chooseCustomerViewOrdersBody': 'اختر عميلاً لعرض طلباته هنا',
          'allOrders': 'جميع الطلبات',
          'today': 'اليوم',
          'yesterday': 'أمس',
          'thisWeek': 'هذا الأسبوع',
          'thisMonth': 'هذا الشهر',
          'thisYear': 'هذا العام',
          'customDate': 'تاريخ مخصص',
          'orderChargedSuccess': 'تم دفع الطلب بنجاح',
          'tableEmptySuccess': 'تم تعيين الطاولة كفارغة بنجاح',
          'chooseBilledOption': 'اختر خيار الطاولة المفوترة',
          'tableIsEmpty': 'الطاولة فارغة',
          'reopenOrder': 'إعادة فتح الطلب',
          'emailNotRegistered': 'هذا البريد الإلكتروني غير مسجل',
          'print': 'طباعة',
          'reopen': 'إعادة فتح',
          'orderPrintSuccess': 'تم طباعة فاتورة الطلب بنجاح',
          'searchOrdersHint': 'ابحث عن الطلبات بواسطة رقم تعريف الطلب...',
          'conflictingTablesError':
              'لا يمكن إعادة فتح هذا الطلب لأن الطاولات غير متوفرة',
          'orderCanceledSuccess': 'تم إلغاء الطلب بنجاح',
          'orderReturnedSuccess': 'تم إرجاع الطلب بنجاح',
          'orderCompletedSuccess': 'تم إكمال الطلب بنجاح',
          'cancelOrder': 'إلغاء الطلب',
          'complete': 'إكمال',
          'return': 'إرجاع',
          'printInvoice': 'طباعة الفاتورة',
        },
        'en_US': {
          'skip': 'Skip',
          'continueApp': 'Continue to app',
          'privacyPolicy': 'Our privacy policy',
          'onBoardingTitle1': 'Effortless Order Management',
          'onBoardingDescription1':
              'Handle orders smoothly from start to finish, ensuring efficient and organized service.',
          'onBoardingTitle2': 'Real-Time Inventory Updates',
          'onBoardingDescription2':
              'Stay informed on stock levels with automatic updates and low-stock alerts.',
          'onBoardingTitle3': 'Powerful Sales Insights',
          'onBoardingDescription3':
              'Access valuable sales and inventory data to drive smarter business decisions.',
          'onBoardingTitle4': 'Easy Payment & Discounts',
          'onBoardingDescription4':
              'Simplify checkout with flexible payment options, discounts, and coupons.',
          'chooseLanguage': 'Choose your preferred language',
          'english': 'ENGLISH',
          'arabic': 'العربية',
          'settings': 'Settings',
          'qrcodeNotFound': 'No QrCode detected, please try again',
          'noImageChosen': 'You didn\'t choose any image, please try again',
          'errorOccurred': 'An error occurred, please try again',
          'cameraPermission': 'Camera permission',
          'cameraPermissionDeniedForever':
              'Camera permission denied forever please enable it from the settings',
          'storagePermission': 'Storage permission',
          'storagePermissionDeniedForever':
              'Storage permission denied forever please enable it from the settings',
          'callPermission': 'Call permission',
          'callPermissionDeniedForever':
              'Call permission denied forever please enable it from the settings',
          'micPermission': 'Microphone permission',
          'micPermissionDeniedForever':
              'Microphone permission denied forever please enable it from the settings',
          'contactsPermission': 'Contacts permission',
          'contactsPermissionDeniedForever':
              'Contacts permission denied forever please enable it from the settings',
          'enableLocationPermission': 'Please accept location permission',
          'enableCameraPermission': 'Please accept camera permission',
          'enableStoragePermission': 'Please accept storage permission',
          'goToSettings': 'Go to settings',
          'qrcode': 'QrCode',
          'wifi': 'Wi-Fi',
          'contact': 'Contact',
          'sms': 'SMS',
          'email': 'E-Mail',
          'website': 'Website',
          'number': 'Number',
          'available': 'Available',
          'occupied': 'Occupied',
          'billed': 'Billed',
          'unavailable': 'Unavailable',
          'takeawayOrder': 'Takeaway Order',
          'dineInOrder': 'Dine-in Order',
          'tableSameOrderId': 'Those tables serve the same order',
          'tableUnavailable': 'This Table is Unavailable',
          'tablesOrdersSwitched': 'Tables orders switched successfully',
          'noOrderToSwitch': 'Both tables have no orders',
          'door': 'Door',
          'counter': 'Counter',
          'launchUrlFailed': 'Url launch failed, please try again',
          'copiedSuccess': 'Copied to Clipboard!',
          'copy': 'Copy',
          'share': 'Share',
          'open': 'Open',
          'save': 'Save',
          'password': 'Password',
          'yes': 'Yes',
          'no': 'No',
          'home': 'Home',
          'tables': 'Tables',
          'table': 'Table',
          'orders': 'Orders',
          'ordersNoNew': 'Order #New',
          'reports': 'Reports',
          'account': 'Account',
          'invalidEmailEntered': 'Email entered is invalid',
          'emailAlreadyExists': 'This email already exists',
          'missingEmail': 'No Email entered',
          'requireRecentLoginError':
              'This operation is sensitive and requires recent authentication',
          'unknownError': 'An unknown error occurred. Try again',
          'failedGoogleAuth': 'Google authentication failed, Please try again',
          'successGoogleLink': 'Google account was linked successfully',
          'googleAccountInUse':
              'This google account is already in use by you or another user',
          'failedGoogleLink': 'Google account Link failed, Please try again',
          'googleMapsNavigation': 'Google maps navigation',
          'failedToChangeSetting': 'Failed to change setting, please try again',
          'deleteAccountBody':
              'If you\'re deleting your account because you don\'t use it, you don\'t have to worry because we don\'t share any of your information with any third-party organization. Please know that your data is safe.',
          'emailChangedSuccess': 'Your email was changed successfully',
          'enterChangeEmailData':
              'Please enter the new email and your password to change your email',
          'linkEmailPassword': 'Link email and password',
          'verificationSent': 'Verification sent',
          'verifyEmailSent': 'Email verification link sent successfully',
          'verifyEmailSendFailed': 'Email verification link sending failed',
          'timedOut': 'Request timed out',
          'welcome': 'Welcome',
          'changeGoogleAccount': 'Change Google Account',
          'loadingFailed': 'Loading Failed, Click retry',
          'welcomeTitle': 'Login or create an account',
          'loginTextTitle': 'LOGIN',
          'registerTextTitle': 'REGISTER',
          'skipLabel': 'Skip',
          'delete': "Delete",
          'successFacebookLink': 'Facebook account was linked successfully',
          'notAvailableErrorTitle': 'Not Currently Available',
          'notAvailableErrorSubTitle': 'We are working on it....',
          'noConnectionAlertTitle': 'No Internet Connection',
          'connectionRestored': 'Internet Connection Restored',
          'noConnectionAlertContent': 'Please check your internet connectivity',
          'ok': 'OK',
          'addContact': 'Add contact',
          'loginWithGoogle': 'CONTINUE WITH GOOGLE',
          'loginWithFacebook': 'CONTINUE WITH FACEBOOK',
          'loginWithMobile': 'CONTINUE WITH PHONE NUMBER',
          'emailLabel': 'E-Mail',
          'newEmailLabel': 'New E-Mail',
          'emailHintLabel': 'Enter your E-Mail',
          'newEmailHintLabel': 'Enter your new E-Mail',
          'tryAgain': 'Try again',
          'passwordLabel': 'Password',
          'passwordHintLabel': 'Enter your Password',
          'forgotPassword': 'Forgot Password?',
          'or': 'OR',
          'noEmailAccount': 'Don\'t have an email account? Register with email',
          'chooseForgetPasswordMethod':
              'Choose a method to reset your password',
          'emailReset': 'Reset password via E-Mail Link',
          'numberReset': 'Reset password via Phone OTP Verification',
          'phoneLabel': 'Phone number',
          'phoneFieldLabel': 'Enter Phone Number',
          'passwordResetLink':
              'Enter your E-Mail to get the password reset link',
          'loggedInPasswordResetLink':
              'Press on send button to get the password reset link',
          'continue': 'CONTINUE',
          'confirm': 'Confirm',
          'confirmPassword': 'Confirm Password',
          'alreadyHaveAnAccount': 'Already Have an account? Login here',
          'invalidEmail': 'Invalid Email',
          'noRegisteredEmail': 'There is no account with this email registered',
          'wrongPassword': 'Password entered is wrong',
          'enterStrongerPassword': 'Please enter a stronger password',
          'operationNotAllowed': 'Operation now allowed. Contact Support',
          'userDisabled': 'This user is disabled',
          'invalidPhoneNumber': 'Entered phone number is invalid',
          'failedFacebookLink':
              'Facebook account Link failed, Please try again',
          'facebookAccountInUse':
              'This facebook account is already in use by you or another user',
          'failedFacebookAuth':
              'Facebook authentication failed, Please try again',
          'failedAuth': 'Authentication failed',
          'success': 'Success',
          'warning': 'Warning',
          'info': 'Info',
          'completed': 'Completed',
          'canceled': 'Canceled',
          'error': 'Error',
          'search': 'Search',
          'passwordResetSuccess': 'Reset password email sent successfully',
          'emptyFields': 'Fields can\'t be empty',
          'smallPass': 'Password can\'t be less than 8 characters',
          'passwordNotMatch': 'Passwords don\'t match',
          'lang': 'Language',
          'logout': 'Logout',
          'logoutConfirm': 'Are you sure you want to logout?',
          'emailPasswordAccountSuccess':
              'Email and password account linked successfully',
          'viewAll': 'See All',
          'status': 'Status',
          'payment': 'Payment',
          'newOrder': 'New Order',
          'back': 'Back',
          'notifications': 'Notifications',
          'noActiveOrdersTitle': 'No Active Orders',
          'noActiveOrdersBody': 'There are no active orders at the moment',
          'activeOrders': 'Active Orders',
          'tablesView': 'Tables View',
          'ordersHistory': 'Orders History',
          'aboutUs': 'About Us',
          'locationService': 'Location Service',
          'enableLocationService':
              'Please enable location service to use this feature',
          'acceptLocationPermission':
              'Please enable location permission to use this feature',
          'locationPermission': 'Location permission',
          'locationPermissionDeniedForever':
              'Locations permission denied forever please enable it from the settings',
          'enableCallPermission': 'Please accept call permission',
          'enableMicPermission': 'Please accept microphone permission',
          'enableContactsPermission': 'Please accept contacts permission',
          'accountDetailSavedSuccess': 'Account information saved successfully',
          'phoneChangeSuccess': 'Phone number changed successfully',
          'pullToRefresh': 'Pull down to refresh',
          'releaseToRefresh': 'Release to refresh',
          'refreshing': 'Refreshing',
          'refreshCompleted': 'Refresh completed',
          'pullToLoad': 'Pull up to load more',
          'releaseToLoad': 'Release to load more',
          'loadingCompleted': 'Loading completed',
          'fullName': 'Full Name',
          'enterEmailPasswordDetails':
              'Please enter email and password account details',
          'signOutFailed': 'Sign out failed, please try again',
          'enterFullName': 'Enter your full name',
          'enterYourInfo':
              'Please enter your personal information to complete your account registration',
          'enterBirthDate': 'Choose your Birth Date',
          'birthDate': 'Birth date',
          'enterGender': 'Choose your gender',
          'enterPhoto': 'Please add your photo',
          'addPhoto': 'Add photo',
          'changePhoto': 'Change photo',
          'choosePicMethod': 'Please choose a method to add your photo',
          'selectValue': 'Select',
          'pickGallery': 'Pick from gallery',
          'capturePhoto': 'Capture a photo',
          'smsPermission': 'SMS permission',
          'notificationsPermission': 'Notifications permission',
          'smsPermissionDeniedForever':
              'SMS permission denied forever please enable it from the settings',
          'notificationsPermissionDeniedForever':
              'Notifications permission denied forever please enable it from the settings',
          'enableSmsPermission': 'Please accept SMS permission',
          'enableNotificationPermission':
              'Please accept Notifications permission',
          'enableSpeechPermission': 'Please accept speech permission',
          'speechPermissionDeniedForever':
              'Speech permission denied forever please enable it from the settings',
          'speechPermission': 'Speech permission',
          'don\'tKnow': 'Don\'t know',
          'requiredFields':
              'Please provide all of the information highlighted in red correctly',
          'saveUserInfoError':
              'Failed to save your information, please try again',
          'loginFailed': 'Login failed, please try again',
          'add': 'Add',
          'confirmPermanentDelete':
              'Please note that the deletion process is permanent, and your account cannot be retrieved again',
          'cancel': 'Cancel',
          'loading': 'Loading',
          'notAllowed': 'Not allowed',
          'enterRequestInfo': 'Please fill the ambulance request information',
          'cancelReason': 'Cancel reason',
          'egp': 'EGP',
          'editUserInfo': 'You can edit your account details here',
          'linkGoogleAccount': 'Link google account',
          'linkFacebookAccount': 'Link Facebook Account',
          'verify': 'Verify email',
          'send': 'Send',
          'userInformation': 'User information',
          'personalInformation': 'Personal information',
          'phoneNumber': 'Phone number',
          'unknown': 'Unknown',
          'noAdditionalInformation': 'No additional information',
          'edit': 'Edit',
          'noNotification': 'You don\'t have notifications currently',
          'textEmpty': 'This can\'t be empty',
          'charactersOnly': 'You can\'t use special characters here',
          'resetUnlinkSocial':
              'Please notice that resetting your password will unlink all your social media accounts',
          'passwordRequired': 'Password is required',
          'password8long': 'Password must be at least 8 characters long',
          'passwordUpperCase':
              'Password must contain at least one uppercase letter',
          'passwordNumber': 'Password must contain at least one number',
          'emailRequired': 'Email is required',
          'emailValid': 'Please enter a valid email',
          'invalidNumberMsg': 'Invalid mobile number',
          'invalidNumber': 'Please enter a valid phone number',
          'name': 'Name: ',
          'deleteAccountTitle': 'Delete your account',
          'deleteAccount': 'Delete account',
          'placeOrder': 'Place Order',
          'tableNumber': 'T-@number',
          'tableNumberD': 'T@number',
          'orderNumber': 'Order #@number',
          'searchItemsHint': 'Search all items here...',
          'chooseSize': 'Choose Size',
          'chooseSugar': 'Choose Sugar Level',
          'chooseOptions': 'Choose from options',
          'selectSize': 'Select size',
          'addToOrder': 'Add to Order',
          'notes': 'Notes',
          'note': 'Note',
          'subtotal': 'Subtotal',
          'totalSalesTax': 'Total Sales Tax',
          'discountSales': 'Discount Sales',
          'total': 'Total',
          'totalAmount': 'Total Amount',
          'typeNotes': 'Any notes for the item should be entered here',
          'itemNote': 'Item Notes',
          'currentOrder': 'Current Order',
          'addCustomer': 'Add Customer',
          'removeCustomer': 'Remove Customer',
          'noCustomer': 'No Customer',
          'itemDetails': 'Item details',
          'sugarItemReveal': 'Sugar - @sugarLevel',
          'charge': 'Charge',
          'holdCart': 'Hold Cart',
          'updateOrder': 'Update Order',
          'chooseCustomer': 'Choose Customer',
          'addDiscount': 'Add Discount',
          'editDiscount': 'Edit Discount',
          'enterDiscountValue': 'Please enter a discount value',
          'enterNumber': 'Please enter numbers only',
          'searchCountry': 'Search for country',
          'customerInformation': 'Customer information',
          'orderCart': 'Order Cart',
          'noItemsCart': 'Cart is currently Empty',
          'checkOut': 'Check Out',
          'paymentDetails': 'Payment Details',
          'size': 'Size',
          'customers': 'Customers',
          'noCompletedOrdersTitle': 'No Completed Orders',
          'noCompletedOrdersBody':
              'There are no completed orders at the moment',
          'noCanceledOrdersTitle': 'No Canceled Orders',
          'noCanceledOrdersBody': 'There are no Canceled orders at the moment',
          'noReturnedOrdersTitle': 'No Returned Orders',
          'noReturnedOrdersBody': 'There are no Returned orders at the moment',
          'noOrdersTitle': 'No Orders',
          'noOrdersBody': 'There are no orders at the moment',
          'guest': 'Guest',
          'customer': 'Customer',
          'allMenu': 'All Menu',
          'enterPasscode': 'Enter Passcode',
          'tableNotAvailable': 'Table number @tableNo is unavailable',
          'orderItemDeletedSuccess': 'Order Item Deleted Successfully',
          'functionNotAllowed': 'You don\'t have the permission to do that',
          'searchCustomersHint': 'Search all customers here...',
          'chooseCustomerViewOrdersTitle': 'No Customer Chosen',
          'noOrdersCustomerTitle': 'No Orders',
          'noOrdersCustomerBody': 'This Customer doesn\'t have any orders',
          'noCustomersTitle': 'No Customers',
          'noCustomerBody': 'Add customers to manage them here',
          'editCustomerSuccess': 'Customer was edited successfully',
          'deleteCustomerSuccess': 'Customer was deleted successfully',
          'addCustomerSuccess': 'Customer was added successfully',
          'returned': 'Returned',
          'active': 'Active',
          'chooseCustomerViewOrdersBody':
              'Choose a customer to view his orders here',
          'allOrders': 'All Orders',
          'today': 'Today',
          'yesterday': 'Yesterday',
          'thisWeek': 'This week',
          'thisMonth': 'This month',
          'thisYear': 'This year',
          'customDate': 'Custom date',
          'takeaway': 'Takeaway',
          'orderChargedSuccess': 'Order Charged Successfully',
          'tableEmptySuccess': 'Table was assigned as empty successfully',
          'chooseBilledOption': 'Choose Billed Table Option',
          'tableIsEmpty': 'Table is Empty',
          'reopenOrder': 'Reopen Order',
          'emailNotRegistered': 'This email isn\'t registered',
          'print': 'Print',
          'reopen': 'Reopen',
          'orderPrintSuccess': 'Order invoice printed successfully',
          'searchOrdersHint': 'Search orders by order ID...',
          'conflictingTablesError':
              'This order can\'t be reopened because tables aren\'t available',
          'orderCanceledSuccess': 'Order was canceled successfully',
          'orderReturnedSuccess': 'Order was returned successfully',
          'orderCompletedSuccess': 'Order was completed successfully',
          'cancelOrder': 'Cancel Order',
          'complete': 'Complete',
          'return': 'Return',
          'printInvoice': 'Print Invoice',
          'selectStatus': 'Select Status',
          'selectDate': 'Select Date',
          'orderDetails': 'Order Details',
          'customerOrders': 'Customer Orders',
          'receiptPrintFailed': 'Receipt print failed',
          'cashier': 'Cashier',
          'waiter': 'Waiter',
          'admin': 'Admin',
          'takeawayRole': 'Takeaway Waiter',
        },
      };
}
