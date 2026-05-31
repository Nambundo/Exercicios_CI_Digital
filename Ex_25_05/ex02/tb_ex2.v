
`timescale 1ns/1ps

module tb_cache_contadores;

    // Sinais
    reg        clk;
    reg        reset;
    reg        read;
    reg  [4:0] address;
    reg  [7:0] mem_data;
    wire [7:0] cache_data;
    wire       hit;
    wire       miss;
    wire [7:0] hit_count;
    wire [7:0] miss_count;

    // Instancia o módulo
    cache_contadores dut (
        .clk        (clk),
        .reset      (reset),
        .read       (read),
        .address    (address),
        .mem_data   (mem_data),
        .cache_data (cache_data),
        .hit        (hit),
        .miss       (miss),
        .hit_count  (hit_count),
        .miss_count (miss_count)
    );

    // Clock: período de 10 ns
    initial clk = 0;
    always #5 clk = ~clk;

    integer num_acesso;

    task acesso;
        input [4:0] addr;
        input [7:0] dado;
        begin
            num_acesso = num_acesso + 1;
            address    = addr;
            mem_data   = dado;
            read       = 1;
            @(posedge clk); #1;
            $display("Acesso %0d | End: %b | Tag: %b | Idx: %b | %s | Dado: %h | Hits: %0d | Miss: %0d",
                     num_acesso, addr, addr[4:3], addr[2:0],
                     hit ? "HIT " : "MISS",
                     cache_data,
                     hit_count, miss_count);
            read = 0;
            @(posedge clk); #1;
        end
    endtask

    initial begin
        // Geração do arquivo de ondas — caminho absoluto para Windows
        $dumpfile("C:/Users/jones/Desktop/Projectos/ex02/wave_ex2.vcd");
        $dumpvars(0, tb_cache_contadores);

        num_acesso = 0;

        $display("===========================================================");
        $display("  Exercicio 2 - Cache com Contadores de Hit e Miss");
        $display("  8 blocos | Endereco 5 bits | TAG[4:3] | INDICE[2:0]");
        $display("===========================================================");

        // Reset
        reset = 1; read = 0; address = 0; mem_data = 0;
        @(posedge clk); #1;
        reset = 0;
        @(posedge clk); #1;

        acesso(5'b10110, 8'hA1);  // 1: MISS
        acesso(5'b11010, 8'hB2);  // 2: MISS
        acesso(5'b10110, 8'hA1);  // 3: HIT
        acesso(5'b11010, 8'hB2);  // 4: HIT
        acesso(5'b10000, 8'hC3);  // 5: MISS
        acesso(5'b00011, 8'hD4);  // 6: MISS
        acesso(5'b10000, 8'hC3);  // 7: HIT
        acesso(5'b10010, 8'hE5);  // 8: MISS (conflito indice 010)
        acesso(5'b10000, 8'hC3);  // 9: HIT

        $display("===========================================================");
        $display("  Total de acessos : %0d", num_acesso);
        $display("  Hits             : %0d", hit_count);
        $display("  Misses           : %0d", miss_count);
        $display("  Taxa de acerto   : 4/9 = 44.44%%");
        $display("===========================================================");
        $finish;
    end

endmodule