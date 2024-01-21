//*************************************************************************
//   > �ļ���: regfile_display.v
//   > ����  ���Ĵ�������ʾģ�飬����FPGA���ϵ�IO�ӿںʹ�����
//   > ����  : LOONGSON
//   > ����  : 2016-04-14
//*************************************************************************
module regfile_display(
    //ʱ���븴λ�ź�
    input clk,
    input resetn,    //��׺"n"����͵�ƽ��Ч

    //���뿪�أ����ڲ���дʹ�ܺ�ѡ��������
    input wen,
    input [1:0] input_sel,

    //led�ƣ�����ָʾдʹ���źţ�����������ʲô����
    output led_wen,
    output led_waddr,    //ָʾ����д��ַ
    output led_wdata,    //ָʾ����д����
    output led_raddr1,   //ָʾ�������ַ1
    output led_raddr2,   //ָʾ�������ַ2

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
    assign led_wen    = wen;
    assign led_raddr1 = (input_sel==2'd0);
    assign led_raddr2 = (input_sel==2'd1);
    assign led_waddr  = (input_sel==2'd2);
    assign led_wdata  = (input_sel==2'd3);
//-----{LED��ʾ}end

//-----{���üĴ�����ģ��}begin
    //�Ĵ����Ѷ�����һ�����˿ڣ������ڴ���������ʾ32���Ĵ���ֵ
    wire [31:0] test_data;  
    wire [4 :0] test_addr;

    reg  [4 :0] raddr1;
    reg  [4 :0] raddr2;
    reg  [4 :0] waddr;
    reg  [31:0] wdata;
    wire [31:0] rdata1;
    wire [31:0] rdata2;
    regfile rf_module(
        .clk   (clk   ),
        .wen   (wen   ),
        .raddr1(raddr1),
        .raddr2(raddr2),
        .waddr (waddr ),
        .wdata (wdata ),
        .rdata1(rdata1),
        .rdata2(rdata2),
        .test_addr(test_addr),
        .test_data(test_data)
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
    //32���Ĵ�����ʾ��7~38�ŵ���ʾ�飬�ʶ���ַΪ��display_number-1��
    assign test_addr = display_number-5'd7; 
    //��input_selΪ2'b00ʱ����ʾ������Ϊ����ַ1����raddr1
    always @(posedge clk)
    begin
        if (!resetn)
        begin
            raddr1 <= 5'd0;
        end
        else if (input_valid &&  input_sel==2'd0)
        begin
            raddr1 <= input_value[4:0];
        end
    end
    
    //��input_selΪ2'b01ʱ����ʾ������Ϊ����ַ2����raddr2
    always @(posedge clk)
    begin
        if (!resetn)
        begin
            raddr2 <= 5'd0;
        end
        else if (input_valid && input_sel==2'd1)
        begin
            raddr2 <= input_value[4:0];
        end
    end
    
    //��input_selΪ2'b10ʱ����ʾ������Ϊд��ַ����waddr
    always @(posedge clk)
    begin
        if (!resetn)
        begin
            waddr  <= 5'd0;
        end
        else if (input_valid && input_sel==2'd2)
        begin
            waddr  <= input_value[4:0];
        end
    end
    
    //��input_selΪ2'b11ʱ����ʾ������Ϊд���ݣ���wdata
    always @(posedge clk)
    begin
        if (!resetn)
        begin
            wdata  <= 32'd0;
        end
        else if (input_valid && input_sel==2'd3)
        begin
            wdata  <= input_value;     
        end
    end
//-----{�Ӵ�������ȡ����}end

//-----{�������������ʾ}begin
//������Ҫ��ʾ�����޸Ĵ�С�ڣ�
//�������Ϲ���44����ʾ���򣬿���ʾ44��32λ����
//44����ʾ�����1��ʼ��ţ����Ϊ1~44��
    always @(posedge clk)
    begin
        if (display_number >6'd6 && display_number <6'd39 )
        begin //���7~38��ʾ32��ͨ�üĴ�����ֵ
            display_valid <= 1'b1;
            display_name[39:16] <= "REG";
            display_name[15: 8] <= {4'b0011,3'b000,test_addr[4]};
            display_name[7 : 0] <= {4'b0011,test_addr[3:0]}; 
            display_value       <= test_data;
          end
        else
        begin
            case(display_number)
                6'd1 : //��ʾ���˿�1�ĵ�ַ
                begin
                    display_valid <= 1'b1;
                    display_name  <= "RADD1";
                    display_value <= raddr1;
                end
                6'd2 : //��ʾ���˿�1����������
                begin
                    display_valid <= 1'b1;
                    display_name  <= "RDAT1";
                    display_value <= rdata1;
                end
                6'd3 : //��ʾ���˿�2�ĵ�ַ
                begin
                    display_valid <= 1'b1;
                    display_name  <= "RADD2";
                    display_value <= raddr2;
                end
                6'd4 : //��ʾ���˿�2����������
                begin
                    display_valid <= 1'b1;
                    display_name  <= "RDAT2";
                    display_value <= rdata2;
                end
                6'd5 : //��ʾд�˿ڵĵ�ַ
                begin
                    display_valid <= 1'b1;
                    display_name  <= "WADDR";
                    display_value <= waddr;
                end
                6'd6 : //��ʾд�˿�д�������
                begin
                    display_valid <= 1'b1;
                    display_name  <= "WDATA";
                    display_value <= wdata;
                end
                default :
                begin
                    display_valid <= 1'b0;
                    display_name  <= 40'd0;
                    display_value <= 32'd0;
                end
            endcase
        end
    end
//-----{�������������ʾ}end
//----------------------{���ô�����ģ��}end---------------------//
endmodule
