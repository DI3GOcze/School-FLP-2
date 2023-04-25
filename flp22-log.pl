/**
 * FLP - 2. project - Turing machine
 * Author: Jakub Kryštůfek
 * Date: 25.04.2023
 */

/** 
 * main Makefile target starting point
 */
main :-
    % Disable symbols printed by get_char
	prompt(_, ''),
    read_lines(Lines),
    % Create inital configuration of turing machine
    get_configuration(Tape, Lines),
    % Run turing machine with initial state S, head position 0 and tape from input
    run_ts(['S' | Tape], Steps),
    % Print 
    write_tapes(Steps).



/** ======================== TURING MACHINE BEGIN ======================== **/

/**
 * ts_rule(CURRENT_STATE, HEAD_SYMBOL, NEXT_STATE, ACTION(symbol/R/L))
 */
:- dynamic ts_rule/4.

/**
 * get_configuration Parses list of strings to Tape and Rules (last string is Tape)
 */
get_configuration(Tape , [Tape]).
get_configuration(Tape, [[P, _, A, _, Q, _, B] | LineRest]) :-
    assert(ts_rule(P, A, Q, B)),
    get_configuration(Tape, LineRest).

/**
 * get_current_state Finds current State and Symbol in given Tape
 * Possible only if States are uppercase and symbols lowercase
 */
% Head is enywhere else than at the end (symbol is to the right of the state)
get_current_state(State, Symbol, [State, Symbol | _]):-
    is_state(State),
    is_tape_symbol(Symbol), !.
% If tape is empty or head is at the end of tape
get_current_state(State, Symbol, [State]):-
    is_state(State),
    Symbol = ' ', !.
% Iterator
get_current_state(State, Symbol, [_ | RestTape]) :-
    get_current_state(State, Symbol, RestTape).

/** 
 * apply_rule Modifies current tape with given rule (changing state and aplying action)
 */
% If action is L
apply_rule([PreviousSymbol, CurrentState | RestTape], NextState, Action, [NextState, PreviousSymbol | RestTape]) :-
    is_equal(Action, 'L'),
    is_state(CurrentState),
    is_tape_symbol(PreviousSymbol), !.
% If action is R
apply_rule([CurrentState, HeadSymbol | RestTape], NextState, Action, [HeadSymbol, NextState | RestTape]) :-
    is_equal(Action, 'R'),
    is_state(CurrentState),
    is_tape_symbol(HeadSymbol), !.
% If action is R and head is at the end
apply_rule([CurrentState | RestTape], NextState, Action, [' ', NextState | RestTape]) :-
    is_equal(Action, 'R'),
    is_state(CurrentState), !.
% If action is new tape symbol
apply_rule([CurrentState, HeadSymbol | RestTape], NextState, Action, [NextState, Action | RestTape]) :-
    is_tape_symbol(Action),
    is_state(CurrentState),
    is_tape_symbol(HeadSymbol), !.
% If action is new tape symbol and is at the end of tape
apply_rule([CurrentState], NextState, Action, [NextState, Action]) :-
    is_tape_symbol(Action),
    is_state(CurrentState), !.
% Iterator
apply_rule([C | RestTape], NextState, Action, [C | NewTape]) :-
    apply_rule(RestTape, NextState, Action, NewTape).


/** 
 * get_applicable_rule Returns rule that can be applied on current symbol under head and current state
 */
get_applicable_rule(CurrState, HeadSymbol, NextState, Action):- 
    ts_rule(CurrState, HeadSymbol, NextState, Action).

/** 
 * run_ts Runs turing machine simulation on given initial tape (uses rules from ts_rule/4)
 * One call of run_ts equals one step of turing machine
 */
% If current state is F, stop the simulation
run_ts(Tape, [Tape]) :-
    get_current_state(CurrentState, _, Tape),
    is_equal(CurrentState, 'F').
% For every other situation than state = F, simulete one step of turing machine
run_ts(Tape, [Tape | Steps]) :-
    % Get character on HEAD and current state
    get_current_state(CurrentState, HeadSymbol, Tape),
    get_applicable_rule(CurrentState, HeadSymbol, NextState, Action),
    % Apply found rule on current tape
    apply_rule(Tape, NextState, Action, ModifiedTape),
    run_ts(ModifiedTape, Steps).

/** ======================== TURING MACHINE END ======================== **/



/** ======================== STDIN/STDOUT HELPERS BEGIN ======================== **/

% Reads single line from STDIN
read_line(L,C) :-
	get_char(C),
	(isEOFEOL(C), L = [], !;
    read_line(LL,_),% atom_codes(C,[Cd]),
    [C|LL] = L).

% Checks if given charactrer is EOF
isEOFEOL(C) :-
	C == end_of_file;
	(char_code(C,Code), Code==10).

% Reads all lines from STDIN until EOF
read_lines(Ls) :-
    read_line(L,C),
	( C == end_of_file, Ls = [] ;
    read_lines(LLs), Ls = [L|LLs]
	), !. 

/** 
 * write_tapes Prints list of turing taps to stdout in string format => ['a', 'b', 'S', 'c'] => 'abSc'
 */
write_tapes([]).
write_tapes([Tape|RestTapes]) :- atomic_list_concat(Tape, '', TapeString), writeln(TapeString) , write_tapes(RestTapes).
    
/** ======================== STDIN HELPERS END ======================== **/



/** ======================== CAHARACTERS HELPERS BEGIN ======================== **/

/**
 * is_equal Checks if two values are qual
 */
is_equal(A,A).

/**
 * is_state Checks if given character is valid state character (uppercase) or not.
 */
is_state(State) :- 
    member(State, ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O','P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z']).

/**
 * is_tape_symbol Checks if given character is valid symbol from tape (lowercase) or not.
 */
is_tape_symbol(Symbol) :- 
    member(Symbol, ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', ' ']).

/** ======================== CAHARACTERS HELPERS END ======================== **/