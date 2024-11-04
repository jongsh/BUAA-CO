`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:46:14 11/06/2022 
// Design Name: 
// Module Name:    mips 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module mips(
    input clk,
    input reset,
    input [31:0] i_inst_rdata,
    input [31:0] m_data_rdata,
    output [31:0] i_inst_addr,
    output [31:0] m_data_addr,
    output [31:0] m_data_wdata,
    output [3 :0] m_data_byteen,
    output [31:0] m_inst_addr,
    output w_grf_we,
    output [4:0] w_grf_addr,
    output [31:0] w_grf_wdata,
    output [31:0] w_inst_addr
    );
	 
//////////////////////// ��ͻ���Ƶ�Ԫ /////////////////////////////////

	 wire [31:0] F_PC;           // F ��ָ���ַ
	 wire [31:0] D_PC;           // D ��ָ���ַ
	 wire [31:0] E_PC;           // E ��ָ���ַ
	 wire [31:0] M_PC;           // M ��ָ���ַ
	 wire [31:0] W_PC;           // W ��ָ���ַ
	 wire [3:0] D_rs_Tuse;       // D ��ָ��rs_Tuse
	 wire [3:0] D_rt_Tuse;       // D ��ָ��rt_Tuse
	 wire [3:0] D_Tnew;          // D ��ָ��Tnew
	 wire [3:0] E_rs_Tuse;       // E ��ָ��rs_Tuse
	 wire [3:0] E_rt_Tuse;       // E ��ָ��rt_Tuse
	 wire [3:0] E_Tnew;          // E ��ָ��Tnew
	 wire [3:0] M_rs_Tuse;       // M ��ָ��rs_Tuse
	 wire [3:0] M_rt_Tuse;       // M ��ָ��rt_Tuse
	 wire [3:0] M_Tnew;          // M ��ָ��Tnew
	 wire [3:0] W_rs_Tuse;       // W ��ָ��rs_Tuse
	 wire [3:0] W_rt_Tuse;       // W ��ָ��rt_Tuse
	 wire [3:0] W_Tnew;          // W ��ָ��Tnew
	 wire D_GRF_write;           // D ��ָ��GRFд�ź�
	 wire E_GRF_write;           // E ��ָ��GRFд�ź�
	 wire M_GRF_write;           // M ��ָ��GRFд�ź�
	 wire W_GRF_write;           // W ��ָ��GRFд�ź�
	 wire [4:0] D_GRF_A3;        // D ��ָ��Ŀ��Ĵ���
	 wire [3:0] D_GRF_DatatoReg; // D ��ָ��д����ѡ���ź�
	 wire [4:0] E_GRF_A3;        // E ��ָ��Ŀ��Ĵ���
	 wire [3:0] E_GRF_DatatoReg; // E ��ָ��д����ѡ���ź�
	 wire [4:0] M_GRF_A3;        // M ��ָ��Ŀ��Ĵ���
	 wire [3:0] M_GRF_DatatoReg; // M ��ָ��д����ѡ���ź�
	 wire [4:0] W_GRF_A3;        // W ��ָ��Ŀ��Ĵ���
	 wire [3:0] W_GRF_DatatoReg; // W ��ָ��д����ѡ���ź�
	 wire [4:0] D_FW_rs_sel;     // D ��ָ��rs����ת���ź�
	 wire [4:0] D_FW_rt_sel;     // D ��ָ��rt����ת���ź�
	 wire [4:0] E_FW_rs_sel;     // E ��ָ��rs����ת���ź�
	 wire [4:0] E_FW_rt_sel;     // E ��ָ��rt����ת���ź�
	 wire [4:0] M_FW_rt_sel;     // M ��ָ��rt����ת���ź�
	 wire stall;                 // �����ź�
	 wire E_flush;               // E ����ˮ�߼Ĵ�������ź�
	 wire D_MDU_start;           // D ��ָ�� MDU �Ŀ�ʼ�ź�
	 wire E_MDU_start;           // E ��ָ�� MDU �Ŀ�ʼ�ź�
	 wire E_MDU_busy;            // E ��ָ�� MDU �Ĺ����ź�
	 
	 wire [31:0] F_instr;       // F ��ָ�������
	 wire [31:0] D_instr;       // D ��ָ�������
	 wire [31:0] E_instr;       // E ��ָ�������
	 wire [31:0] M_instr;       // M ��ָ�������
	 wire [31:0] W_instr;       // W ��ָ�������
	 
	 HCU hcu (
    .D_instr(D_instr), 
    .E_instr(E_instr), 
    .M_instr(M_instr), 
    .D_rs_Tuse(D_rs_Tuse), 
    .D_rt_Tuse(D_rt_Tuse), 
    .E_rs_Tuse(E_rs_Tuse), 
    .E_rt_Tuse(E_rt_Tuse), 
    .E_Tnew(E_Tnew), 
    .M_rt_Tuse(M_rt_Tuse), 
    .M_Tnew(M_Tnew), 
    .W_Tnew(W_Tnew), 
    .E_GRF_write(E_GRF_write), 
    .M_GRF_write(M_GRF_write), 
    .W_GRF_write(W_GRF_write), 
    .E_GRF_A3(E_GRF_A3), 
    .M_GRF_A3(M_GRF_A3), 
    .W_GRF_A3(W_GRF_A3), 
    .M_GRF_DatatoReg(M_GRF_DatatoReg), 
    .E_GRF_DatatoReg(E_GRF_DatatoReg), 
    .W_GRF_DatatoReg(W_GRF_DatatoReg), 
    .D_FW_rs_sel(D_FW_rs_sel), 
    .D_FW_rt_sel(D_FW_rt_sel), 
    .E_FW_rs_sel(E_FW_rs_sel), 
    .E_FW_rt_sel(E_FW_rt_sel), 
    .M_FW_rt_sel(M_FW_rt_sel), 
    .stall(stall),
	 .E_flush(E_flush),
	 .E_MDU_busy(E_MDU_busy),
	 .E_MDU_start(E_MDU_start)
    );
	 
///////////////////////// Fetch stage	/////////////////////////////////////

	 wire [31:0] F_PCnext;      // D ��PCģ������ֵ������NPC�������
	 wire F_PC_EN;              // PC ʹ���ź�
	 assign F_PC_EN = ~stall;
	 
	 PC pc (
    .clk(clk), 
    .reset(reset), 
    .F_PC_EN(F_PC_EN), 
    .F_PCnext(F_PCnext), 
    .F_PC(F_PC)
    );
	 
	 assign i_inst_addr = F_PC;
	 assign F_instr = i_inst_rdata;
	 
	 
////////////////////////////// Decode stage ////////////////////////////////////

	 wire [4:0] D_instr_rs;           // D ��ָ��rs��
	 wire [4:0] D_instr_rt;           // D ��ָ��rt��  
	 wire [4:0] D_instr_rd;           // D ��ָ��rd��
	 wire [5:0] D_instr_op;           // D ��ָ��opcode��
	 wire [5:0] D_instr_func;         // D ��ָ��functioncode��
	 wire [4:0] D_instr_shamt;        // D ��ָ��shamt��
	 wire [15:0] D_instr_imm16;       // D ��ָ��16λ������
	 wire [25:0] D_instr_imm26;       // D ��ָ��26λ������
	 wire [31:0] W_GRF_WD;            // W ������д��GRF������
	 wire [31:0] D_GRF_RD1;           // D ��ָ���GRF�����ĵ�һ�����ݣ�δת��
	 wire [31:0] D_GRF_RD2;           // D ��ָ���GRF�����ĵڶ������ݣ�δת��
	 wire [31:0] D_EXT_imm32;         // D ��ָ��EXTģ���32λ��������չ���
	 wire D_DM_write;                 // D ��ָ��DMд�ź�
	 wire [3:0] D_EXTop;              // D ��ָ���EXT�����ź�
	 wire [3:0] D_NPCop;              // D ��ָ���NPC�����ź�
	 wire [3:0] D_CMPop;              // D ��ָ���CMP�����ź�
	 wire [4:0] D_ALUop;              // D ��ָ���ALU�����ź�   
    wire [2:0] D_ALU_Bsel;           // D ��ָ�� ALU ������Bѡ���ź�	 
	 wire [2:0] D_GRF_A3_sel;         // D ��ָ��Ŀ�ļĴ���ѡ���ź�
	 wire [1:0] D_DMop;               // D ��ָ���DM�����ź�
	 wire [3:0] D_MDUop;              // D ��ָ���MDU�����ź�
	 wire D_MDUout_sel;               // D ��ָ���MDUoutѡ���ź�
	 wire [2:0] D_BEop;               // D ��ָ���BE�����ź�
	 wire [31:0] D_RD1;               // D ��ָ���GRF�����ĵ�һ�����ݣ���ת��
	 wire [31:0] D_RD2;               // D ��ָ���GRF�����ĵڶ������ݣ���ת��
	 wire [31:0] D_CMP_result;        // D ��ָ��CMP�ȽϽ��
	 wire F_D_REG_EN;                 // D ��ˮ�߼Ĵ���ʹ���ź�
	 
	 assign F_D_REG_EN = ~stall;
	 assign D_instr_rs = D_instr[25:21];
	 assign D_instr_rt = D_instr[20:16];
	 assign D_instr_rd = D_instr[15:11];
	 assign D_instr_shamt = D_instr[10:6];
	 assign D_instr_imm16 = D_instr[15:0];
	 assign D_instr_imm26 = D_instr[25:0];
	 assign D_instr_op = D_instr[31:26];
	 assign D_instr_func = D_instr[5:0];
	 
	 F_D_REG F_D_reg (
    .clk(clk), 
    .reset(reset), 
    .F_D_REG_EN(F_D_REG_EN), 
    .F_PC(F_PC), 
    .F_instr(F_instr), 
    .D_PC(D_PC), 
    .D_instr(D_instr)
    );
	 
	 CU controller (
    .D_CU_opcode(D_instr_op), 
    .D_CU_func(D_instr_func), 
    .D_GRF_write(D_GRF_write), 
    .D_DM_write(D_DM_write), 
    .D_EXTop(D_EXTop), 
    .D_CMPop(D_CMPop), 
    .D_NPCop(D_NPCop), 
    .D_ALUop(D_ALUop), 
    .D_GRF_DatatoReg(D_GRF_DatatoReg), 
    .D_GRF_A3_sel(D_GRF_A3_sel), 
    .D_ALU_Bsel(D_ALU_Bsel), 
    .D_DMop(D_DMop), 
	 .D_MDUop(D_MDUop),
	 .D_MDU_start(D_MDU_start),
	 .D_MDUout_sel(D_MDUout_sel),
	 .D_BEop(D_BEop),
    .D_rs_Tuse(D_rs_Tuse), 
    .D_rt_Tuse(D_rt_Tuse), 
    .D_Tnew(D_Tnew)
    );
	 
	 assign w_grf_we = W_GRF_write;
	 assign w_grf_addr = W_GRF_A3;
	 assign w_grf_wdata = W_GRF_WD;
	 assign w_inst_addr = W_PC;
	 
	 GRF grf (
    .clk(clk), 
    .reset(reset), 
    .GRF_write(W_GRF_write), 
    .GRF_A1(D_instr_rs), 
    .GRF_A2(D_instr_rt), 
    .GRF_A3(W_GRF_A3), 
    .GRF_WD(W_GRF_WD), 
    .GRF_RD1(D_GRF_RD1), 
    .GRF_RD2(D_GRF_RD2)
    );
	 
	 // 00000: keep; 00001: E_PC+8; 00010: E_CMP_result; 00011: M_PC+8; 00100: M_ALUout; 00101: M_CMP_result; 00110: M_MDUout
	 assign D_RD1 = (D_FW_rs_sel == 5'd0) ? D_GRF_RD1 :
	                (D_FW_rs_sel == 5'd1) ? E_PC + 32'd8 :
						 (D_FW_rs_sel == 5'd2) ? E_CMP_result :
						 (D_FW_rs_sel == 5'd3) ? M_PC + 32'd8 :
						 (D_FW_rs_sel == 5'd4) ? M_ALUout :
						 (D_FW_rs_sel == 5'd5) ? M_CMP_result :
						 (D_FW_rs_sel == 5'd6) ? M_MDUout :
						                         D_GRF_RD1;
														 
    assign D_RD2 = (D_FW_rt_sel == 5'd0) ? D_GRF_RD2 :
	                (D_FW_rt_sel == 5'd1) ? E_PC + 32'd8 :
						 (D_FW_rt_sel == 5'd2) ? E_CMP_result :
						 (D_FW_rt_sel == 5'd3) ? M_PC + 32'd8 :
						 (D_FW_rt_sel == 5'd4) ? M_ALUout :
						 (D_FW_rt_sel == 5'd5) ? M_CMP_result :
						 (D_FW_rt_sel == 5'd6) ? M_MDUout :
						                         D_GRF_RD2;
	 
	 EXT ext (
    .D_EXT_imm16(D_instr_imm16), 
    .D_EXTop(D_EXTop), 
    .D_EXT_imm32(D_EXT_imm32)
    );
	 
	 CMP cmp (
    .D_CMP_opA(D_RD1), 
    .D_CMP_opB(D_RD2), 
    .D_CMPop(D_CMPop), 
    .D_CMP_result(D_CMP_result)
    );
	 
	 NPC npc (
    .D_NPC_PC(F_PC), 
    .D_NPCop(D_NPCop), 
    .D_NPC_imm16(D_instr_imm16), 
    .D_NPC_imm26(D_instr_imm26), 
    .D_CMP_result(D_CMP_result), 
    .D_NPC_RegData(D_RD1), 
    .D_NPC_PCnext(F_PCnext)
    );
	 
	 // 000��rd��001��rt��010��31�żĴ���
	 assign D_GRF_A3 = (D_GRF_A3_sel == 3'd0) ? D_instr_rd :
	                   (D_GRF_A3_sel == 3'd1) ? D_instr_rt :
							 (D_GRF_A3_sel == 3'd2) ? 5'd31 :
							                          5'd0;
	 
//////////////////////////////// Execute stage /////////////////////////////////////////

	 wire [31:0] E_RD1;                 // E ���ĵ�һ���Ĵ�������,δת��
	 wire [31:0] E_RD2;                 // E ���ĵڶ����Ĵ������ݣ�δת��
	 wire [31:0] E_RD2_new;             // E ���ĵڶ����Ĵ������ݣ���ת��
	 wire [31:0] E_RD1_new;             // E ���ĵ�һ���Ĵ������ݣ���ת��
	 wire [31:0] E_ALU_opA;             // E ��ָ��ALU��һ��������������ת����ѡ��
	 wire [31:0] E_ALU_opB;             // E ��ָ��ALU�ڶ���������������ת����ѡ��
	 wire [4:0] E_ALUop;                // E ��ָ���ALU�����ź�
	 wire E_DM_write;                   // E ��ָ��DMд�ź�
	 wire [31:0] E_EXT_imm32;           // E ��ָ��EXTģ���32λ��������չ���
	 wire [31:0] E_CMP_result;          // E ��ָ��CMP�ȽϽ��
	 wire [2:0] E_ALU_Bsel;             // E ��ָ�� ALU ������Bѡ���ź�
	 wire [1:0] E_DMop;                 // E ��ָ���DM�����ź�
	 wire [4:0] E_instr_shamt;          // E ��ָ��shamt��
	 wire [31:0] E_ALUout;              // E ��ָ���ALU������
	 wire E_reg_reset;                  // E ����ˮ�߼Ĵ����ĸ�λ�ź�
	 wire [2:0] E_BEop;                 // E ��ָ��BE�����ź�
	 wire E_MDUout_sel;                 // E ��ָ���MDUoutѡ���ź�
	 wire [3:0] E_MDUop;                // E ��ָ���MDU����ѡ���ź�
	 wire [31:0] E_MDUout;              // E ��ָ���MDU������
	 wire [31:0] M_MDUout;              // M ��ָ��MDU������
	 wire [31:0] W_MDUout;              // W ��ָ��MDU������
	 wire [31:0] E_MDU_HI;              // MDU HI �Ĵ���
	 wire [31:0] E_MDU_LO;              // MDU LO �Ĵ���
	 
	 assign E_reg_reset = reset || E_flush;
	 
	 // 00000: keep; 00001: M_ALUout; 00010: M_PC+8; 00011: M_CMP_result; 00100: M_MDUout; 
	 // 00101: W_ALUout; 00110: W_DMout; 00111: W_PC+8; 01000: W_CMP_result; 01001: W_MDUout
	 assign E_RD2_new = (E_FW_rt_sel == 5'd0) ? E_RD2 :
	                    (E_FW_rt_sel == 5'd1) ? M_ALUout :
							  (E_FW_rt_sel == 5'd2) ? M_PC + 32'd8 :
							  (E_FW_rt_sel == 5'd3) ? M_CMP_result :
							  (E_FW_rt_sel == 5'd4) ? M_MDUout :
							  (E_FW_rt_sel == 5'd5) ? W_ALUout :
							  (E_FW_rt_sel == 5'd6) ? W_DMout :
							  (E_FW_rt_sel == 5'd7) ? W_PC+ 32'd8 :
                       (E_FW_rt_sel == 5'd8) ? W_CMP_result:
							  (E_FW_rt_sel == 5'd9) ? W_MDUout :
                                               E_RD2;
															  
	 assign E_RD1_new = (E_FW_rs_sel == 5'd0) ? E_RD1 :
	                    (E_FW_rs_sel == 5'd1) ? M_ALUout :
							  (E_FW_rs_sel == 5'd2) ? M_PC + 32'd8 :
							  (E_FW_rs_sel == 5'd3) ? M_CMP_result :
							  (E_FW_rs_sel == 5'd4) ? M_MDUout :
							  (E_FW_rs_sel == 5'd5) ? W_ALUout :
							  (E_FW_rs_sel == 5'd6) ? W_DMout :
							  (E_FW_rs_sel == 5'd7) ? W_PC+ 32'd8 :
                       (E_FW_rs_sel == 5'd8) ? W_CMP_result:
							  (E_FW_rs_sel == 5'd9) ? W_MDUout :
                                               E_RD1;
															  
	 assign E_ALU_opA = E_RD1_new;
	 // 000��RD2 001����չ���32λ������												  
    assign E_ALU_opB	= (E_ALU_Bsel == 3'd0) ? E_RD2_new :
                       (E_ALU_Bsel == 3'd1) ? E_EXT_imm32 :
                                              32'd0;							  
	 
    D_E_REG D_E_reg (
    .clk(clk), 
    .reset(E_reg_reset), 
    .D_E_REG_EN(1'b1), 
    .D_PC(D_PC), 
    .D_instr(D_instr), 
    .D_ALUop(D_ALUop), 
    .D_DM_write(D_DM_write), 
    .D_GRF_write(D_GRF_write), 
    .D_RD1(D_RD1), 
    .D_RD2(D_RD2), 
    .D_instr_shamt(D_instr_shamt), 
    .D_EXT_imm32(D_EXT_imm32), 
    .D_GRF_A3(D_GRF_A3), 
    .D_CMP_result(D_CMP_result), 
    .D_GRF_DatatoReg(D_GRF_DatatoReg), 
    .D_ALU_Bsel(D_ALU_Bsel), 
    .D_DMop(D_DMop), 
    .D_rs_Tuse(D_rs_Tuse), 
    .D_rt_Tuse(D_rt_Tuse), 
    .D_Tnew(D_Tnew),
	 .D_MDU_start(D_MDU_start),
	 .D_BEop(D_BEop),
	 .D_MDUout_sel(D_MDUout_sel),
	 .D_MDUop(D_MDUop),	 
    .E_PC(E_PC), 
    .E_instr(E_instr), 
    .E_ALUop(E_ALUop), 
    .E_DM_write(E_DM_write), 
    .E_GRF_write(E_GRF_write), 
    .E_RD1(E_RD1), 
    .E_RD2(E_RD2), 
    .E_instr_shamt(E_instr_shamt), 
    .E_EXT_imm32(E_EXT_imm32), 
    .E_GRF_A3(E_GRF_A3), 
    .E_CMP_result(E_CMP_result), 
    .E_GRF_DatatoReg(E_GRF_DatatoReg), 
    .E_ALU_Bsel(E_ALU_Bsel), 
    .E_DMop(E_DMop), 
	 .E_MDU_start(E_MDU_start),
	 .E_BEop(E_BEop),
	 .E_MDUout_sel(E_MDUout_sel),
	 .E_MDUop(E_MDUop),
    .E_rs_Tuse(E_rs_Tuse), 
    .E_rt_Tuse(E_rt_Tuse), 
    .E_Tnew(E_Tnew)
    );

	 ALU alu (
    .ALU_opA(E_ALU_opA), 
    .ALU_opB(E_ALU_opB), 
    .ALU_opC(E_instr_shamt), 
    .ALUop(E_ALUop), 
    .ALU_result(E_ALUout)
    );
	 
	 MDU mdu (
    .clk(clk), 
    .reset(reset), 
    .start(E_MDU_start), 
    .MDU_opA(E_RD1_new), 
    .MDU_opB(E_RD2_new), 
    .MDUop(E_MDUop), 
    .busy(E_MDU_busy), 
    .HI(E_MDU_HI), 
    .LO(E_MDU_LO)
    );
	 
	 // 0��HI �Ĵ�����1��LO �Ĵ���
	 assign E_MDUout = (E_MDUout_sel == 1'b0) ? E_MDU_HI :
	                   (E_MDUout_sel == 1'b1) ? E_MDU_LO :
							                          32'd0;
	 
///////////////////////////////////// Memory stage //////////////////////////////////

	 wire [31:0] M_RD2;                // M ��ָ��ĵڶ����Ĵ������ݣ�δת��
	 wire [31:0] M_RD2_new;            // M ��ָ��ĵڶ����Ĵ������ݣ���ת��
	 wire [31:0] M_DM_WD;              // M ��ָ��DMд����
	 wire M_DM_write;                  // M ��ָ���DMд�ź�
	 wire [1:0] M_DMop;                // M ��ָ���DM�����ź�
	 wire [31:0] M_ALUout;             // M ��ָ���ALU������
	 wire [31:0] M_CMP_result;         // M ��ָ��CMP�ȽϽ��
	 wire [31:0] M_DMout;              // M ��ָ�������DM����
	 wire [2:0] M_BEop;                // M ��ָ��BE�����ź�
	 wire [31:0] M_BE_in;              // M �� BE ģ�������
	 
	 
	 // 00000: keep; 00001: W_ALUout; 00010: W_DMout; 00011: W_PC+8; 00100: W_CMP_result; 00101: W_MDUout
	 assign M_RD2_new = (M_FW_rt_sel == 5'd0) ? M_RD2 :
	                  (M_FW_rt_sel == 5'd1) ? W_ALUout :
							(M_FW_rt_sel == 5'd2) ? W_DMout :
							(M_FW_rt_sel == 5'd3) ? W_PC + 32'd8 :
                     (M_FW_rt_sel == 5'd4) ? W_CMP_result :
							(M_FW_rt_sel == 5'd5) ? W_MDUout :
							                        M_RD2;
	 
	 E_M_REG E_M_reg (
    .clk(clk), 
    .reset(reset), 
    .E_M_REG_EN(1'b1), 
    .E_PC(E_PC), 
    .E_instr(E_instr), 
    .E_RD2(E_RD2_new), 
    .E_DM_write(E_DM_write), 
    .E_GRF_write(E_GRF_write), 
    .E_DMop(E_DMop), 
    .E_ALUout(E_ALUout), 
    .E_GRF_A3(E_GRF_A3), 
    .E_GRF_DatatoReg(E_GRF_DatatoReg), 
    .E_CMP_result(E_CMP_result), 
    .E_rs_Tuse(E_rs_Tuse), 
    .E_rt_Tuse(E_rt_Tuse), 
    .E_Tnew(E_Tnew), 
	 .E_BEop(E_BEop),
	 .E_MDUout(E_MDUout),
    .M_PC(M_PC), 
    .M_instr(M_instr), 
    .M_RD2(M_RD2), 
    .M_DM_write(M_DM_write), 
    .M_GRF_write(M_GRF_write), 
    .M_DMop(M_DMop), 
    .M_ALUout(M_ALUout), 
	 .M_BEop(M_BEop),
	 .M_MDUout(M_MDUout),
    .M_GRF_A3(M_GRF_A3), 
    .M_GRF_DatatoReg(M_GRF_DatatoReg), 
    .M_CMP_result(M_CMP_result), 
    .M_rs_Tuse(M_rs_Tuse), 
    .M_rt_Tuse(M_rt_Tuse), 
    .M_Tnew(M_Tnew)
    );
	 
	 DM_CU dm_cu (
    .M_ALUout(M_ALUout), 
	 .M_RD2(M_RD2_new),
    .DM_write(M_DM_write), 
    .M_DMop(M_DMop), 
    .M_byteen(m_data_byteen),
	 .M_DM_WD(M_DM_WD)
    );
	 
	 assign m_inst_addr = M_PC;
	 assign m_data_wdata = M_DM_WD;
	 assign M_BE_in = m_data_rdata;
	 assign m_data_addr = M_ALUout;
	 
	 BE be (
    .M_BE_addr(M_ALUout), 
    .M_BE_in(M_BE_in), 
    .M_BEop(M_BEop), 
    .M_BEout(M_DMout)
    );
	 
///////////////////////////////////  WriteBack stage  //////////////////////////// 

	 wire [31:0] W_ALUout;          // W ��ָ���ALU������ 
	 wire [31:0] W_DMout;           // W ��ָ��CMP�ȽϽ��
	 wire [31:0] W_CMP_result;      // W ��ָ��CMP�ȽϽ��
	 
	 M_W_REG M_W_reg (
    .clk(clk), 
    .reset(reset), 
    .M_W_REG_EN(1'b1), 
    .M_PC(M_PC), 
    .M_instr(M_instr), 
    .M_ALUout(M_ALUout), 
    .M_GRF_A3(M_GRF_A3), 
    .M_DMout(M_DMout), 
    .M_GRF_write(M_GRF_write), 
    .M_GRF_DatatoReg(M_GRF_DatatoReg), 
    .M_CMP_result(M_CMP_result), 
	 .M_MDUout(M_MDUout),
    .M_rs_Tuse(M_rs_Tuse), 
    .M_rt_Tuse(M_rt_Tuse), 
    .M_Tnew(M_Tnew), 
    .W_PC(W_PC), 
    .W_instr(W_instr), 
    .W_ALUout(W_ALUout), 
    .W_GRF_A3(W_GRF_A3), 
    .W_DMout(W_DMout), 
    .W_GRF_write(W_GRF_write), 
    .W_GRF_DatatoReg(W_GRF_DatatoReg), 
    .W_CMP_result(W_CMP_result), 
	 .W_MDUout(W_MDUout),
    .W_rs_Tuse(W_rs_Tuse), 
    .W_rt_Tuse(W_rt_Tuse), 
    .W_Tnew(W_Tnew)
    );
	 // 0000��ALUout; 0001��DMout; 0010��PC+8; 0011��д��CMPresult
	 assign W_GRF_WD = (W_GRF_DatatoReg == 4'd0) ? W_ALUout :
	                   (W_GRF_DatatoReg == 4'd1) ? W_DMout :
							 (W_GRF_DatatoReg == 4'd2) ? W_PC + 32'd8 :
							 (W_GRF_DatatoReg == 4'd3) ? W_CMP_result :
							 (W_GRF_DatatoReg == 4'd4) ? W_MDUout :
							                             32'd0;
	 
	 
endmodule