# 项目
PROJECT_NAME := stm32f103rct6

# 编译工具
# SDK_PATH := /Applications/gcc-arm-none-eabi/sdk/bin/
SDK_PATH := 
# 参与编译的源文件列表
SOURCE := system/src/newlib/_cxx.cpp \
          system/src/newlib/_exit.c \
		  system/src/newlib/_sbrk.c \
		  system/src/newlib/_startup.c \
		  system/src/newlib/_syscalls.c \
		  system/src/newlib/assert.c \
		  system/src/diag/Trace.c \
		  system/src/diag/trace_impl.c \
		  system/src/cortexm/_initialize_hardware.c \
		  system/src/cortexm/_reset_hardware.c \
		  system/src/cortexm/exception_handlers.c \
		  system/src/cmsis/system_stm32f10x.c \
		  system/src/cmsis/vectors_stm32f10x.c  \
		  system/src/stm32f1-stdperiph/stm32f10x_rcc.c \
		  system/src/stm32f1-stdperiph/stm32f10x_gpio.c \
		  src/main.c  

# 编译选项
CFLAGS := -mcpu=cortex-m3 \
          -mthumb \
		  -Os \
		  -fmessage-length=0 \
		  -fsigned-char \
		  -ffunction-sections \
		  -fdata-sections \
		  -ffreestanding \
		  -g 
# 参数
FEATHER := -DSTM32F10X_HD \
           -DUSE_STDPERIPH_DRIVER \
		   -DHSE_VALUE=8000000 
# include目录
INCLUDE := -I"include" \
           -I"system/include" \
		   -I"system/include/cmsis" \
		   -I"system/include/stm32f1-stdperiph" 

# 以下内容为自动化内容，不需要在进行修改

# 自动化完成
CFLAGS += $(FEATHER) $(INCLUDE)

C_SRC := $(filter %.c,$(SOURCE))
C_OBJS := $(C_SRC:%.c=%.o)
CPP_SRC := $(filter %.cpp,$(SOURCE))
CPP_OBJS := $(CPP_SRC:%.cpp=%.o)

#
CC := $(SDK_PATH)arm-none-eabi-gcc
CXX := $(SDK_PATH)arm-none-eabi-g++
CP := $(SDK_PATH)arm-none-eabi-objcopy


all: $(PROJECT_NAME).hex
	@echo "Finish"

$(PROJECT_NAME).hex: $(PROJECT_NAME).elf
	@echo 'Invoking: Cross ARM GNU Create Flash Image'
	$(CP) -O ihex $< $@
	@echo 'Finished building: $@'
	@echo ' '

$(PROJECT_NAME).elf: $(C_OBJS) $(CPP_OBJS)
	$(CXX) -mcpu=cortex-m3 -mthumb -Os -fmessage-length=0 -fsigned-char -ffunction-sections -fdata-sections -ffreestanding  -g -T "ldscripts/mem.ld" -T "ldscripts/libs.ld" -T "ldscripts/sections.ld" -L"ldscripts" -nostartfiles -Xlinker --gc-sections -Wl,-Map,$(PROJECT_NAME)".map" -o $@ $(C_OBJS:%.o=output/%.o) $(CPP_OBJS:%.o=output/%.o)

$(C_OBJS): %.o: %.c
	@echo 'Building file: $<'
	@echo 'Invoking: Cross ARM C Compiler'
	@mkdir -p output/$(@D)
	$(CC) $(CFLAGS) -std=gnu11 -MMD -MP -MF"output/$(@:%.o=%.d)" -MT"output/$@" -c -o "output/$@" $<
	@echo 'Finished building: $<'
	@echo ' '

$(CPP_OBJS): %.o: %.cpp
	@echo 'Building file: $<'
	@echo 'Invoking: Cross ARM C++ Compiler'
	@mkdir -p output/$(@D)
	$(CXX) $(CFLAGS) -MMD -MP -MF"output/$(@:%.o=%.d)" -MT"output/$@" -c -o "output/$@" $<
	@echo 'Finished building: $<'
	@echo ' '

clean:
	rm -Rf output/ $(PROJECT_NAME).map $(PROJECT_NAME).elf $(PROJECT_NAME).hex
