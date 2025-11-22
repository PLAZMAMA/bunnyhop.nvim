# Changelog

## [0.8.0](https://github.com/PLAZMAMA/bunnyhop.nvim/compare/v0.7.0...v0.8.0) (2025-11-22)


### Features

* add data collection toggle option ([c7033ca](https://github.com/PLAZMAMA/bunnyhop.nvim/commit/c7033cad7141fa0ecaad5b503d957c2bdab0b2a1))
* collect prompt for future debugging and (potentially) model training ([37a6d3d](https://github.com/PLAZMAMA/bunnyhop.nvim/commit/37a6d3d09526244b062eb2b480499619f686b315))
* handle data extraction from prompt more robustly ([62f5d1c](https://github.com/PLAZMAMA/bunnyhop.nvim/commit/62f5d1cd3d5574867906caa427d4034494b42259))


### Bug Fixes

* add model key value pair ([3b41783](https://github.com/PLAZMAMA/bunnyhop.nvim/commit/3b41783b50658013292716030a03f33e3cfdd8db))
* fix json prediction assignment code ([6042ce0](https://github.com/PLAZMAMA/bunnyhop.nvim/commit/6042ce099f3fc6d32ae13f0b9ed72f5f21da4297))
* wrap latest_edit in a list when passing to append ([f477eac](https://github.com/PLAZMAMA/bunnyhop.nvim/commit/f477eac4b86b435a237dc56a9aa8baf72ae4ec09))

## [0.7.0](https://github.com/PLAZMAMA/bunnyhop.nvim/compare/v0.6.0...v0.7.0) (2025-03-03)


### Features

* add data collection ([84f4e82](https://github.com/PLAZMAMA/bunnyhop.nvim/commit/84f4e82e590c1cb7f8cdbabaf1a427f6d516d110))
* add o3-mini model to Copilot ([faccbe8](https://github.com/PLAZMAMA/bunnyhop.nvim/commit/faccbe8d06d2c2bf961b882ec7dc998f15940091))

### Bug Fixes

* correct prediction.line assignment ([48975eb](https://github.com/PLAZMAMA/bunnyhop.nvim/commit/48975ebf456b03210e3aa6eb2211e2b000337a59))
* don't modify given prediction argument ([4a3a7ed](https://github.com/PLAZMAMA/bunnyhop.nvim/commit/4a3a7ed6d3e8fe7bd804d285b0cb660e07bf584d))
* fix copilot expiration error ([87f2bac](https://github.com/PLAZMAMA/bunnyhop.nvim/commit/87f2bac8c8ece9963133518f0ae8cb76a9c1c8e5))
* fix linter checks ([887adfa](https://github.com/PLAZMAMA/bunnyhop.nvim/commit/887adfab69317843e64a310263bd45258a1eeac8))
* make process_api_key adhear to the spec ([7423c58](https://github.com/PLAZMAMA/bunnyhop.nvim/commit/7423c584dbb465ba132f982084fad79cf1f775e2))
* only get editlist of valid files ([cf5b78a](https://github.com/PLAZMAMA/bunnyhop.nvim/commit/cf5b78a4db69b61b5f8a1cee8da2948536f2b791))
* prepend "_" to bhop_adapter ([d0bed47](https://github.com/PLAZMAMA/bunnyhop.nvim/commit/d0bed4771bf0b4d54e9b2547e36d683e3e6a6414))
* reduce expiration time from 5 to 2 minutes ([ac6c353](https://github.com/PLAZMAMA/bunnyhop.nvim/commit/ac6c353a6b21c90d305bad05ace7537e982afdbe))
* remove api_key arg for authorize_token callback ([a8e4d20](https://github.com/PLAZMAMA/bunnyhop.nvim/commit/a8e4d207f664111b659a719f7eeff6d580b21d28))
* remove extra space in preview window opening line ([60c9e4f](https://github.com/PLAZMAMA/bunnyhop.nvim/commit/60c9e4f5b7558553e346edce443cd0b837de7d61))
* temporarly account for a nil _editlists entry ([22f5bcf](https://github.com/PLAZMAMA/bunnyhop.nvim/commit/22f5bcf74b31f956353eb910460a4c52a613baf9))

## [0.6.0](https://github.com/PLAZMAMA/bunnyhop.nvim/compare/v0.5.1...v0.6.0) (2025-01-26)


### Features

* add column focus in preview window ([8c3baa9](https://github.com/PLAZMAMA/bunnyhop.nvim/commit/8c3baa9787ace3effb0ffbea2531faf6de5ead2b))


### Bug Fixes

* fix highlight alignment ([baada08](https://github.com/PLAZMAMA/bunnyhop.nvim/commit/baada08f0d315ed4c7a742477d4be9be420ffe41))
* fix highlight missalignment ([dc3576d](https://github.com/PLAZMAMA/bunnyhop.nvim/commit/dc3576de7b4d9664044a651bcbc27c31aea1ca71))
* fix invalid buf check ([d9fd158](https://github.com/PLAZMAMA/bunnyhop.nvim/commit/d9fd158d745931db209a9275b94b0c245c1f3686))
* fix predicted column clipping ([a285bb3](https://github.com/PLAZMAMA/bunnyhop.nvim/commit/a285bb31a31b209eee4eebcc13f4f20633f84d05))
* reduce estimated expiration time by half ([0bbd1c8](https://github.com/PLAZMAMA/bunnyhop.nvim/commit/0bbd1c8a2d18db80bcc03cb4f4f12ac683a974de))
* reduce expiration time estimate to 5 minutes ([b984733](https://github.com/PLAZMAMA/bunnyhop.nvim/commit/b9847332f9f40dcfb624a22c3d0a90658ec6aedd))
* return -1 on non existant buffer open_preview_win ([1617bcb](https://github.com/PLAZMAMA/bunnyhop.nvim/commit/1617bcb16e9c7e8955deb3b698adbaf91587b91c))

## [0.5.1](https://github.com/PLAZMAMA/bunnyhop.nvim/compare/v0.5.0...v0.5.1) (2025-01-25)


### Bug Fixes

* fix buffer is invalid when going to telescope result ([3f794d7](https://github.com/PLAZMAMA/bunnyhop.nvim/commit/3f794d7bcc4220cc4cab2033756038e6fbc2f787))
* fix copilot expired token error ([2dd8556](https://github.com/PLAZMAMA/bunnyhop.nvim/commit/2dd8556a4b8658f67b2ee9f422d05d1a063a3072))
* handle nil file_content ([ba9bb88](https://github.com/PLAZMAMA/bunnyhop.nvim/commit/ba9bb880ba8260713deb0345fa55b06ee9b8f024))

## [0.5.0](https://github.com/PLAZMAMA/bunnyhop.nvim/compare/v0.4.0...v0.5.0) (2025-01-23)


### Features

* add cache functionaly to copilot verification function ([400fb95](https://github.com/PLAZMAMA/bunnyhop.nvim/commit/400fb95a9eac3cc7d69773769dc9850ae1c90ca9))
* remove jumpts and add files to context ([5464f75](https://github.com/PLAZMAMA/bunnyhop.nvim/commit/5464f753b1ed6655596b82b532b383a9a1ec8b84))


### Bug Fixes

* change environment variable fetching of get_github_token ([4419966](https://github.com/PLAZMAMA/bunnyhop.nvim/commit/4419966a48589f06695c84637cd9c78293d9b8c7))
* correct args in notify call and move notify into schedule ([ea14358](https://github.com/PLAZMAMA/bunnyhop.nvim/commit/ea143584627348a736075e45ff143c7ea86571cd))
* fix callback being called twice in authorize_token ([d14c6fd](https://github.com/PLAZMAMA/bunnyhop.nvim/commit/d14c6fd3cdc4d14b0d83dc1d59c1467c1d1f1ad6))
* fix linter errors ([8494e9a](https://github.com/PLAZMAMA/bunnyhop.nvim/commit/8494e9aa02896a3f8b16190783461c57055993d2))
* remove api_key assignment ([569a720](https://github.com/PLAZMAMA/bunnyhop.nvim/commit/569a720035f50879c25126b7e1508f5c91a2c730))
* remove persistant "Authorizing GitHub Copilot token" notification ([fff3f8a](https://github.com/PLAZMAMA/bunnyhop.nvim/commit/fff3f8ad540f11f77181808f1499f33f54fc13e9))
* remove unnecessary github token fetch in complete ([cfb9ef4](https://github.com/PLAZMAMA/bunnyhop.nvim/commit/cfb9ef4ff14f995c1a714963ca1c328a9a184ee6))
* stale/persistent window during rapid prediction ([da851e0](https://github.com/PLAZMAMA/bunnyhop.nvim/commit/da851e042aeac1a76656c3becd064a794ac113a2))

## [0.4.0](https://github.com/PLAZMAMA/bunnyhop.nvim/compare/v0.3.1...v0.4.0) (2025-01-18)


### Features

* add copilot adapter ([8f56a1a](https://github.com/PLAZMAMA/bunnyhop.nvim/commit/8f56a1ad794a0b59dad77c676a3f2574667514a1))
* add process_api_key to copilot adapter ([2da9e12](https://github.com/PLAZMAMA/bunnyhop.nvim/commit/2da9e1266e2f75fd853ea96c2d53bb57202e72a9))
* add rest of currently available copilot models ([256c9d4](https://github.com/PLAZMAMA/bunnyhop.nvim/commit/256c9d463069702feaebfbf59376decbcdf128c8))


### Bug Fixes

* add early return if api_key was successfully found ([d01dd90](https://github.com/PLAZMAMA/bunnyhop.nvim/commit/d01dd90037af7b1e3357c5c6c57b9a99342b8c63))
* fix linter errors and add TODO ([42c2c77](https://github.com/PLAZMAMA/bunnyhop.nvim/commit/42c2c77ed871f72a3ee96f4fb5e931e2a390e578))
* fix linter warnings ([694a395](https://github.com/PLAZMAMA/bunnyhop.nvim/commit/694a395151080e537e5ecfd386d22587abc9319d))

## [0.3.1](https://github.com/PLAZMAMA/bunnyhop.nvim/compare/v0.3.0...v0.3.1) (2025-01-16)


### Bug Fixes

* fix adapters require statement ([5d4d646](https://github.com/PLAZMAMA/bunnyhop.nvim/commit/5d4d646358e154405172f2455863ea650b25411a))
* remove spelling check to the CHANGELOG.md file ([fcf7b63](https://github.com/PLAZMAMA/bunnyhop.nvim/commit/fcf7b63a015493154b9987b9c29851437787c323))

## [0.3.0](https://github.com/PLAZMAMA/bunnyhop.nvim/compare/v0.2.0...v0.3.0) (2025-01-15)


### Features

* update default model and prompt ([d7bbb68](https://github.com/PLAZMAMA/bunnyhop.nvim/commit/d7bbb686a82ca60c1bff6cd2bd92318dabd2feed))


### Bug Fixes

* fix "unused variable" linter error ([b64799d](https://github.com/PLAZMAMA/bunnyhop.nvim/commit/b64799db00e55d1dd336ee39fd86f65b2e0a3219))
* fix get_models function ([5cf438a](https://github.com/PLAZMAMA/bunnyhop.nvim/commit/5cf438a6c34ba5c46a5c12f6297346e37be23c8f))
