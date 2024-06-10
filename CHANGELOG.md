# Changelog

All notable changes to `Deploy to Remote Repository Action` will be documented in this file.

## 2.1.0 - 2024-06-10

- Added support for deploying to AWS CodeCommit repositories via the `codecommit://` protocol and AWS Access Key credentials.

## 2.0.0 - 2024-05-10

- Potential **breaking change**: extends [Pantheon Mode](/README.md#pantheon-mode) to automatically add `mu-plugins/pantheon-mu-plugin` to the [exclude list](/README.md#exclude_list) to prevent common deployment errors related to this directory.

## 1.1.0 - 2023-07-12

- Adds support for copying the `private` folder to the root in Pantheon deploys.

## 1.0.0 - 2023-07-10

- Initial release
