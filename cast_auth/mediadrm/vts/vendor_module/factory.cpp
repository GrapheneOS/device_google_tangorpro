#include "drm_hal_vendor_module_api.h"
#include "vts_module.h"

namespace castkey_vts {
    extern "C" {
        DrmHalVTSVendorModule *vendorModuleFactory() {
            return new CastkeyVTSVendorModule_V1();
        }
    };
}; // namespace castkey_vts
