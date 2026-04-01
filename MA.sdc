# clock: 100 MHz
create_clock -name clk -period 10.000 [get_ports {clk}]
# 비동기 리셋은 타이밍 제외
set_false_path -from [get_ports {rst_n}]
# (옵션) 여유를 위해 소량의 지터/여유를 모델링
#set_clock_uncertainty 0.10 [get_clocks {clk}]