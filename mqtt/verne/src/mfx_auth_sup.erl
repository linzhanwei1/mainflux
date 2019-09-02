-module(mfx_auth_sup).

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

%% Helper macro for declaring children of supervisor
-define(CHILD(I, Type), {I, {I, start_link, []}, permanent, 5000, Type, [I]}).

%% ===================================================================
%% API functions
%% ===================================================================

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

%% ===================================================================
%% Supervisor callbacks
%% ===================================================================

init([]) ->
    SizeArgs = [{size, 10}, {max_overflow, 10}],
    PoolArgs = [{name, {local, grpc_pool}}, {worker_module, mfx_grpc}],
    WorkerArgs = [],
    PoolSpec = poolboy:child_spec(grpc_pool, PoolArgs ++ SizeArgs, WorkerArgs),

    error_logger:info_msg("PoolSpec: ~p", [PoolSpec]),

    {ok, { {one_for_one, 5, 10}, [
        {mfx_nats, {mfx_nats, start_link, []}, permanent, 2000, worker, [mfx_nats]},
        {mfx_redis, {mfx_redis, start_link, []}, permanent, 2000, worker, [mfx_redis]},
        PoolSpec
    ]} }.
