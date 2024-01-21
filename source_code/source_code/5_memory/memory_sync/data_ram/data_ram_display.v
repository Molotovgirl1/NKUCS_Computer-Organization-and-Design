`timescale 1ns / 1ps
//*************************************************************************
//   > �ļ���: data_ram_display.v
//   > ����  �����ݴ洢��ģ����ʾģ�飬����FPGA���ϵ�IO�ӿںʹ�����
//   > ����  : LOONGSON
//   > ����  : 2016-04-14
//*************************************************************************
module data_ram_display(
    //ʱ���븴λ�ź�
    input clk,
    input resetn,    //��׺"n"����͵�ƽ��Ч

    //���뿪�أ����ڲ���дʹ�ܺ�ѡ��������
    input [3:0] wen,
    input [1:0] input_sel,

    //led�ƣ�����ָʾдʹ���źţ�����������ʲô����
    output [3:0] led_wen,
    output led_addr,      //ָʾ�����д��ַ
    output led_wdata,     //ָʾ����д����
    output led_test_addr, //ָʾ����test��ַ

    //��������ؽӿڣ�����Ҫ����
    output lcd_rst,
    output lcd_cs,
    output lcd_rs,
    output lcd_wr,
    output lcd_rd,
    inout[15:0] lcd_data_io,
    output lcd_bl_ctr,
    inout ct_int,
    inout ct_sda,
    output ct_scl,
    output ct_rstn
    );
//-----{LED��ʾ}begin
    assign led_wen       = wen;
    assign led_addr      = (input_sel==2'd0);
    assign led_wdata     = (input_sel==2'd1);
    assign led_test_addr = (input_sel==2'd2);
//-----{LED��ʾ}end
//-----{�������ݴ�����ģ��}begin
    //���ݴ洢��������һ�����˿ڣ����ڶ����ض��ڴ��ַ��ʾ�ڴ�������
    reg  [31:0] addr;
    reg  [31:0] wdata;
    wire [31:0] rdata;
    reg  [31:0] test_addr;
    wire [31:0] test_data;  

    data_ram data_ram_module(
        .clka  (clk           ),
        .wea   (wen           ),
        .addra (addr[9:2]     ),
        .dina  (wdata         ),
        .douta (rdata         ),
        .clkb  (clk           ),
        .web   (4'd0          ),
        .addrb (test_addr[9:2]),
        .doutb (test_data     ),
        .dinb  (32'd0         )
    );
//-----{���üĴ�����ģ��}end

//---------------------{���ô�����ģ��}begin--------------------//
//-----{ʵ����������}begin
//��С�ڲ���Ҫ����
    reg         display_valid;
    reg  [39:0] display_name;
    reg  [31:0] display_value;
    wire [5 :0] display_number;
    wire        input_valid;
    wire [31:0] input_value;

    lcd_module lcd_module(
        .clk            (clk           ),   //10Mhz
        .resetn         (resetn        ),

        //���ô������Ľӿ�
        .display_valid  (display_valid ),
        .display_name   (display_name  ),
        .display_value  (display_value ),
        .display_number (display_number),
        .input_valid    (input_valid   ),
        .input_value    (input_value   ),

        //lcd��������ؽӿڣ�����Ҫ����
        .lcd_rst        (lcd_rst       ),
        .lcd_cs         (lcd_cs        ),
        .lcd_rs         (lcd_rs        ),
        .lcd_wr         (lcd_wr        ),
        .lcd_rd         (lcd_rd        ),
        .lcd_data_io    (lcd_data_io   ),
        .lcd_bl_ctr     (lcd_bl_ctr    ),
        .ct_int         (ct_int        ),
        .ct_sda         (ct_sda        ),
        .ct_scl         (ct_scl        ),
        .ct_rstn        (ct_rstn       )
    ); 
//-----{ʵ����������}end

//-----{�Ӵ�������ȡ����}begin
//����ʵ����Ҫ��������޸Ĵ�С�ڣ�
//�����ÿһ���������룬��д����һ��always��
    //��input_selΪ2'b00ʱ����ʾ������Ϊ��д��ַ����addr
    always @(posedge clk)
    begin
        if (!resetn)
        begin
            addr <= 32'd0;
        end
        else if (input_valid &&  input_sel==2'd0)
        begin
            addr[31:2] <= input_value[31:2];
        end
    end
    
    //��input_selΪ2'b01ʱ����ʾ������Ϊд���ݣ���wdata
    always @(posedge clk)
    begin
        if (!resetn)
        begin
            wdata <= 32'd0;
        end
        else if (input_valid && input_sel==2'd1)
        begin
            wdata <= input_value;
        end
    end
    
    //��input_selΪ2'b10ʱ����ʾ������Ϊtest��ַ����test_addr
    always @(posedge clk)
    begin
        if (!resetn)
        begin
            test_addr  <= 32'd0;
        end
        else if (input_valid && input_sel==2'd2)
        begin
            test_addr[31:2] <= input_value[31:2];
        end
    end
//-----{�Ӵ�������ȡ����}end

//-----{�������������ʾ}begin
//������Ҫ��ʾ�����޸Ĵ�С�ڣ�
//�������Ϲ���44����ʾ���򣬿���ʾ44��32λ����
//44����ʾ�����1��ʼ��ţ����Ϊ1~44��
    always @(posedge clk)
    begin
       case(display_number)
           6'd1:
           begin
               display_valid <= 1'b1;
               display_name  <= "ADDR ";
               display_value <= addr;
           end
           6'd2: 
           begin
               display_valid <= 1'b1;
               display_name  <= "WDATA";
               display_value <= wdata;
           end
           6'd3: 
           begin
               display_valid <= 1'b1;
               display_name  <= "RDATA";
               display_value <= rdata;
           end
           6'd5: 
           begin
               display_valid <= 1'b1;
               display_name  <= "T_ADD";
               display_value <= test_addr;
           end
           6'd6: 
           begin
               display_valid <= 1'b1;
               display_name  <= "T_DAT";
               display_value <= test_data;
           end
           default :
           begin
               display_valid <= 1'b0;
               display_name  <= 40'd0;
               display_value <= 32'd0;
           end
       endcase
    end
//-----{�������������ʾ}end
//----------------------{���ô�����ģ��}end---------------------//
endmodule
