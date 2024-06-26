// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#ifndef OPENTITAN_SW_DEVICE_SILICON_CREATOR_LIB_DRIVERS_IBEX_H_
#define OPENTITAN_SW_DEVICE_SILICON_CREATOR_LIB_DRIVERS_IBEX_H_

#include <stddef.h>
#include <stdint.h>

#include "sw/device/lib/arch/device.h"
#include "sw/device/lib/base/csr.h"
#include "sw/device/lib/base/macros.h"

#ifdef __cplusplus
extern "C" {
#endif

/**
 * Get the FPGA version value from the USR_ACCESS register.
 *
 * @return FPGA version.
 */
OT_WARN_UNUSED_RESULT
uint32_t ibex_fpga_version(void);

#ifdef OT_PLATFORM_RV32
OT_WARN_UNUSED_RESULT
inline uint64_t ibex_mcycle(void) {
  uint32_t lo, hi, hi2;
  do {
    CSR_READ(CSR_REG_MCYCLEH, &hi);
    CSR_READ(CSR_REG_MCYCLE, &lo);
    CSR_READ(CSR_REG_MCYCLEH, &hi2);
  } while (hi != hi2);
  return ((uint64_t)hi << 32) | lo;
}

inline uint64_t ibex_time_to_cycles(uint64_t time_us) {
  return to_cpu_cycles(time_us);
}
#else
extern uint64_t ibex_mcycle(void);
extern uint64_t ibex_time_to_cycles(uint64_t time_us);
#endif

/**
 * The following constants represent the expected number of sec_mmio register
 * writes performed by functions in provided in this module. See
 * `SEC_MMIO_WRITE_INCREMENT()` for more details.
 *
 * Example:
 * ```
 *  ibex_addr_remap_0_set(...);
 *  SEC_MMIO_WRITE_INCREMENT(kAddressTranslationSecMmioConfigure);
 * ```
 */
enum {
  kAddressTranslationSecMmioConfigure = 6,
};

/**
 * Configure the instruction and data bus in the address translation slot 0.
 *
 * @param matching_addr When an incoming transaction matches the matching
 * region, it is redirected to the new address. If a transaction does not match,
 * then it is directly passed through.
 * @param remap_addr  The region where the matched transtaction will be
 * redirected to.
 * @param size The size of the regions mapped.
 */
void ibex_addr_remap_0_set(uint32_t matching_addr, uint32_t remap_addr,
                           size_t size);

/**
 * Configure the instruction and data bus in the address translation slot 1.
 *
 * @param matching_addr When an incoming transaction matches the matching
 * region, it is redirected to the new address. If a transaction does not match,
 * then it is directly passed through.
 * @param remap_addr  The region where the matched transtaction will be
 * redirected to.
 * @param size The size of the regions mapped.
 */
void ibex_addr_remap_1_set(uint32_t matching_addr, uint32_t remap_addr,
                           size_t size);

/**
 * Lock the remap windows so they cannot be reprogrammed.
 * This function locks the given the IBUS and DBUS windows simultaneously.
 *
 * @param index Which window to lock (0 or 1).
 */
void ibex_addr_remap_lockdown(uint32_t index);

#ifdef __cplusplus
}
#endif
#endif  // OPENTITAN_SW_DEVICE_SILICON_CREATOR_LIB_DRIVERS_IBEX_H_
