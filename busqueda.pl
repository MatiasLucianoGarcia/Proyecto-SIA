:-[operadores].

:- dynamic frontera/2 , visitados/1.

%generar_vecinos(+EstadoActual,-Vecinos):
generar_vecinos(EstadoActual,Vecinos):-
    findall([EstadoSiguente,Operacion], realizar_operacion(EstadoActual,EstadoSiguente,Operacion), Vecinos).

%buscar_plan(+EInicial,-Plan,-Destino,-Costo):

%Para la heuristica verificar que no implique un orden en dejar la carga, buscarla, buscar el detonador y usarlo.
%Nodo=[Estado,Camino,Costo,Heuristica]    

agregar_vecinos([]):-!.

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


%Caso 1:Detonador = SI, CargaPendiente = NO => ir al sitio de detonacion  
calcularHeuristica([[X,Y],_,ListaItems,_,no],Valor):-
    member([c,_],ListaItems),
    member([d,_,_],ListaItems),
    calcular_mejor_sitioDetonacion([X,Y],ValorN),
    Valor is ValorN.

%Caso 2:Detonador = NO  - ColocacionCargaPendiente = NO
calcularHeuristica([[X,Y],_,ListaItems,_,no],Valor):-
    not(member([d,_,_], ListaItems)),
    estaEn([d,_,_],[Xd,Yd]),
    distanciaManhattam([X,Y],[Xd,Yd],DistDetonador),
    calcular_mejor_sitioDetonacion([Xd,Yd],CostoIrSitDet),
    Valor is DistDetonador + CostoIrSitDet.

%Caso 3: Detonador = Si, Carga = Si , ColocacionCargaPendiente = SI
calcularHeuristica([[X,Y],_,ListaItems,_,si],Valor):-
    member([d,_,_],ListaItems),
    member([c,_],ListaItems),
    ubicacionCarga([Xu,Yu]),
    distanciaManhattam([X,Y],[Xu,Yu],DistDejarCarga),
    calcular_mejor_sitioDetonacion([Xu,Yu],CostoIrSitDet),
    Valor is DistDejarCarga + CostoIrSitDet.
      
%Caso 4: Detonador = Si, Carga = No , ColocacionCargaPendiente = SI
calcularHeuristica([[X,Y],_,ListaItems,_,si],Valor):-
    member([d,_,_],ListaItems),
    not(member([c,_],ListaItems)),
    estaEn([c,_], [Xc,Yc]),
    %Busco la carga
    distanciaManhattam([X,Y],[Xc,Yc],DistCarga),
    ubicacionCarga([Xu,Yu]),
    %Dejo la carga
    distanciaManhattam([Xc,Yc],[Xu,Yu],DistDejarCarga),
    %Voy a sitio de detonacion mas cercano
    calcular_mejor_sitioDetonacion([Xu,Yu],CostoIrSitDet),
    Valor is DistCarga + DistDejarCarga + CostoIrSitDet.

% Detonador = NO - Carga = SI - ColocacionCargaPendiente = SI
calcularHeuristica([[X,Y],_,ListaItems,_,si],Valor):-
    not(member([d,_,_],ListaItems)),
    member([c,_],ListaItems),
    estaEn([d,_,_],[Xd,Yd]),
    ubicacionCarga([Xu,Yu]),
    distanciaManhattam([X,Y],[Xd,Yd],DistDetonador),
    %Calculo la distancia desde donde fui a buscar el detonador hasta donde debo dejar la carga
    distanciaManhattam([Xd,Yd],[Xu,Yu],DistDetoDejarCarga),
    DetoDejarCarga is DistDetonador + DistDetoDejarCarga,
    distanciaManhattam([X,Y],[Xu,Yu],DistDejarCarga),
    %Calculo la distancia desde donde fui a dejar la carga hasta donde debo ir a buscar el detonador
    distanciaManhattam([Xu,Yu],[Xd,Yd],DistDejarCargaDeto),
    DejarCargaDeto is DistDejarCarga + DistDejarCargaDeto
    

%Caso 6: Detonador = NO, Carga = No, ColocacionCargaPendiente = SI 
calcularHeuristica([[X,Y],_,ListaItems,_,si],Valor):-
        not(member([d,_,_],ListaItems)),
        not(member([c,_],ListaItems)),
        estaEn([c,_], [Xc,Yc]),
        estaEn([d,_,_],[Xd,Yd]),
        distanciaManhattam([X,Y],[Xc,Yc],DistCarga),
        distanciaManhattam([X,Y],[Xd,Yd],DistDetonador),
       %calcularHeuristica([[Xc,Yc],_,ListaItems,_,si],HeuristicaCarga),
        %calcularHeuristica([[Xd,Yd],_,ListaItems,_,si],HeuristicaDetonador),
        Valor is min(DistCarga+HeuristicaCarga,DistDetonador+HeuristicaDetonador).


%Calcula la distancia de manhattam desde la primer posicion a la segunda.
%alcularDistanciaManhattam(+PosInicial,+PosDestino,-Valor):
distanciaManhattam([X,Y],[Xs,Ys],Valor):-
    Valor is abs(X-Xs) + abs(Y-Ys).

calcular_mejor_sitioDetonacion([X,Y],Valor):-
    sitioDetonacion([Xs,Ys]),
    forall(sitioDetonacion([Xn,Yn]),esMenorDistancia([X,Y],[Xs,Ys],[Xn,Yn],Valor)).

esMenorDistancia([X,Y],[Xs,Ys],[Xn,Yn],ValorIS):-
    ValorIS is abs(X-Xs) + abs(Y-Ys),
    ValorIN is abs(X-Xn) + abs(Y-Yn),
    ValorIS =< ValorIN. 


