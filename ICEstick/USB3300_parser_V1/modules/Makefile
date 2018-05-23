all: UART fifo

UART: UART_tb.vcd

fifo: fifo_stack_tb.vcd

fifo_u: fifo_stack_u_tb.vcd

receiver: USB3300_receiver_tb.vcd

UART_tb.vcd: UART.v UART_tb.v

	iverilog $^ -o UART_tb.out

	./UART_tb.out

	# gtkwave $@ UART_tb.gtkw &

fifo_stack_tb.vcd: fifo_stack.v fifo_stack_tb.v

	iverilog $^ -o fifo_stack_tb.out

	./fifo_stack_tb.out

	# gtkwave $@ UART_tb.gtkw &

fifo_stack_u_tb.vcd: fifo_stack_u.v fifo_stack_u_tb.v

	iverilog $^ -o fifo_stack_u_tb.out

	./fifo_stack_u_tb.out

	# gtkwave $@ UART_tb.gtkw &

USB3300_receiver_tb.vcd: USB3300_receiver.v USB3300_receiver_tb.v

	iverilog $^ -o USB3300_receiver_tb.out

	./USB3300_receiver_tb.out

	# gtkwave $@ USB3300_receiver_tb.gtkw &

clean:
	rm -f *.bin *.txt *.blif *.out *.vcd *~