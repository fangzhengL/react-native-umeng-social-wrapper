using ReactNative.Bridge;
using System;
using System.Collections.Generic;
using Windows.ApplicationModel.Core;
using Windows.UI.Core;

namespace Com.Reactlibrary.ZKUmengSocialWrapper
{
    /// <summary>
    /// A module that allows JS to share data.
    /// </summary>
    class ZKUmengSocialWrapperModule : NativeModuleBase
    {
        /// <summary>
        /// Instantiates the <see cref="ZKUmengSocialWrapperModule"/>.
        /// </summary>
        internal ZKUmengSocialWrapperModule()
        {

        }

        /// <summary>
        /// The name of the native module.
        /// </summary>
        public override string Name
        {
            get
            {
                return "ZKUmengSocialWrapper";
            }
        }
    }
}
