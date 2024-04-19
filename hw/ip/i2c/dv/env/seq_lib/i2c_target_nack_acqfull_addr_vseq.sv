// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// This directed test exercises the automatic-nack'ing features of the DUT-Target
//
// This vseq extends the parent 'acqfull' sequence by enabling the 'CTRL.NACK_ADDR_AFTER_TIMEOUT'
// feature and neglecting to clear the ACQFIFO between stimulus runs. This leaves the fifo full at
// the beginning of each new transaction, and we expect the DUT to automatically stretch into a
// NACK for each subsequent stimulus item.
//
////////////////////////////////////////////////////////////////////////////////////////////////////
//
// TESTPOINT DESC. (TP:target_mode_nack_generation)
//
// > NACK when ACQFIFO is full.
// >   - Stimulate WRITE transactions to fill the ACQFIFO (quickly), then allow the
// >     TARGET_TIMEOUT_CTRL value to elapse. Check that we nack at this point.
// >   - Check we nack all remaining bytes immediately while full.
//
// > TARGET_NACK_COUNT records the number of NACK'd bytes.
// >   - After some number of NACKs (e.g. generated by the cases above), check
// >     that the TARGET_NACK_COUNT contains the number of NACKs.
// >   - Reading the register clears it, so read twice and confirm zero the second time.
// >
// > NACK on address-byte from stretch-timeout (CTRL.NACK_ADDR_AFTER_TIMEOUT)
//
// I2C bus devices configured as: (DUT/Agent == Target/Controller)
// This testcase is interrupt driven, so the plusarg +use_intr_handler=1 is needed.
//
class i2c_target_nack_acqfull_addr_vseq extends i2c_target_nack_acqfull_vseq;
  `uvm_object_utils(i2c_target_nack_acqfull_addr_vseq)
  `uvm_object_new

  rand int stim_cnt_limit_local;

  // Limit the stimulus count to <=255, as the short stetch-into-NACK on the first byte of
  // each transaction can cause us to overflow the NACK counter (8-bit) in a short order, and
  // the directed nature of this testcase does not properly model the saturation of this counter.
  // It would be preferable to model this properly in the model/scoreboard in the future.
  constraint stim_cnt_limit_local_c {
    stim_cnt_limit_local inside {[1 : 2**8 - 1]};
  }

  virtual task pre_start();
    super.pre_start();

    stim_cnt_limit = stim_cnt_limit_local;
    seq_runtime_us = 0; // Disable timeout

    // With this setting enabled, we always NACK the address byte upon stretching timeout.
    ral.ctrl.nack_addr_after_timeout.set(1);
    csr_update(ral.ctrl);

    // This assertion becomes untrue when the ACQFIFO is full, and the
    // Target-FSM is stretching while awaiting space in the fifo.
    // If the stretch-timeout expires, the pending wvalid then de-asserts,
    // causing the assertion to fail.
    $assertoff(0, "tb.dut.i2c_core.u_fifos.AcqWriteStableBeforeHandshake_A");

  endtask: pre_start

  // This hook implements the same function as the parent class, except without clearing out
  // the ACQFIFO between stimulus runs. This is necessary to trigger the intented behaviour, which
  // occurs when starting a new transfer while the fifo is full. Each subsequent run will trigger
  // the automated NACK behaviour so long as the acqfifo remains full.
  //
  virtual task end_of_stim_hook();
    // Check the 'nack_count' csr, but a backdoor check to avoid clearing
    // the value due to the "RC" access for software.
    csr_rd_check(.ptr(ral.target_nack_count), .compare_value(stim_cnt), .backdoor(1));

    // Don't cleanup the acqfifo for the next iteration.

    // If we've reached the final iteration, read nack_count via frontdoor, except read twice
    // to check the "RC" access.
    if (timer_expired) begin
      `uvm_info(`gfn, "Reading 'target_nack_count via the frontdoor now.", UVM_MEDIUM)
      csr_rd_check(.ptr(ral.target_nack_count), .compare_value(stim_cnt));
      `uvm_info(`gfn, "Reading 'target_nack_count via the frontdoor again, expecting zero.",
                UVM_MEDIUM)
      csr_rd_check(.ptr(ral.target_nack_count), .compare_value(0));
    end
  endtask

endclass: i2c_target_nack_acqfull_addr_vseq