

:-	 use_module(library(python)).
:-	 use_module(library(yapi)).

:-	python_import(sys).



set_python_output(OldOutput,OldError) :-
	open('//python/sys.stdout', append, Output),
	open('//python/sys.stderr', append, Error),
	prolog_flag(user_output, OldOutput, Output),
	prolog_flag(user_error, OldError, Error).



restore_python_output(OldOutput,OldError) :-
	set_prolog_flag(user_output, Output),
	set_prolog_flag(user_error, Error),
	prolog_flag(user_output, OldOutput, Output),
	prolog_flag(user_error, OldError, Error),
	close(OldOutput),
	close(OldError).

jupyter_query(String, Dict )  :-
	set_python_output(OldOutput,OldError),
	writeln(my:String),
	yapi_query( String, Dict),
	writeln(my:Dict),
	restore_python_output(OldOutput,OldError),
	true.
