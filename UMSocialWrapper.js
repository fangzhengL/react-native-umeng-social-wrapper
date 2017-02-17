// @flow
import promisify from 'es6-promisify';
import { NativeModules } from 'react-native';

const thisArg = NativeModules.ZKUmengSocialWrapper;
export default {
  config: promisify(thisArg.configUMSocialNetworkWithKey, { thisArg }),
  setPlatform: promisify(thisArg.setPlatform, { thisArg }),
};

