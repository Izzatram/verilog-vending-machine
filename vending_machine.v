module vending_machine (
    clk, inserted_cash, reset, present_state,
    next_state, count_money, dispense_noodle, change, cancel,
    select_menu
);

    input clk, reset, cancel;
    input [1:0] select_menu;
    input [2:0] inserted_cash;

    output reg [1:0] dispense_noodle;
    output reg [2:0] change;
    output reg [2:0] present_state, next_state;
    output reg [3:0] count_money;

    initial count_money = 4'b0000;

    parameter idle = 0, one = 1, two = 2, menu_select = 3, result = 4, refund = 5;

    always @ (posedge clk or posedge reset) begin
        if (reset) begin
            present_state <= idle; // set initial state to idle
        end else begin
            present_state <= next_state; // allow to move to next states
        end
    end

    // Next state logic and output generation
    always @ (present_state) begin
        case (present_state)
            idle: begin
                if (cancel == 1) begin
                    next_state = refund;
                end
                else if (inserted_cash == 3'b000) begin
                    next_state = idle;
                end
                else if (inserted_cash == 3'b001) begin // insert RM1
                    next_state = one;
                end
                else if (inserted_cash == 3'b101) begin // insert RM5
                    next_state = menu_select;
                end
            end
            
            one: begin
                if (cancel == 1) begin
                    next_state = refund;
                end
                else if (inserted_cash == 3'b001) begin // insert RM1
                    next_state = two;
                end
                else if (inserted_cash == 3'b101) begin // insert RM5
                    next_state = menu_select;
                end
            end
            
            two: begin
                if (cancel == 1) begin
                    next_state = refund;
                end
                else if (inserted_cash == 3'b001) begin // insert RM1
                    next_state = menu_select;
                end
                else if (inserted_cash == 3'b101) begin // insert RM5
                    next_state = menu_select;
                end
            end
            
            menu_select: begin
                if (cancel == 1) // cancel after it goes to menu to refund
                    next_state = refund;
                else
                    next_state = result; // proceed to menu select and change calculation
            end
            
            result: begin
                next_state = idle; // transition idle
            end
            
            refund: begin
                next_state = idle; // transition idle
            end
            
            default: next_state = idle; // default to idle
        endcase
    end

    // RTL Output
    always @ (negedge clk) begin
        if (present_state == idle) begin // when present state is idle
            count_money = 0;
            dispense_noodle = 0;
            change = 0;
        end
        else if (present_state == one || present_state == two) begin // when present state is one or two
            count_money = count_money + inserted_cash; // count inserted notes
        end
        else if (present_state == result) begin // when present state is result
            change = count_money - 3'b011; // calculate change by subtracting RM3 from count money
            dispense_noodle = select_menu; // dispense noodle that is selected
        end
        else if (present_state == menu_select) begin // when present state is menu select
            count_money = count_money + inserted_cash; // continue to count money
        end
        else if (present_state == refund) begin // when refund
            change = count_money; // calculate change based on inserted notes
        end
    end

endmodule
