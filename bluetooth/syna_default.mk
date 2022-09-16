
#
# Copyright (C) 2022 The Android Open-Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Bluetooth HAL and Pixel extension
DEVICE_MANIFEST_FILE += \
       device/google/tangorpro/bluetooth/manifest_bluetooth.xml
DEVICE_PRODUCT_COMPATIBILITY_MATRIX_FILE += device/google/tangorpro/bluetooth/device_framework_matrix_product.xml
BOARD_SEPOLICY_DIRS += device/google/tangorpro-sepolicy/bluetooth
PRODUCT_PACKAGES += android.hardware.bluetooth@1.1-service.synabtlinux \
        android.hardware.bluetooth.prebuilt.xml \
        android.hardware.bluetooth_le.prebuilt.xml

# Bluetooth SAR test tools
PRODUCT_PACKAGES_DEBUG += bluetooth_sar_test
# default BDADDR for EVB only
PRODUCT_PROPERTY_OVERRIDES += \
       ro.vendor.bluetooth.evb_bdaddr="22:22:22:33:44:55"
PRODUCT_PROPERTY_OVERRIDES += \
    ro.bluetooth.a2dp_offload.supported=true \
    persist.bluetooth.a2dp_offload.disabled=false \
    persist.bluetooth.a2dp_offload.cap=sbc-aac-aptx-aptxhd-ldac
PRODUCT_PRODUCT_PROPERTIES += \
    persist.bluetooth.uart.port="/dev/ttySAC18" \
    persist.bluetooth.firmware.selection="BTFW.hcd"
