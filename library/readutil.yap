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
* File:		readutil.yap						 *
* Last rev:	5/12/99							 *
* mods:									 *
* comments:	SWI compatible read utilities				 *
*									 *
*************************************************************************/

/**
 * @file   readutil.yap
 * @author VITOR SANTOS COSTA <vsc@VITORs-MBP.lan>
 * @date   Wed Nov 18 00:16:15 2015
 *
 * @brief  Read full lines and a full file in a single call.
 *
 *
*/

:- module(readutil, [
	read_line_to_codes/2,
	read_line_to_codes/3,
	read_stream_to_codes/2,
	read_stream_to_codes/3,
	read_file_to_codes/2,
	read_file_to_codes/3,
	read_file_to_terms/2,
                     read_file_to_terms/3,
                     read_line_to_string/2
		    ]).

/**
* @defgroup readutil
* @ingroup library
*
*  Read full lines and a full file in a single call.
*
*/


read_stream_to_codes(Stream, Codes) :-
	read_stream_to_codes(Stream, Codes, []).

read_file_to_codes(File, Codes, _) :-
	open(File, read, Stream),
	read_stream_to_codes(Stream, Codes, []),
	close(Stream).

read_file_to_codes(File, Codes) :-
	open(File, read, Stream),
	read_stream_to_codes(Stream, Codes, []),
	close(Stream).

read_file_to_terms(File, Codes, _) :-
	open(File, read, Stream),
	prolog_read_stream_to_terms(Stream, Codes, []),
	close(Stream).

read_file_to_terms(File, Codes) :-
	open(File, read, Stream),
	read_stream_to_terms(Stream, Codes, []),
	close(Stream).


prolog_read_stream_to_terms(Stream, Terms, Terms0) :-
	read(Stream, Term),
	(Term == end_of_file ->
	    Terms = Terms0
	;
	    Terms = [Term|TermsI],
	    prolog_read_stream_to_terms(Stream, TermsI, Terms0)
	).
