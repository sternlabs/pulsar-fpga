SRCS=	pwm.sv
TBS=	pwm_tb.sv

_srcs= $(addprefix rtl/,${SRCS})
_tbs= $(addprefix tb/,${TBS})

SYNPLIFYPRJ=	bledim_syn.prj

MODELSIMDIR?=	/opt/altera/14.0/modelsim_ase/linux
DIAMONDDIR?=	/usr/local/diamond/3.2_x64

define synplify_get_impl
$(shell awk '$$1 == "impl" && $$2 == "-active" { print $$3 }' ${SYNPLIFYPRJ})
endef

define SYNPLIFY ?=
LD_LIBRARY_PATH=${DIAMONDDIR}/bin/lin64/synpwrap \
SYNPLIFY_PATH=${DIAMONDDIR}/synpbase \
${DIAMONDDIR}/bin/lin64/synpwrap -prj ${SYNPLIFYPRJ};
cat $(call synplify_get_impl)/synlog/report/*.txt
endef

all: simulate

work:
	${MODELSIMDIR}/vlib work

lint: ${SRCS:.sv=-lint}

%-lint: %.sv
	verilator -Dsynthesis --lint-only -Wall $^

compile: compile-modelsim compile-synplify

compile-modelsim.stamp: work ${_srcs} ${_tbs}
	${MODELSIMDIR}/vlog -sv12compat -lint $^
	touch $@

compile-synplify:
	${SYNPLIFY}

simulate: $(patsubst %.sv,%.vcd,${TBS})

%.vcd: compile-modelsim.stamp
	${MODELSIMDIR}/vsim -c -do 'vcd file $@; vcd add -r *; run -all' ${@:.vcd=}
