// ******************************************************************
// Wrapper for the Ariane Core
// ******************************************************************

`define HARTID_LEN 64

module ArianeCoreBlackbox
    #(
        parameter TRACEPORT_SZ = 0,
        parameter XLEN = 0,
        parameter RAS_ENTRIES = 0,
        parameter BTB_ENTRIES = 0,
        parameter BHT_ENTRIES = 0,
        parameter [63:0] EXEC_REG_CNT = 0,
        parameter [63:0] EXEC_REG_BASE_0 = 0,
        parameter [63:0] EXEC_REG_SZ_0 = 0,
        parameter [63:0] EXEC_REG_BASE_1 = 0,
        parameter [63:0] EXEC_REG_SZ_1 = 0,
        parameter [63:0] EXEC_REG_BASE_2 = 0,
        parameter [63:0] EXEC_REG_SZ_2 = 0,
        parameter [63:0] EXEC_REG_BASE_3 = 0,
        parameter [63:0] EXEC_REG_SZ_3 = 0,
        parameter [63:0] EXEC_REG_BASE_4 = 0,
        parameter [63:0] EXEC_REG_SZ_4 = 0,
        parameter [63:0] CACHE_REG_CNT = 0,
        parameter [63:0] CACHE_REG_BASE_0 = 0,
        parameter [63:0] CACHE_REG_SZ_0 = 0,
        parameter [63:0] CACHE_REG_BASE_1 = 0,
        parameter [63:0] CACHE_REG_SZ_1 = 0,
        parameter [63:0] CACHE_REG_BASE_2 = 0,
        parameter [63:0] CACHE_REG_SZ_2 = 0,
        parameter [63:0] CACHE_REG_BASE_3 = 0,
        parameter [63:0] CACHE_REG_SZ_3 = 0,
        parameter [63:0] CACHE_REG_BASE_4 = 0,
        parameter [63:0] CACHE_REG_SZ_4 = 0,
        parameter [63:0] DEBUG_BASE = 0,
        parameter AXI_ADDRESS_WIDTH = 0,
        parameter AXI_DATA_WIDTH = 0,
        parameter AXI_USER_WIDTH = 0,
        parameter AXI_ID_WIDTH = 0
     )
(
    input clk_i,
    input rst_ni,
    input [XLEN - 1:0] boot_addr_i,
    input [`HARTID_LEN - 1:0] hart_id_i,
    input [1:0] irq_i,
    input ipi_i,
    input time_irq_i,
    input debug_req_i,
    output [TRACEPORT_SZ-1:0] trace_o,

    input  axi_resp_i_aw_ready,
    output axi_req_o_aw_valid,
    output [AXI_ID_WIDTH-1:0] axi_req_o_aw_bits_id,
    output [AXI_ADDRESS_WIDTH-1:0] axi_req_o_aw_bits_addr,
    output [7:0] axi_req_o_aw_bits_len,
    output [2:0] axi_req_o_aw_bits_size,
    output [1:0] axi_req_o_aw_bits_burst,
    output axi_req_o_aw_bits_lock,
    output [3:0] axi_req_o_aw_bits_cache,
    output [2:0] axi_req_o_aw_bits_prot,
    output [3:0] axi_req_o_aw_bits_qos,
    output [3:0] axi_req_o_aw_bits_region,
    output [5:0] axi_req_o_aw_bits_atop,
    output [AXI_USER_WIDTH-1:0] axi_req_o_aw_bits_user,

    input axi_resp_i_w_ready,
    output axi_req_o_w_valid,
    output [AXI_DATA_WIDTH-1:0] axi_req_o_w_bits_data,
    output [(AXI_DATA_WIDTH/8)-1:0] axi_req_o_w_bits_strb,
    output axi_req_o_w_bits_last,
    output [AXI_USER_WIDTH-1:0] axi_req_o_w_bits_user,

    input axi_resp_i_ar_ready,
    output axi_req_o_ar_valid,
    output [AXI_ID_WIDTH-1:0] axi_req_o_ar_bits_id,
    output [AXI_ADDRESS_WIDTH-1:0] axi_req_o_ar_bits_addr,
    output [7:0] axi_req_o_ar_bits_len,
    output [2:0] axi_req_o_ar_bits_size,
    output [1:0] axi_req_o_ar_bits_burst,
    output axi_req_o_ar_bits_lock,
    output [3:0] axi_req_o_ar_bits_cache,
    output [2:0] axi_req_o_ar_bits_prot,
    output [3:0] axi_req_o_ar_bits_qos,
    output [3:0] axi_req_o_ar_bits_region,
    output [AXI_USER_WIDTH-1:0] axi_req_o_ar_bits_user,

    output axi_req_o_b_ready,
    input axi_resp_i_b_valid,
    input [AXI_ID_WIDTH-1:0] axi_resp_i_b_bits_id,
    input [1:0] axi_resp_i_b_bits_resp,
    input [AXI_USER_WIDTH-1:0] axi_resp_i_b_bits_user,

    output axi_req_o_r_ready,
    input axi_resp_i_r_valid,
    input [AXI_ID_WIDTH-1:0] axi_resp_i_r_bits_id,
    input [AXI_DATA_WIDTH-1:0] axi_resp_i_r_bits_data,
    input [1:0] axi_resp_i_r_bits_resp,
    input axi_resp_i_r_bits_last,
    input [AXI_USER_WIDTH-1:0] axi_resp_i_r_bits_user
);

    localparam ariane_pkg::ariane_cfg_t ArianeSocCfg = '{
        RASDepth: RAS_ENTRIES,
        BTBEntries: BTB_ENTRIES,
        BHTEntries: BHT_ENTRIES,
        // idempotent region
        NrNonIdempotentRules:  0,
        NonIdempotentAddrBase: {64'b0},
        NonIdempotentLength:   {64'b0},
        // execute region
        NrExecuteRegionRules:  EXEC_REG_CNT,
        ExecuteRegionAddrBase: {EXEC_REG_BASE_4, EXEC_REG_BASE_3, EXEC_REG_BASE_2, EXEC_REG_BASE_1, EXEC_REG_BASE_0},
        ExecuteRegionLength:   {  EXEC_REG_SZ_4,   EXEC_REG_SZ_3,   EXEC_REG_SZ_2,   EXEC_REG_SZ_1,   EXEC_REG_SZ_0},
        // cached region
        NrCachedRegionRules:   CACHE_REG_CNT,
        CachedRegionAddrBase:  {CACHE_REG_BASE_4, CACHE_REG_BASE_3, CACHE_REG_BASE_2, CACHE_REG_BASE_1, CACHE_REG_BASE_0},
        CachedRegionLength:    {  CACHE_REG_SZ_4,   CACHE_REG_SZ_3,   CACHE_REG_SZ_2,   CACHE_REG_SZ_1,   CACHE_REG_SZ_0},
        //  cache config
        Axi64BitCompliant:      1'b1,
        SwapEndianess:          1'b0,
        // debug
        DmBaseAddress:          DEBUG_BASE
    };

    // connect ariane
    ariane_axi::req_t  ariane_axi_req;
    ariane_axi::resp_t ariane_axi_resp;

    `ifdef FIRESIM_TRACE
        traced_instr_pkg::trace_port_t tp_if;

        ariane #(
            .ArianeCfg ( ArianeSocCfg )
        ) i_ariane (
            .clk_i,
            .rst_ni,
            .boot_addr_i,
            .hart_id_i,
            .irq_i,
            .ipi_i,
            .time_irq_i,
            .debug_req_i,
            .trace_o ( tp_if ),
            .axi_req_o ( ariane_axi_req ),
            .axi_resp_i ( ariane_axi_resp )
        );
    `else
        ariane #(
            .ArianeCfg ( ArianeSocCfg )
        ) i_ariane (
            .clk_i,
            .rst_ni,
            .boot_addr_i,
            .hart_id_i,
            .irq_i,
            .ipi_i,
            .time_irq_i,
            .debug_req_i,
            .axi_req_o ( ariane_axi_req ),
            .axi_resp_i ( ariane_axi_resp )
        );
    `endif

    `ifdef FIRESIM_TRACE
        // roll all trace signals into a single bit array (and pack according to rocket-chip)
        for (genvar i = 0; i < ariane_pkg::NR_COMMIT_PORTS; ++i) begin : gen_tp_roll
            assign trace_o[(TRACEPORT_SZ*(i+1)/ariane_pkg::NR_COMMIT_PORTS)-1:(TRACEPORT_SZ*i/ariane_pkg::NR_COMMIT_PORTS)] = {
                tp_if[i].tval[39:0],
                tp_if[i].cause[7:0],
                tp_if[i].interrupt,
                tp_if[i].exception,
                { 1'b0, tp_if[i].priv[1:0] },
                tp_if[i].insn[31:0],
                tp_if[i].iaddr[39:0],
                tp_if[i].valid,
                ~tp_if[i].reset,
                tp_if[i].clock
            };
        end
    `else
        // set all the trace signals to 0
        assign trace_o = '0;
    `endif

    AXI_BUS #(
        .AXI_ADDR_WIDTH(AXI_ADDRESS_WIDTH),
        .AXI_DATA_WIDTH(AXI_DATA_WIDTH),
        .AXI_ID_WIDTH(AXI_ID_WIDTH),
        .AXI_USER_WIDTH(AXI_USER_WIDTH)
    ) axi_slave_bus();

    // convert ariane axi port to normal axi port
    axi_master_connect i_axi_master_connect_ariane (
        .axi_req_i(ariane_axi_req),
        .axi_resp_o(ariane_axi_resp),
        .master(axi_slave_bus)
    );

    AXI_BUS #(
        .AXI_ADDR_WIDTH(AXI_ADDRESS_WIDTH),
        .AXI_DATA_WIDTH(AXI_DATA_WIDTH),
        .AXI_ID_WIDTH(AXI_ID_WIDTH),
        .AXI_USER_WIDTH(AXI_USER_WIDTH)
    ) axi_master_bus();

    // deal with atomics using arianes wrapper
    axi_riscv_atomics_wrap #(
        .AXI_ADDR_WIDTH(AXI_ADDRESS_WIDTH),
        .AXI_DATA_WIDTH(AXI_DATA_WIDTH),
        .AXI_ID_WIDTH(AXI_ID_WIDTH),
        .AXI_USER_WIDTH(AXI_USER_WIDTH),
        .AXI_MAX_WRITE_TXNS (1),
        .RISCV_WORD_WIDTH(XLEN)
    ) i_axi_riscv_atomics (
        .clk_i,
        .rst_ni,
        .slv(axi_slave_bus),
        .mst(axi_master_bus)
    );

    // connect axi_master_bus to the outgoing signals
    assign axi_master_bus.aw_ready = axi_resp_i_aw_ready;
    assign axi_req_o_aw_valid = axi_master_bus.aw_valid;
    assign axi_req_o_aw_bits_id = axi_master_bus.aw_id;
    assign axi_req_o_aw_bits_addr = axi_master_bus.aw_addr;
    assign axi_req_o_aw_bits_len = axi_master_bus.aw_len;
    assign axi_req_o_aw_bits_size = axi_master_bus.aw_size;
    assign axi_req_o_aw_bits_burst = axi_master_bus.aw_burst;
    assign axi_req_o_aw_bits_lock = axi_master_bus.aw_lock;
    assign axi_req_o_aw_bits_cache = axi_master_bus.aw_cache;
    assign axi_req_o_aw_bits_prot = axi_master_bus.aw_prot;
    assign axi_req_o_aw_bits_qos = axi_master_bus.aw_qos;
    assign axi_req_o_aw_bits_region = axi_master_bus.aw_region;
    assign axi_req_o_aw_bits_atop = axi_master_bus.aw_atop;
    assign axi_req_o_aw_bits_user = axi_master_bus.aw_user;

    assign axi_master_bus.w_ready = axi_resp_i_w_ready;
    assign axi_req_o_w_valid = axi_master_bus.w_valid;
    assign axi_req_o_w_bits_data = axi_master_bus.w_data;
    assign axi_req_o_w_bits_strb = axi_master_bus.w_strb;
    assign axi_req_o_w_bits_last = axi_master_bus.w_last;
    assign axi_req_o_w_bits_user = axi_master_bus.w_user;

    assign axi_master_bus.ar_ready =  axi_resp_i_ar_ready;
    assign axi_req_o_ar_valid = axi_master_bus.ar_valid;
    assign axi_req_o_ar_bits_id = axi_master_bus.ar_id;
    assign axi_req_o_ar_bits_addr = axi_master_bus.ar_addr;
    assign axi_req_o_ar_bits_len = axi_master_bus.ar_len;
    assign axi_req_o_ar_bits_size = axi_master_bus.ar_size;
    assign axi_req_o_ar_bits_burst = axi_master_bus.ar_burst;
    assign axi_req_o_ar_bits_lock = axi_master_bus.ar_lock;
    assign axi_req_o_ar_bits_cache = axi_master_bus.ar_cache;
    assign axi_req_o_ar_bits_prot = axi_master_bus.ar_prot;
    assign axi_req_o_ar_bits_qos = axi_master_bus.ar_qos;
    assign axi_req_o_ar_bits_region = axi_master_bus.ar_region;
    assign axi_req_o_ar_bits_user = axi_master_bus.ar_user;

    assign axi_req_o_b_ready = axi_master_bus.b_ready;
    assign axi_master_bus.b_valid = axi_resp_i_b_valid;
    assign axi_master_bus.b_id = axi_resp_i_b_bits_id;
    assign axi_master_bus.b_resp = axi_resp_i_b_bits_resp;
    assign axi_master_bus.b_user = axi_resp_i_b_bits_user;

    assign axi_req_o_r_ready = axi_master_bus.r_ready;
    assign axi_master_bus.r_valid = axi_resp_i_r_valid;
    assign axi_master_bus.r_id = axi_resp_i_r_bits_id;
    assign axi_master_bus.r_data = axi_resp_i_r_bits_data;
    assign axi_master_bus.r_resp = axi_resp_i_r_bits_resp;
    assign axi_master_bus.r_last = axi_resp_i_r_bits_last;
    assign axi_master_bus.r_user = axi_resp_i_r_bits_user;

endmodule
