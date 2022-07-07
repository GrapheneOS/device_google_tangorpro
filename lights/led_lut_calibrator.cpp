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

#include "led_lut_calibrator.h"

#include <android-base/logging.h>
#include <fcntl.h>

#include <iostream>
#include <sstream>

const char kCalibrationPath[] = "/mnt/vendor/persist/led/led_calibration_LUT.txt";

LedLutCalibrator::LedLutCalibrator() {
    if (!ReadCalibrationTable()) {
        LOG(ERROR) << "Failed to read calibration table";
        cal_table_.clear();
    }
}

int LedLutCalibrator::GetByColorIntensity(const std::string &color, int intensity) const {
    std::string key = MakeLutKey(color, intensity);
    const auto cal_data = cal_table_.find(key);

    if (cal_data == cal_table_.end()) {
        LOG(ERROR) << "Failed to get calibration data";
        return -1;
    }

    return cal_data->second;
}

bool LedLutCalibrator::ReadCalibrationTable() {
    int fd;
    int bytes;
    bool ret = true;
    std::vector<uint8_t> buffer;
    buffer.resize(512);

    fd = open(kCalibrationPath, O_RDONLY);
    if (fd < 0) {
        LOG(ERROR) << "Failed to open " << kCalibrationPath;
        ret = false;
        goto ReadCalibrationTable_err;
    }

    bytes = read(fd, buffer.data(), buffer.size());
    if (bytes == -1) {
        LOG(ERROR) << "Failed to read " << kCalibrationPath;
        ret = false;
        goto ReadCalibrationTable_err;
    }

    if (!ParseBlock(&buffer)) {
        LOG(ERROR) << "Failed to parse calibration table ";
        ret = false;
        goto ReadCalibrationTable_err;
    }

ReadCalibrationTable_err:
    if (fd != -1)
        close(fd);

    return ret;
}

bool LedLutCalibrator::ParseBlock(const std::vector<uint8_t> *table) {
    std::string str(table->begin(), table->end());
    auto result = std::vector<std::string>{};
    auto ss = std::stringstream{str};

    for (std::string line; std::getline(ss, line, '\n');) {
        size_t start;
        size_t end = 0;
        std::vector<std::string> colon_separated;
        while ((start = line.find_first_not_of(':', end)) != std::string::npos) {
            end = line.find(':', start);
            if (end == std::string::npos) {
                end = line.size();
            }
            colon_separated.push_back(line.substr(start, end - start));
        }
        if (colon_separated.size() != 3) {
            continue;
        }
        std::string color_name = colon_separated[0];
        uint16_t intensity = atoi(colon_separated[1].c_str());
        uint16_t pwm = atoi(colon_separated[2].c_str());
        std::cout << color_name << intensity << pwm << std::endl;
        std::string key = MakeLutKey(color_name, intensity);
        cal_table_[key] = pwm;
    }

    return true;
}

std::string LedLutCalibrator::MakeLutKey(const std::string &color, int intensity) const {
    std::string intensity_str = std::to_string(intensity);
    std::string terms{color};

    terms.append(intensity_str);

    return terms;
}
