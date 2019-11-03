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
buscar_plan(EInicial,Plan,Destino,Costo):-
    NodoInicial=[EInicial,[],0,0],
    frontera(NodoInicial),
    aEstrella(NodoM),
    NodoM = [EstadoM,CaminoM,Costo,_],
    EstadoM=[Destino,_,_,_,_],
    reverse(CaminoM,Plan).

buscar_plan(_,_,_,_,_):-
	writeln('No se encontro plan.'),
	fail.

agregar_vecinos([]):-!.

agregar_vecinos([X|ListaVecinos]):-
    visitados(X),
    agregar_vecinos(ListaVecinos).
    
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
aEstrella(Nodo):-
    obtener_minimo_frontera(Nodo),
    esMeta(Nodo).

aEstrella(Nodo):-
    obtener_minimo_frontera(NodoMinimo),
    not(esMeta(NodoMinimo)),
    generar_vecinos(NodoMinimo,Vecinos),
    retract(frontera(NodoMinimo)),
    agregar_vecinos(Vecinos),
    aEstrella(Nodo).     

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
%Caso A: Busco primero el Detonador, luego la carga y realizo la detonacion.
%Caso B: Busco primero la carga
calcularHeuristica([[X,Y],_,ListaItems,_,si],Valor):-
    not(member([d,_,_],ListaItems)),
    not(member([c,_],ListaItems)),
    estaEn([c,_], [Xc,Yc]),
    estaEn([d,_,_],[Xd,Yd]),
    ubicacionCarga([Xu,Yu]),
    %Caso A      
    %Busco el detonador primero 
    distanciaManhattam([X,Y],[Xd,Yd],DistDetonador),
    %Solo puedo ir a buscar la carga
    distanciaManhattam([Xd,Yd],[Xc,Yc],DistDetoCarga),
    %Solo puedo ir a dejar la carga en su unicacion
    distanciaManhattam([Xc,Yc],[Xu,Yu],DistDetoCargaUbi),
    %Detono en el sitio mas cercano 
    calcular_mejor_sitioDetonacion([Xu,Yu],DistDetoCargaDetonar),
    CasoA is DistDetonador + DistDetoCarga + DistDetoCargaDetonar + DistDetoCargaUbi,
    %Caso B
    %Busco la carga primero
    distanciaManhattam([X,Y],[Xc,Yc],DistCarga),
    %Tengo dos opciones dejar la carga o buscar detonador
    %Caso B-1 en este caso dejo la carga primero
    distanciaManhattam([Xc,Yc],[Xu,Yu],DistCargaDejarCarga),
    distanciaManhattam([Xu,Yu],[Xd,Yd],DistCargaDejarCargaDeto),
    calcular_mejor_sitioDetonacion([Xd,Yd],DistCargaDejarCargaDetoDetonar),
    B1 is DistCargaDejarCargaDetoDetonar + DistCargaDejarCargaDeto + DistCargaDejarCarga,
    %Caso B-2 en este caso busco el detonador primero
    distanciaManhattam([Xc,Yc],[Xd,Yd],DistCargaDeto),
    distanciaManhattam([Xd,Yd],[Xu,Yu],DistCargaDetoDejarCarga),
    calcular_mejor_sitioDetonacion([Xu,Yu],DistCargaDetoDejarCargaDetonar),
    B2 is DistCargaDetoDejarCargaDetonar +DistCargaDetoDejarCarga + DistCargaDeto,
    CasoB is min(B1,B2) + DistCarga,
    Valor is min(CasoA,CasoB).  


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



