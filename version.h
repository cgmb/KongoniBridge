#pragma once

#include <stdint.h>

struct Version {
  uint8_t major;
  uint8_t minor;
  uint8_t patch;
  uint8_t build;
};

inline bool operator<(const Version& lhs, const Version& rhs) {
  if (lhs.major < rhs.major) {
    return true;
  } else if (lhs.major == rhs.major) {
    if (lhs.minor < rhs.minor) {
      return true;
    } else if (lhs.minor == rhs.minor) {
      if (lhs.patch < rhs.patch) {
        return true;
      } else if (lhs.patch == rhs.patch) {
        if (lhs.build < rhs.build) {
          return true;
        }
      }
    }
  }
  return false;
}

const Version k_version = { 0, 0, 0, 0 };
