# 1. Nome do app 

finances

# 2. Breve descrição: 

Finances: Manage budget, track expenses

# 3. Descrição completa

"Finances" is a comprehensive financial management application developed by rudsonalves67@gmail.com. Its primary purpose is to empower users with efficient budget control, allowing them to create and manage accounts, track financial transactions sorted into customizable categories, and plan and execute budgets. 

## App Objectives

Finances aims to be a user-friendly tool for expense tracking and improved financial management. It empowers users to manage an unlimited number of accounts, categorize their expenses into customizable categories, and create and track their budget execution.

### Privacy

Finances only collects personal information in the form of a specific email address and password required for Firebase Google account registration. This data is solely used for storing these credentials securely.

Finances is designed to be minimally intrusive, retaining no personal or sensitive information related to user security or privacy. All financial transaction information is exclusively stored on the user's device and is not shared by the application in any manner.

## App Description

Finances features four primary pages and occasional secondary pages (currently, only the settings page and the "About" page). Users can navigate between these pages through a PageView in the app's bottom bar. Below, we provide a brief overview of these pages:

* **Transaction Page**: This is the app's main page, where users input transactions, select different accounts, and track monthly balances.
* **Statistics Page**: Here, users can monitor annual spending statistics and various declared categories.
* **Accounts Page**: Users can add, remove, or edit accounts in the app on this page.
* **Budget/Categories Page**: This page allows users to add, remove, or edit payment categories and set monthly budgets.

There is also a fifth page for adjusting app settings, accessible through the menu in the upper-right corner of the Transaction Page. Through this page, users can customize themes, languages, and perform data backup and recovery.

These pages will be detailed further in the following sections.

"Finances" is your financial companion, empowering you to take control of your budget and financial future. With its user-friendly features and commitment to privacy, it's designed to simplify your financial life.

## About Code Development

This project serves as a platform to enhance proficiency in the Flutter SDK and the entire ecosystem surrounding app development. In essence, the project follows a feature-based architecture, where components and modules related to a particular functionality are logically grouped, easing comprehension and project maintenance.

Pages are constructed following the State pattern, where a page's construction changes as its internal state evolves. Typically, a page consists of three modules: an abstract class module, its subclasses that extend the abstract class to define different states, and a control module responsible for managing states used in page construction. The third module handles the page's construction based on the current state.

The "get_it" Service Locator is utilized, offering centralized access to necessary service instances throughout the application. It also facilitates Singleton and on-demand object generation, providing flexibility in resource distribution and control.

The chosen database is SQFLite, a widely popular SQLite implementation for Flutter among developers.

## Thanks

My thanks to [@devkaio](https://www.youtube.com/@devkaio), whose best practices and innovative ideas contributed significantly to its implementation.

To my former brother-in-law and great friend Sirhan Bortolini for the meaningful and warm debates, without which the project would not have reached the desired maturity.

# 4. Ícone do aplicativo

[Icon](assets/icons/finances_icon.png)