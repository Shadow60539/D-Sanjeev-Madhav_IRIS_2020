
[![support](https://img.shields.io/badge/plateform-flutter%7Candroid%20studio-9cf?style=plastic&logo=appveyor)](https://github.com/Shadow60539/D-Sanjeev-Madhav_IRIS_2020)

# Introduction

> “TODOey”
is a small, simple and beautiful app，
It can help you keep track of your daily plans.
If you happen to have the habit of writing a mission plan, then it must be perfect for you.

Before we start, you can take a look at the app:

![image](images/app.jpg)


### Packages


Some very good packages are used in the project, not a big list.


Below are the information about these packages.


package | explain
---|---
[dio](https://pub.flutter-io.cn/packages/dio) | network request
[shared_preferences](https://pub.flutter-io.cn/packages/shared_preferences) | local storage
[provider](https://pub.flutter-io.cn/packages/provider) | state management
[test](https://pub.flutter-io.cn/packages/test) | unit test
[carousel_slider](https://pub.flutter-io.cn/packages/carousel_slider) | slide control
[circle_list](https://pub.flutter-io.cn/packages/circle_list) | circle list
[intl](https://pub.flutter-io.cn/packages/intl) | change language 
[sqflite](https://pub.flutter-io.cn/packages/sqflite) | sqlite database
[flutter_colorpicker](https://pub.flutter-io.cn/packages/flutter_colorpicker) | color picker
[cached_network_image](https://pub.flutter-io.cn/packages/cached_network_image) | image cache
[image_picker](https://pub.flutter-io.cn/packages/image_picker) | image picker
[permission_handler](https://pub.flutter-io.cn/packages/permission_handler) | request for permissions
[path_provider](https://pub.flutter-io.cn/packages/path_provider) | get path
[image_crop](https://pub.flutter-io.cn/packages/image_crop) | image crop
[flutter_svg](https://pub.flutter-io.cn/packages/flutter_svg) | svg pictures
[package_info](https://pub.flutter-io.cn/packages/package_info) | get package info
[flutter_webview_plugin](https://pub.flutter-io.cn/packages/flutter_webview_plugin) | webview
[pull_to_refresh](https://pub.flutter-io.cn/packages/pull_to_refresh) | pull to refresh data
[photo_view](https://pub.flutter-io.cn/packages/photo_view) | show the picture
[url_launcher](https://pub.flutter-io.cn/packages/url_launcher) | open app store
[open_file](https://pub.flutter-io.cn/packages/open_file) | open apk file
[flare_flutter](https://pub.flutter-io.cn/packages/flare_flutter) | flare animation
[encrypt](https://pub.flutter-io.cn/packages/encrypt) | encrypt password
[flutter_staggered_animations](https://pub.flutter-io.cn/packages/flutter_staggered_animations) | listview animation


### Directory Structure

The project directory structure is as follows:

```
├── android
├── assets
├── fonts
├── build
├── images
├── ios
├── lib
├── test
├── pubspec.lock
├── pubspec.yaml

```


Let me explain the other directories besides **lib**:

directory | explain
---|---
images | For storing various pictures
fonts | custom fonts
assets | sound (.wav) files

Then the lib directory


![image](images/lib.png)



directory | explain
---|---
model | Model layer directory for task_model
provider | Provider State Management (I could have used _bloc but I'm familiar with providers)
utils | Custom calendar created by me


