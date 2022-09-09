#
# Copyright (C) 2021 The Android Open-Source Project
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

TARGET_KERNEL_DIR ?= device/google/tangorpro-kernel
TARGET_BOARD_KERNEL_HEADERS := device/google/tangorpro-kernel/kernel-headers
TARGET_RECOVERY_DEFAULT_ROTATION := ROTATION_LEFT

BOARD_WITHOUT_RADIO := true

$(call inherit-product-if-exists, vendor/google_devices/tangorpro/prebuilts/device-vendor-tangorpro.mk)
$(call inherit-product-if-exists, vendor/google_devices/gs201/prebuilts/device-vendor.mk)
$(call inherit-product-if-exists, vendor/google_devices/gs201/proprietary/device-vendor.mk)
$(call inherit-product-if-exists, vendor/google_devices/tangorpro/proprietary/tangorpro/device-vendor-tangorpro.mk)

DEVICE_PACKAGE_OVERLAYS += device/google/tangorpro/tangorpro/overlay
PRODUCT_SOONG_NAMESPACES += device/google/tangorpro
PRODUCT_PACKAGES += WifiOverlayT6pro

# Disable camera flash and autofocus related xml with a disable flag.
# This flag need to be set before device/google/gs201/device.mk
DISABLE_CAMERA_FS_AF := true

# Disable baro, prox, hifi sensor related xml with a disable flag.
DISABLE_SENSOR_BARO_PROX_HIFI := true

# Identify the device type.
# This flag need to be set before device/google/gs201/device.mk
# to have tablet COD setting
USE_TABLET_BT_COD := true

include device/google/tangorpro/audio/tangorpro/audio-tables.mk
include device/google/gs201/device-shipping-common.mk

$(call soong_config_set,lyric,tuning_product,cloudripper)
$(call soong_config_set,google3a_config,target_device,cloudripper)

ifeq ($(filter factory_tangorpro, $(TARGET_PRODUCT)),)
include device/google/tangorpro/uwb/uwb_calibration.mk
endif

# Touch files
PRODUCT_COPY_FILES += \
        device/google/tangorpro/NVTCapacitiveTouchScreen.idc:$(TARGET_COPY_OUT_VENDOR)/usr/idc/NVTCapacitiveTouchScreen.idc \
        device/google/tangorpro/NVTCapacitivePen.idc:$(TARGET_COPY_OUT_VENDOR)/usr/idc/NVTCapacitivePen.idc

# Init files
PRODUCT_COPY_FILES += \
	device/google/tangorpro/conf/init.tangorpro.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.tangorpro.rc

# Recovery files
PRODUCT_COPY_FILES += \
        device/google/tangorpro/conf/init.recovery.device.rc:$(TARGET_COPY_OUT_RECOVERY)/root/init.recovery.tangorpro.rc

# insmod files
PRODUCT_COPY_FILES += \
	device/google/tangorpro/init.insmod.tangorpro.cfg:$(TARGET_COPY_OUT_VENDOR)/etc/init.insmod.tangorpro.cfg

# Camera
PRODUCT_COPY_FILES += \
	device/google/tangorpro/media_profiles_tangorpro.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_profiles_V1_0.xml

# Thermal Config
PRODUCT_COPY_FILES += \
	device/google/tangorpro/thermal_info_config_tangorpro.json:$(TARGET_COPY_OUT_VENDOR)/etc/thermal_info_config.json \
	device/google/tangorpro/thermal_info_config_charge_tangorpro.json:$(TARGET_COPY_OUT_VENDOR)/etc/thermal_info_config_charge.json \

# Power HAL config
PRODUCT_COPY_FILES += \
	device/google/tangorpro/powerhint.json:$(TARGET_COPY_OUT_VENDOR)/etc/powerhint.json

# PowerStats HAL
PRODUCT_SOONG_NAMESPACES += device/google/tangorpro/powerstats

# Bluetooth HAL and Pixel extension
include device/google/tangorpro/bluetooth/syna_default.mk

# Keymaster HAL
#LOCAL_KEYMASTER_PRODUCT_PACKAGE ?= android.hardware.keymaster@4.1-service

# Gatekeeper HAL
#LOCAL_GATEKEEPER_PRODUCT_PACKAGE ?= android.hardware.gatekeeper@1.0-service.software


# Gatekeeper
# PRODUCT_PACKAGES += \
# 	android.hardware.gatekeeper@1.0-service.software

# Keymint replaces Keymaster
# PRODUCT_PACKAGES += \
# 	android.hardware.security.keymint-service

# Keymaster
#PRODUCT_PACKAGES += \
#	android.hardware.keymaster@4.0-impl \
#	android.hardware.keymaster@4.0-service

#PRODUCT_PACKAGES += android.hardware.keymaster@4.0-service.remote
#PRODUCT_PACKAGES += android.hardware.keymaster@4.1-service.remote
#LOCAL_KEYMASTER_PRODUCT_PACKAGE := android.hardware.keymaster@4.1-service
#LOCAL_KEYMASTER_PRODUCT_PACKAGE ?= android.hardware.keymaster@4.1-service

# PRODUCT_PROPERTY_OVERRIDES += \
# 	ro.hardware.keystore_desede=true \
# 	ro.hardware.keystore=software \
# 	ro.hardware.gatekeeper=software

# Fingerprint
include device/google/gs101/fingerprint/fpc1540/sw42/fpc1540.mk
FPC_MODULE_TYPE=1542_S
$(call soong_config_set,fp_hal_feature,pixel_product, product_b)
# Fingerprint config
include device/google/tangorpro/fingerprint_config.mk

# Trusty liboemcrypto.so
PRODUCT_SOONG_NAMESPACES += vendor/google_devices/tangorpro/prebuilts

# DCK properties based on target
PRODUCT_PROPERTY_OVERRIDES += \
    ro.gms.dck.eligible_wcc=2

# Wifi SAP Interface Name
PRODUCT_PROPERTY_OVERRIDES += \
    ro.vendor.wifi.sap.interface=wlan1

# Set ro.crypto.metadata_init_delete_all_keys.enabled to false to unblock boot
PRODUCT_PROPERTY_OVERRIDES += ro.crypto.metadata_init_delete_all_keys.enabled=false

# Enable Telecom feature
# b/227692870
PRODUCT_COPY_FILES += \
	frameworks/native/data/etc/android.software.telecom.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.telecom.xml

# Trusty libbinder_trusty_paidl.so and libcast_auth.so
PRODUCT_SOONG_NAMESPACES += \
        vendor/google/trusty/common

# Cast auth
PRODUCT_COPY_FILES += \
        device/google/tangorpro/cast_auth/tangor_ica.crt:$(TARGET_COPY_OUT_VENDOR)/etc/cert-chain.crt

PRODUCT_PACKAGES_DEBUG += \
        test_cast_auth

# USI stylus test tool
PRODUCT_PACKAGES_DEBUG += \
        usi_test

# Lights HAL
PRODUCT_PACKAGES += \
    android.hardware.lights-service.tangorpro

# Device features
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/tablet_core_hardware.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/tablet_core_hardware.xml

# Display LBE
PRODUCT_DEFAULT_PROPERTY_OVERRIDES += vendor.display.lbe.supported=1

# Enable adpf cpu hint session for SurfaceFlinger
PRODUCT_DEFAULT_PROPERTY_OVERRIDES += \
    debug.sf.enable_adpf_cpu_hint=true
