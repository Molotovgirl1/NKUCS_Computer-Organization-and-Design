`timescale 1ns / 1ps   //���浥λʱ��Ϊ1ns������Ϊ1ps
module testbench;

    // Inputs
    reg [31:0] operand1;
    reg [31:0] operand2;
    reg cin;

    // Outputs
    wire [31:0] result;
    wire cout;
    // Instantiate the Unit Under Test (UUT)
    adder uut (
        .operand1(operand1), 
        .operand2(operand2), 
        .cin(cin), 
        .result(result), 
        .cout(cout)
    );
    initial begin
        // Initialize Inputs
        operand1 = 0;
        operand2 = 0;
        cin = 0;
        // Wait 100 ns for global reset to finish
        #100;
        // Add stimulus here
    end
    always #10 operand1 = $random;  //$randomΪϵͳ���񣬲���һ�������32λ��
    always #10 operand2 = $random;  //#10 ��ʾ�ȴ�10����λʱ��(10ns)����ÿ��10ns����ֵһ�������32λ��
    always #10 cin = {$random} % 2; //����ƴ�ӷ���{$random}����һ���Ǹ�������2ȡ��õ�0��1
endmodule

