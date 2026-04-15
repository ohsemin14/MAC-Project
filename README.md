# 8x8 Systolic Array 기반 MAC 코어(v1.0)

## Project Overview
엣지 디바이스 환경을 타겟으로 한 고성능·저면적 행렬 곱셈 하드웨어 가속기 IP 설계 프로젝트입니다.
Python 기반의 Golden Model과 SystemVerilog RTL 설계를 교차 검증실시 하였으며 완벽하게 통과하여 설계의 무결성을 증명했습니다.

* **Target Device** : Intel Cyclone V FPGA (5CGXFC7C7F23C8)
* **Language** : SystemVerilog
* **Tools** : Quartus Prime , ModelSim, Python

## Key Architecture
1. **Output Stationary Systolic Array** : 데이터 이동으로 인한 전력 소모를 최소화하기 위해서 8x8 배열을 선택했습니다. ( 추후, 배열 확장 예정 )

    ※ 각 PE 내부에는 32-bit 누산기를 배치하여 내부 병목 현상을 제거했습니다.
2. **FSM Controller** : 파이프라인 데이터 주입을 위한 Pre-skewing 및 연산 타이밍 제어 신호를 생성하는 3-state(IDLE->RUN->DONE)를 설계했습니다.
3. **Datapath** : 오버플로우를 방지하는 포화 연산 및 산술 우측 시프트 기반의 스케일링(Truncation) 로직을 하드웨어에 구현하였습니다.

## PPA Results
* **Fmax** : 117.88 MHz
* **Computing Power** : 15.08 GOPS
* **Logic Utilization** : 2,739 ALMs
* **DSP Blocks** : 64/156(41%)
* **Timing Slack** : 1.517 ns
* **Total Virtual Pins** 1,536개

## Verification
* **Python Golden Model** : Numpy를 활용하여 데이터 자료형 및 하드웨어 연산 특성을 모사하여 정답지 모델을 설계했습니다.
* **Testbench** : SystemVerilog의 '$readmemh'를 활용하여 64개의 매트릭스 출력을 매 클럭 자동으로 비교하고 에러를 검출하는 환경을 설계했습니다.
* **Corner Case Test** : 최대 양수 및 최소 음수 데이터의 연속 누산 상황에서도 오버플로우 없이 100% 일치하는 연산 결과를 확보했습니다.

## 향후 계획
**FPGA 내부의 M10K 메모리 블록을 인스턴스화하여, 외부에서 들어오는 데이터를 미리 저장할 buffer 설계 예정.**

**문제점** : 현재 순수 MAC 코어 단독 설계 상태이며, 1,536비트의 대규모 데이터 입출력으로 인한 I/O병목 현상과 물리적 핀 개수 한계가 존재합니다. (현재는 Virtual Pin 제약을 통해 Fitter 에러를 우회하여 PPA를 추출한 상태입니다.)

**개선 방안** : 코어 내부에 데이터를 미리 저장할 수 있는 SRAM Buffer를 설계하여 I/O 병목을 해결하려고 합니다.
