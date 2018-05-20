all: UART

UART: UART_tb.vcd

UART_tb.vcd: UART.v UART_tb.v

	iverilog $^ -o UART_tb.out

	./UART_tb.out

	# gtkwave $@ UART_tb.gtkw &

clean:
	rm -f *.bin *.txt *.blif *.out *.vcd *~