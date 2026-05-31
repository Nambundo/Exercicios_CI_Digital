module cache_contadores (
    input  wire        clk,
    input  wire        reset,
    input  wire        read,
    input  wire [4:0]  address,
    input  wire [7:0]  mem_data,
    output reg  [7:0]  cache_data,
    output reg         hit,
    output reg         miss,
    output reg  [7:0]  hit_count,
    output reg  [7:0]  miss_count
);

    // Memória interna da cache
    reg        valid     [0:7];  // bits de validade
    reg [1:0]  tag_array [0:7];  // tags armazenadas (2 bits)
    reg [7:0]  data_array[0:7];  // dados armazenados

    // Divisão do endereço: 5 bits → TAG[4:3] | ÍNDICE[2:0]
    wire [1:0] tag   = address[4:3];
    wire [2:0] index = address[2:0];

    integer i;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i = 0; i < 8; i = i + 1)
                valid[i] <= 1'b0;
            hit        <= 1'b0;
            miss       <= 1'b0;
            hit_count  <= 8'd0;
            miss_count <= 8'd0;
            cache_data <= 8'h00;
        end
        else if (read) begin
            if (valid[index] && (tag_array[index] == tag)) begin
                // HIT
                hit        <= 1'b1;
                miss       <= 1'b0;
                cache_data <= data_array[index];
                hit_count  <= hit_count + 1;
            end
            else begin
                // MISS — substitui o conteúdo da posição
                hit              <= 1'b0;
                miss             <= 1'b1;
                valid[index]     <= 1'b1;
                tag_array[index] <= tag;
                data_array[index]<= mem_data;
                cache_data       <= mem_data;
                miss_count       <= miss_count + 1;
            end
        end
        else begin
            hit  <= 1'b0;
            miss <= 1'b0;
        end
    end

endmodule
