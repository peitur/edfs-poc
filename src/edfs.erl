-module( edfs ).

-export([]).


start(  ) ->
  start( false ).

start( true ) ->
  application:start( sasl ),
  application:start( ?MODULE );

start( false ) ->
  application:start( ?MODULE ).
