# DataHoteling WHM Inventory

Last verified: 2026-11-15

This document records observed production configuration.
Secrets, credentials and customer data must never be committed.

## 1. Hosting Packages

| Package | Disk MB | Bandwidth MB | Addon | FTP | Mailing Lists | Parked | Email | Databases | Subdomains | Passenger Apps | CGI |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---|
| data-economy | 5120 | 51200 | 0 | 2 | 5 | 0 | 5 | 2 | 2 | 0 | No |
| data-linux | 10240 | 102400 | 1 | 5 | 2 | 1 | 20 | 5 | 5 | 1 | No |
| data-wordpress | 15360 | 153600 | 2 | 5 | 2 | 1 | 20 | 5 | 5 | 1 | No |
| data-cloud | 30720 | 307200 | 5 | 10 | 5 | 2 | 50 | 10 | 10 | 2 | Yes |
| data-hightraffic | 51200 | 512000 | 10 | 15 | 10 | 5 | 100 | 20 | 20 | 5 | Yes |
| datahotel-basic | 5120 | 51200 | 0 | 10 | 2 | 1 | 20 | 5 | 5 | 4 | Yes |

All six packages use:
- Package type: standard
- cPanel theme: jupiter
- Language: en
- Dedicated IP: No
- Shell access: No
- Feature List: default

## 2. Email and Team Limits

| Package | Email Quota MB | Emails Per Hour | Deferred Failure % | Team Users |
|---|---:|---:|---:|---:|
| data-economy | 1024 | 100 | 10 | 0 |
| data-linux | 2048 | 200 | 10 | 0 |
| data-wordpress | 2048 | 300 | 10 | 0 |
| data-cloud | 4096 | 500 | 10 | 0 |
| data-hightraffic | 8192 | 1000 | 10 | 0 |
| datahotel-basic | Unlimited | Unlimited | 100 | 7 |

## 3. WHM Feature Lists

Three feature lists were found:

- `default`
- `Mail Only`
- `disabled`

### 3.1 default

- Total features: 110
- Features disabled in this list:
  - `api_shell`
  - `team_manager`
  - `modsecurity`
- No globally disabled features were reported.

### 3.2 Mail Only

- Total features: 110
- This list enables a limited set of mail-related and account-management features.
- It is intended for restricted mail-oriented hosting.
- No globally disabled features were reported.

### 3.3 disabled

- Total features: 110
- The API output showed all feature values enabled.
- No globally disabled features were reported.
- The exact operational meaning of this feature list has not yet been verified.

### 3.4 Package Assignment

All six custom hosting packages currently reference the `default` feature list.

Important:
A feature set value of `0` means that the feature is disabled in that feature list.
The `is_disabled` property represents a global disable state.
These two properties must not be treated as equivalent.

The `modsecurity` feature-list setting does not, by itself, prove that the server-wide ModSecurity engine is disabled.

## 4. WHMCS Registered Servers

WHMCS server records were inspected in the `tblservers` database table.

### 4.1 Main Hosting Server

- WHMCS Server ID: 1
- Name: Main Hosting Server
- Hostname: server.datahoteling.com
- Public IP: 84.241.13.103
- Module type: cpanel
- Username: root
- Secure connection: Enabled
- Port: Not explicitly configured
- Active: Yes
- Disabled: No
- Maximum accounts: 200

This is the standard WHMCS cPanel server entry used for shared hosting integration.

### 4.2 DataHoteling Provisioning API

- WHMCS Server ID: 2
- Name: DataHoteling Provisioning API
- Hostname: 127.0.0.1
- Module type: datahotelingvps
- Active: Yes
- Disabled: No
- Maximum accounts: 200

This entry represents the custom DataHoteling VPS provisioning integration.
It must be treated separately from the standard cPanel shared hosting server.

### 4.3 Authentication Security

The WHMCS `tblservers` table contains authentication fields such as
`password` and `accesshash`.

Their actual values must never be copied into this repository.
The exact authentication method used by the main hosting server
has not yet been confirmed.

### 4.4 Authentication Field Inspection

The WHMCS database record for server ID 1 was inspected.

Observed values:
- `password`: Empty
- `accesshash`: Set
- `secure`: on
- `port`: Default

The `accesshash` field is populated, while the `password` field is empty.

The credential value was not retrieved or displayed.
The exact credential format and authentication behavior have not
yet been independently verified.

## 5. WHMCS Standard cPanel Module

The production WHMCS installation contains the standard cPanel server module.

Observed module details:
- Path: `modules/servers/cpanel/`
- Main file: `cpanel.php`
- File size: 480454 bytes
- WHMCS module version: 8.12.1
- Build date: 2025-01-21
- Code protection: ionCube

The module directory also contains client-side assets, templates,
JSON metadata and other supporting files.

The main module is proprietary WHMCS software.
Its source code and vendor assets are not copied into this repository.
No decryption, reverse engineering or modification is part of this audit.

The exact internal provisioning implementation has not been independently
verified. WHMCS server configuration and product-to-server mappings
will be investigated separately.

## 6. WHMCS Product-to-WHM Package Mapping

The following mappings were verified against the production WHMCS
`tblproducts` table and the WHM package inventory.

| WHMCS Product ID | Product Name | Module | WHM Package |
|---:|---|---|---|
| 2 | هاست اقتصادی | cpanel | datahotel-basic |
| 3 | data-economy | cpanel | data-economy |
| 4 | Data-wordpress | cpanel | data-wordpress |
| 5 | data-cloud | cpanel | data-cloud |
| 6 | Data High Traffic | cpanel | data-hightraffic |
| 7 | Data Linux | cpanel | data-linux |

All six products use the standard `cpanel` module.
All six referenced WHM packages were found in the WHM package inventory.

### 6.1 Server Group Assignments

- Server Group ID 1: `DataHotel cPanel Servers`
  - Contains WHMCS Server ID 1: `Main Hosting Server`
- Server Group ID 2: `DataHoteling VPS Provisioning`
  - Contains WHMCS Server ID 2: `DataHoteling Provisioning API`

Product ID 3 (`data-economy`) explicitly references Server Group ID 1.
The other five cPanel products have `servergroup=0`.

The exact server-selection behavior for products with `servergroup=0`
has not yet been independently verified.

### 6.2 VPS Product Separation

Product ID 9 (`Ubuntu 24.04 VPS`) uses the custom
`datahotelingvps` module and Server Group ID 2.

VPS provisioning is a separate workflow from shared cPanel hosting.
