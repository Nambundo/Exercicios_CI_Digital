// Especificação:
//   - 4 registradores de 32 bits
//   - reg0, reg1: controle — escritos via AXI4-Lite
//   - reg2, reg3: status   — atualizados por entradas externas
//   - Mapeamento: 0x00, 0x04, 0x08, 0x0C
// ============================================================

module axi4lite_regs (
    // ── Clock e Reset ────────────────────────────────────────
    input  wire        ACLK,
    input  wire        ARESETn,       // reset ativo em nível baixo

    // ── Canal AW — Write Address ─────────────────────────────
    input  wire [31:0] S_AXI_AWADDR,
    input  wire        S_AXI_AWVALID,
    output reg         S_AXI_AWREADY,

    // ── Canal W — Write Data ─────────────────────────────────
    input  wire [31:0] S_AXI_WDATA,
    input  wire [3:0]  S_AXI_WSTRB,
    input  wire        S_AXI_WVALID,
    output reg         S_AXI_WREADY,

    // ── Canal B — Write Response ─────────────────────────────
    output reg  [1:0]  S_AXI_BRESP,
    output reg         S_AXI_BVALID,
    input  wire        S_AXI_BREADY,

    // ── Canal AR — Read Address ───────────────────────────────
    input  wire [31:0] S_AXI_ARADDR,
    input  wire        S_AXI_ARVALID,
    output reg         S_AXI_ARREADY,

    // ── Canal R — Read Data ───────────────────────────────────
    output reg  [31:0] S_AXI_RDATA,
    output reg  [1:0]  S_AXI_RRESP,
    output reg         S_AXI_RVALID,
    input  wire        S_AXI_RREADY,

    // ── Entradas externas ─────────────────────────────────────
    input  wire [31:0] reg0_din,   // mantido para padronização
    input  wire [31:0] reg1_din,   // mantido para padronização
    input  wire [31:0] reg2_din,   // status externo
    input  wire [31:0] reg3_din,   // status externo

    // ── Saídas dos registradores ──────────────────────────────
    output wire [31:0] reg0_dout,
    output wire [31:0] reg1_dout,
    output wire [31:0] reg2_dout,
    output wire [31:0] reg3_dout
);

    // ── Registradores internos ────────────────────────────────
    reg [31:0] reg0;   // controle — escrito via AXI
    reg [31:0] reg1;   // controle — escrito via AXI
    // reg2 e reg3 são combinacionais (direto de din)

    // ── Saídas contínuas ─────────────────────────────────────
    assign reg0_dout = reg0;
    assign reg1_dout = reg1;
    assign reg2_dout = reg2_din;   // status: sempre reflete a entrada
    assign reg3_dout = reg3_din;   // status: sempre reflete a entrada

    // ── Endereço de escrita capturado ─────────────────────────
    reg [31:0] aw_addr_lat;   // endereço AW travado no handshake
    reg        aw_done;       // flag: endereço AW recebido
    reg        w_done;        // flag: dado W  recebido

    // =========================================================
    // ESCRITA — canais AW e W (independentes, conforme AXI4)
    // =========================================================
    always @(posedge ACLK or negedge ARESETn) begin
        if (!ARESETn) begin
            S_AXI_AWREADY <= 1'b0;
            S_AXI_WREADY  <= 1'b0;
            S_AXI_BVALID  <= 1'b0;
            S_AXI_BRESP   <= 2'b00;
            aw_addr_lat   <= 32'h0;
            aw_done       <= 1'b0;
            w_done        <= 1'b0;
            reg0          <= 32'h0;
            reg1          <= 32'h0;
        end
        else begin

            // ── Handshake AW ──────────────────────────────────
            if (S_AXI_AWVALID && !S_AXI_AWREADY) begin
                S_AXI_AWREADY <= 1'b1;
                aw_addr_lat   <= S_AXI_AWADDR;
                aw_done       <= 1'b1;
            end else begin
                S_AXI_AWREADY <= 1'b0;
            end

            // ── Handshake W ───────────────────────────────────
            if (S_AXI_WVALID && !S_AXI_WREADY) begin
                S_AXI_WREADY <= 1'b1;
                w_done       <= 1'b1;
            end else begin
                S_AXI_WREADY <= 1'b0;
            end

            // ── Escrita no registrador quando AW e W completos ─
            if (aw_done && w_done) begin
                aw_done <= 1'b0;
                w_done  <= 1'b0;
                // Aplica strobe byte a byte
                case (aw_addr_lat[3:0])
                    4'h0: begin  // reg0 — controle
                        if (S_AXI_WSTRB[0]) reg0[ 7: 0] <= S_AXI_WDATA[ 7: 0];
                        if (S_AXI_WSTRB[1]) reg0[15: 8] <= S_AXI_WDATA[15: 8];
                        if (S_AXI_WSTRB[2]) reg0[23:16] <= S_AXI_WDATA[23:16];
                        if (S_AXI_WSTRB[3]) reg0[31:24] <= S_AXI_WDATA[31:24];
                    end
                    4'h4: begin  // reg1 — controle
                        if (S_AXI_WSTRB[0]) reg1[ 7: 0] <= S_AXI_WDATA[ 7: 0];
                        if (S_AXI_WSTRB[1]) reg1[15: 8] <= S_AXI_WDATA[15: 8];
                        if (S_AXI_WSTRB[2]) reg1[23:16] <= S_AXI_WDATA[23:16];
                        if (S_AXI_WSTRB[3]) reg1[31:24] <= S_AXI_WDATA[31:24];
                    end
                    // 0x08 e 0x0C: reg2/reg3 são status — ignora escrita
                    default: ; // endereço inválido — não altera nada
                endcase
                // Gera resposta OKAY
                S_AXI_BRESP  <= 2'b00;
                S_AXI_BVALID <= 1'b1;
            end

            // ── Handshake B ───────────────────────────────────
            if (S_AXI_BVALID && S_AXI_BREADY) begin
                S_AXI_BVALID <= 1'b0;
            end
        end
    end

    // =========================================================
    // LEITURA — canais AR e R
    // =========================================================
    always @(posedge ACLK or negedge ARESETn) begin
        if (!ARESETn) begin
            S_AXI_ARREADY <= 1'b0;
            S_AXI_RVALID  <= 1'b0;
            S_AXI_RDATA   <= 32'h0;
            S_AXI_RRESP   <= 2'b00;
        end
        else begin

            // ── Handshake AR + seleção do registrador ─────────
            if (S_AXI_ARVALID && !S_AXI_ARREADY) begin
                S_AXI_ARREADY <= 1'b1;
                S_AXI_RRESP   <= 2'b00;  // OKAY
                S_AXI_RVALID  <= 1'b1;
                case (S_AXI_ARADDR[3:0])
                    4'h0:    S_AXI_RDATA <= reg0;
                    4'h4:    S_AXI_RDATA <= reg1;
                    4'h8:    S_AXI_RDATA <= reg2_din;  // status externo
                    4'hC:    S_AXI_RDATA <= reg3_din;  // status externo
                    default: S_AXI_RDATA <= 32'hDEADBEEF; // endereço inválido
                endcase
            end else begin
                S_AXI_ARREADY <= 1'b0;
            end

            // ── Handshake R ───────────────────────────────────
            if (S_AXI_RVALID && S_AXI_RREADY) begin
                S_AXI_RVALID <= 1'b0;
            end
        end
    end

endmodule
