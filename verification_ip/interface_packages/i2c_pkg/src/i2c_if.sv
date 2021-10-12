`timescale 1ns / 10ps
interface i2c_if   #(
	int I2C_ADDR_WIDTH = 32,
	int I2C_DATA_WIDTH = 16
	)

(	//MASTER SIGNALS
	inout triand sda, //SDA LINE
	input  scl 	  //sCL LINE
);
import ncsu_pkg::*; 	  
// **************************************************************************************************************************************************************************

// VARIABLES DECLARATION

 bit addr_queue[$]; 				     	//TO STORE THE 7-BIT SLAVE ADDRESS
 bit data_queue[$]; 				     	//TO STORE THE 8-BIT DATA RECEIVED 
 bit start_flag =1'b0;					//FLAG TO INDICATE THE START BIT
 bit stop_flag= 1'b0;					//FLAG TO INDICATE THE STOP BIT
 logic sda_ack = 0; 					//CONTROL SIGNAL TO DRIVE THE SDA LINE DURING ACKNOWLEDGE
 logic ack_drive = 0;					//TO DRIVE SDA LOW DURING ACKNOWLEDGE	
 int p, k, z;						//SOME VARIABLES TO USE IN LOOPS	
 int x,y = 0;						//COUNTER VARIABLES TO KEEP COUNT OF READ TRANSFERS
 bit data_queue_2[$];					//QUEUE TO COPY THE DATA CAPTURED
 bit [I2C_DATA_WIDTH-1:0] rd_data[];			//TO COPY THE READ DATA 
// **************************************************************************************************************************************************************************

 assign sda = sda_ack ? ack_drive : 'bz;		//CONTINUOSLY DRIVE THE SDA LINE. DRIVE LOW WHEN SLAVE HAS TO ACKNOWLEDGE.

// **************************************************************************************************************************************************************************

// CONTINUOSLY MONITORING START AND STOP BITS

always @(negedge sda) begin 
	if(scl == 1) begin 
		start_flag =1'b1;			//SET FLAG TO 1 IF START CONDITION OCCURS
		end
	    end


always @(posedge sda) begin 
	if(scl == 1) begin 
		stop_flag =1'b1;			//SET FLAG TO 1 IF STOP CONDITION OCCURS
		end
	     end					
initial begin
	#5 stop_flag=1'b0;
end
// **************************************************************************************************************************************************************************

//WAIT FOR TRANSFER TASK

task wait_for_i2c_transfer (output i2c_op_t op, output bit[I2C_DATA_WIDTH-1:0] write_data[]);
	
	
	  wait(start_flag) begin 								//BEGIN TRANSFER IF START OCCURS				
		
		@(negedge scl) start_flag = 1'b0; 
		repeat(I2C_ADDR_WIDTH) @(posedge scl) addr_queue.push_back(sda); 			//COPY ADDRESS TO QUEUE 
	
		@(posedge scl) begin									//CHECK THE R/W BIT AND SET THE ENUM VARIABLE ACCORDINGLY
			if(sda == 1) begin op <= READ; end					//IF IT IS READ, GO TO provide_read_data TASK
			else op  <= WRITE;
			end
		@(negedge scl) begin sda_ack <=1;
				     ack_drive <=0; end							//ACKNOWLEDGE SLAVE ADDRESS + R/W BIT
		@(posedge scl) ;
									
		if(op == WRITE) begin
			@(negedge scl) sda_ack <=0;
			repeat(I2C_DATA_WIDTH) begin @(posedge scl) data_queue.push_back(sda); end 	//IF OPERATION IS WRITE, CAPTURE THE 8-BITS INTO A QUEUE
				
			@(negedge scl) begin sda_ack <=1;
					     ack_drive <=0; end 					//ACKNOWLEDGE THE DATA BYTE RECEIVED
			@(posedge scl)
			@(negedge scl) sda_ack =0; 			
			
			fork begin 
				while(1) begin 
					repeat(I2C_DATA_WIDTH) begin @(posedge scl) data_queue.push_back(sda); end
					@(negedge scl) begin sda_ack <=1; ack_drive <=0; end
					@(posedge scl); 							//ACKNOWLEDGE THE DATA BYTE RECEIVED
					@(negedge scl) sda_ack <=0;
					end
			     end

			     begin //THREAD THAT WAITS FOR START FLAG
				wait(start_flag);
			     end

			     begin //THREAD THAT WAITS FOR STOP FLAG
				wait(stop_flag);
			     end
			
			  join_any begin //IF REPEATED START OR STOP OCCURS THEN DISABLE THE THREADS
				disable fork;
				data_queue_2 = data_queue;
				void '(data_queue.pop_back());						//THROW AWAY THE LAST CAPTURED BIT(AS IT IS NOT DATA BIT IF START OR STOP OCCURS)		
				write_data = new[(data_queue.size()/(I2C_DATA_WIDTH))];			//ALLOCATE SIZE FOR DYNAMIC ARRAY
				k = (data_queue.size()/(I2C_DATA_WIDTH));
				for(int i=0; i < k; i++) begin
					for(int j=I2C_DATA_WIDTH-1 ; j>= 0; j--) begin
						write_data[i][j] = data_queue.pop_front();		//COPY THE CAPTURED DATA TO THE DYNAMIC ARRAY
						end
				        end
				  end
			    end
		     end

endtask	

// **************************************************************************************************************************************************************************

//PROVIDE READ DATA TASK
task provide_read_data(input bit [I2C_DATA_WIDTH-1:0] read_data[], output bit transfer_complete);
	rd_data = new[read_data.size()] (read_data);
	for(int j=0; j<I2C_DATA_WIDTH ; j++) begin
		@(negedge scl) ack_drive <= read_data[x][I2C_DATA_WIDTH-1-j];				//TRANSFER THE DATA FROM ARRAY ON TO SDA LINE
	     end
	x++;
	@(negedge scl) sda_ack <=0;
	@(posedge scl);											//WAIT FOR ACKNOWLEDGE FROM MASTER
	while(!sda) begin										//IF ACKNOWLEDGED THEN TRANSFER THE NEXT BYTE OF DATA
		@(negedge scl) begin sda_ack <=1; ack_drive <=read_data[x][I2C_DATA_WIDTH-1]; end
		for(int j=1; j<I2C_DATA_WIDTH; j++) begin
			@(negedge scl) ack_drive <= read_data[x][I2C_DATA_WIDTH-1-j];			//KEEP TRANSFERRING THE DATA AND WAIT FOR ACKNOWLEDGE
		     end
		x++;											//COUNTER VARIABLE TO KEEP TRACK OF NUMBER OF BYTES TRANSFERRED SO FAR
		@(negedge scl) sda_ack <=0;
		@(posedge scl); 
	     end
	
	fork begin	//THREAD THAT WAITS FOR START
		wait(start_flag);
	     end

	     begin	//THREAD THAT WAITS FOR STOP
		wait(stop_flag);
	     end

	join_any begin
		transfer_complete = 1;
	     end	
endtask	
	
// **************************************************************************************************************************************************************************

//MONITOR TASK
task monitor(output bit [I2C_ADDR_WIDTH-1:0] addr, output i2c_op_t op, output bit [I2C_DATA_WIDTH-1:0] data[]);
	wait(start_flag) begin

		for(int i=0; i<I2C_ADDR_WIDTH; i++) begin
			@(posedge scl) addr[I2C_ADDR_WIDTH-1-i] = sda;		//COPY THE 7-BIT ADDRESS TO THE ARRAY
			end
		@(posedge scl) begin
			if(sda==1) op = READ;								//CHECK FOR R/W BIT
			else op = WRITE;
			end
		@(posedge scl);

		if(op == WRITE) begin
			repeat(I2C_DATA_WIDTH) @(posedge scl);
			@(posedge scl);
			fork begin
				while(1) begin
					repeat(I2C_DATA_WIDTH) @(posedge scl);
					@(posedge scl); 
					end
			     end
			     begin
				wait(start_flag); 
			     end
			     begin
				wait(stop_flag); 
		   	     end
			join_any begin
				disable fork;
				void '(data_queue_2.pop_back());				
				data = new[(data_queue_2.size()/(I2C_DATA_WIDTH))];			//ALLOCATE SIZE FOR DYNAMIC ARRAY
				p = (data_queue_2.size()/(I2C_DATA_WIDTH));
				for(int i=0; i < k; i++) begin
					for(int j=I2C_DATA_WIDTH-1 ; j>= 0; j--) begin
						data[i][j] = data_queue_2.pop_front();			//COPY THE CAPTURED DATA TO THE DYNAMIC ARRAY
						end
				        end
				
				end
			end
		if(op == READ) begin 
			repeat(I2C_DATA_WIDTH) @(posedge scl);
			@(posedge scl);
			while(!sda) begin
				repeat(I2C_DATA_WIDTH) @(posedge scl);
				@(posedge scl);
				end
			
			fork begin
				wait(start_flag); 
			     end
			     begin
				wait(stop_flag); 
			     end
			join_any begin
				disable fork;
				data = new[x-y];							//USE THE COUNTER VARIABLES TO DETERMINE THE SIZE OF ARRAY
				for(int i=y; i < x; i++) begin
					data[i-y] = rd_data[i];
					end
				y = x;									//SET ANOTHER COUNTER VARIABLE TO KEEP TRACK OF PREVIOUS NO. OF BYTES TRANSFERRED
			        end
			end
		
	end
endtask
endinterface	