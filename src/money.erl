%%%-------------------------------------------------------------------
%%% @author admin
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 17. Jun 2019 11:49 PM
%%%-------------------------------------------------------------------
-module(money).
-author("admin").
-import(lists,[nth/2]).
%% API
-export([start/0,create_process_for_customers
/3,create_process_for_banks/2,master_process/4]).

start()->

  {ok, Db}=file:consult("banks.txt"),
  io:fwrite("** Banks and financial resources ** ~n"),
  Map_DB_bank=maps:from_list(Db),
  lists:foreach(fun(A)->
    create_process_for_banks(A, maps:get(A, Map_DB_bank)),
    io:fwrite("~w: ~w ~n",[A,maps:get(A, Map_DB_bank)])
                end,maps:keys(Map_DB_bank)),


  io:fwrite("~n ** Customers and loan objectives ** ~n "),

  {ok,DB_cus}=file:consult("customers.txt"),
  Map_DB_cus=maps:from_list(DB_cus),
  Map1 = maps:keys(Map_DB_bank),
  Map2=maps:keys(Map_DB_cus),
  register(masterprocess,spawn(money, master_process,[length(Map2),Map1,Map_DB_cus,Map_DB_cus])),
  lists:foreach(fun(A)->
    create_process_for_customers(A,maps:get(A, Map_DB_cus),Map1),
    io:fwrite("~w: ~w ~n",[A,maps:get(A, Map_DB_cus)])
                end,maps:keys(Map_DB_cus)).


create_process_for_banks(Pid,Funds)->
  register(Pid,spawn(bank, bank_receive_function,[Pid,Funds])).

create_process_for_customers(Pid,LoanAmount,Banks)->
  register(Pid,spawn(customer, customer_function,[Pid,LoanAmount,Banks])).

master_process(0,[],Map_DB_cus1,Map_DB_cus2)->


  lists:foreach(fun(A)->

    Result=maps:get(A, Map_DB_cus1),
    if
      Result==0->io:fwrite("~w has reached the objective of ~w dollars(s). Woo Hoo ~n",[A,maps:get(A, Map_DB_cus2)]);
      true -> io:fwrite("~w was only able to borrow ~w dollar(s). Boo Hoo ~n ",[A,maps:get(A, Map_DB_cus2)-Result])
    end
                end,maps:keys(Map_DB_cus1)),

  io:fwrite("End of Program");




master_process(0,Map1,Map_DB_cus1,Map_DB_cus2)->

  whereis(lists:last(Map1))!display1,
  receive
    {remain,Pid,Funds}->
      io:fwrite("~w has ~w Dollars remaining ~n",[Pid,Funds]),
      master_process(0,lists:droplast(Map1),Map_DB_cus1,Map_DB_cus2)
  end;

master_process(N,Map1,Map_DB_cus1,Map_DB_cus2)->
  receive
    {lnreq,Pid,Amount,Bank}->
      io:fwrite("~w request a loan of ~w Dollar(s) from ~w ~n",[Pid,Amount,Bank]),
      master_process(N,Map1,Map_DB_cus1,Map_DB_cus2);
    {lnapp,Pid,Pd,Amountx}->
      io:fwrite("~w Approves a loan of ~w Dollar(s) from ~w ~n",[Pd,Amountx,Pid]),
      Ini=maps:get(Pid,Map_DB_cus1),
      maps:remove(Pid,Map_DB_cus1),
      New_DB=maps:put(Pid,Ini-Amountx,Map_DB_cus1),
      master_process(N,Map1,New_DB,Map_DB_cus2);
    {lnuapp,Pid,Pd,Amountx}->
      io:fwrite("~w Denies a loan of ~w Dollar(s) from ~w ~n",[Pd,Amountx,Pid]),
      master_process(N,Map1,Map_DB_cus1,Map_DB_cus2);
    kill->
      master_process(N-1,Map1,Map_DB_cus1,Map_DB_cus2)
  end.