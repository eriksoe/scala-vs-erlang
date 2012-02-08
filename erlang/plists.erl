-module(plists).

-export([foreach/2]).


% Algorithm - Split into 4 lists, have each list and the fun run in a separate spawned process
foreach(Fun,List) -> 
        Pids = split_and_execute(8, List, Fun, self()),
	waitCompletion(Pids).

split_and_execute(Pieces,List,Fun,EndPid) ->
    PieceSize = round(length(List) / Pieces),
    split_and_execute(Pieces, PieceSize, List, Fun, EndPid).
    
split_and_execute(1,_PieceSize,List,Fun,EndPid) ->
    [execute(List, Fun, EndPid)];
split_and_execute(Pieces,PieceSize,List,Fun,EndPid) -> 
	{List1,Remainder} = lists:split(PieceSize,List),
	[execute(List1, Fun, EndPid)
	 | split_and_execute(Pieces-1,PieceSize,Remainder,Fun,EndPid)].

execute(List,Fun,EndPid) -> 
    spawn( fun()->runFun(Fun,List,EndPid) end ).

runFun(Fun,List,EndPid) -> lists:foreach(Fun,List),
	EndPid ! finished.

waitCompletion(Pids) -> 
	lists:foreach(fun (_X) -> 
			receive finished -> ok 
			end
		end, Pids).
