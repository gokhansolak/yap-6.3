/*************************************************************************
*									 *
*	 YAP Prolog 							 *
*									 *
*	Yap Prolog was developed at NCCUP - Universidade do Porto	 *
*									 *
* Copyright L.Damas, V.S.Costa and Universidade do Porto 1985-1997	 *
*									 *
**************************************************************************
*									 *
* File:		directives.yap						 *
* Last rev:								 *
* mods:									 *
* comments:	directing system execution				 *
*									 *
*************************************************************************/

'$directive'(multifile(_)).
'$directive'(discontiguous(_)).
'$directive'(initialization(_)).
'$directive'(include(_)).
'$directive'(module(_,_)).
'$directive'(module(_,_,_)).
'$directive'(meta_predicate(_)).
'$directive'(public(_)).
'$directive'(dynamic(_)).
'$directive'(op(_,_,_)).
'$directive'(set_prolog_flag(_,_)).
'$directive'(ensure_loaded(_)).
'$directive'(char_conversion(_,_)).
'$directive'(compile(_)).
'$directive'(consult(_)).
'$directive'(reconsult(_)).
'$directive'(sequential).
'$directive'(parallel).
'$directive'(sequential(_)).
'$directive'(block(_)).
'$directive'(wait(_)).
'$directive'(use_module(_)).
'$directive'(use_module(_,_)).
'$directive'(use_module(_,_,_)).

'$exec_directive'(multifile(D), _, M) :-
	'$system_catch'('$multifile'(D, M), M,
	      Error,
	      user:'$LoopError'(Error)).
'$exec_directive'(discontiguous(D), _, M) :-
	'$discontiguous'(D,M).
'$exec_directive'(initialization(D), _, M) :-
	'$initialization'(M:D).
'$exec_directive'(parallel, _, _) :-
	'$parallel'.
'$exec_directive'(sequential, _, _) :-
	'$sequential'.
'$exec_directive'(sequential(G), _, M) :-
	'$sequential_directive'(G, M).
'$exec_directive'(parallel(G), _, M) :-
	'$parallel_directive'(G, M).
'$exec_directive'(include(F), Status, _) :-
	'$include'(F, Status).
'$exec_directive'(module(N,P), Status, _) :-
	'$module'(Status,N,P).
'$exec_directive'(module(N,P,Op), Status, _) :-
	'$module'(Status,N,P,Op).
'$exec_directive'(meta_predicate(P), _, M) :-
	'$meta_predicate'(P, M).
'$exec_directive'(dynamic(P), _, M) :-
	'$dynamic'(P, M).
'$exec_directive'(op(P,OPSEC,OP), _, _) :-
	op(P,OPSEC,OP).
'$exec_directive'(set_prolog_flag(F,V), _, _) :-
	set_prolog_flag(F,V).
'$exec_directive'(ensure_loaded(F), _, M) :-
	'$ensure_loaded'(M:F).
'$exec_directive'(char_conversion(IN,OUT), _, _) :-
	char_conversion(IN,OUT).
'$exec_directive'(public(P), _, M) :-
	'$public'(P, M).
'$exec_directive'(compile(F), _, M) :-
	'$compile'(M:F).
'$exec_directive'(reconsult(Fs), _, M) :-
	'$reconsult'(M:Fs).
'$exec_directive'(consult(Fs), _, M) :-
	'$consult'(Fs).
'$exec_directive'(use_module(Fs), _, M) :-
	'$use_module'(M:Fs).
'$exec_directive'(use_module(Fs,I), _, M) :-
	'$use_module'(M:Fs,I).
'$exec_directive'(use_module(Fs,F,I), _, M) :-
	'$use_module'(Fs,M:F,I).
'$exec_directive'(block(BlockSpec), _, _) :-
	'$block'(BlockSpec).
'$exec_directive'(wait(BlockSpec), _, _) :-
	'$wait'(BlockSpec).
'$exec_directive'(table(PredSpec), _, M) :-
	'$table'(PredSpec, M).

'$exec_directives'((G1,G2), Mode, M) :- !,
	'$exec_directives'(G1, Mode, M),
	'$exec_directives'(G2, Mode, M).
'$exec_directives'(G, Mode, M) :-
	'$exec_directive'(G, Mode, M).




yap_flag(V,Out) :-
	var(V), !,
	'$show_yap_flag_opts'(V,Out).

% do or do not machine code
yap_flag(fast,on) :- '$set_value'('$fast',true).
yap_flag(fast,off) :- !, '$set_value'('$fast',[]).

% do or do not machine code
yap_flag(argv,L) :- '$argv'(L).

% hide/unhide atoms
yap_flag(hide,Atom) :- !, hide(Atom).
yap_flag(unhide,Atom) :- !, unhide(Atom).

% control garbage collection
yap_flag(gc,V) :-
	var(V), !,
	( '$get_value'('$gc',[]) -> V = off ; V = on).
yap_flag(gc,on) :- '$set_value'('$gc',true).
yap_flag(gc,off) :- '$set_value'('$gc',[]).
yap_flag(gc_margin,N) :- 
	var(N) -> 
		 '$get_value'('$gc_margin',N)
        ;
        integer(N) ->
	         '$set_value'('$gc_margin',N).
yap_flag(gc_trace,V) :-
	var(V), !,
	'$get_value'('$gc_trace',N1),
	'$get_value'('$gc_verbose',N2),
	'$get_value'('$gc_very_verbose',N3),
	'$yap_flag_show_gc_tracing'(N1, N2, N3, V).
yap_flag(gc_trace,on) :-
	'$set_value'('$gc_trace',true),
	'$set_value'('$gc_verbose',[]),
	'$set_value'('$gc_very_verbose',[]).
yap_flag(gc_trace,verbose) :-
	'$set_value'('$gc_trace',[]),
	'$set_value'('$gc_verbose',true),
	'$set_value'('$gc_very_verbose',[]).
yap_flag(gc_trace,very_verbose) :-
	'$set_value'('$gc_trace',[]),
	'$set_value'('$gc_verbose',true),
	'$set_value'('$gc_very_verbose',true).
yap_flag(gc_trace,off) :-
	'$set_value'('$gc_trace',[]),
	'$set_value'('$gc_verbose',[]),
	'$set_value'('$gc_very_verbose',[]).
yap_flag(syntax_errors, V) :- var(V), !,
	'$get_read_error_handler'(V).
yap_flag(syntax_errors, Option) :-
	'$set_read_error_handler'(Option).
% compatibility flag
yap_flag(enhanced,on) :- '$set_value'('$enhanced',true).
yap_flag(enhanced,off) :- '$set_value'('$enhanced',[]).
%
% show state of $
%
yap_flag(dollar_as_lower_case,V) :-
	var(V), !,
	'$type_of_char'(36,T),
	(T = 3 -> V = on ; V = off).
%
% make $a a legit atom
%
yap_flag(dollar_as_lower_case,on) :-
	'$change_type_of_char'(36,3).
%
% force quoting of '$a'
%
yap_flag(dollar_as_lower_case,off) :- 
	'$change_type_of_char'(36,7).

yap_flag(profiling,X) :- (var(X); X = on; X = off), !,
	'$is_profiled'(X).

yap_flag(bounded,X) :-
	var(X), !,
	'$access_yap_flags'(0, X1),
	'$transl_to_true_false'(X1,X).
yap_flag(bounded,X) :-
	(X = true ; X = false), !,
	throw(error(permission_error(modify,flag,bounded),yap_flag(bounded,X))).
yap_flag(bounded,X) :-
	throw(error(domain_error(flag_value,bounded+X),yap_flag(bounded,X))).

% do or do not indexation
yap_flag(index,X) :- var(X), !,
	 ( '$get_value'('$doindex',true) -> X=on ; X=off).
yap_flag(index,on)  :- !, '$set_value'('$doindex',true).
yap_flag(index,off) :- !, '$set_value'('$doindex',[]).

yap_flag(informational_messages,X) :- var(X), !,
	 '$get_value'('$verbose',X).
yap_flag(informational_messages,on)  :- !, '$set_value'('$verbose',on).
yap_flag(informational_messages,off) :- !, '$set_value'('$verbose',off).
yap_flag(informational_messages,X) :-
	throw(error(domain_error(flag_value,informational_messages+X),yap_flag(informational_messages,X))).

yap_flag(integer_rounding_function,X) :-
	var(X), !,
	'$access_yap_flags'(2, X1),
	'$transl_to_rounding_function'(X1,X).
yap_flag(integer_rounding_function,X) :-
	(X = down; X = toward_zero), !,
	throw(error(permission_error(modify,flag,integer_rounding_function),yap_flag(integer_rounding_function,X))).
yap_flag(integer_rounding_function,X) :-
	throw(error(domain_error(flag_value,integer_rounding_function+X),yap_flag(integer_rounding_function,X))).

yap_flag(max_arity,X) :-
	var(X), !,
	'$access_yap_flags'(1, X1),
	'$transl_to_arity'(X1,X).
yap_flag(max_arity,X) :-
	integer(X), X > 0, !,
	throw(error(permission_error(modify,flag,max_arity),yap_flag(max_arity,X))).
yap_flag(max_arity,X) :-
	throw(error(domain_error(flag_value,max_arity+X),yap_flag(max_arity,X))).

yap_flag(version,X) :-
	var(X), !,
	'$get_value'('$version_name',X).
yap_flag(version,X) :-
	throw(error(permission_error(modify,flag,version),yap_flag(version,X))).

yap_flag(max_integer,X) :-
	var(X), !,
	'$access_yap_flags'(0, 1),
	'$access_yap_flags'(3, X).
yap_flag(max_integer,X) :-
	integer(X), X > 0, !,
	throw(error(permission_error(modify,flag,max_integer),yap_flag(max_integer,X))).
yap_flag(max_integer,X) :-
	throw(error(domain_error(flag_value,max_integer+X),yap_flag(max_integer,X))).

yap_flag(min_integer,X) :-
	var(X), !,
	'$access_yap_flags'(0, 1),
	'$access_yap_flags'(4, X).
yap_flag(min_integer,X) :-
	integer(X), X < 0, !,
	throw(error(permission_error(modify,flag,min_integer),yap_flag(min_integer,X))).
yap_flag(min_integer,X) :-
	throw(error(domain_error(flag_value,min_integer+X),yap_flag(min_integer,X))).

yap_flag(char_conversion,X) :-
	var(X), !,
	'$access_yap_flags'(5, X1),
	'$transl_to_on_off'(X1,X).
yap_flag(char_conversion,X) :-
	'$transl_to_on_off'(X1,X), !,
	'$set_yap_flags'(5,X1),
	( X1 = 1 ->
	    '$force_char_conversion'
	    ;
	    '$disable_char_conversion'
	).
yap_flag(char_conversion,X) :-
	throw(error(domain_error(flag_value,char_conversion+X),yap_flag(char_conversion,X))).

yap_flag(double_quotes,X) :-
	var(X), !,
	'$access_yap_flags'(6, X1),
	'$transl_to_trl_types'(X1,X).
yap_flag(double_quotes,X) :-
	'$transl_to_trl_types'(X1,X), !,
	'$set_yap_flags'(6,X1).
yap_flag(double_quotes,X) :-
	throw(error(domain_error(flag_value,double_quotes+X),yap_flag(double_quotes,X))).

yap_flag(n_of_integer_keys_in_db,X) :-
	var(X), !,
	'$resize_int_keys'(X).
yap_flag(n_of_integer_keys_in_db,X) :- integer(X), X > 0, !,
	'$resize_int_keys'(X).
yap_flag(n_of_integer_keys_in_db,X) :-
	throw(error(domain_error(flag_value,n_of_integer_keys_in_db+X),yap_flag(n_of_integer_keys_in_db,X))).

yap_flag(n_of_integer_keys_in_bb,X) :-
	var(X), !,
	'$resize_bb_int_keys'(X).
yap_flag(n_of_integer_keys_in_bb,X) :- integer(X), X > 0, !,
	'$resize_bb_int_keys'(X).
yap_flag(n_of_integer_keys_in_bb,X) :-
	throw(error(domain_error(flag_value,n_of_integer_keys_in_bb+X),yap_flag(n_of_integer_keys_in_bb,X))).

yap_flag(strict_iso,OUT) :-
	var(OUT), !,
	'$access_yap_flags'(9,X),
	'$transl_to_on_off'(X,OUT).
yap_flag(strict_iso,on) :- !,
	yap_flag(language,iso),
	'$transl_to_on_off'(X,on),
	'$set_yap_flags'(9,X).
yap_flag(strict_iso,off) :- !,
	'$transl_to_on_off'(X,off),
	'$set_yap_flags'(9,X).
yap_flag(strict_iso,X) :-
	throw(error(domain_error(flag_value,strict_iso+X),yap_flag(strict_iso,X))).

yap_flag(language,X) :-
	var(X), !,
	'$access_yap_flags'(8, X1),
	'$trans_to_lang_flag'(X1,X).
yap_flag(language,X) :-
	'$trans_to_lang_flag'(N,X), !,
	'$set_yap_flags'(8,N),
	'$adjust_language'(X).
yap_flag(language,X) :-
	throw(error(domain_error(flag_value,language+X),yap_flag(language,X))).

yap_flag(debug,X) :-
	var(X), !,
	('$get_value'(debug,1) ->
	    X = on
	;
	    X = off
	).
yap_flag(debug,X) :-
	'$transl_to_on_off'(_,X), !,
	(X = on -> debug ; nodebug).
yap_flag(debug,X) :-
	throw(error(domain_error(flag_value,debug+X),yap_flag(debug,X))).

yap_flag(discontiguous_warnings,X) :-
	var(X), !,
	('$syntax_check_mode'(on,_), '$syntax_check_discontiguous'(on,_) ->
	    X = on
	;
	    X = off
	).
yap_flag(discontiguous_warnings,X) :-
	'$transl_to_on_off'(_,X), !,
	(X = on -> 
	    '$syntax_check_mode'(_,on),
	    '$syntax_check_discontiguous'(_,on)
	;
	    '$syntax_check_discontiguous'(_,off)).
yap_flag(discontiguous_warnings,X) :-
	throw(error(domain_error(flag_value,discontiguous_warnings+X),yap_flag(discontiguous_warnings,X))).

yap_flag(redefine_warnings,X) :-
	var(X), !,
	('$syntax_check_mode'(on,_), '$syntax_check_multiple'(on,_) ->
	    X = on
	;
	    X = off
	).
yap_flag(redefine_warnings,X) :-
	'$transl_to_on_off'(_,X), !,
	(X = on -> 
	    '$syntax_check_mode'(_,on),
	    '$syntax_check_multiple'(_,on)
	;
	    '$syntax_check_multiple'(_,off)).
yap_flag(redefine_warnings,X) :-
	throw(error(domain_error(flag_value,redefine_warnings+X),yap_flag(redefine_warnings,X))).

yap_flag(single_var_warnings,X) :-
	var(X), !,
	('$syntax_check_mode'(on,_), '$syntax_check_single_var'(on,_) ->
	    X = on
	;
	    X = off
	).
yap_flag(single_var_warnings,X) :-
	'$transl_to_on_off'(_,X), !,
	(X = on -> 
	    '$syntax_check_mode'(_,on),
	    '$syntax_check_single_var'(_,on)
	;
	    '$syntax_check_single_var'(_,off)).
yap_flag(single_var_warnings,X) :-
	throw(error(domain_error(flag_value,single_var_warnings+X),yap_flag(single_var_warnings,X))).

yap_flag(unknown,X) :-
	var(X), !,
	unknown(X,_).
yap_flag(unknown,N) :-
	unknown(_,N).

yap_flag(to_chars_mode,X) :-
	var(X), !,
	( '$access_yap_flags'(7,0) -> X = quintus ; X = iso ).
yap_flag(to_chars_mode,quintus) :- !,
	'$set_yap_flags'(7,0).
yap_flag(to_chars_mode,iso) :- !,
	'$set_yap_flags'(7,1).
yap_flag(to_chars_mode,X) :-
	throw(error(domain_error(flag_value,to_chars_mode+X),yap_flag(to_chars_mode,X))).

yap_flag(character_escapes,X) :-
	var(X), !,
	'$access_yap_flags'(12,Y),	
	'$transl_to_character_escape_modes'(Y,X).
yap_flag(character_escapes,X) :- !,
	'$transl_to_character_escape_modes'(Y,X), !,
	'$set_yap_flags'(12,Y).
yap_flag(character_escapes,X) :-
	throw(error(domain_error(flag_value,character_escapes+X),yap_flag(to_chars_mode,X))).

yap_flag(update_semantics,X) :-
	var(X), !,
	( '$log_upd'(I) -> '$convert_upd_sem'(I,X) ).
yap_flag(update_semantics,logical) :- !,
	'$switch_log_upd'(1).
yap_flag(update_semantics,logical_assert) :- !,
	'$switch_log_upd'(2).
yap_flag(update_semantics,immediate) :- !,
	'$switch_log_upd'(0).
yap_flag(update_semantics,X) :-
	throw(error(domain_error(flag_value,update_semantics+X),yap_flag(update_semantics,X))).

yap_flag(toplevel_hook,X) :-
	var(X), !,
	( '$recorded'('$toplevel_hooks',G,_) -> G ; true ).
yap_flag(toplevel_hook,G) :- !,
	'$set_toplevel_hook'(G).

yap_flag(typein_module,X) :-
	var(X), !,
	'$current_module'(X).
yap_flag(typein_module,X) :-
	module(X).

yap_flag(write_strings,OUT) :-
	var(OUT), !,
	'$access_yap_flags'(13,X),
	'$transl_to_on_off'(X,OUT).
yap_flag(write_strings,on) :- !,
	'$transl_to_on_off'(X,on),
	'$set_yap_flags'(13,X).
yap_flag(write_strings,off) :- !,
	'$transl_to_on_off'(X,off),
	'$set_yap_flags'(13,X).
yap_flag(write_strings,X) :-
	throw(error(domain_error(flag_value,write_strings+X),yap_flag(write_strings,X))).

yap_flag(user_input,OUT) :-
	var(OUT), !,
	'$flag_check_alias'(OUT, user_input).
	
yap_flag(user_input,Stream) :-
	'$change_alias_to_stream'(user_input,Stream).

yap_flag(user_output,OUT) :-
	var(OUT), !,
	'$flag_check_alias'(OUT, user_output).
yap_flag(user_output,Stream) :-
	'$change_alias_to_stream'(user_output,Stream).


yap_flag(user_error,OUT) :-
	var(OUT), !,
	'$flag_check_alias'(OUT, user_error).
yap_flag(user_error,Stream) :-
	'$change_alias_to_stream'(user_error,Stream).

yap_flag(debugger_print_options,OUT) :-
	var(OUT),
	'$recorded'('$print_options','$debugger'(OUT),_), !.
yap_flag(debugger_print_options,Opts) :- !,
	'$check_io_opts'(Opts, yap_flag(debugger_print_options,Opts)),
	'$recorda'('$print_options','$debugger'(Opts),_).

:- '$recorda'('$print_options','$debugger'([quoted(true),numbervars(true),portrayed(true),max_depth(10)]),_).

yap_flag(toplevel_print_options,OUT) :-
	var(OUT),
	'$recorded'('$print_options','$toplevel'(OUT),_), !.
yap_flag(toplevel_print_options,Opts) :- !,
	'$check_io_opts'(Opts, yap_flag(toplevel_print_options,Opts)),
	'$recorda'('$print_options','$toplevel'(Opts),_).

:- '$recorda'('$print_options','$toplevel'([quoted(true),numbervars(true),portrayed(true)]),_).

yap_flag(host_type,X) :-
	'$host_type'(X).

'$show_yap_flag_opts'(V,Out) :-
	(
	    V = argv ;
	    V = bounded ;
	    V = char_conversion ;
	    V = character_escapes ;
	    V = debug ;
	    V = debugger_print_options ;
	    V = discontiguous_warnings ;
	    V = dollar_as_lower_case ;
	    V = double_quotes ;
%	    V = fast  ;
	    V = gc    ;
	    V = gc_margin    ;
	    V = gc_trace     ;
%	    V = hide  ;
%	    V = host_type  ;
	    V = index ;
	    V = informational_messages ;
	    V = integer_rounding_function ;
	    V = language ;
	    V = max_arity ;
	    V = max_integer ;
	    V = min_integer ;
            V = n_of_integer_keys_in_db ;
	    V = profiling ;
	    V = redefine_warnings ;
	    V = single_var_warnings ;
	    V = strict_iso ;
	    V = syntax_errors ;
	    V = to_chars_mode ;
	    V = toplevel_hook ;
	    V = toplevel_print_options ;
	    V = typein_module ;
	    V = unknown ;
	    V = update_semantics ;
            V = user_error ;
	    V = user_input ;
            V = user_output ;
            V = version ;
            V = write_strings
	),
	yap_flag(V, Out).

'$trans_to_lang_flag'(0,cprolog).
'$trans_to_lang_flag'(1,iso).
'$trans_to_lang_flag'(2,sicstus).

'$adjust_language'(cprolog) :-
	'$switch_log_upd'(0),
	'$syntax_check_mode'(_,off),
	'$syntax_check_single_var'(_,off),
	'$syntax_check_discontiguous'(_,off),
	'$syntax_check_multiple'(_,off),
	'$transl_to_on_off'(Y,off), % disable character escapes.
	'$set_yap_flags'(12,Y),
	'$set_yap_flags'(14,1),
	'$set_fpu_exceptions',
	unknown(_,error).
'$adjust_language'(sicstus) :-
	'$switch_log_upd'(1),
	leash(full),
	'$syntax_check_mode'(_,on),
	'$syntax_check_single_var'(_,on),
	'$syntax_check_discontiguous'(_,on),
	'$syntax_check_multiple'(_,on),
	'$transl_to_on_off'(X1,on),
	'$set_yap_flags'(5,X1),
	'$force_char_conversion',
	'$set_yap_flags'(14,0),
	'$set_fpu_exceptions',
	unknown(_,error).
'$adjust_language'(iso) :-
	'$switch_log_upd'(2),
	'$syntax_check_mode'(_,on),
	'$syntax_check_single_var'(_,on),
	'$syntax_check_discontiguous'(_,on),
	'$syntax_check_multiple'(_,on),
	'$set_yap_flags'(7,1),
	fileerrors,
	'$transl_to_on_off'(X1,on),
	'$set_yap_flags'(5,X1),
	'$force_char_conversion',
	'$set_yap_flags'(14,0),
	'$set_fpu_exceptions',
	unknown(_,error).

'$transl_to_character_escape_modes'(0,off) :- !.
'$transl_to_character_escape_modes'(0,cprolog).
'$transl_to_character_escape_modes'(1,on) :- !.
'$transl_to_character_escape_modes'(1,iso).
'$transl_to_character_escape_modes'(2,sicstus).

'$convert_upd_sem'(0,immediate).
'$convert_upd_sem'(1,logical).
'$convert_upd_sem'(2,logical_assert).

'$transl_to_true_false'(0,false).
'$transl_to_true_false'(1,true).

'$transl_to_on_off'(0,off).
'$transl_to_on_off'(1,on).

'$transl_to_arity'(X1,X) :- X1 < 0, !, X = unbounded.
'$transl_to_arity'(X,X).

'$transl_to_rounding_function'(0,down).
'$transl_to_rounding_function'(1,toward_zero).

'$transl_to_trl_types'(0,chars).
'$transl_to_trl_types'(1,codes).
'$transl_to_trl_types'(2,atom).

'$yap_flag_show_gc_tracing'(true, _, _, on) :- !.
'$yap_flag_show_gc_tracing'(_, true, _, verbose) :- !.
'$yap_flag_show_gc_tracing'(_, _, on, very_verbose) :- !.
'$yap_flag_show_gc_tracing'(_, _, _, off).

'$flag_check_alias'(OUT, Alias) :-
	stream_property(OUT,[alias(Alias)]), !.
	
current_prolog_flag(V,Out) :-
	(var(V) ; atom(V) ), !,
	'$show_yap_flag_opts'(V,NOut),
	NOut = Out.
current_prolog_flag(V,Out) :-
	throw(error(type_error(atom,V),current_prolog_flag(V,Out))).

set_prolog_flag(F,V) :-
	var(F), !,
	throw(error(instantiation_error,set_prolog_flag(F,V))).
set_prolog_flag(F,V) :-
	var(V), !,
	throw(error(instantiation_error,set_prolog_flag(F,V))).
set_prolog_flag(F,V) :-
	\+ atom(F), !,
	throw(error(type_error(atom,F),set_prolog_flag(F,V))).
set_prolog_flag(F,V) :-
	yap_flag(F,V).

prolog_flag(F, Old, New) :-
	var(F), !,
	throw(error(instantiation_error,prolog_flag(F,Old,New))).
prolog_flag(F, Old, New) :-
	current_prolog_flag(F, Old),
	set_prolog_flag(F, New).

prolog_flag(F, Old) :-
	current_prolog_flag(F, Old).

% if source_mode is on, then the source for the predicates
% is stored with the code
source_mode(Old,New) :-
	'$access_yap_flags'(11,X),
	'$transl_to_on_off'(X,Old),
	'$transl_to_on_off'(XN,New),
	'$set_yap_flags'(11,XN).

source :- '$set_yap_flags'(11,1).
no_source :- '$set_yap_flags'(11,0).

