%%
%%   Copyright (c) 2013 - 2015, Dmitry Kolesnikov
%%   Copyright (c) 2013 - 2015, Mario Cardona
%%   All Rights Reserved.
%%
%%   Licensed under the Apache License, Version 2.0 (the "License");
%%   you may not use this file except in compliance with the License.
%%   You may obtain a copy of the License at
%%
%%       http://www.apache.org/licenses/LICENSE-2.0
%%
%%   Unless required by applicable law or agreed to in writing, software
%%   distributed under the License is distributed on an "AS IS" BASIS,
%%   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%%   See the License for the specific language governing permissions and
%%   limitations under the License.
%%
%% @description
%%   queue tcp protocol
-module(kmq_tcp).
-behaviour(pipe).

-export([
   start_link/2,
   init/1,
   free/2,
   ioctl/2,
   handle/3
]).


%%
%%
start_link(Uri, Opts) ->
   pipe:start_link(?MODULE, [Uri, Opts], []).

init([Uri, Opts]) ->
   {ok, handle, knet:bind(Uri, Opts)}.

free(_, Sock) ->
   knet:close(Sock).

%%
ioctl(_, _) ->
   throw(not_implemented).

%%
%%
handle({tcp, _Pid, {established, _Peer}}, _Pipe, Sock) ->
   {next_state, handle, Sock};

handle({tcp, _Peer, Pckt}, _Pipe, Sock) ->
   [Queue, E] = binary:split(Pckt, <<$:>>),
   kmq:enq(Queue, E),
   {next_state, handle, Sock}.


