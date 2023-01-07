
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
BOARD_SEPOLICY_DIRS += device/google/tangorpro-sepolicy/bluetooth
PRODUCT_PACKAGES += android.hardware.bluetooth@1.1-service.synabtlinux
# Bluetooth SAR test tools
PRODUCT_PACKAGES_DEBUG += bt_sar_test

# Bluetooth Tx power caps
PRODUCT_COPY_FILES += \
    device/google/tangorpro/bluetooth/bluetooth_power_limits_tangorpro.csv:$(TARGET_COPY_OUT_VENDOR)/etc/bluetooth_power_limits.csv \
    device/google/tangorpro/bluetooth/bluetooth_power_limits_tangorpro_GTU8P_CA.csv:$(TARGET_COPY_OUT_VENDOR)/etc/bluetooth_power_limits_GTU8P_CA.csv \
    device/google/tangorpro/bluetooth/bluetooth_power_limits_tangorpro_GTU8P_EU.csv:$(TARGET_COPY_OUT_VENDOR)/etc/bluetooth_power_limits_GTU8P_EU.csv \
    device/google/tangorpro/bluetooth/bluetooth_power_limits_tangorpro_GTU8P_JP.csv:$(TARGET_COPY_OUT_VENDOR)/etc/bluetooth_power_limits_GTU8P_JP.csv \
    device/google/tangorpro/bluetooth/bluetooth_power_limits_tangorpro_GTU8P_US.csv:$(TARGET_COPY_OUT_VENDOR)/etc/bluetooth_power_limits_GTU8P_US.csv \

# default BDADDR for EVB only
PRODUCT_PROPERTY_OVERRIDES += \
       ro.vendor.bluetooth.evb_bdaddr="22:22:22:33:44:55"
PRODUCT_PROPERTY_OVERRIDES += \
    ro.bluetooth.a2dp_offload.supported=true \
    persist.bluetooth.a2dp_offload.disabled=false \
    persist.bluetooth.a2dp_offload.cap=sbc-aac-aptx-aptxhd-ldac
PRODUCT_PRODUCT_PROPERTIES += \
    persist.bluetooth.firmware.selection="BTFW.hcd"

# Disable MAP, PBAP and SAP profiles
PRODUCT_PRODUCT_PROPERTIES += \
       bluetooth.profile.map.server.enabled=false \
       bluetooth.profile.pbap.server.enabled=false \
       bluetooth.profile.sap.server.enabled=false \

BLUETOOTH_UART_PORT = /dev/ttySAC18

# Inject soong bluetooth configurations
$(call soong_config_set,bluetooth,bluetooth_uart_port,$(BLUETOOTH_UART_PORT))
