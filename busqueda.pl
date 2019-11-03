:-[operadores].

:- dynamic frontera/1.
:- dynamic visitados/1.

%generar_vecinos(+EstadoActual,-Vecinos):
generar_vecinos(Nodo,Vecinos):-
    Nodo=[Estado,Camino,Costo,_],
    Estado=[_,_,_,CostoEstado,_],
    Costo is CostoEstado,
    findall([EstadoSiguente,[Operacion|Camino],CostoEstadoNuevo], realizar_operacion(EstadoActual,EstadoSiguente,Operacion), Vecinos),
    EstadoActual=[_,_,_,CostoEstadoNuevo,_,_].


%buscar_plan(+EInicial,-Plan,-Destino,-Costo):

agregar_vecinos([]):-!.

agregar_vecinos([X|ListaVecinos]):-
    not(visitados(X)),
    asserta(visitados(X)),
    X=[Estado,Camino,Costo],
    calcularHeuristica(Estado,CostoH),
    CostoT is CostoH+Costo,
    N=[Estado,Camino,Costo,CostoT],
    asserta(frontera(N)),
    agregar_vecinos(ListaVecinos). 

obtener_minimo_frontera(MinimoNodo):-
    N1 = [_,_,_,Costo1],
    N2 = [_,_,_,Costo2],
    frontera(N1),
    forall(frontera(N2),Costo1=<Costo2),
    MinimoNodo is N1. 

%Caso Base aEstrella:  Saco el minimo nodo y si es meta lo agrego al camino y  
%aEstrella(Costo):-
 %   obtener_minimo_frontera(Estado),
  %  esMeta(Estado),!.

%aEstrella(Costo):-
 %   obtener_minimo_frontera(Estado),
  %  generar_vecinos(Estado,Vecinos),
   % agregar_vecinos(Vecinos),
    %aEstrella(Costo).     

%Define si el estado es un estado meta
esMeta(Nodo):-
    Nodo=[Estado,_,_,_],
    Estado=[[X,Y],_,ListaItems,_,no],
    member([d,_,si],ListaItems),
    sitioDetonacion([X,Y]).


%Caso 1:Detonador = SI, CargaPendiente = NO => ir al sitio de detonacion  
calcularHeuristica([[X,Y],_,ListaItems,_,no],Valor):-
    member([d,_,_],ListaItems),
    calcular_mejor_sitioDetonacion([X,Y],ValorN),
    Valor is ValorN.

%Caso 2:Detonador = NO  - ColocacionCargaPendiente = NO => tengo que buscar el detonador e ir al sitio de detonacion
calcularHeuristica([[X,Y],_,ListaItems,_,no],Valor):-
    not(member([d,_,_], ListaItems)),
    estaEn([d,_,_],[Xd,Yd]),
    distanciaManhattam([X,Y],[Xd,Yd],DistDetonador),
    calcular_mejor_sitioDetonacion([Xd,Yd],CostoIrSitDet),
    Valor is DistDetonador + CostoIrSitDet.

%Caso 3: Detonador = Si, Carga = Si , ColocacionCargaPendiente = SI => tengo que dejar la Carga en su ubicacion e ir al sitio de detonacion
calcularHeuristica([[X,Y],_,ListaItems,_,si],Valor):-
    member([d,_,_],ListaItems),
    member([c,_],ListaItems),
    ubicacionCarga([Xu,Yu]),
    distanciaManhattam([X,Y],[Xu,Yu],DistDejarCarga),
    calcular_mejor_sitioDetonacion([Xu,Yu],CostoIrSitDet),
    Valor is DistDejarCarga + CostoIrSitDet.
      
%Caso 4: Detonador = Si, Carga = No , ColocacionCargaPendiente = SI => tengo que buscar la carga, dejarla en su ubicacion e ir al sitio de detonacion.
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

% Caso 5: Detonador = NO - Carga = SI - ColocacionCargaPendiente = SI
calcularHeuristica([[X,Y],_,ListaItems,_,si],Valor):-
    not(member([d,_,_],ListaItems)),
    member([c,_],ListaItems),
    estaEn([d,_,_],[Xd,Yd]),
    ubicacionCarga([Xu,Yu]),
    %Calculo la distancia desde donde fui a buscar el detonador hasta donde debo dejar la carga
    distanciaManhattam([X,Y],[Xd,Yd],DistDetonador),
    distanciaManhattam([Xd,Yd],[Xu,Yu],DistDetoDejarCarga),
    calcular_mejor_sitioDetonacion([Xu,Yu],DetonoA),
    DetoDejarCarga is DistDetonador + DistDetoDejarCarga + DetonoA,
    %Calculo la distancia desde donde fui a dejar la carga hasta donde debo ir a buscar el detonador
    distanciaManhattam([X,Y],[Xu,Yu],DistDejarCarga),
    distanciaManhattam([Xu,Yu],[Xd,Yd],DistDejarCargaDeto),
    calcular_mejor_sitioDetonacion([Xd,Yd],DetonoB),
    DejarCargaDeto is DistDejarCarga + DistDejarCargaDeto + DetonoB,
    %El menor de los dos recorridos es el correcto
    Valor is min(DetoDejarCarga,DejarCargaDeto).
    

%Caso 6: Detonador = NO, Carga = No, ColocacionCargaPendiente = SI 
%Caso A: Busco  
%calcularHeuristica([[X,Y],_,ListaItems,_,si],Valor):-
    %not(member([d,_,_],ListaItems)),
    %not(member([c,_],ListaItems)),
    %estaEn([c,_], [Xc,Yc]),
    %estaEn([d,_,_],[Xd,Yd]),       
    %distanciaManhattam([X,Y],[Xd,Yd],DistDetonador),
    %distanciaManhattam([Xd,Yd],[Xc,Yc],DistDetoCarga),
    %calcular_mejor_sitioDetonacion([Xc,Yc],DistDetoCargaDetonar),
    %CasoA is DistDetonador + DistDetoCarga + DistDetoCargaDetonar

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



