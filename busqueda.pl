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
calcularHeuristica([[X,Y],_,ListaItems,_,no],Valor):-
    member([c,_],ListaItems),
    member([d,_,_],ListaItems),
    calcular_mejor_sitioDetonacion([X,Y],ValorN),
    Valor is ValorN.

calcular_mejor_sitioDetonacion([X,Y],Valor):-
    sitioDetonacion([Xs,Ys]),
    forall(sitioDetonacion([Xn,Yn]),esMenorDistancia([X,Y],[Xs,Ys],[Xn,Yn],Valor)).

esMenorDistancia([X,Y],[Xs,Ys],[Xn,Yn],ValorIS):-
    ValorIS is abs(X-Xs) + abs(Y-Ys),
    ValorIN is abs(X-Xn) + abs(Y-Yn),
    ValorIS =< ValorIN. 

