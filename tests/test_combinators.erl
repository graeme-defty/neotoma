-module(test_combinators).
-author("Sean Cribbs <seancribbs@gmail.com>").
-include_lib("eunit/include/eunit.hrl").

% Test the parser-combinators in the 'peg_includes' module
-define(STARTINDEX, [1|1]).
eof_test_() ->
    [
     ?_assertEqual({fail,{expected,eof,?STARTINDEX}}, (peg_includes:p_eof())(<<"abc">>,?STARTINDEX)),
     ?_assertEqual({eof, [], ?STARTINDEX}, (peg_includes:p_eof())(<<>>,?STARTINDEX))
    ].

optional_test_() ->
    [
     ?_assertEqual({[], <<"xyz">>,?STARTINDEX}, (peg_includes:p_optional(peg_includes:p_string(<<"abc">>)))(<<"xyz">>,?STARTINDEX)),
     ?_assertEqual({<<"abc">>, <<"xyz">>,[1|4]}, (peg_includes:p_optional(peg_includes:p_string(<<"abc">>)))(<<"abcxyz">>,?STARTINDEX))
    ].

not_test_() ->
    [
     ?_assertEqual({[], <<"xyzabc">>,?STARTINDEX}, (peg_includes:p_not(peg_includes:p_string(<<"abc">>)))(<<"xyzabc">>,?STARTINDEX)),
     ?_assertEqual({fail,{expected, {no_match, <<"abc">>}, ?STARTINDEX}}, (peg_includes:p_not(peg_includes:p_string(<<"abc">>)))(<<"abcxyz">>,?STARTINDEX))
    ].

assert_test_() ->
    [
     ?_assertEqual({fail,{expected, {string, <<"abc">>}, ?STARTINDEX}}, (peg_includes:p_assert(peg_includes:p_string(<<"abc">>)))(<<"xyzabc">>,?STARTINDEX)),
     ?_assertEqual({[], <<"abcxyz">>,?STARTINDEX}, (peg_includes:p_assert(peg_includes:p_string(<<"abc">>)))(<<"abcxyz">>,?STARTINDEX))
    ].

seq_test_() ->
    [
     ?_assertEqual({[<<"abc">>,<<"def">>], <<"xyz">>,[1|7]}, (peg_includes:p_seq([peg_includes:p_string(<<"abc">>), peg_includes:p_string(<<"def">>)]))(<<"abcdefxyz">>,?STARTINDEX)),
     ?_assertEqual({fail,{expected, {string, <<"def">>}, [1|4]}}, (peg_includes:p_seq([peg_includes:p_string(<<"abc">>), peg_includes:p_string(<<"def">>)]))(<<"abcxyz">>,?STARTINDEX))
    ].

choose_test_() ->
    [
     ?_assertEqual({<<"abc">>, <<"xyz">>, [1|4]}, (peg_includes:p_choose([peg_includes:p_string(<<"abc">>), peg_includes:p_string(<<"def">>)]))(<<"abcxyz">>,?STARTINDEX)),
     ?_assertEqual({<<"def">>, <<"xyz">>, [1|4]}, (peg_includes:p_choose([peg_includes:p_string(<<"abc">>), peg_includes:p_string(<<"def">>)]))(<<"defxyz">>,?STARTINDEX)),
     ?_assertEqual({<<"xyz">>, <<"xyz">>, [1|4]}, (peg_includes:p_choose([peg_includes:p_string(<<"abc">>), peg_includes:p_string(<<"def">>), peg_includes:p_string(<<"xyz">>)]))(<<"xyzxyz">>,?STARTINDEX)),
     ?_assertEqual({fail,{expected,{string,<<"abc">>},?STARTINDEX}}, (peg_includes:p_choose([peg_includes:p_string(<<"abc">>),peg_includes:p_string(<<"def">>)]))(<<"xyz">>, ?STARTINDEX))
    ].

zero_or_more_test_() ->
    [
     ?_assertEqual({[], <<>>, ?STARTINDEX}, (peg_includes:p_zero_or_more(peg_includes:p_string(<<"abc">>)))(<<"">>,?STARTINDEX)),
     ?_assertEqual({[], <<"def">>,?STARTINDEX}, (peg_includes:p_zero_or_more(peg_includes:p_string(<<"abc">>)))(<<"def">>,?STARTINDEX)),
     ?_assertEqual({[<<"abc">>], <<"def">>,[1|4]}, (peg_includes:p_zero_or_more(peg_includes:p_string(<<"abc">>)))(<<"abcdef">>,?STARTINDEX)),
     ?_assertEqual({[<<"abc">>, <<"abc">>], <<"def">>,[1|7]}, (peg_includes:p_zero_or_more(peg_includes:p_string(<<"abc">>)))(<<"abcabcdef">>,?STARTINDEX))
    ].

one_or_more_test_() ->
    [
     ?_assertEqual({fail,{expected,
                          {at_least_one,
                           {string, <<"abc">>}
                          }, ?STARTINDEX}}, (peg_includes:p_one_or_more(peg_includes:p_string(<<"abc">>)))(<<"def">>,?STARTINDEX)),
     ?_assertEqual({[<<"abc">>], <<"def">>,[1|4]}, (peg_includes:p_one_or_more(peg_includes:p_string(<<"abc">>)))(<<"abcdef">>,?STARTINDEX)),
     ?_assertEqual({[<<"abc">>,<<"abc">>], <<"def">>,[1|7]}, (peg_includes:p_one_or_more(peg_includes:p_string(<<"abc">>)))(<<"abcabcdef">>,?STARTINDEX))
    ].

label_test_() ->
    [
     ?_assertEqual({fail,{expected, {string, <<"!">>}, ?STARTINDEX}}, (peg_includes:p_label(bang, peg_includes:p_string(<<"!">>)))(<<"?">>,?STARTINDEX)),
     ?_assertEqual({{bang, <<"!">>}, <<"">>,[1|2]}, (peg_includes:p_label(bang, peg_includes:p_string(<<"!">>)))(<<"!">>,?STARTINDEX))
    ].

string_test_() ->
    [
     ?_assertEqual({<<"abc">>, <<"def">>,[1|4]}, (peg_includes:p_string(<<"abc">>))(<<"abcdef">>,?STARTINDEX)),
     ?_assertEqual({fail,{expected, {string, <<"abc">>}, ?STARTINDEX}}, (peg_includes:p_string(<<"abc">>))(<<"defabc">>,?STARTINDEX))
    ].

anything_test_() ->
    [
     ?_assertEqual({<<"a">>,<<"bcde">>,[1|2]}, (peg_includes:p_anything())(<<"abcde">>,?STARTINDEX)),
     ?_assertEqual({<<"\n">>,<<"bcde">>,[2|1]}, (peg_includes:p_anything())(<<"\nbcde">>,?STARTINDEX)),
     ?_assertEqual({fail,{expected, any_character, ?STARTINDEX}}, (peg_includes:p_anything())(<<"">>,?STARTINDEX))
    ].

charclass_test_() ->
    [
     ?_assertEqual({<<"+">>,<<"----">>,[1|2]}, (peg_includes:p_charclass(<<"[+]">>))(<<"+----">>,?STARTINDEX)),
     ?_assertEqual({fail,{expected, {character_class, "[+]"}, ?STARTINDEX}}, (peg_includes:p_charclass(<<"[+]">>))(<<"----">>,?STARTINDEX))
    ].

line_test() ->
    ?assertEqual(11, peg_includes:line([11|22])).

column_test() ->
    ?assertEqual(33, peg_includes:column([22|33])).

