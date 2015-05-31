SRCS=	top.sv machxo2/platform.sv por.sv pwm.sv thresmem.sv spi_slave.sv
TBS=	pwm_tb.sv spi_tb.sv

_srcs= $(addprefix rtl/,${SRCS})
_tbs= $(addprefix tb/,${TBS})

DIAMONDPRJ=	bledim.ldf

MODELSIMDIR?=	/opt/altera/15.0/modelsim_ase/linux
DIAMONDDIR?=	/usr/local/diamond/3.4_x64

define synplify_get_impl
$(shell ruby -rnokogiri -e '
p = Nokogiri::XML(File.read(ARGV[0]))
r = {
project: p.xpath("//BaliProject/@title"),
impl: p.xpath("//BaliProject/@default_implementation"),
dir: p.xpath("//BaliProject/Implementation[@title=//BaliProject/@default_implementation]/@dir"),
}
r[:synprj] = "#{r[:project]}_#{r[:impl]}_synplify.tcl"
print r[ARGV[1].to_sym]
' ${DIAMONDPRJ} $1)
endef

define SYNPLIFY ?=
cd $(call synplify_get_impl,dir) && \
rm synlog/report/*; \
env LD_LIBRARY_PATH=${DIAMONDDIR}/bin/lin64 \
SYNPLIFY_PATH=${DIAMONDDIR}/synpbase \
${DIAMONDDIR}/bin/lin64/synpwrap -prj $(call synplify_get_impl,synprj); \
e=$$?; \
cat synlog/report/*.txt; \
exit $$e
endef

all: simulate

work:
	${MODELSIMDIR}/vlib work

lint: ${SRCS:.sv=-lint}

%-lint: %.sv
	verilator -Dsynthesis --lint-only -Wall $^

compile: compile-modelsim.stamp compile-synplify.stamp

compile-modelsim.stamp: work ${_srcs} ${_tbs}
	${MODELSIMDIR}/vlog -sv12compat -lint ${_srcs} ${_tbs}
	touch $@

compile-synplify.stamp: ${_srcs} ${SYNPLIFYPRJ}
	${SYNPLIFY}
	touch $@

simulate: $(patsubst %.sv,%.vcd,${TBS})

%.vcd: compile-modelsim.stamp
	${MODELSIMDIR}/vsim -c -do 'vcd file $@; vcd add -r *; run -all' ${@:.vcd=}
