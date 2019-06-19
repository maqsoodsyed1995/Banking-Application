%%%-------------------------------------------------------------------
%%% @author admin
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 17. Jun 2019 11:49 PM
%%%-------------------------------------------------------------------
-module(bank).
-author("admin").

%% API
-export([bank_receive_function/2]).
-import(customer,[customer_function/3]).
bank_receive_function(Pid,Funds)->
  receive
    {request,Amount,Pd}->
      Temp=Funds-Amount,
      if Temp>0->
        whereis(Pd)!{req,Pid,Amount},
        bank_receive_function(Pid,Funds-Amount);
        true ->
          whereis(Pd)!{response,Pid,Amount},
         bank_receive_function(Pid,Funds)
      end
  end.




