// @flow
import promisify from 'es6-promisify';
import {
  NativeModules,
  Alert,
} from 'react-native';

const UMengShareManager = NativeModules.ZKUmengSocialWrapper;

export type ShareInfoType = {
  mainTitle:string,
  subTitle:string,
  link:string,
  localImagePath?:string,
};

function shareToSocialNetwork(
  info:ShareInfoType,
  platforms?:[string],
  callback:(error:string, success:boolean) => void) {
  if (!platforms || !platforms.length) {
    platforms = [/* 'SocialPlatformQQ', 'SocialPlatformQzone', 'SocialPlatformSina'*/'SocialPlatformWechatSession', 'SocialPlatformWechatTimeLine'];
  }
  const doShare = where => () => (
    UMengShareManager.addEvent(info, where, (error, success) => {
      callback && callback(error, success);
    })
  );
  Alert.alert(
    '分享至',
    '',
    platforms.map(item => ({ text:UMengShareManager[item], onPress:doShare(item) })).concat({ text:'取消', onPress:() => {} })
  );
}

const thisArg = UMengShareManager;
export default {
  config: promisify(thisArg.configUMSocialNetworkWithKey, { thisArg }),
  setPlatform: promisify(thisArg.setPlatform, { thisArg }),
  shareToSocialNetwork,
};

