module mux_prepc (
input wire ContOrExcep;
input wire[31:0] Data0;
input wire[31:0] Data1;
output wire[31:0] DataOut;

);

assign DataOut = (ContOrExep) ? Data1 : Data0;
end module;