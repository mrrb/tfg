// Prueba para verificar la posibilidad de utiliza run reloj externo en la FPGA
//
// En este caso, se utiliza un divisor de longitud 26 ante una entrada de 60MHz para tener una pulsación
// en el LED verde de aproximadamente 1.11 segundos

module counter(input clk_int,
               input clk_ext,
               output [1:0]clks,
               output [4:0]LEDs);

    localparam div_val = 27;

    reg [div_val:0] divider;

    always @(posedge clk_ext) begin
        divider <= divider + 1;
    end

    assign LEDs[4:0] = divider[div_val:div_val-4];
    
    assign clks = {clk_ext, clk_int};

endmodule