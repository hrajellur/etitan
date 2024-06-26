# Copyright lowRISC contributors (OpenTitan project).
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

load("//rules/opentitan:defs.bzl", "OPENTITAN_CPU", "opentitan_binary", "opentitan_test")
load("//rules/opentitan:legacy.bzl", "legacy_rom_targets")
load("//rules:files.bzl", "output_groups")
load("//rules:linker.bzl", "ld_library")
load("//rules:opentitan_test.bzl", "manual_test")
load("//rules:cross_platform.bzl", "dual_cc_library", "dual_inputs")
load("@rules_pkg//pkg:mappings.bzl", "pkg_files")
load("@rules_fuzzing//fuzzing:cc_defs.bzl", "cc_fuzz_test")

package(default_visibility = ["//visibility:public"])

dual_cc_library(
    name = "boot_policy_ptrs",
    srcs = dual_inputs(
        host = ["mock_boot_policy_ptrs.cc"],
        shared = ["boot_policy_ptrs.c"],
    ),
    hdrs = dual_inputs(
        host = ["mock_boot_policy_ptrs.h"],
        shared = ["boot_policy_ptrs.h"],
    ),
    deps = dual_inputs(
        host = [
            "//sw/device/lib/base:global_mock",
            "//sw/device/silicon_creator/testing:rom_test",
            "@googletest//:gtest",
        ],
        shared = [
            "//sw/device/silicon_creator/lib:manifest",
            "//hw/top_earlgrey/sw/autogen:top_earlgrey",
        ],
    ),
)

cc_library(
    name = "boot_policy",
    srcs = ["boot_policy.c"],
    hdrs = ["boot_policy.h"],
    deps = [
        ":boot_policy_ptrs",
        "//sw/device/lib/base:hardened",
        "//sw/device/silicon_creator/lib:boot_data",
        "//sw/device/silicon_creator/lib:error",
        "//sw/device/silicon_creator/lib:manifest",
        "//sw/device/silicon_creator/lib:shutdown",
        "//sw/device/silicon_creator/lib/base:chip",
    ],
)

cc_test(
    name = "boot_policy_unittest",
    srcs = ["boot_policy_unittest.cc"],
    deps = [
        ":boot_policy",
        "//sw/device/silicon_creator/testing:rom_test",
        "@googletest//:gtest_main",
    ],
)

ld_library(
    name = "linker_script",
    script = "rom.ld",
    deps = [
        "//hw/top_earlgrey/sw/autogen:top_earlgrey_memory",
        "//sw/device:info_sections",
    ],
)

cc_library(
    name = "rom_without_keys",
    srcs = [
        "rom_start.S",
    ],
    target_compatible_with = [OPENTITAN_CPU],
    deps = [
        ":linker_script",
        ":rom_common",
        ":rom_epmp",
        "//hw/ip/aon_timer/data:aon_timer_c_regs",
        "//hw/ip/csrng/data:csrng_c_regs",
        "//hw/ip/edn/data:edn_c_regs",
        "//hw/ip/entropy_src/data:entropy_src_c_regs",
        "//hw/ip/gpio/data:gpio_c_regs",
        "//hw/ip/lc_ctrl/data:lc_ctrl_c_regs",
        "//hw/ip/otp_ctrl/data:otp_ctrl_c_regs",
        "//hw/ip/rv_core_ibex/data:rv_core_ibex_c_regs",
        "//hw/ip/sram_ctrl/data:sram_ctrl_c_regs",
        "//hw/top_earlgrey/ip/ast/data:ast_c_regs",
        "//hw/top_earlgrey/ip/pinmux/data/autogen:pinmux_c_regs",
        "//hw/top_earlgrey/ip/sensor_ctrl/data:sensor_ctrl_c_regs",
        "//hw/top_earlgrey/ip_autogen/clkmgr/data:clkmgr_c_regs",
        "//hw/top_earlgrey/ip_autogen/pwrmgr/data:pwrmgr_c_regs",
        "//hw/top_earlgrey/ip_autogen/rstmgr/data:rstmgr_c_regs",
        "//hw/top_earlgrey/sw/autogen:top_earlgrey",
        "//sw/device/lib/base:hardened",
        "//sw/device/lib/base:multibits",
        "//sw/device/silicon_creator/lib/base:chip",
    ],
    alwayslink = True,
)

cc_library(
    name = "rom_common",
    srcs = [
        "rom.c",
        "rom.h",
    ],
    deps = [
        ":boot_policy",
        ":bootstrap",
        ":rom_epmp",
        ":sigverify_keys",
        ":sigverify_keys_rsa",
        ":sigverify_keys_spx",
        ":sigverify_otp_keys",
        "//hw/ip/aon_timer/data:aon_timer_c_regs",
        "//sw/device/lib/arch:device",
        "//sw/device/lib/base:bitfield",
        "//sw/device/lib/base:csr",
        "//sw/device/lib/base:macros",
        "//sw/device/lib/base:memory",
        "//sw/device/lib/base:stdasm",
        "//sw/device/lib/crt",
        "//sw/device/lib/runtime:hart",
        "//sw/device/silicon_creator/lib:boot_log",
        "//sw/device/silicon_creator/lib:cfi",
        "//sw/device/silicon_creator/lib:chip_info",
        "//sw/device/silicon_creator/lib:epmp_state",
        "//sw/device/silicon_creator/lib:error",
        "//sw/device/silicon_creator/lib:irq_asm",
        "//sw/device/silicon_creator/lib:manifest",
        "//sw/device/silicon_creator/lib:shutdown",
        "//sw/device/silicon_creator/lib/base:chip",
        "//sw/device/silicon_creator/lib/base:sec_mmio",
        "//sw/device/silicon_creator/lib/base:static_critical",
        "//sw/device/silicon_creator/lib/drivers:alert",
        "//sw/device/silicon_creator/lib/drivers:ast",
        "//sw/device/silicon_creator/lib/drivers:flash_ctrl",
        "//sw/device/silicon_creator/lib/drivers:ibex",
        "//sw/device/silicon_creator/lib/drivers:keymgr",
        "//sw/device/silicon_creator/lib/drivers:lifecycle",
        "//sw/device/silicon_creator/lib/drivers:otp",
        "//sw/device/silicon_creator/lib/drivers:pinmux",
        "//sw/device/silicon_creator/lib/drivers:pwrmgr",
        "//sw/device/silicon_creator/lib/drivers:retention_sram",
        "//sw/device/silicon_creator/lib/drivers:rnd",
        "//sw/device/silicon_creator/lib/drivers:rstmgr",
        "//sw/device/silicon_creator/lib/drivers:uart",
        "//sw/device/silicon_creator/lib/drivers:watchdog",
        "//sw/device/silicon_creator/lib/sigverify",
    ],
)

_ROM_DEVICES = [
    "sim_dv",
    "sim_verilator",
    "fpga_cw310",
    "fpga_cw340",
]

opentitan_binary(
    name = "rom_with_fake_keys",
    testonly = True,
    exec_env = [
        "//hw/top_earlgrey:fpga_cw310",
        "//hw/top_earlgrey:fpga_cw340",
        "//hw/top_earlgrey:sim_dv_base",
        "//hw/top_earlgrey:sim_verilator_base",
    ],
    kind = "rom",
    linker_script = ":linker_script",
    deps = [
        ":rom_without_keys",
        "//sw/device/silicon_creator/rom/keys/fake/rsa",
    ],
)

# Create the legacy ROM target names so that existing splicing rules can find
# the rom VMEM files.
legacy_rom_targets(
    testonly = True,
    suffixes = _ROM_DEVICES,
    target = "rom_with_fake_keys",
)

filegroup(
    name = "rom_with_fake_keys_fpga_cw310_elf",
    testonly = True,
    srcs = [":rom_with_fake_keys"],
    output_group = "fpga_cw310_elf",
)

opentitan_binary(
    name = "rom_with_real_keys",
    exec_env = [
        "//hw/top_earlgrey:fpga_cw310",
        "//hw/top_earlgrey:fpga_cw340",
        "//hw/top_earlgrey:sim_dv_base",
        "//hw/top_earlgrey:sim_verilator_base",
    ],
    kind = "rom",
    linker_script = ":linker_script",
    deps = [
        ":rom_without_keys",
        "//sw/device/silicon_creator/rom/keys/real/rsa",
    ],
)

# Create the legacy ROM target names so that existing splicing rules can find
# the rom VMEM files.
legacy_rom_targets(
    suffixes = _ROM_DEVICES,
    target = "rom_with_real_keys",
)

cc_library(
    name = "rom_epmp",
    srcs = [
        "rom_epmp.c",
        "rom_epmp_init.S",
    ],
    hdrs = ["rom_epmp.h"],
    target_compatible_with = [OPENTITAN_CPU],
    deps = [
        "//hw/top_earlgrey/sw/autogen:top_earlgrey",
        "//sw/device/lib/base:bitfield",
        "//sw/device/lib/base:csr",
        "//sw/device/lib/base:memory",
        "//sw/device/silicon_creator/lib:epmp_state",
        "//sw/device/silicon_creator/lib/drivers:lifecycle",
    ],
)

opentitan_test(
    name = "rom_epmp_test",
    srcs = [
        "rom_epmp_test.c",
    ],
    # This test doesn't use the OTTF and can only run in verilator right now.
    #
    # This test is designed to run and complete entirely in the ROM boot stage.
    # Setting `kind = "rom"` makes the `opentitan_test` rule aware
    # of this, and instructs it to load the test image into ROM (rather than
    # loading the default test ROM, or any other ROM that may be specified via
    # Verilator or CW310 params).
    exec_env = {
        "//hw/top_earlgrey:sim_verilator": None,
    },
    kind = "rom",
    linker_script = ":linker_script",
    linkopts = [
        "-Wl,--defsym=rom_test=1",
    ],
    deps = [
        ":rom_without_keys",
        "//hw/top_earlgrey/ip/flash_ctrl/data/autogen:flash_ctrl_c_regs",
        "//sw/device/lib/arch:device",
        "//sw/device/lib/base:abs_mmio",
        "//sw/device/lib/base:bitfield",
        "//sw/device/lib/base:csr",
        "//sw/device/lib/base:macros",
        "//sw/device/lib/crt",
        "//sw/device/lib/dif:pinmux",
        "//sw/device/lib/dif:sram_ctrl",
        "//sw/device/lib/runtime:hart",
        "//sw/device/lib/runtime:ibex",
        "//sw/device/lib/runtime:log",
        "//sw/device/lib/runtime:print",
        "//sw/device/lib/testing:pinmux_testutils",
        "//sw/device/lib/testing/test_framework:check",
        "//sw/device/lib/testing/test_framework:status",
        "//sw/device/silicon_creator/lib:epmp_state",
        "//sw/device/silicon_creator/lib:epmp_test_unlock",
        "//sw/device/silicon_creator/lib:irq_asm",
        "//sw/device/silicon_creator/lib/base:chip",
        "//sw/device/silicon_creator/lib/base:sec_mmio",
        "//sw/device/silicon_creator/lib/base:static_critical",
        "//sw/device/silicon_creator/lib/drivers:flash_ctrl",
        "//sw/device/silicon_creator/lib/drivers:uart",
    ],
)

filegroup(
    name = "english_breakfast_test_rom_bootstrap_srcs",
    srcs = [
        "bootstrap.c",
        "bootstrap.h",
        "//sw/device/silicon_creator/lib:bootstrap_srcs",
    ],
)

cc_library(
    name = "bootstrap",
    srcs = ["bootstrap.c"],
    hdrs = ["bootstrap.h"],
    deps = [
        "//hw/ip/gpio/data:gpio_c_regs",
        "//hw/ip/otp_ctrl/data:otp_ctrl_c_regs",
        "//hw/top_earlgrey/ip/flash_ctrl/data/autogen:flash_ctrl_c_regs",
        "//hw/top_earlgrey/sw/autogen:top_earlgrey",
        "//sw/device/lib/base:abs_mmio",
        "//sw/device/lib/base:bitfield",
        "//sw/device/lib/base:hardened",
        "//sw/device/silicon_creator/lib:bootstrap",
        "//sw/device/silicon_creator/lib:error",
        "//sw/device/silicon_creator/lib/base:chip",
        "//sw/device/silicon_creator/lib/drivers:flash_ctrl",
        "//sw/device/silicon_creator/lib/drivers:otp",
    ],
)

cc_test(
    name = "bootstrap_unittest",
    srcs = ["bootstrap_unittest.cc"],
    deps = [
        ":bootstrap",
        "//hw/ip/gpio/data:gpio_c_regs",
        "//hw/ip/otp_ctrl/data:otp_ctrl_c_regs",
        "//hw/top_earlgrey/ip/flash_ctrl/data/autogen:flash_ctrl_c_regs",
        "//hw/top_earlgrey/sw/autogen:top_earlgrey",
        "//sw/device/silicon_creator/lib:bootstrap_unittest_util",
        "@googletest//:gtest_main",
    ],
)

# To test this target, you must specify `--config=asan-libfuzzer`.
cc_fuzz_test(
    name = "bootstrap_fuzz_test",
    srcs = ["bootstrap_fuzz_test.cc"],
    tags = [
        "fuzzer",
        "manual",
    ],
    deps = [
        ":bootstrap",
        "//sw/device/silicon_creator/lib:bootstrap_fuzzer_util",
        "@com_google_absl//absl/types:span",
    ],
)

cc_library(
    name = "sigverify_keys",
    srcs = [
        "sigverify_keys.c",
        "sigverify_keys_rsa.h",
        "sigverify_keys_spx.h",
    ],
    hdrs = [
        "sigverify_keys.h",
    ],
    deps = [
        ":sigverify_key_types",
        "//sw/device/lib/base:bitfield",
        "//sw/device/lib/base:hardened",
        "//sw/device/lib/base:macros",
        "//sw/device/silicon_creator/lib:error",
        "//sw/device/silicon_creator/lib/drivers:lifecycle",
        "//sw/device/silicon_creator/lib/drivers:otp",
        "//sw/device/silicon_creator/lib/drivers:rnd",
        "//sw/device/silicon_creator/lib/sigverify:rsa_key",
        "//sw/device/silicon_creator/lib/sigverify:spx_key",
    ],
)

cc_library(
    name = "sigverify_otp_keys",
    srcs = ["sigverify_otp_keys.c"],
    hdrs = ["sigverify_otp_keys.h"],
    deps = [
        ":sigverify_key_types",
        "//hw/ip/otp_ctrl/data:otp_ctrl_c_regs",
        "//sw/device/lib/base:macros",
        "//sw/device/silicon_creator/lib:error",
        "//sw/device/silicon_creator/lib/drivers:hmac",
        "//sw/device/silicon_creator/lib/drivers:lifecycle",
        "//sw/device/silicon_creator/lib/drivers:otp",
        "//sw/device/silicon_creator/lib/drivers:rnd",
    ],
)

cc_library(
    name = "sigverify_key_types",
    hdrs = ["sigverify_key_types.h"],
    deps = [
        "//sw/device/silicon_creator/lib/sigverify:ecdsa_p256_key",
        "//sw/device/silicon_creator/lib/sigverify:rsa_key",
        "//sw/device/silicon_creator/lib/sigverify:spx_key",
    ],
)

cc_library(
    name = "sigverify_keys_ecdsa_p256",
    srcs = [
        "sigverify_keys_ecdsa_p256.c",
    ],
    hdrs = [
        "sigverify_keys_ecdsa_p256.h",
    ],
    deps = [
        ":sigverify_key_types",
        ":sigverify_otp_keys",
        "//sw/device/lib/base:macros",
        "//sw/device/silicon_creator/lib:error",
        "//sw/device/silicon_creator/lib/drivers:lifecycle",
        "//sw/device/silicon_creator/lib/sigverify",
        "//sw/device/silicon_creator/lib/sigverify:ecdsa_p256_key",
    ],
)

cc_library(
    name = "sigverify_keys_rsa",
    srcs = [
        "sigverify_keys_rsa.c",
    ],
    hdrs = [
        "sigverify_keys_rsa.h",
    ],
    deps = [
        ":sigverify_key_types",
        ":sigverify_keys",
        "//hw/ip/otp_ctrl/data:otp_ctrl_c_regs",
        "//sw/device/lib/base:macros",
        "//sw/device/silicon_creator/lib:error",
        "//sw/device/silicon_creator/lib/drivers:lifecycle",
        "//sw/device/silicon_creator/lib/sigverify:rsa_key",
    ],
)

cc_library(
    name = "sigverify_keys_spx",
    srcs = [
        "sigverify_keys_spx.c",
    ],
    hdrs = [
        "sigverify_keys_spx.h",
    ],
    deps = [
        ":sigverify_key_types",
        ":sigverify_otp_keys",
        "//hw/ip/otp_ctrl/data:otp_ctrl_c_regs",
        "//sw/device/lib/base:macros",
        "//sw/device/silicon_creator/lib:error",
        "//sw/device/silicon_creator/lib/drivers:lifecycle",
        "//sw/device/silicon_creator/lib/sigverify",
        "//sw/device/silicon_creator/lib/sigverify:spx_key",
    ],
)

cc_test(
    name = "sigverify_keys_unittest",
    srcs = ["sigverify_keys_unittest.cc"],
    deps = [
        ":sigverify_keys",
        ":sigverify_keys_rsa",
        "//hw/top_earlgrey/sw/autogen:top_earlgrey",
        "//sw/device/silicon_creator/testing:rom_test",
        "@googletest//:gtest_main",
    ],
)

[output_groups(
    name = "pre_package_{}".format(authenticity),
    testonly = testonly,
    srcs = [":rom_with_{}_keys".format(authenticity)],
    groups = [
        "fpga_cw310_binary",
        "fpga_cw310_elf",
        "fpga_cw310_rom",
        "fpga_cw310_mapfile",
        "fpga_cw340_binary",
        "fpga_cw340_elf",
        "fpga_cw340_rom",
        "fpga_cw340_mapfile",
        "sim_dv_elf",
        "sim_dv_rom",
        "sim_dv_logs",
        "sim_dv_mapfile",
        "sim_verilator_elf",
        "sim_verilator_rom",
        "sim_verilator_mapfile",
    ],
) for authenticity, testonly in (
    ("fake", True),
    # FIXME: remove testonly after adding the real keys
    ("real", True),
)]

[pkg_files(
    name = "package_{}".format(authenticity),
    testonly = testonly,
    srcs = [":pre_package_{}".format(authenticity)],
    prefix = "earlgrey/rom",
) for authenticity, testonly in (
    ("fake", True),
    # FIXME: remove testonly after adding the real keys
    ("real", True),
)]

manual_test(
    name = "manual_test",
    tags = [
        "manual",
        "no-cache",
    ],
    testplan = "//sw/device/silicon_creator/rom/data:rom_manual_testplan.hjson",
)

output_groups(
    name = "rom_with_real_keys_binaries",
    srcs = [":rom_with_real_keys"],
    groups = [
        "fpga_cw310_binary",
        "fpga_cw340_binary",
        "sim_dv_binary",
        "sim_verilator_binary",
    ],
)

genrule(
    name = "rom_hashes",
    testonly = True,
    srcs = [
        ":rom_with_real_keys_binaries",
    ],
    outs = ["rom_hashes.txt"],
    cmd = """
        echo "SHA256 of rom with real keys" > $@
	for f in $(locations :rom_with_real_keys_binaries); do
	    if [[ "$$f" == *bin ]]; then
	        name=$$(basename $$f)
		echo $$f >> $@
		size=$$(stat -L -c %s $$f)
		full=$$(sha256sum $$f | cut -f1 -d' ')
		without_chip_info=$$(head -c -12 $$f | sha256sum | cut -f1 -d' ')
		code=$$(echo $$without_chip_info | sed -E s'/(.{8})(.{8})(.{8})(.{8})(.{8})(.{8})(.{8})(.{8})/0x\\8,0x\\7,0x\\6,0x\\5,0x\\4,0x\\3,0x\\2,0x\\1,/g')

		echo "              size: $$size" >> $@
		echo "     complete hash: $$full" >> $@
		echo " without chip_info: $$without_chip_info" >> $@
		echo "w/o chip_info le32: $$code" >> $@
		echo >> $@
	    fi
	done
    """,
)
