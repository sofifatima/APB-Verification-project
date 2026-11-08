module apb_master (
	input clk,
	input rst,
	
	input start_valid,
	input st_wr_rd,
	input [31:0] wr_data,
	output reg [31:0] rd_data,
	input [31:0] wr_addr,
	input [31:0] rd_addr,
	
	output reg [31:0] PADDR,
	output reg [31:0] PDATA,
	output reg PWRITE,
	output reg PSEL,
	output reg PENABLE,
	
	input PREADY,
	input [31:0] PRDATA
	);
	
	reg [31:0] write_data;
	reg [31:0] write_addr;
	reg [31:0] read_data;
	reg [31:0] read_addr;
	
	enum reg [1:0] {IDLE,SETUP,ACCESS} m_current_state, m_next_state;
	
	//state change//
	always @(posedge clk or posedge rst)
	begin 
		if (rst) m_current_state<= IDLE;
		else m_current_state <= m_next_state;
	end 
	
	
//states change//	
	always @(posedge clk or posedge rst)
	begin 
	if (rst)  m_next_state <= IDLE;
	else begin 
		case (m_current_state)
			IDLE: 
				begin 
				PADDR <= 32'd0;
				PDATA <= 32'd0;
				read_data <= 32'd0;
				PWRITE <= 1'b0;
				PSEL <= 1'b0;
				if (start_valid) m_next_state<=SETUP;
				end 
				 
			SETUP: m_next_state <= ACCESS;
			ACCESS: begin 
						case({start_valid,PREADY})
						2'b11:  m_next_state <= SETUP;
						2'b01: m_next_state  <=IDLE;							  
						default: m_next_state<= ACCESS;
						endcase 
					
					end 
						
		endcase 
	end 
end 
	
//write data//	
	always @(posedge clk or posedge rst)
	begin 
		if (rst) 
			write_data<=32'd0;
		else 
			write_data <= st_wr_rd ? wr_data : write_data;
	end 
	
	always @(posedge clk or posedge rst)
	begin 
		if (rst) 
			write_addr <= 32'd0;
		else 
			write_addr <= st_wr_rd ? wr_addr : write_addr;
	end 

//read data//
	always @(posedge clk or posedge rst)
	begin 
		if (rst) 
			read_data<=32'd0;
		else 
			read_data <= st_wr_rd ? read_data : rd_data;
	end 
	
	always @(posedge clk or posedge rst)
	begin 
		if (rst) 
			read_addr <= 32'd0;
		else 
			read_addr <= st_wr_rd ? read_addr : rd_addr;
	end 

//signals assertion//	
always @(posedge clk or posedge rst)
begin 
	if (rst) begin 
				PADDR <= 32'd0;
				PDATA <= 32'd0;
				read_data <= 32'd0;
				PWRITE <= 1'b0;
				PSEL <= 1'b0;
				PENABLE <= 1'b0;
			end 
	else begin 
				
		case(m_current_state)
		IDLE: begin 
				PADDR <= 32'd0;
				PDATA <= 32'd0;
				read_data <= 32'd0;
				PWRITE <= 1'b0;
				PSEL <= 1'b0;
				
			  end 
		SETUP: begin 
					case (st_wr_rd)
					1'b1: begin 
							PADDR <= write_addr;
							PDATA <= write_data;
							PWRITE <= 1'b1;
							PSEL <= 1'b1;
							
						  end 
			        1'b0: begin	
							PADDR <= read_addr;
							read_data <= rd_data;
							PWRITE <= 1'b0;
							PSEL <= 1'b1;
						  end 
					endcase
							
				end 
	  endcase 
	end 
end 
//PENABLE
always @(posedge clk or posedge rst)
begin 
	if (rst) m_next_state <= IDLE;
	else begin 
	case (m_next_state)
	ACCESS: PENABLE <= 1;
	default: PENABLE <= 0;
	endcase
	
end
end
assign rd_data= PRDATA;
					
endmodule	
