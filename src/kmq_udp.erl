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
-module(kmq_udp).
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
   {ok, handle, 
      #{sock => knet:bind(Uri, Opts)}
   }.

free(_, #{sock := Sock}) ->
   knet:close(Sock).

%%
ioctl(_, _) ->
   throw(not_implemented).

%%
%%
handle({udp, _Pid, passive}, Pipe, State) ->
   pipe:a(Pipe, active),
   {next_state, handle, State};

handle({udp, _, {_Peer, Pckt}}, _Pipe, State) ->
   [Queue, E] = binary:split(Pckt, <<$:>>),
   kmq:enq(Queue, E, infinity),
   {next_state, handle, State}.
