
# react-native-umeng-social-wrapper

## Getting started

`$ npm install react-native-umeng-social-wrapper --save`

### Mostly automatic installation

`$ react-native link react-native-umeng-social-wrapper`

### Manual installation


#### iOS

1. In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
2. Go to `node_modules` ➜ `react-native-umeng-social-wrapper` and add `ZKUmengSocialWrapper.xcodeproj`
3. In XCode, in the project navigator, select your project. Add `libZKUmengSocialWrapper.a` to your project's `Build Phases` ➜ `Link Binary With Libraries`
4. Run your project (`Cmd+R`)<

#### Android

1. Open up `android/app/src/main/java/[...]/MainActivity.java`
  - Add `import com.umsocial.ZKUmengSocialWrapperPackage;` to the imports at the top of the file
  - Add `new ZKUmengSocialWrapperPackage()` to the list returned by the `getPackages()` method
2. Append the following lines to `android/settings.gradle`:
  	```
  	include ':react-native-umeng-social-wrapper'
  	project(':react-native-umeng-social-wrapper').projectDir = new File(rootProject.projectDir, 	'../node_modules/react-native-umeng-social-wrapper/android')
  	```
3. Insert the following lines inside the dependencies block in `android/app/build.gradle`:
  	```
      compile project(':react-native-umeng-social-wrapper')
  	```

#### Windows
[Read it! :D](https://github.com/ReactWindows/react-native)

1. In Visual Studio add the `ZKUmengSocialWrapper.sln` in `node_modules/react-native-umeng-social-wrapper/windows/ZKUmengSocialWrapper.sln` folder to their solution, reference from their app.
2. Open up your `MainPage.cs` app
  - Add `using Cl.Json.ZKUmengSocialWrapper;` to the usings at the top of the file
  - Add `new ZKUmengSocialWrapperPackage()` to the `List<IReactPackage>` returned by the `Packages` method


## Usage
```javascript
import ZKUmengSocialWrapper from 'react-native-umeng-social-wrapper';

// TODO: What do with the module?
ZKUmengSocialWrapper;
```
  
