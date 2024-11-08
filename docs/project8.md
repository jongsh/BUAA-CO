# P8 MIPS 微系统设计文档



## 一、主存地址分配

P8 中主存中有许多部分，包括**数据存储器**，**指令存储器**，**定时器**，**UART**，**数码管**，**拨码开关**，**按键开关**，**LED**，下表是他们在主存的地址分配

|外设名称|地址范围|类型|
|---|---|---|
|DM|0x0000-0x2FFF|可读可写|
|IM|0x3000-0x6FFF|可读|
|定时器|0x7F00-0x7F0B|可读可写|
|UART|0x7F30-0x7F3F|可读可写|
|数码管|0x7F50-0x7F57|只写|
|拨码开关|0x7F60-0x7F67|只读|
|按键开关|0x7F68-0x7F6B|只读|
|LED|0x7F70-0x7F73|只写|

<br> 

## 二、外设模块 

### 2.1 UART
UART 协议是典型的串行通信协议，数据传输时每一比特位依次发送 / 接收。UART 协议规定空闲时信号线为高电平，因此可以通过电平的变化（由高到低）来指示信号传输的开始，同时传输双方约定好一次传输中比特的个数和每个比特的持续时间（波特率）来定位传输的结束。这种传输对于传输双方的时间同步性有一定要求，因而不宜一次性传输过多数据。同时，UART 协议为全双工通信协议，有两根 1 位的互不干扰的单向的传输线，因而传输双方间应将发送端口和接收端口交错相连，即设备 A 的 TX 应连至设备 B 的 RX，B 的 TX 连至 A 的 RX。

UART 模块包括三个子模块：**uart_rx、uart_tx、uart_count**

* **uart_count**: 该模块用作计时模块。由于 UART 数据传输受波特率限制，在 P8 中波特率一般设置为 **9600**，即每秒发送 9600 个 bit （可以是开始位、数据位或停止位），时钟频率为 **25MHZ**，故计算可知，每一个 bit 发送时需要保持 **2604** 个时钟周期, uart_count 则是完成这一部分功能。
* **uart_rx**: 作为微处理器接收串口数据的模块，根据协议接收数据，并且在完成一个完整字节接收以后产生 ready 信号作为外部中断信号交到 CP0 处理
* **uart_tx**: 作为微处理器向串口发送数据，把它的 avai 信号绑定给 state 寄存器的 0 号位，用于 CPU 读取识别是否可以继续发送数据

| 端口 | 方向 | 功能|
|---|---|---|
|clk|input|时钟控制信号|
|reset|input|复位信号|
|WE|input| 写使能信号 |
|addr|input[31:0]|CPU 读写外设地址|
|WD|input[31:0]| CPU 写外设数据|
|rxd|input|来自串口的字节数据|
|txd|output|输出到串口的字节数据|
|RD|ouput[31:0]|CPU 从 UART 的寄存器读出的数据|
|interrupt|output|中断请求信号，绑定 rx_ready 信号|



### 2.2 GPIO

通用 IO 包括三个部分，分别是按键开关，拨码开关，32 位 LED 灯。其中按键开关是对实现功能的选择，拨码开关输入两个 32 位源操作数，LED 灯是一种输出外设，输出功能计算结果。

**KEY**：

| 端口| 方向| 功能|
|---|---|---|
|clk|input|时钟信号|
|reset|input|复位信号|
|key_in|input[7:0]|8位按键信号|
|key_out|output[31:0]|32位拓展按键信号|

**DipSwitch**：

| 端口 | 方向 | 功能 |
|---|---|---|
|clk|input|时钟信号|
|reset|input|复位信号|
|addr|input[31:0]|CPU 读写外设地址|
|switch0|input[7:0]|第0组拨码开关数据|
|switch1|input[7:0]|第1组拨码开关数据|
|switch2|input[7:0]|第2组拨码开关数据|
|switch3|input[7:0]|第3组拨码开关数据|
|switch4|input[7:0]|第4组拨码开关数据|
|switch5|input[7:0]|第5组拨码开关数据|
|switch6|input[7:0]|第6组拨码开关数据|
|switch7|input[7:0]|第7组拨码开关数据|
|RD|output[31:0]|CPU 读数据|

**LED**：

| 端口 | 方向 | 功能 |
|---|---|---|
|clk|input|时钟信号|
|reset|input|复位信号|
|byteen|input[3:0]|字节使能信号|
|WD|input[31:0]|CPU 写数据|
|led_light|output[31:0]|LED 灯控制信号|



### 2.3 DigitalTube

数码管输出模块，用于控制九位八段数码管，其中最高一个数码管始终熄灭。

| 端口 | 方向 | 功能|
|---|---|---|
|clk|input|时钟信号|
|reset|input|复位信号|
|byteen|input[3:0]|字节使能信号|
|Addr|input[31:0]|CPU 读写外设地址|
|WD|input[31:0]|CPU 写外设数据|
|digital_tube0|output[7:0]|第 0 组数码管控制信号|
|digital_tube1|output[7:0]|第 1 组数码管控制信号|
|digital_tube2|output[7:0]|第 2 组数码管控制信号|
|digital_tube_sel0|output[3:0]|第 0 组数码管选择信号|
|digital_tube_sel1|output[3:0]|第 1 组数码管选择信号|
|digital_tube_sel2|output|第 2 组数码管选择信号|

<br> 

## 三、CPU 的修改：

P8 的 CPU 相比 P7 需要做一些修改，包括实现与更多外设的交互，适应 IP 核的同步读特点，实现可综合的乘除器。

### 3.1 更多外设交互
为了和更多外设交互，CPU 的异常判断需要做调整，我的做法是直接屏蔽一部分异常，原因是内部指令是自己实现的，保证无异常即可，在 CU 内部译码出一个信号，告诉 CPU 该指令在任何阶段都不应发生异常，这在 P7 中已实现，仅做一部分修改即可。

其次，为了能够保证 UART 接受数据时可以及时读取保存，需要增加对 UART 中断的响应。



### 3.2 可综合的乘法器

由于课程组已经提供了乘法器原码，所以只需在此基础上做一部分调整即可。

| 端口 | 方向 | 功能 |
|---|---|---|
|clk|input|时钟信号|
|reset|input|复位信号|
|in_valid|input|计算请求信号|
|in_src0|input[31:0]|操作数 0|
|in_src1|input[31:0]|操作数 1|
|in_op|input[1:0]|0：IDLE、1：MUL、2：DIV|
|in_sign|input|0：无符号计算、1：有符号计算|
|out_ready|input|后级模块是否接受信号标记|
|out_valid|output|输出计算有效|
|in_ready|output|乘除器空闲信号|
|out_res0|output[31:0]|LO|
|out_res1|output[31:0]|HI|

为了保证相关功能的正确性，我做了如下调整：

- 在乘除器模块外部接入寄存器，保存 HI，LO 的数据，原因在于乘除模块即便在没有运算情况下，HI，LO的数据都会置零，无法保存，因此需要额外加寄存器，另一方面是，乘除模块无法实现 mthi，mtlo 的功能，因此将 mt 信号和 out_valid 信号作为新增寄存器的使能信号。
- 把原先乘除控制信号 MDUop 再翻译出 in_sign, in_op 接入乘除器。
- 将 start，busy 信号按正确方式分别连接 in_valid、in_ready 端口。



### 3.3 同步读功能
由于 IP core 的读出操作也是同步的，和以往 Project 有很大不同，需要我们对此修改 CPU 的部分细节。这也是整个 CPU 修改中的核心部分，也是我个人认为比较困难的部分。

该部分需要做两方面调整：

- **指令存储器部分**：由于取值在 F 级实现，而 FD 寄存器又有很多控制信号对 F_instr 做修改才流水到 D_instr, 也就是从同步读的 IM 读出的指令不一定是D_instr 的期望数据。因此需要从两个信号中做选择，一个是 IM_RD，另一个是通过流水线寄存器修改得到的信号，比如 M 级出现 req 时这个信号就是 nop。而控制两个信号的选择信号必须在时钟周期内稳定，否则 D_instr 会在一个时钟内部发生改变，出现难以预料的结果。所以这个信号也是从流水线寄存器上流下来的。
- **数据存储器部分：**相比指令存储器，数据存储器的处理就比较简单，因为读出的数据并不需要修正，直接短接到流水线寄存器相应端口即可。但是需要注意的是，从外设包括 DM 等读入的数据要经过 BE 模块的拓展，这里就要修改 BE 的控制信号为 W 级指令的控制信号，因为读出数据时已是下一个时钟上升沿之后，此时 load 指令已经流水到 W 级了，如果还用 M 级指令的控制信号的话，数据扩展会出现错误。

<br> 

## 四、汇编程序

完成微系统要求功能的 MIPS 汇编程序（自认为是整个 P8 最烦人的部分）。

```assembly
####  initial $a1 - $a2
####  
####
.text 0x3000
    nop # Timer --- control:0x7f00  present:0x7f04 count:0x7f08
    nop # UART --- Data:0x7f30  State:0x7f34
    nop # Digital Tube---- 0x7f50
    nop # DipSwitch --- Team 0-3:0x7f60  Team 4-7:0x7f64 
    nop # Key --- 0x7f68
    nop # LED --- 0x7f70
initial:
    addi $a1, $0, -1
    sw $a1, 0($0)
    sw $a1, 4($0)
    sw $a1, 8($0)
    sw $a1, 12($0)
    
    addi $a1, $0, 25000000
    sw $a1, 0x7f04($0)
    addi $a1, $0, 0x1401
    mtc0 $a1, $12

input:
    addi $a1, $0, 0
    sw $a1, 0x7f00($0)  # disable Timer
    lw $s0, 0x7f68($0)  # $s0 = key
    lw $s1, 0x7f60($0)  # $s1 = group 0-3
    lw $s2, 0x7f64($0)  # $s2 = group 4-7
    sw $s0, 0($0)       # keep key
    sw $s1, 4($0)       # keep group 0-3
    sw $s2, 8($0)       # keep group 4-7
    andi $t0, $s0, 1
    beq $t0, $0, Calculator
    nop
    
###########################
###########################
Counter:
    andi $t0, $s0, 4
    bne $t0, $0, Counter2
    nop
   
Counter1:   # add count
    addi $s3, $0, 0
    addi $v1, $0, 1
  loop_Counter1:
    lw $s0, 0x7f68($0)  # $s0 = key
    lw $s1, 0x7f60($0)  # $s1 = group 0-3
    lw $s2, 0x7f64($0)  # $s2 = group 4-7
    lw $t0, 0($0)
    lw $t1, 4($0)
    lw $t2, 8($0)
    bne $s0, $t0, input
    nop
    bne $s1, $t1, input
    nop
    bne $s2, $t2, input
    nop
  if_Counter1:
    bne $s1, $s3, if_Counter1_end
    nop
    sw $0, 0x7f00($0)  # disable Timer
  if_Counter1_end:
    jal output
    nop
    addi $a1, $0, 0xb
    sw $a1, 0x7f00($0)
    jal loop_Counter1
    nop
################################
################################
Counter2:  # sub count
    add $s3, $0, $s1
    addi $v1, $0, -1
   loop_Counter2:
    lw $s0, 0x7f68($0)  # $s0 = key
    lw $s1, 0x7f60($0)  # $s1 = group 0-3
    lw $s2, 0x7f64($0)  # $s2 = group 4-7
    lw $t0, 0($0)
    lw $t1, 4($0)
    lw $t2, 8($0)
    bne $s0, $t0, input
    nop
    bne $s1, $t1, input
    nop
    bne $s2, $t2, input
    nop
  if_Counter2:
    bne $s3, $0, if_Counter2_end
    nop
    sw $0, 0x7f00($0)  # disable Timer
  if_Counter2_end:
    jal output
    nop
    addi $a1, $0, 0xb
    sw $a1, 0x7f00($0)
    jal loop_Counter2
    nop

######################
######################
Calculator:
    andi $t0, $s0, 4
    bne $t0, $0, add
    nop
    andi $t0, $s0, 8
    bne $t0, $0, sub
    nop
    andi $t0, $s0, 16
    bne $t0, $0, mult
    nop
    andi $t0, $s0, 32
    bne $t0, $0, div
    nop
    andi $t0, $s0, 64
    bne $t0, $0, and
    nop
    andi $t0, $s0, 128
    bne $t0, $0, or
    nop
    jal default 
    nop
  add:
    add $s3, $s2, $s1
    jal Calculator_end
    nop
  sub:
    sub $s3, $s2, $s1
    jal Calculator_end
    nop
  mult:
    mult $s2, $s1
    mflo $s3
    jal Calculator_end
    nop
  div:
    div $s2, $s1
    mflo $s3
    jal Calculator_end
    nop
  and:
    and $s3, $s2, $s1
    jal Calculator_end
    nop
  or:
    or $s3, $s2, $s1
    jal Calculator_end
    nop
  default:
    nop
  Calculator_end:   
    jal output
    nop
    jal input
    nop   
      
#######################
#######################
output:
    lw $t3, 12($0)
  if_output: 
    bne $t3, $s3, if_output_end
    nop
    jr $ra
    nop
  if_output_end:
    sw $s3, 12($0)
    andi $t0, $s0, 2
    bne $t0, $0, output_UART
    nop
output_LED:
    sw $s3, 0x7f70($0)
    sw $s3, 0x7f50($0)
    jr $ra
    nop

output_UART:
    lb $t3, 15($0)
  loop_UART1:
    lw $t4, 0x7f34($0)
    beq $t4, $0, loop_UART1
    nop
    sb $t3, 0x7f32($0)
    nop
    nop
    nop
    lb $t3, 14($0)
  loop_UART2:
    lw $t4, 0x7f34($0)
    beq $t4, $0, loop_UART2
    nop
    sb $t3, 0x7f32($0)
    nop
    nop
    nop
    lb $t3, 13($0)
  loop_UART3:
    lw $t4, 0x7f34($0)
    beq $t4, $0, loop_UART3
    nop
    sb $t3, 0x7f32($0)
    nop
    nop
    nop
    lb $t3, 12($0)
  loop_UART4:
    lw $t4, 0x7f34($0)
    beq $t4, $0, loop_UART4
    nop
    sb $t3, 0x7f32($0)
    
    jr $ra
    nop


.ktext 0x4180
    mfc0 $v0, $13
    andi $t4, $v0, 0x1000
    bne $t4, $0, handler_UART
    nop
    
  handler_Counter:
    add $s3, $s3, $v1
    eret
    nop
     
  handler_UART:
    lb $s4, 0x7f30($0)
   loop_handler_UART:
    lw $t4, 0x7f34($0)
    beq $t4, $0, loop_handler_UART
    nop
    sb $s4, 0x7f32($0)
   loop_handler_UART_end:
    eret
    nop        
```

