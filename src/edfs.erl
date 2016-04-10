-module( edfs ).

-export([start/0, start/1]).


start(  ) ->
  start( true ).

start( true ) ->
  application:start( sasl ),
  application:start( edfspoc );

start( false ) ->
  application:start( edfspoc ).
