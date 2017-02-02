library verilog;
use verilog.vl_types.all;
entity MC68K_vlg_sample_tst is
    port(
        Bus_Request_SW8_H: in     vl_logic;
        CLK_50Mhz       : in     vl_logic;
        FlashData       : in     vl_logic_vector(7 downto 0);
        InPortA         : in     vl_logic_vector(7 downto 0);
        InPortB         : in     vl_logic_vector(7 downto 0);
        InPortC         : in     vl_logic_vector(7 downto 0);
        InPortE         : in     vl_logic_vector(7 downto 0);
        IRQ2_Key2_L     : in     vl_logic;
        IRQ4_Key1_L     : in     vl_logic;
        RESET_Key0_L    : in     vl_logic;
        RS232_RxData    : in     vl_logic;
        sdram_dq        : in     vl_logic_vector(15 downto 0);
        SRam_Data       : in     vl_logic_vector(15 downto 0);
        Trace_Request_Key3_L: in     vl_logic;
        sampler_tx      : out    vl_logic
    );
end MC68K_vlg_sample_tst;
