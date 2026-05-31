module cache_simples (
    input  wire        clk,
    input  wire        reset,
    input  wire        read,
    input  wire [3:0]  address,
    input  wire [7:0]  mem_data,
    output reg  [7:0]  cache_data,
    output reg         hit,
    output reg         miss
);

    // Memória interna da cache
    reg        valid     [0:3];  // bits de validade
    reg [1:0]  tag_array [0:3];  // tags armazenadas
    reg [7:0]  data_array[0:3];  // dados armazenados

    // Divisão do endereço
    wire [1:0] tag   = address[3:2];  // bits mais significativos
    wire [1:0] index = address[1:0];  // bits menos significativos

    integer i;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Zera todos os bits de validade
            for (i = 0; i < 4; i = i + 1)
                valid[i] <= 1'b0;
            hit        <= 1'b0;
            miss       <= 1'b0;
            cache_data <= 8'h00;
        end
        else if (read) begin
            if (valid[index] && (tag_array[index] == tag)) begin
                // HIT — dado encontrado na cache
                hit        <= 1'b1;
                miss       <= 1'b0;
                cache_data <= data_array[index];
            end
            else begin
                // MISS — carrega dado da memória principal
                hit              <= 1'b0;
                miss             <= 1'b1;
                valid[index]     <= 1'b1;
                tag_array[index] <= tag;
                data_array[index]<= mem_data;
                cache_data       <= mem_data;
            end
        end
        else begin
            hit  <= 1'b0;
            miss <= 1'b0;
        end
    end

endmodule
