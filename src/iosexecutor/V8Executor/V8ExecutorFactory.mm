/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 * Copyright (c) Kudo Chien.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#include "V8ExecutorFactory.h"

#import <React/RCTLog.h>
#import "../../v8runtime/V8Runtime.h"

namespace jsi = facebook::jsi;
namespace react = facebook::react;

namespace rnv8 {

std::unique_ptr<react::JSExecutor> V8ExecutorFactory::createJSExecutor(
    std::shared_ptr<react::ExecutorDelegate> delegate,
    std::shared_ptr<react::MessageQueueThread> __unused jsQueue)
{
  auto installBindings = [runtimeInstaller = runtimeInstaller_](jsi::Runtime &runtime) {
    react::Logger iosLoggingBinder = [](const std::string &message, unsigned int logLevel) {
      _RCTLogJavaScriptInternal(static_cast<RCTLogLevel>(logLevel), [NSString stringWithUTF8String:message.c_str()]);
    };
    react::bindNativeLogger(runtime, iosLoggingBinder);
    // Wrap over the original runtimeInstaller
    if (runtimeInstaller) {
      runtimeInstaller(runtime);
    }
  };
  return folly::make_unique<JSIExecutor>(
      std::make_shared<V8Runtime>(""), delegate, JSIExecutor::defaultTimeoutInvoker, std::move(installBindings));
}

} // namespace rnv8
