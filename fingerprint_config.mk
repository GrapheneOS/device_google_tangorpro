# Factory build, use HIDL hal & extension so that we can use Test tool
ifneq ( ,$(findstring factory, $(TARGET_PRODUCT)))
GOOGLE_CONFIG_FP_STATUS=1
FPC_CONFIG_TRUSTY_CLEAN_TA=1
else
# Non factory build, use fingerprint AIDL version
endif
