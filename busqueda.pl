:-[operadores].

:- dynamic frontera/2 , visitados/1.

%generar_vecinos(+EstadoActual,-Vecinos):
generar_vecinos(EstadoActual,Vecinos):-
    findall([EstadoSiguente,Operacion], realizar_operacion(EstadoActual,EstadoSiguente,Operacion), Vecinos).

%buscar_plan(+EInicial,-Plan,-Destino,-Costo):

%Para la heuristica verificar que no implique un orden en dejar la carga, buscarla, buscar el detonador y usarlo.
%Nodo=[Estado,Camino,Costo,Heuristica]    
%calcularHeuristica(Estado):-!.

agregar_vecinos([X|ListaVecinos]):-
    calcularHeuristica(X,Valor),
    asserta(frontera(X,Valor)),
    asserta(visitados(X)),
    agregar_vecinos(ListaVecinos).


%Calcular para ir a la zona de detonacion 
calcularHeuristica([[X,Y],PuntoCardinal,ListaItems,Costo,no],Valor):-
    member([c,IdCarga],ListaItems),
    member([d,IdDetonador,_],ListaIatems),
    calcular_mejor_sitioDetonacion([X,Y],[Xf,Yf],ValorN).

calcular_mejor_sitioDetonacion([X,Y],[Xf,Yf],Valor):-
    forall(sitioDetonacion([Xf,Yf]),,)

