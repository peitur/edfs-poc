-module( edfsc_service ).
-behaviour(gen_server).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-include_lib("include/edfs.hrl").

%% ====================================================================
%% API functions
%% ====================================================================
-export([start_link/0, start_link/1, start_link/2, stop/0, stop/1 ]).

start_link() ->
  start_link( [] ).

start_link( Options ) ->
  start_link( ?DEFAULT_CONFIG_FILE, Options ).

start_link( Filename, Options ) ->
  gen_server:start_link( {local, ?MODULE}, ?MODULE, [Filename, Options], [] ).

stop( ) -> stop( normal ).
stop( Reason ) -> gen_server:call( ?MODULE, {stop, Reason}).

get_value( Key ) ->
  get_value( Key, undefined ).

get_value( Key, Default ) ->
  case gen_server:call( ?MODULE, {get, value, Key } ) of
    undefined -> Default;
    {ok, Value} -> {ok, Value }
  end.

%% ====================================================================
%% Behavioural functions
%% ====================================================================
-record(state, { configfile, values = [] }).

%% init/1
%% ====================================================================
%% @doc <a href="http://www.erlang.org/doc/man/gen_server.html#Module:init-1">gen_server:init/1</a>
-spec init(Args :: term()) -> Result when
	Result :: {ok, State}
			| {ok, State, Timeout}
			| {ok, State, hibernate}
			| {stop, Reason :: term()}
			| ignore,
	State :: term(),
	Timeout :: non_neg_integer() | infinity.
%% ====================================================================
init( [Filename, Options] ) ->
    {ok, #state{ configfile = Filename }, 0}.


%% handle_call/3
%% ====================================================================
%% @doc <a href="http://www.erlang.org/doc/man/gen_server.html#Module:handle_call-3">gen_server:handle_call/3</a>
-spec handle_call(Request :: term(), From :: {pid(), Tag :: term()}, State :: term()) -> Result when
	Result :: {reply, Reply, NewState}
			| {reply, Reply, NewState, Timeout}
			| {reply, Reply, NewState, hibernate}
			| {noreply, NewState}
			| {noreply, NewState, Timeout}
			| {noreply, NewState, hibernate}
			| {stop, Reason, Reply, NewState}
			| {stop, Reason, NewState},
	Reply :: term(),
	NewState :: term(),
	Timeout :: non_neg_integer() | infinity,
	Reason :: term().
%% ====================================================================
handle_call( {get, value, Key}, _From, #state{ values = ValueList} = State ) ->
  Val = proplists:get_value( Key, ValueList ),
  {reply, {ok, Val}, State };

handle_call( {stop, Reason}, _From, State ) ->
  {stop, Reason, ok, State};

handle_call(Request, From, State) ->
    Reply = ok,
    {reply, Reply, State}.


%% handle_cast/2
%% ====================================================================
%% @doc <a href="http://www.erlang.org/doc/man/gen_server.html#Module:handle_cast-2">gen_server:handle_cast/2</a>
-spec handle_cast(Request :: term(), State :: term()) -> Result when
	Result :: {noreply, NewState}
			| {noreply, NewState, Timeout}
			| {noreply, NewState, hibernate}
			| {stop, Reason :: term(), NewState},
	NewState :: term(),
	Timeout :: non_neg_integer() | infinity.
%% ====================================================================
handle_cast(Msg, State) ->
    {noreply, State}.


%% handle_info/2
%% ====================================================================
%% @doc <a href="http://www.erlang.org/doc/man/gen_server.html#Module:handle_info-2">gen_server:handle_info/2</a>
-spec handle_info(Info :: timeout | term(), State :: term()) -> Result when
	Result :: {noreply, NewState}
			| {noreply, NewState, Timeout}
			| {noreply, NewState, hibernate}
			| {stop, Reason :: term(), NewState},
	NewState :: term(),
	Timeout :: non_neg_integer() | infinity.
%% ====================================================================
handle_info( timeout, #state{ configfile = File} = State ) ->
  case x_read_configfile( File ) of
    {error, Reason} ->
      {stop, {error, Reason}, State};
    Data -> {noreply, State#state{ values = Data } }
  end;

handle_info(Info, State) ->
    {noreply, State}.


%% terminate/2
%% ====================================================================
%% @doc <a href="http://www.erlang.org/doc/man/gen_server.html#Module:terminate-2">gen_server:terminate/2</a>
-spec terminate(Reason, State :: term()) -> Any :: term() when
	Reason :: normal
			| shutdown
			| {shutdown, term()}
			| term().
%% ====================================================================
terminate(Reason, State) ->
    ok.


%% code_change/3
%% ====================================================================
%% @doc <a href="http://www.erlang.org/doc/man/gen_server.html#Module:code_change-3">gen_server:code_change/3</a>
-spec code_change(OldVsn, State :: term(), Extra :: term()) -> Result when
	Result :: {ok, NewState :: term()} | {error, Reason :: term()},
	OldVsn :: Vsn | {down, Vsn},
	Vsn :: term().
%% ====================================================================
code_change(OldVsn, State, Extra) ->
    {ok, State}.


%% ====================================================================
%% Internal functions
%% ====================================================================

x_read_configfile( Filename ) ->
  case filelib:is_file( Filename ) of
    true ->
      case file:consult( Filename ) of
        {ok, Data} -> Data;
        {error, Reason} ->
          error_logger:error_msg( "ERROR: Error loading ~p : ~p", [Filename, Reason] ),
          {error, Reason}
        end;
    Other ->
      error_logger:error_msg( "ERROR: Could not find file ~p", [Filename] ),
      {error, nosuchfile}
  end.
