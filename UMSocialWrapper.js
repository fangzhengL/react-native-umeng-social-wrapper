// @flow
import promisify from 'es6-promisify';
import React from 'react';
import {
  NativeModules,
  Alert,
  View,
  Text,
  Image,
  TouchableHighlight,
  TouchableWithoutFeedback,
  PixelRatio,
} from 'react-native';
import { AnimatedAlertContainer } from 'zhike-mobile-components';
const UMengShareManager = NativeModules.ZKUmengSocialWrapper;
const WECHAT_SESSION = require('./img/ic-wechat-session.png');
const WECHAT_TIMELINE = require('./img/ic-wechat-timeline.png');

const DEFAULT_PLATFORM_ICONS = [WECHAT_SESSION, WECHAT_TIMELINE];
const DEFAULT_PLATFORMS = [/* 'SocialPlatformQQ', 'SocialPlatformQzone', 'SocialPlatformSina'*/'SocialPlatformWechatSession', 'SocialPlatformWechatTimeLine'];

export type ShareInfoType = {
  mainTitle:string,
  subTitle:string,
  link:string,
  localImagePath?:string,
};

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
    platforms.map(item => ({ text:UMengShareManager[item], onPress:doShare(item) })).concat({ text:'取消', onPress:() => {} })
  );
}

function share (
  args: { info:ShareInfoType, showAlert:(components:any) => void, hideAlert:() => void, platforms?:Array<string>, icons?:Array<number> },
  callback:(error:string, done?:bool) => void) {

  const { info, platforms=[...DEFAULT_PLATFORMS], icons=[...DEFAULT_PLATFORM_ICONS], showAlert, hideAlert } = args || {};
  if (!info) {
    callback && callback('no data to share');
    return;
  }

  let animatedContainer = null;

  showAlert(
    <AnimatedAlertContainer
      ref={ref => (animatedContainer = ref)}
      onHide={(onDidHide) => {
        hideAlert();
        if (!onDidHide) {
          callback && callback('canceled');
        } else {
          onDidHide();
        }
      }}
    >
      <View
        style={{ height:132, alignSelf:'stretch', alignItems:'center', backgroundColor:'#ffffff' }}
      >
        <TouchableWithoutFeedback
          onPress={() => null}
        >
          <View
            style={{ flex:1, alignSelf:'stretch', flexDirection:'row', alignItems:'center', justifyContent:'space-around' }}
          >
            {
              icons.map((item, ii) => (
                <TouchableHighlight
                  key={`key-${ii}`} 
                  underlayColor={'#f9fafa'}
                  onPress={() => {
                    animatedContainer && animatedContainer.hide(() => null);
                    UMengShareManager.addEvent(
                      info,
                      platforms[ii],
                      (error, success) => callback && callback(error, success)
                    );
                  }}
                >
                  <Image source={item} />
                </TouchableHighlight>
              ))
            }
          </View>
        </TouchableWithoutFeedback>
        <TouchableHighlight
          style={{ height:45, alignSelf:'stretch', borderTopColor:'#eaeff2', borderTopWidth:1.0 / PixelRatio.get() }}
          underlayColor={'#f9fafa'}
          onPress={() => {
            if (animatedContainer) {
              animatedContainer.hide();
            } else {
              hideAlert();
              callback && callback('canceled');
            }
          }}
        >
          <View
            style={{ flex:1, alignSelf:'stretch', alignItems:'center', justifyContent:'center' }}
          >
            <Text style={{ fontSize:14, color:'#ff4242' }} >取消</Text>
          </View>
        </TouchableHighlight>
      </View>
    </AnimatedAlertContainer>
  );
}

const thisArg = UMengShareManager;
export default {
  config: promisify(thisArg.configUMSocialNetworkWithKey, { thisArg }),
  setPlatform: promisify(thisArg.setPlatform, { thisArg }),
  shareToSocialNetwork,
  share: promisify(share, null),
};

