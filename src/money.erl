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

%% API
-export([start/0,create_process_for_customers
/3,create_process_for_banks/2,master_process/1]).

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
  register(masterprocess,spawn(money, master_process,[length(Map2)])),
  lists:foreach(fun(A)->
    create_process_for_customers(A,maps:get(A, Map_DB_cus),Map1),
    io:fwrite("~w: ~w ~n",[A,maps:get(A, Map_DB_cus)])
                end,maps:keys(Map_DB_cus)).


create_process_for_banks(Pid,Funds)->
  register(Pid,spawn(bank, bank_receive_function,[Pid,Funds])).

create_process_for_customers(Pid,LoanAmount,Banks)->
  register(Pid,spawn(customer, customer_function,[Pid,LoanAmount,Banks])).


master_process(0)->
io:fwrite("program finised");

master_process(N)->
  receive
    {lnreq,Pid,Amount,Bank}->
      io:fwrite("~w request a loan of ~w Dollar(s) from ~w ~n",[Pid,Amount,Bank]),
      master_process(N);
    {lnapp,Pid,Pd,Amountx}->
      io:fwrite("~w Approves a loan of ~w Dollar(s) from ~w ~n",[Pd,Amountx,Pid]),
      master_process(N);
    {lnuapp,Pid,Pd,Amountx}->
      io:fwrite("~w Denies a loan of ~w Dollar(s) from ~w ~n",[Pd,Amountx,Pid]),
      master_process(N);
    kill->
      io:fwrite("Inside Kill"),
      master_process(N-1)
  end.