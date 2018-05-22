all: UART fifo

UART: UART_tb.vcd

fifo: fifo_stack_tb.vcd

UART_tb.vcd: UART.v UART_tb.v

	iverilog $^ -o UART_tb.out

	./UART_tb.out

	# gtkwave $@ UART_tb.gtkw &

fifo_stack_tb.vcd: fifo_stack.v fifo_stack_tb.v

	iverilog $^ -o fifo_stack_tb.out

	./fifo_stack_tb.out

	# gtkwave $@ UART_tb.gtkw &

clean:
	rm -f *.bin *.txt *.blif *.out *.vcd *~