/*
 * Copyright (C) 2022 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include <aidl/android/hardware/light/BnLights.h>
#include <android-base/logging.h>
#include <android/binder_manager.h>
#include <android/binder_process.h>
#include <fcntl.h>

#include "led_lut_calibrator.h"

using ::aidl::android::hardware::light::BnLights;
using ::aidl::android::hardware::light::HwLight;
using ::aidl::android::hardware::light::HwLightState;
using ::aidl::android::hardware::light::ILights;
using ::aidl::android::hardware::light::LightType;
using ::ndk::ScopedAStatus;
using ::ndk::SharedRefBase;

static pthread_mutex_t g_lock = PTHREAD_MUTEX_INITIALIZER;

char const *const GREEN_LED_FILE = "/sys/class/leds/green/brightness";

enum { ARGB_ON_IN_DAY = 0x0000ff00, ARGB_ON_IN_NIGHT = 0x00008000, ARGB_OFF = 0x00000000 };
enum { DAY = 4095, NIGHT = 0 };

static int sys_write_int(int fd, int value) {
    char buffer[16];
    size_t bytes;
    ssize_t amount;

    bytes = snprintf(buffer, sizeof(buffer), "%d\n", value);
    if (bytes >= sizeof(buffer)) {
        return -EINVAL;
    }
    amount = write(fd, buffer, bytes);

    return amount == -1 ? -errno : 0;
}

class Lights : public BnLights {
  private:
    std::vector<HwLight> availableLights;
    LedLutCalibrator calibrator;

    void addLight(LightType const type, int const ordinal) {
        HwLight light{};
        light.id = availableLights.size();
        light.type = type;
        light.ordinal = ordinal;
        availableLights.emplace_back(light);
    }

    void writeLed(const char *path, int color) {
        int fd = open(path, O_WRONLY);
        if (fd < 0) {
            LOG(ERROR) << "Failed to open LED device " << path << strerror(errno);
            return;
        }
        sys_write_int(fd, color);
        close(fd);
    }

  public:
    Lights() : BnLights() {
        pthread_mutex_init(&g_lock, NULL);

        addLight(LightType::BACKLIGHT, 0);
        addLight(LightType::KEYBOARD, 0);
        addLight(LightType::BUTTONS, 0);
        addLight(LightType::BATTERY, 0);
        addLight(LightType::NOTIFICATIONS, 0);
        addLight(LightType::ATTENTION, 0);
        addLight(LightType::BLUETOOTH, 0);
        addLight(LightType::WIFI, 0);
        addLight(LightType::MICROPHONE, 0);
        addLight(LightType::CAMERA, 0);
    }

    ScopedAStatus setLightState(int id, const HwLightState &state) override {
        if (!(0 <= id && id < availableLights.size())) {
            LOG(ERROR) << "Light id " << (int32_t)id << " does not exist.";
            return ScopedAStatus::fromExceptionCode(EX_UNSUPPORTED_OPERATION);
        }

        HwLight const &light = availableLights[id];
        int cal_color = 0;
        switch (light.type) {
            case LightType::CAMERA:
                if (state.color == ARGB_ON_IN_DAY) {
                    cal_color = calibrator.GetByColorIntensity("green", DAY);
                } else if (state.color == ARGB_ON_IN_NIGHT) {
                    cal_color = calibrator.GetByColorIntensity("green", NIGHT);
                } else if (state.color == ARGB_OFF) {
                    cal_color = 0;
                } else {
                    goto setLightState_end;
                }
                if (cal_color < 0) {
                    goto setLightState_end;
                }
                pthread_mutex_lock(&g_lock);
                writeLed(GREEN_LED_FILE, cal_color);
                pthread_mutex_unlock(&g_lock);
                break;
            default:
                break;
        }

    setLightState_end:
        return ScopedAStatus::ok();
    }

    ScopedAStatus getLights(std::vector<HwLight> *lights) override {
        for (auto i = availableLights.begin(); i != availableLights.end(); i++) {
            lights->push_back(*i);
        }

        return ScopedAStatus::ok();
    }
};

int main() {
    ABinderProcess_setThreadPoolMaxThreadCount(0);

    std::shared_ptr<Lights> light = SharedRefBase::make<Lights>();

    const std::string instance = std::string() + ILights::descriptor + "/default";
    binder_status_t status = AServiceManager_addService(light->asBinder().get(), instance.c_str());

    if (status != STATUS_OK) {
        LOG(ERROR) << "Failed to register" << instance;
    }

    ABinderProcess_joinThreadPool();

    return -1;  // should not reach
}
