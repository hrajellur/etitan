# Copyright lowRISC contributors.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

load(
    "//rules:opentitan_test.bzl",
    "cw310_params",
    "opentitan_functest",
)
load(
    "//rules:const.bzl",
    "CONST",
    "hex",
)
load(
    "//rules:otp.bzl",
    "STD_OTP_OVERLAYS",
    "otp_hex",
    "otp_image",
    "otp_json",
    "otp_partition",
)
load(
    "//rules:rom_e2e.bzl",
    "maybe_skip_in_ci",
)
load(
    "//rules:splice.bzl",
    "bitstream_splice",
)

package(default_visibility = ["//visibility:public"])

otp_json(
    name = "otp_json_reset_ret_ram_overlay",
    partitions = [
        otp_partition(
            name = "CREATOR_SW_CFG",
            # Set the mask to 1 << kRstmgrReasonSoftwareRequest to trigger a
            # retention RAM reset after a SW-requested reset
            items = {"CREATOR_SW_CFG_RET_RAM_RESET_MASK": otp_hex(0x4)},
        ),
    ],
)

otp_image(
    name = "otp_img_reset_ret_ram",
    src = "//hw/ip/otp_ctrl/data:otp_json_rma",
    overlays = STD_OTP_OVERLAYS + [":otp_json_reset_ret_ram_overlay"],
    visibility = ["//visibility:private"],
)

bitstream_splice(
    name = "bitstream_reset_ret_ram",
    src = "//hw/bitstream:rom_with_fake_keys",
    data = ":otp_img_reset_ret_ram",
    meminfo = "//hw/bitstream:otp_mmi",
    tags = maybe_skip_in_ci(CONST.LCV.RMA),
    update_usr_access = True,
    visibility = ["//visibility:private"],
)

opentitan_functest(
    name = "rom_e2e_ret_ram_init",
    srcs = ["rom_e2e_ret_ram_init_test.c"],
    cw310 = cw310_params(
        bitstream = ":bitstream_reset_ret_ram",
        tags = maybe_skip_in_ci(CONST.LCV.RMA),
    ),
    signed = True,
    targets = [
        "cw310_rom_with_fake_keys",
    ],
    deps = [
        "//sw/device/lib/base:memory",
        "//sw/device/lib/dif:rstmgr",
        "//sw/device/lib/runtime:log",
        "//sw/device/lib/testing/test_framework:ottf_main",
        "//sw/device/silicon_creator/lib/drivers:retention_sram",
        "//sw/device/silicon_creator/lib/drivers:rstmgr",
    ],
)

opentitan_functest(
    name = "rom_e2e_ret_ram_keep",
    srcs = ["rom_e2e_ret_ram_keep_test.c"],
    cw310 = cw310_params(
        bitstream = "//hw/bitstream:rom_with_fake_keys",
        tags = maybe_skip_in_ci(CONST.LCV.RMA),
    ),
    signed = True,
    targets = [
        "cw310_rom_with_fake_keys",
    ],
    deps = [
        "//hw/top_earlgrey/ip_autogen/pwrmgr/data:pwrmgr_regs",
        "//sw/device/lib/base:memory",
        "//sw/device/lib/dif:aon_timer",
        "//sw/device/lib/dif:pwrmgr",
        "//sw/device/lib/runtime:log",
        "//sw/device/lib/testing:aon_timer_testutils",
        "//sw/device/lib/testing:pwrmgr_testutils",
        "//sw/device/lib/testing/test_framework:check",
        "//sw/device/lib/testing/test_framework:ottf_main",
        "//sw/device/silicon_creator/lib/drivers:retention_sram",
        "//sw/device/silicon_creator/lib/drivers:rstmgr",
    ],
)