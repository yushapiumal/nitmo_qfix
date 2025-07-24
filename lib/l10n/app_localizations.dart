import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_si.dart';
import 'app_localizations_ta.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('si'),
    Locale('ta')
  ];

  /// The current Language
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get language;

  /// all txt
  ///
  /// In en, this message translates to:
  /// **'ALL'**
  String get all;

  /// name txt
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// s.id txt
  ///
  /// In en, this message translates to:
  /// **'S.ID'**
  String get sid;

  /// late txt
  ///
  /// In en, this message translates to:
  /// **'late'**
  String get late;

  /// No description provided for @intext.
  ///
  /// In en, this message translates to:
  /// **'IN'**
  String get intext;

  /// late txt
  ///
  /// In en, this message translates to:
  /// **'OUT'**
  String get out;

  /// open txt
  ///
  /// In en, this message translates to:
  /// **'OPEN'**
  String get open;

  /// priority txt
  ///
  /// In en, this message translates to:
  /// **'PRIORITY'**
  String get priority;

  /// mine txt
  ///
  /// In en, this message translates to:
  /// **'MINE'**
  String get mine;

  /// The Tenant Code
  ///
  /// In en, this message translates to:
  /// **'Company Code'**
  String get companycode;

  /// Login Txt
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// Checking Txt
  ///
  /// In en, this message translates to:
  /// **'Checking'**
  String get checking;

  /// Error Msg Company code is required
  ///
  /// In en, this message translates to:
  /// **'Company code is required'**
  String get errorCompanyCode;

  /// Error Msg username
  ///
  /// In en, this message translates to:
  /// **'Please enter username'**
  String get errorUsername;

  /// Error Msg password
  ///
  /// In en, this message translates to:
  /// **'Please enter password'**
  String get errorPassword;

  /// Error Msg email
  ///
  /// In en, this message translates to:
  /// **'Please enter correct email address'**
  String get errorEmail;

  /// username field txt
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// password field txt
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// forgotPassword field txt
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// Contact administrator msg txt
  ///
  /// In en, this message translates to:
  /// **'Contact administrator'**
  String get contactAdministrator;

  /// Menu customerService
  ///
  /// In en, this message translates to:
  /// **'Customer Service'**
  String get customerService;

  /// Menu inventoryControl
  ///
  /// In en, this message translates to:
  /// **'Inventory Control'**
  String get inventoryControl;

  ///  attendance
  ///
  /// In en, this message translates to:
  /// **'ATTENDANCE'**
  String get attendance;

  /// Menu attendance
  ///
  /// In en, this message translates to:
  /// **'Attendance'**
  String get attendanceMenu;

  /// Menu new item
  ///
  /// In en, this message translates to:
  /// **'Add New Item'**
  String get newItemMenu;

  /// Menu settings
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// ADD NEW ITEM txt
  ///
  /// In en, this message translates to:
  /// **'Add Item'**
  String get addItem;

  /// Menu about
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// Menu logout
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// Alret areyousure
  ///
  /// In en, this message translates to:
  /// **'Are you sure?'**
  String get areyousure;

  /// Alret doyouwantlogout
  ///
  /// In en, this message translates to:
  /// **'Do you want to logout'**
  String get doyouwantlogout;

  /// Alret yes
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// Alret no
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// Alret permissionError
  ///
  /// In en, this message translates to:
  /// **'You do not have permission'**
  String get permissionError;

  /// menu csr
  ///
  /// In en, this message translates to:
  /// **'CSR'**
  String get csr;

  /// menu site
  ///
  /// In en, this message translates to:
  /// **'Site'**
  String get site;

  /// menu work
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get work;

  /// menu parts
  ///
  /// In en, this message translates to:
  /// **'Parts'**
  String get parts;

  /// menu timeline
  ///
  /// In en, this message translates to:
  /// **'Timeline'**
  String get timeline;

  /// back  details screen
  ///
  /// In en, this message translates to:
  /// **'Do you want to go details screen'**
  String get detailsScreen;

  /// text issue task
  ///
  /// In en, this message translates to:
  /// **'Issue / Task'**
  String get issueTask;

  /// text solution
  ///
  /// In en, this message translates to:
  /// **'Solution'**
  String get solution;

  /// text technicians
  ///
  /// In en, this message translates to:
  /// **'Technician\'s'**
  String get technicians;

  /// text customer
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get customer;

  /// text assignedTo
  ///
  /// In en, this message translates to:
  /// **'Assigned To'**
  String get assignedTo;

  /// text owner
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get owner;

  /// text cancel
  ///
  /// In en, this message translates to:
  /// **'CANCEL'**
  String get cancel;

  /// text submit
  ///
  /// In en, this message translates to:
  /// **'SUBMIT'**
  String get submit;

  /// Alret solutionError
  ///
  /// In en, this message translates to:
  /// **'Please enter solution'**
  String get solutionError;

  /// Alret markIn
  ///
  /// In en, this message translates to:
  /// **'Mark In'**
  String get markIn;

  /// Alret markOut
  ///
  /// In en, this message translates to:
  /// **'Mark Out'**
  String get markOut;

  /// Alret onTheWay
  ///
  /// In en, this message translates to:
  /// **'On The Way'**
  String get onTheWay;

  /// Alret startWork
  ///
  /// In en, this message translates to:
  /// **'Start Work'**
  String get startWork;

  /// Alret markAsDelay
  ///
  /// In en, this message translates to:
  /// **'Mark as Delay'**
  String get markAsDelay;

  /// Alret markAsComplete
  ///
  /// In en, this message translates to:
  /// **'Mark as Complete'**
  String get markAsComplete;

  /// Alret reschedule
  ///
  /// In en, this message translates to:
  /// **'Reschedule'**
  String get reschedule;

  /// clear lbl
  ///
  /// In en, this message translates to:
  /// **'CLEAR'**
  String get clear;

  /// customersName filed
  ///
  /// In en, this message translates to:
  /// **'Customer\'s Name'**
  String get customersName;

  /// customersNameError filed
  ///
  /// In en, this message translates to:
  /// **'Please enter customer\'s Name'**
  String get customersNameError;

  /// description filed
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// descriptionError filed
  ///
  /// In en, this message translates to:
  /// **'Please enter description'**
  String get descriptionError;

  /// customerSignature txt
  ///
  /// In en, this message translates to:
  /// **'customer signature'**
  String get customerSignature;

  /// orderBtnName txt
  ///
  /// In en, this message translates to:
  /// **'Order New Parts'**
  String get orderBtnName;

  /// partsFiled filed
  ///
  /// In en, this message translates to:
  /// **'New Parts List'**
  String get partsFiled;

  /// partsFiled partsFiledError
  ///
  /// In en, this message translates to:
  /// **'Please enter new parts list'**
  String get partsFiledError;

  /// No timeline found txt
  ///
  /// In en, this message translates to:
  /// **'No timeline found'**
  String get notimeLinetxt;

  /// itemCode txt
  ///
  /// In en, this message translates to:
  /// **'Item Code'**
  String get itemCode;

  /// Item Name txt
  ///
  /// In en, this message translates to:
  /// **'Item Name'**
  String get itemName;

  /// ADD NEW ITEM txt
  ///
  /// In en, this message translates to:
  /// **'ADD NEW ITEM'**
  String get addNewItem;

  /// Item SubCategory txt
  ///
  /// In en, this message translates to:
  /// **'Item SubCategory'**
  String get itemSubCategory;

  /// Item Category txt
  ///
  /// In en, this message translates to:
  /// **'Item Category'**
  String get itemCategory;

  /// Item Location txt
  ///
  /// In en, this message translates to:
  /// **'Item Location'**
  String get itemLocation;

  /// Item max amount txt
  ///
  /// In en, this message translates to:
  /// **'Item max amount'**
  String get itemMaxAmount;

  /// Item min Amount txt
  ///
  /// In en, this message translates to:
  /// **'Item min Amount'**
  String get itemMinAmount;

  ///  select Uom  txt
  ///
  /// In en, this message translates to:
  /// **' select '**
  String get selectUom;

  /// Item min re-order txt
  ///
  /// In en, this message translates to:
  /// **'Item re-order Amount'**
  String get itemReOderAmount;

  /// Item Description txt
  ///
  /// In en, this message translates to:
  /// **'Item Description'**
  String get itemDescription;

  /// Please enter item code/bin code txt
  ///
  /// In en, this message translates to:
  /// **'Please enter item code/bin code'**
  String get itemCodeError;

  /// Please enter item name txt
  ///
  /// In en, this message translates to:
  /// **'Please enter item name'**
  String get itemNameerror;

  /// Please enter item max amaout txt
  ///
  /// In en, this message translates to:
  /// **'Please enter item max amount'**
  String get itemMaxAmountError;

  /// Please enter item category txt
  ///
  /// In en, this message translates to:
  /// **'Please enter item category'**
  String get itemCategoryError;

  /// Please enter item select UOM txt
  ///
  /// In en, this message translates to:
  /// **'Please enter select Sub category'**
  String get itemSubCategoryError;

  /// Please enter item description txt
  ///
  /// In en, this message translates to:
  /// **'Please enter item location'**
  String get itemLocationError;

  /// Please enter item select UOM txt
  ///
  /// In en, this message translates to:
  /// **'Please enter select UOM'**
  String get itemUomErrorError;

  /// Please enter item max amount txt
  ///
  /// In en, this message translates to:
  /// **'Please enter item max amount'**
  String get itemMinAmountError;

  /// Please enter item re-order amount txt
  ///
  /// In en, this message translates to:
  /// **'Please enter item re-order amount'**
  String get itemReOderAmountError;

  /// Please enter item description txt
  ///
  /// In en, this message translates to:
  /// **'Please enter item description'**
  String get pleaseitemDescription;

  /// please select txt
  ///
  /// In en, this message translates to:
  /// **'Please select UOM'**
  String get selectUomError;

  /// new csr txt
  ///
  /// In en, this message translates to:
  /// **'ADD NEW CSR'**
  String get addnewCsr;

  /// No description provided for @serviceArea.
  ///
  /// In en, this message translates to:
  /// **'Service Area'**
  String get serviceArea;

  /// No description provided for @selectCustomer.
  ///
  /// In en, this message translates to:
  /// **'Please select Customer'**
  String get selectCustomer;

  /// Issue/Request txt
  ///
  /// In en, this message translates to:
  /// **'Issue/Request'**
  String get issueOrRequest;

  /// Please select Service Type txt
  ///
  /// In en, this message translates to:
  /// **'Please select Service Type'**
  String get selectServiceType;

  /// Please select Owner txt
  ///
  /// In en, this message translates to:
  /// **'Please select Owner(primary Contact)'**
  String get selectOwner;

  /// Please select Technician txt
  ///
  /// In en, this message translates to:
  /// **'Please select Technician'**
  String get selectTechnician;

  /// Please select Complexity txt
  ///
  /// In en, this message translates to:
  /// **'Please select Complexity'**
  String get selectComplexity;

  ///  Project/Task txt
  ///
  /// In en, this message translates to:
  /// **'Project/Task'**
  String get projectOrTask;

  /// Project Serial txt
  ///
  /// In en, this message translates to:
  /// **'Project Serial'**
  String get projectSerial;

  /// Project Description txt
  ///
  /// In en, this message translates to:
  /// **'Project Description'**
  String get projectDescription;

  /// Customer Name txt
  ///
  /// In en, this message translates to:
  /// **'Customer Name'**
  String get customerName;

  /// Contact Number txt
  ///
  /// In en, this message translates to:
  /// **'Contact Number'**
  String get contactNumber;

  /// Contact Persion Name txt
  ///
  /// In en, this message translates to:
  /// **'Contact Persion Name'**
  String get contactPersionName;

  /// Customer Address txt
  ///
  /// In en, this message translates to:
  /// **'Customer Address/Location'**
  String get customerAddress;

  /// Please select project txt
  ///
  /// In en, this message translates to:
  /// **'Please select project'**
  String get selectProjectPlease;

  /// Please enter service area txt
  ///
  /// In en, this message translates to:
  /// **'Please enter service area'**
  String get enterServiceAreaPlease;

  /// Please enter customer name txt
  ///
  /// In en, this message translates to:
  /// **'Please enter customer name'**
  String get enterCustomerNamePlease;

  /// Please enter contact person name txt
  ///
  /// In en, this message translates to:
  /// **'Please enter contact person name'**
  String get enterContactPersonNamePlease;

  /// Please enter contact number txt
  ///
  /// In en, this message translates to:
  /// **'Please enter contact number'**
  String get enterContactNumberPlease;

  /// Please enter address/location txt
  ///
  /// In en, this message translates to:
  /// **'Please enter address/location'**
  String get enterAddressPlease;

  /// Please enter be descriptive txt
  ///
  /// In en, this message translates to:
  /// **'Please enter be descriptive'**
  String get beDescriptivePlease;

  /// Please enter project serial txt
  ///
  /// In en, this message translates to:
  /// **'Please enter project serial'**
  String get enterProjectSerialPlease;

  /// Please enter project detail txt
  ///
  /// In en, this message translates to:
  /// **'Please enter project detail'**
  String get enterProjectDetailPlease;

  /// Please select customer txt
  ///
  /// In en, this message translates to:
  /// **'Please select customer'**
  String get selectCustomerPlease;

  /// Please select service type txt
  ///
  /// In en, this message translates to:
  /// **'Please select service type'**
  String get selectServiceTypePlease;

  /// Please select owner txt
  ///
  /// In en, this message translates to:
  /// **'Please select owner'**
  String get selectOwnerPlease;

  /// Please select technician txt
  ///
  /// In en, this message translates to:
  /// **'Please select technician'**
  String get selectTechnicianPlease;

  /// Please select complexity txt
  ///
  /// In en, this message translates to:
  /// **'Please select complexity'**
  String get selectComplexityPlease;

  /// Please enter customer address txt
  ///
  /// In en, this message translates to:
  /// **'Please enter customer address'**
  String get selectCustomerAddressPlease;

  /// please enter task error txt
  ///
  /// In en, this message translates to:
  /// **'please enter task'**
  String get taskEror;

  /// View Projects txt
  ///
  /// In en, this message translates to:
  /// **'View Projects'**
  String get viewProjects;

  /// No projects or tasks found txt
  ///
  /// In en, this message translates to:
  /// **'No projects or tasks found'**
  String get noProjectsOrTasksFound;

  /// Projects txt
  ///
  /// In en, this message translates to:
  /// **'Projects'**
  String get projects;

  /// Tasks txt
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tasks;

  /// Worked Hours Formatted txt
  ///
  /// In en, this message translates to:
  /// **'wrkd_hours_fmtd'**
  String get workedHoursFormatted;

  /// Please Enter GRN Code and PRN Code txt
  ///
  /// In en, this message translates to:
  /// **'Please Enter GRN Code and PRN Code'**
  String get grnAndPrn;

  /// Please Enter GRN Code  txt
  ///
  /// In en, this message translates to:
  /// **'Please Enter correct GRN Code'**
  String get grnError;

  /// Please Enter PRN Code txt
  ///
  /// In en, this message translates to:
  /// **'Please Enter correct PRN Code'**
  String get prnError;

  ///  PRN Code txt
  ///
  /// In en, this message translates to:
  /// **'PRN Code'**
  String get prn;

  /// GRN Code txt
  ///
  /// In en, this message translates to:
  /// **'GRN Code'**
  String get grn;

  /// Start txt
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// update txt
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// Please start work first txt
  ///
  /// In en, this message translates to:
  /// **'Please start work first'**
  String get startworkfirst;

  /// Finish txt
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// Are you sure you want to finish work? txt
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to finish work?'**
  String get askfinish;

  /// Are you sure you want to start work? txt
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to start work?'**
  String get askstart;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'si', 'ta'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'si':
      return AppLocalizationsSi();
    case 'ta':
      return AppLocalizationsTa();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
