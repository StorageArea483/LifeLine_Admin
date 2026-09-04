# LifeLine - Admin Web Application

## 🚨 About LifeLine

LifeLine is a disaster relief and emergency response system designed to
improve communication and coordination between **victims, rescuers,
NGOs, and administrators** during emergencies such as earthquakes,
floods, landslides, accidents, and other critical situations.

This repository contains the **Admin Web Application**, which provides
administrators with centralized access to important information and
management functions across the LifeLine system.

The admin application allows administrators to:

-   Securely authenticate and access the admin platform.
-   Monitor important emergency information.
-   View and manage victim information.
-   View and manage rescuer information.
-   View and manage NGO information.
-   Monitor critical emergency alerts.
-   Access location information related to emergency situations.
-   Manage application settings and administrative functions.

The overall LifeLine system integrates the admin application with
separate victim, rescuer, and NGO applications.

------------------------------------------------------------------------

## 🎯 Objectives

The main objectives of the admin application are:

1.  **Provide centralized administration** of the LifeLine emergency
    response system.
2.  **Monitor victims, rescuers, and NGOs** involved in emergency
    response.
3.  **Provide access to important emergency information**.
4.  **Monitor critical alerts** and emergency situations.
5.  **Support effective coordination** between different LifeLine system
    roles.
6.  **Provide controlled administrative access** to system information.
7.  **Improve visibility and management** of emergency response
    activities.

------------------------------------------------------------------------

# 🧩 Admin Application Modules

## 1. 🔐 Admin Authentication Module

Provides secure access to the administrative platform.

### Features

-   Admin authentication.
-   Login validation.
-   Authentication error handling.
-   Controlled access to administrative features.
-   Session management.

------------------------------------------------------------------------

## 2. 📊 Admin Dashboard Module

Provides administrators with a central view of the LifeLine system.

### Features

-   Administrative dashboard.
-   Overview of system information.
-   Access to important emergency data.
-   Navigation to management sections.
-   Centralized administrative controls.

------------------------------------------------------------------------

## 3. 🚨 Critical Alerts Module

Allows administrators to monitor important emergency alerts.

### Features

-   View critical alerts.
-   Monitor emergency situations.
-   Access important alert information.
-   Review emergency-related updates.
-   Support administrative awareness of critical events.

------------------------------------------------------------------------

## 4. 👤 Victim Information Management Module

Provides administrators with access to victim-related information.

### Features

-   View victim information.
-   Access emergency-related victim details.
-   Review victim records.
-   Monitor information relevant to emergency response.

------------------------------------------------------------------------

## 5. 🚑 Rescuer Information Management Module

Provides administrators with access to rescuer-related information.

### Features

-   View rescuer information.
-   Review rescuer records.
-   Monitor rescuer-related information.
-   Support administrative coordination of rescue personnel.

------------------------------------------------------------------------

## 6. 🤝 NGO Information Management Module

Provides administrators with access to NGO-related information.

### Features

-   View NGO information.
-   Review NGO records.
-   Access NGO-related details.
-   Support coordination with participating organizations.

------------------------------------------------------------------------

## 7. 🗺️ Location & Map Module

Provides map-based information for administrative awareness.

### Features

-   Interactive map.
-   Location visualization.
-   Emergency-related location information.
-   Location markers.
-   Map-based monitoring.

**Repository implementation note:** the current repository uses
`flutter_map`, `flutter_map_location_marker`, and `latlong2` for its map
functionality and identifies the map implementation as OpenStreetMap.

------------------------------------------------------------------------

## 8. ⚙️ Settings Module

Provides administrative application settings.

### Features

-   Application settings.
-   Administrative configuration options.
-   Account-related settings.
-   Management of available application preferences.

------------------------------------------------------------------------

## 9. 🔄 LifeLine System Integration

The Admin Web Application works as part of the complete LifeLine
emergency response system.

It provides administrative access to information related to:

-   Victims.
-   Rescuers.
-   NGOs.
-   Emergency alerts.
-   Location information.
-   Overall emergency-response coordination.

------------------------------------------------------------------------

# 🛠️ Technology Stack

## Frontend / Web

-   **Flutter**
-   **Dart**
-   **Flutter Riverpod**

## Authentication & Backend

-   **Firebase Core**
-   **Firebase Authentication**
-   **Cloud Firestore**

## Maps & Location

-   **Flutter Map**
-   **Flutter Map Location Marker**
-   **LatLong2**
-   **OpenStreetMap**

## Utilities

-   **URL Launcher**

------------------------------------------------------------------------

# 📦 Dependencies

The current `pubspec.yaml` includes the major dependencies used by the
application:

``` yaml
firebase_core
cloud_firestore
firebase_auth
url_launcher
flutter_riverpod
flutter_map
flutter_map_location_marker
latlong2
```

For the exact dependency versions, refer to the repository's
`pubspec.yaml`.

------------------------------------------------------------------------

# ⚙️ Requirements

Before running the project, install:

-   Flutter SDK
-   Dart SDK compatible with the project's declared SDK constraint
-   Android Studio for Flutter development
-   A configured Firebase project
-   A supported browser or Flutter web development environment

The current repository declares the Dart SDK constraint:

``` text
^3.9.2
```

Check your local Flutter environment with:

``` bash
flutter doctor
```

------------------------------------------------------------------------

# 🚀 Installation & Setup

## 1. Clone the Repository

``` bash
git clone https://github.com/StorageArea483/LifeLine_Admin.git
```

``` bash
cd LifeLine_Admin
```

## 2. Install Dependencies

``` bash
flutter pub get
```

## 3. Configure Firebase

Make sure the Firebase configuration used by the local build corresponds
to the intended LifeLine project.

The application uses Firebase Authentication and Cloud Firestore for
backend functionality.

## 4. Run the Application

For Flutter web:

``` bash
flutter run -d chrome
```

You can also check available devices with:

``` bash
flutter devices
```

------------------------------------------------------------------------

# 🔑 Required Permissions & Configuration

The application uses services that may require appropriate platform or
browser permissions/configuration, including:

-   Internet/network access
-   Location services where required
-   Browser access for web functionality

Review the Firebase and web configuration before deployment.

------------------------------------------------------------------------

# 🧪 Testing

The Admin application should be tested across its main administrative
functionality, including:

-   Admin authentication
-   Dashboard access
-   Critical alerts
-   Victim information
-   Rescuer information
-   NGO information
-   Map and location functionality
-   Settings and administrative controls

The complete LifeLine FYP report provides the project's broader testing
and evaluation information.

------------------------------------------------------------------------

# 🔒 Security & Privacy

The Admin application is designed to provide controlled access to
sensitive emergency-response information.

Security considerations include:

-   Authenticated administrative access.
-   Controlled access to system information.
-   Firebase Authentication.
-   Cloud database security rules.
-   Protection of sensitive user information.
-   Avoiding hard-coded private credentials.

### Important

Never commit private credentials or sensitive configuration files to
GitHub.

Examples include:

``` text
.env
private API keys
service-account credentials
private tokens
private signing credentials
```

------------------------------------------------------------------------

# 📱 Supported Platform

The application is designed as a **Flutter Web Application**.

It can be run and tested using a supported web browser through Flutter's
web development tools.

------------------------------------------------------------------------

# 📚 Project Documentation

The complete LifeLine FYP report provides detailed information about:

-   Project background
-   Problem definition
-   Requirements
-   Use cases
-   System architecture
-   Algorithms
-   External services
-   Implementation
-   Testing
-   Evaluation
-   Conclusion and future work

This repository should be considered together with the final FYP report
for complete project documentation.

------------------------------------------------------------------------

# ⚠️ Emergency Use Notice

LifeLine is an academic Final Year Project developed to support disaster
relief and emergency response.

The Admin Web Application is intended to assist administrative
monitoring and coordination and should not be considered a replacement
for official emergency authorities or professional emergency-response
organizations.

------------------------------------------------------------------------

**Daniyal Mushtaq**\
BS Computer Science --- COMSATS University Islamabad, Abbottabad Campus

**Aryan Sajid**\
BS Computer Science --- COMSATS University Islamabad, Abbottabad Campus

**Supervisor:** Ms. Aatikah Rasool

------------------------------------------------------------------------

# 🎓 Final Year Project

**LifeLine - A Disaster Relief & Emergency Response App**

Bachelor of Science in Computer Science\
COMSATS University Islamabad, Abbottabad Campus

Academic Session: **2022 - 2026**

**Final Year Project - Spring 2026**

------------------------------------------------------------------------

## 📄 License

This repository is an academic Final Year Project repository. Unless a
separate license file is added, the project should be treated as an
academic submission rather than as a separately licensed open-source
package.
