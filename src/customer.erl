%%%-------------------------------------------------------------------
%%% @author admin
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 17. Jun 2019 11:49 PM
%%%-------------------------------------------------------------------
-module(customer).
-author("admin").

-import(lists,[nth/2]).
%% API
-export([customer_function/3]).
-import(bank,[bank_receive_function/2]).


customer_function(Pid,0,Banks)->
  whereis(masterprocess)!kill;

customer_function(Pid,LoanAmount,[])->
  whereis(masterprocess)!kill;

customer_function(Pid,LoanAmount,Banks)->

  Amount=rand:uniform(50),
  Result=LoanAmount-Amount,
  timer:sleep(round(timer:seconds(0.01*(rand:uniform())))),
  if
    Result<0 ->
      customer_function(Pid,LoanAmount,Banks);
    true ->
      Bank=nth(rand:uniform(length(Banks)),Banks),
      whereis(Bank)!{request,Amount,Pid},
      whereis(masterprocess)!{lnreq,Pid,Amount,Bank},
      receive
        {req,Pd,Amountx}->
          whereis(masterprocess)!{lnapp,Pid,Pd,Amountx},
          customer_function(Pid,LoanAmount-Amount,Banks);

        {response,Pd,Amountx}->
          whereis(masterprocess)!{lnuapp,Pid,Pd,Amountx},
          customer_function(Pid,LoanAmount,lists:delete(Pd,Banks))
      end
  end.

