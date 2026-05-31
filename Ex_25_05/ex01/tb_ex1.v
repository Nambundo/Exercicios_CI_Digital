`timescale 1ns/1ps

module tb_cache_simples;

    // Sinais
    reg        clk;
    reg        reset;
    reg        read;
    reg  [3:0] address;
    reg  [7:0] mem_data;
    wire [7:0] cache_data;
    wire       hit;
    wire       miss;

    // Instancia o módulo
    cache_simples dut (
        .clk        (clk),
        .reset      (reset),
        .read       (read),
        .address    (address),
        .mem_data   (mem_data),
        .cache_data (cache_data),
        .hit        (hit),
        .miss       (miss)
    );

    // Clock: período de 10 ns
    initial clk = 0;
    always #5 clk = ~clk;

    // Tarefa auxiliar para exibir resultado
    task acesso;
        input [3:0]  addr;
        input [7:0]  dado;
        input [7:0]  acesso_num;
        begin
            address  = addr;
            mem_data = dado;
            read     = 1;
            @(posedge clk); #1;
            $display("Acesso %0d | Endereço: %b | Tag: %b | Índice: %b | Resultado: %s | Dado: %h",
                     acesso_num, addr, addr[3:2], addr[1:0],
                     hit ? "HIT " : "MISS",
                     cache_data);
            read = 0;
            @(posedge clk); #1;
        end
    endtask

    initial begin
        // ── Geração do arquivo de ondas ──
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_cache_simples);

        $display("=======================================================");
        $display("  Exercício 1 — Cache Mapeada Diretamente Simples");
        $display("  4 blocos | Endereço 4 bits | TAG[3:2] | ÍNDICE[1:0]");
        $display("=======================================================");

        // Reset inicial
        reset = 1; read = 0; address = 0; mem_data = 0;
        @(posedge clk); #1;
        reset = 0;
        @(posedge clk); #1;

        $display("Acesso | Endereço | Tag | Índice | Resultado | Dado");
        $display("-------------------------------------------------------");

        acesso(4'b1011, 8'hA1, 1);   // 1: MISS  (1ª vez, cache vazia)
        acesso(4'b1011, 8'hA1, 2);   // 2: HIT   (mesmo endereço)
        acesso(4'b0011, 8'hB2, 3);   // 3: MISS  (mesmo índice, tag diferente)
        acesso(4'b0011, 8'hB2, 4);   // 4: HIT   (mesmo endereço)
        acesso(4'b1011, 8'hA1, 5);   // 5: MISS  (conflito: tag 10 foi substituída por 00)

        $display("=======================================================");
        $display("Simulação concluída.");
        $finish;
    end

endmodule