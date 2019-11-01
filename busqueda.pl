:-[operadores].

:- dynamic frontera/2 , visitados/1.

%generar_vecinos(+EstadoActual,-Vecinos):
generar_vecinos(EstadoActual,Vecinos):-
    findall([EstadoSiguente,Operacion], realizar_operacion(EstadoActual,EstadoSiguente,Operacion), Vecinos).

%buscar_plan(+EInicial,-Plan,-Destino,-Costo):

%Para la heuristica verificar que no implique un orden en dejar la carga, buscarla, buscar el detonador y usarlo.
%Nodo=[Estado,Camino,Costo,Heuristica]    

agregar_vecinos([X|ListaVecinos]):-
    not(visitados(X)),
    asserta(visitados(X)),
    calcularHeuristica(X,Valor),
    asserta(frontera(X,Valor)),
    agregar_vecinos(ListaVecinos). 

obtener_minimo_frontera(MinimoEstado):-
    frontera(A,V),
    forall(frontera(_,V2),V=<V2),
    MinimoEstado is A. 




%Caso 1: el minero posee la carga, posee el detonador, solo debe ir al sitio de detonacion. 
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

%Caso2 tengo el detonador pero no la carga, debo buscar una carga
%calcularHeuristica([[X,Y],_,ListaItems,_,si]):-
 %   member([d,_,_],ListaItems),
  %  not(member([c,_],ListaItems)).


%esMenorDistancia([X,Y],[Xs,Ys],Valor):-
 %   Valor is abs(X-Xs) + abs(Y-Ys).

