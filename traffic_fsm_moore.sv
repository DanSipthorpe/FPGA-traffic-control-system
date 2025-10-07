module traffic_fsm_moore (
    input  logic clk,
    input  logic reset,
    input  logic TA, TB,        // traffic sensors
    output logic [2:0] LA, LB   // traffic lights: {Red, Yellow, Green}
);

    // Light encodings
    localparam RED    = 3'b100,
               YELLOW = 3'b010,
               GREEN  = 3'b001;

    // States
    typedef enum logic [1:0] {
        S0,  // Academic Green, Bravado Red
        S1,  // Academic Yellow, Bravado Red
        S2,  // Academic Red, Bravado Green
        S3   // Academic Red, Bravado Yellow
    } state_t;

    state_t state, next_state;

    // Delay counter (for yellow states)
    logic [3:0] counter;  

    // Sequential: state register
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= S0;
            counter <= 0;
        end else begin
            state <= next_state;

            // Counter logic (used only in yellow states)
            if (state == S1 || state == S3)
                counter <= counter + 1;
            else
                counter <= 0;
        end
    end

    // Combinational: next state logic
    always_comb begin
        next_state = state;
        case (state)
            S0: begin
                if (!TA) next_state = S1; // no traffic → yellow
            end
            S1: begin
                if (counter == 5) next_state = S2; // after 5 cycles
            end
            S2: begin
                if (!TB) next_state = S3; // no traffic on Bravado
            end
            S3: begin
                if (counter == 5) next_state = S0;
            end
        endcase
    end

    // Output logic (Moore: depends only on state)
    always_comb begin
        LA = RED; LB = RED;
        case (state)
            S0: begin LA = GREEN; LB = RED;    end
            S1: begin LA = YELLOW; LB = RED;  end
            S2: begin LA = RED;   LB = GREEN; end
            S3: begin LA = RED;   LB = YELLOW;end
        endcase
    end

endmodule
