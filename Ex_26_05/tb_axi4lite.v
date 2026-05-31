`timescale 1ns/1ps

module tb_axi4lite_regs;

    // ── Sinais de clock e reset ───────────────────────────────
    reg         ACLK;
    reg         ARESETn;

    // ── Canal AW ─────────────────────────────────────────────
    reg  [31:0] S_AXI_AWADDR;
    reg         S_AXI_AWVALID;
    wire        S_AXI_AWREADY;

    // ── Canal W ──────────────────────────────────────────────
    reg  [31:0] S_AXI_WDATA;
    reg  [3:0]  S_AXI_WSTRB;
    reg         S_AXI_WVALID;
    wire        S_AXI_WREADY;

    // ── Canal B ──────────────────────────────────────────────
    wire [1:0]  S_AXI_BRESP;
    wire        S_AXI_BVALID;
    reg         S_AXI_BREADY;

    // ── Canal AR ─────────────────────────────────────────────
    reg  [31:0] S_AXI_ARADDR;
    reg         S_AXI_ARVALID;
    wire        S_AXI_ARREADY;

    // ── Canal R ──────────────────────────────────────────────
    wire [31:0] S_AXI_RDATA;
    wire [1:0]  S_AXI_RRESP;
    wire        S_AXI_RVALID;
    reg         S_AXI_RREADY;

    // ── Entradas externas ─────────────────────────────────────
    reg  [31:0] reg0_din;
    reg  [31:0] reg1_din;
    reg  [31:0] reg2_din;
    reg  [31:0] reg3_din;

    // ── Saídas ───────────────────────────────────────────────
    wire [31:0] reg0_dout;
    wire [31:0] reg1_dout;
    wire [31:0] reg2_dout;
    wire [31:0] reg3_dout;

    // ── Contadores de pass/fail ───────────────────────────────
    integer pass_count;
    integer fail_count;

    // ── Instância do DUT ─────────────────────────────────────
    axi4lite_regs dut (
        .ACLK          (ACLK),
        .ARESETn       (ARESETn),
        .S_AXI_AWADDR  (S_AXI_AWADDR),
        .S_AXI_AWVALID (S_AXI_AWVALID),
        .S_AXI_AWREADY (S_AXI_AWREADY),
        .S_AXI_WDATA   (S_AXI_WDATA),
        .S_AXI_WSTRB   (S_AXI_WSTRB),
        .S_AXI_WVALID  (S_AXI_WVALID),
        .S_AXI_WREADY  (S_AXI_WREADY),
        .S_AXI_BRESP   (S_AXI_BRESP),
        .S_AXI_BVALID  (S_AXI_BVALID),
        .S_AXI_BREADY  (S_AXI_BREADY),
        .S_AXI_ARADDR  (S_AXI_ARADDR),
        .S_AXI_ARVALID (S_AXI_ARVALID),
        .S_AXI_ARREADY (S_AXI_ARREADY),
        .S_AXI_RDATA   (S_AXI_RDATA),
        .S_AXI_RRESP   (S_AXI_RRESP),
        .S_AXI_RVALID  (S_AXI_RVALID),
        .S_AXI_RREADY  (S_AXI_RREADY),
        .reg0_din      (reg0_din),
        .reg1_din      (reg1_din),
        .reg2_din      (reg2_din),
        .reg3_din      (reg3_din),
        .reg0_dout     (reg0_dout),
        .reg1_dout     (reg1_dout),
        .reg2_dout     (reg2_dout),
        .reg3_dout     (reg3_dout)
    );

    // ── Clock 10 ns ──────────────────────────────────────────
    initial ACLK = 0;
    always #5 ACLK = ~ACLK;

    // =========================================================
    // Tarefa: escrita AXI4-Lite
    // =========================================================
    task axi_write;
        input [31:0] addr;
        input [31:0] data;
        begin
            // Apresenta AW e W simultaneamente
            @(posedge ACLK);
            S_AXI_AWADDR  = addr;
            S_AXI_AWVALID = 1;
            S_AXI_WDATA   = data;
            S_AXI_WSTRB   = 4'hF;
            S_AXI_WVALID  = 1;
            S_AXI_BREADY  = 1;

            // Aguarda AWREADY
            @(posedge ACLK);
            while (!S_AXI_AWREADY) @(posedge ACLK);
            S_AXI_AWVALID = 0;

            // Aguarda WREADY
            while (!S_AXI_WREADY) @(posedge ACLK);
            S_AXI_WVALID = 0;

            // Aguarda resposta B
            while (!S_AXI_BVALID) @(posedge ACLK);
            @(posedge ACLK);
            S_AXI_BREADY = 0;
            #1;
        end
    endtask

    // =========================================================
    // Tarefa: leitura AXI4-Lite
    // =========================================================
    task axi_read;
        input  [31:0] addr;
        output [31:0] rdata;
        begin
            @(posedge ACLK);
            S_AXI_ARADDR  = addr;
            S_AXI_ARVALID = 1;
            S_AXI_RREADY  = 1;

            // Aguarda ARREADY
            @(posedge ACLK);
            while (!S_AXI_ARREADY) @(posedge ACLK);
            S_AXI_ARVALID = 0;

            // Aguarda dado R
            while (!S_AXI_RVALID) @(posedge ACLK);
            rdata = S_AXI_RDATA;
            @(posedge ACLK);
            S_AXI_RREADY = 0;
            #1;
        end
    endtask

    // =========================================================
    // Tarefa: verifica resultado
    // =========================================================
    task check;
        input [7:0]  num;
        input [31:0] got;
        input [31:0] expected;
        input [127:0] descricao;
        begin
            if (got === expected) begin
                $display("  [PASS] Teste %02d | %s | got=0x%08h", num, descricao, got);
                pass_count = pass_count + 1;
            end else begin
                $display("  [FAIL] Teste %02d | %s | esperado=0x%08h got=0x%08h",
                         num, descricao, expected, got);
                fail_count = fail_count + 1;
            end
        end
    endtask

    // =========================================================
    // Sequência de testes
    // =========================================================
    reg [31:0] rdata;

    initial begin
        $dumpfile("wave_axi.vcd");
        $dumpvars(0, tb_axi4lite_regs);

        // Inicializa sinais
        ARESETn       = 0;
        S_AXI_AWADDR  = 0; S_AXI_AWVALID = 0;
        S_AXI_WDATA   = 0; S_AXI_WSTRB   = 0; S_AXI_WVALID = 0;
        S_AXI_BREADY  = 0;
        S_AXI_ARADDR  = 0; S_AXI_ARVALID = 0;
        S_AXI_RREADY  = 0;
        reg0_din = 0; reg1_din = 0;
        reg2_din = 0; reg3_din = 0;
        pass_count = 0; fail_count = 0;

        $display("");
        $display("============================================================");
        $display("  Testbench — Periférico AXI4-Lite com Banco de Registradores");
        $display("============================================================");

        // ── Teste 1: Reset ────────────────────────────────────
        $display("");
        $display("── Teste 1: Aplicar reset ──");
        repeat(4) @(posedge ACLK);
        ARESETn = 1;
        @(posedge ACLK); #1;
        check(1, reg0_dout, 32'h00000000, "reg0_dout apos reset  ");
        check(1, reg1_dout, 32'h00000000, "reg1_dout apos reset  ");
        check(1, reg2_dout, 32'h00000000, "reg2_dout apos reset  ");
        check(1, reg3_dout, 32'h00000000, "reg3_dout apos reset  ");

        // ── Teste 2: Escrever reg0 via AXI ───────────────────
        $display("");
        $display("── Teste 2: Escrever 0x00000011 em reg0 (end=0x00) ──");
        axi_write(32'h00000000, 32'h00000011);
        check(2, reg0_dout, 32'h00000011, "reg0_dout apos escrita");

        // ── Teste 3: Escrever reg1 via AXI ───────────────────
        $display("");
        $display("── Teste 3: Escrever 0x00000022 em reg1 (end=0x04) ──");
        axi_write(32'h00000004, 32'h00000022);
        check(3, reg1_dout, 32'h00000022, "reg1_dout apos escrita");

        // ── Teste 4: Entrada externa reg2_din ─────────────────
        $display("");
        $display("── Teste 4: Aplicar 0x00000033 em reg2_din ──");
        reg2_din = 32'h00000033;
        @(posedge ACLK); #1;
        check(4, reg2_dout, 32'h00000033, "reg2_dout = reg2_din  ");

        // ── Teste 5: Entrada externa reg3_din ─────────────────
        $display("");
        $display("── Teste 5: Aplicar 0x00000044 em reg3_din ──");
        reg3_din = 32'h00000044;
        @(posedge ACLK); #1;
        check(5, reg3_dout, 32'h00000044, "reg3_dout = reg3_din  ");

        // ── Teste 6: Ler reg0 via AXI ─────────────────────────
        $display("");
        $display("── Teste 6: Ler reg0 via AXI (end=0x00) ──");
        axi_read(32'h00000000, rdata);
        check(6, rdata,         32'h00000011, "RDATA reg0            ");
        check(6, S_AXI_RRESP,  2'b00,        "RRESP OKAY reg0       ");

        // ── Teste 7: Ler reg1 via AXI ─────────────────────────
        $display("");
        $display("── Teste 7: Ler reg1 via AXI (end=0x04) ──");
        axi_read(32'h00000004, rdata);
        check(7, rdata,         32'h00000022, "RDATA reg1            ");
        check(7, S_AXI_RRESP,  2'b00,        "RRESP OKAY reg1       ");

        // ── Teste 8: Ler reg2 via AXI ─────────────────────────
        $display("");
        $display("── Teste 8: Ler reg2 via AXI (end=0x08) ──");
        axi_read(32'h00000008, rdata);
        check(8, rdata,         32'h00000033, "RDATA reg2            ");
        check(8, S_AXI_RRESP,  2'b00,        "RRESP OKAY reg2       ");

        // ── Teste 9: Ler reg3 via AXI ─────────────────────────
        $display("");
        $display("── Teste 9: Ler reg3 via AXI (end=0x0C) ──");
        axi_read(32'h0000000C, rdata);
        check(9, rdata,         32'h00000044, "RDATA reg3            ");
        check(9, S_AXI_RRESP,  2'b00,        "RRESP OKAY reg3       ");

        // ── Teste 10: Verificar saídas dout ───────────────────
        $display("");
        $display("── Teste 10: Verificar saidas dout ──");
        check(10, reg0_dout, 32'h00000011, "reg0_dout             ");
        check(10, reg1_dout, 32'h00000022, "reg1_dout             ");
        check(10, reg2_dout, 32'h00000033, "reg2_dout             ");
        check(10, reg3_dout, 32'h00000044, "reg3_dout             ");

        // ── Teste 11: Tentar escrever reg2 via AXI ────────────
        $display("");
        $display("── Teste 11: Tentar escrever em reg2 (end=0x08) — deve ser ignorado ──");
        axi_write(32'h00000008, 32'hDEADBEEF);
        @(posedge ACLK); #1;
        check(11, reg2_dout, 32'h00000033, "reg2 mantem reg2_din  ");

        // ── Teste 12: Tentar escrever reg3 via AXI ────────────
        $display("");
        $display("── Teste 12: Tentar escrever em reg3 (end=0x0C) — deve ser ignorado ──");
        axi_write(32'h0000000C, 32'hCAFEBABE);
        @(posedge ACLK); #1;
        check(12, reg3_dout, 32'h00000044, "reg3 mantem reg3_din  ");

        // ── Resumo ────────────────────────────────────────────
        $display("");
        $display("============================================================");
        $display("  RESUMO: %0d PASS | %0d FAIL | Total: %0d testes",
                 pass_count, fail_count, pass_count + fail_count);
        $display("============================================================");
        $display("");
        $finish;
    end

endmodule
