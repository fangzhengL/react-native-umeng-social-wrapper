// @flow
import promisify from 'es6-promisify';
import { Alert, NativeModules } from 'react-native';

const UMengShareManager = NativeModules.ZKUmengSocialWrapper;
const DEFAULT_PLATFORMS = ['SocialPlatformQQ', 'SocialPlatformQzone', 'SocialPlatformSina', 'SocialPlatformWechatSession', 'SocialPlatformWechatTimeLine'];

export type ShareInfoType = {
  mainTitle:string,
  subTitle:string,
  link:string,
  localImagePath?:string,
};

function share (
  args: { info: ShareInfoType, platform: string },
  callback:(error:string, done?:bool) => void) {

  const { info, platform } = args || {};
  if (!info) {
    callback && callback('no data to share');
    return;
  }

  UMengShareManager.addEvent(
    info,
    platform,
    (error, success) => callback && callback(error, success)
  );
}


function shareToSocialNetwork(
  info:ShareInfoType,
  platforms?:Array<string>,
  callback:(error:string, success:boolean) => void) {
  if (!platforms || !platforms.length) {
    platforms = [...DEFAULT_PLATFORMS];
  }

  const doShare = where => () => (
    UMengShareManager.addEvent(info, where, (error, success) => {
      callback && callback(error, success);
    })
  );

  Alert.alert(
    '分享至',
    '',
    platforms
    .map(item => ({ text:UMengShareManager[item], onPress:doShare(item) }))
    .concat({
      text:'取消',
      onPress:() => {
        if (callback) {
          callback('canceled');
        }
      }})
  );
}

const thisArg = UMengShareManager;
export default {
  config: promisify(thisArg.configUMSocialNetworkWithKey, { thisArg }),
  setPlatform: promisify(thisArg.setPlatform, { thisArg }),
  share: promisify(share, null),
  showShare: promisify(shareToSocialNetwork, null);
};
