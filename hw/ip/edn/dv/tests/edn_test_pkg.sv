// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

package edn_test_pkg;
  // dep packages
  import uvm_pkg::*;
  import cip_base_pkg::*;
  import edn_env_pkg::*;

  // macro includes
  `include "uvm_macros.svh"
  `include "dv_macros.svh"

  // local types

  // functions

  // package sources
  `include "edn_base_test.sv"
  `include "edn_smoke_test.sv"
  `include "edn_regwen_test.sv"
  `include "edn_genbits_test.sv"
  `include "edn_stress_all_test.sv"
  `include "edn_intr_test.sv"
  `include "edn_err_test.sv"
  `include "edn_alert_test.sv"
  `include "edn_disable_test.sv"
  `include "edn_disable_auto_req_mode_test.sv"

endpackage
