:-[operadores].

generar_vecinos(EstadoActual,Vecinos):-
    findall([EstadoSiguente,Operacion], realizar_operacion(EstadoActual,EstadoSiguente,Operacion), Vecinos).

%buscar_plan(+EInicial,-Plan,-Destino,-Costo):

%Para la heuristica verificar que no implique un orden en dejar la carga, buscarla, buscar el detonador y usarlo.
%Nodo=[Estado,Camino,Costo,Heuristica]    
%calcularHeuristica(Estado):-!.


generar_vecinos([[X,Y],PuntoCardinal,ListaItems,Costo,ColocacionCargaPendiente],Vecinos):-
    findall([EstadoSiguente,Operacion], realizar_operacion(EstadoActual,EstadoSiguente,Operacion), Vecinos).