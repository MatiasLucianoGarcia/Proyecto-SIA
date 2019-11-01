%:-consult(minaExample).
:-[minaExample].

realizar_operacion(EstadoInicial,EstadoFinal,caminar):- 
    caminar(EstadoInicial,EstadoFinal).    

realizar_operacion(EstadoInicial,EstadoFinal,rotarN):- 
    rotar(EstadoInicial,EstadoFinal,n).        

realizar_operacion(EstadoInicial,EstadoFinal,rotarS):- 
    rotar(EstadoInicial,EstadoFinal,s).

realizar_operacion(EstadoInicial,EstadoFinal,rotarE):- 
    rotar(EstadoInicial,EstadoFinal,e).

realizar_operacion(EstadoInicial,EstadoFinal,rotarO):- 
    rotar(EstadoInicial,EstadoFinal,o).

realizar_operacion(EstadoInicial,EstadoFinal,saltar):- 
    saltar(EstadoInicial,EstadoFinal).

realizar_operacion(EstadoInicial,EstadoFinal,juntar_llave):- 
    juntar_llave(EstadoInicial,EstadoFinal).

realizar_operacion(EstadoInicial,EstadoFinal,juntar_carga):- 
    juntar_carga(EstadoInicial,EstadoFinal).

realizar_operacion(EstadoInicial,EstadoFinal,juntar_detonador):- 
    juntar_detonador(EstadoInicial,EstadoFinal).

realizar_operacion(EstadoInicial,EstadoFinal,dejar_carga):- 
    dejar_carga(EstadoInicial,EstadoFinal).

realizar_operacion(EstadoInicial,EstadoFinal,detonar):- 
    detonar(EstadoInicial,EstadoFinal).

%caminar(+EstadoIncial,-EstadoFinal):
caminar([[X,Y],PuntoCardinal,ListaItems,Costo,ColocacionCargaPendiente],[[Xn,Yn],PuntoCardinal,ListaItems,CostoFinal,ColocacionCargaPendiente]):-
    mover_direccion_correspondiente([X,Y],[Xn,Yn],PuntoCardinal),
    ((not(hay_obstaculos([Xn,Yn]))); (estaEn([r,IdReja],[Xn,Yn]),tengo_llave(ListaItems,IdReja))),
    celda([Xn,Yn],Suelo),
    costoCaminar(Suelo,CostoN),
    CostoFinal is Costo + CostoN.

%rotar(+EstadoInicial,-EstadoFinal,+Direccion):
rotar([[X,Y],PuntoCardinal,ListaItems,Costo,ColocacionCargaPendiente],[[X,Y],Direccion,ListaItems,CostoFinal,ColocacionCargaPendiente],Direccion):-
    costoRotar(PuntoCardinal,Direccion,CostoNuevo),
    PuntoCardinal \= Direccion,
    CostoFinal is Costo + CostoNuevo.

%saltar(+Estado,-EstadoFinal):
saltar([[X,Y],PuntoCardinal,ListaItems,Costo,ColocacionCargaPendiente],[[Xn,Yn],PuntoCardinal,ListaItems,CostoFinal,ColocacionCargaPendiente]):-
    trace,
    mover_direccion_correspondiente([X,Y],[Xs,Ys],PuntoCardinal),
    estaEn([v,_,Altura],[Xs,Ys]),
    Altura<4,
    mover_direccion_correspondiente([Xs,Ys],[Xn,Yn],PuntoCardinal),
    not(estaEn([p,_,_],[Xn,Yn]);estaEn([v,_,_],[Xn,Yn]);estaEn([r,_],[Xn,Yn])),
    celda([Xn,Yn],Suelo),
    costoCaminar(Suelo,CostoNuevo),
    CostoFinal is CostoNuevo + Costo + 1. 

%juntar_llave(+EstadoInicial,-EstadoFinal):
juntar_llave([[X,Y],PuntoCardinal,ListaItems,Costo,ColocacionCargaPendiente],[[X,Y],PuntoCardinal,[[l,IdLlave]|ListaItems],CostoFinal,ColocacionCargaPendiente]):-
    estaEn([l,IdLlave],[X,Y]),
    not(member([l,IdLlave], ListaItems)),
    CostoFinal is Costo + 1.

%juntar_carga(+EstadoInicial,-EstadoFinal):
juntar_carga([[X,Y],PuntoCardinal,ListaItems,Costo,si],[[X,Y],PuntoCardinal,[[c,IdCarga]|ListaItems],CostoFinal,si]):-
    estaEn([c,IdCarga],[X,Y]),
    not(member([c,IdCarga], ListaItems)),
    CostoFinal is Costo +3. 

%juntar_detonador(+EstadoInicial,EstadoFinal):
juntar_detonador([[X,Y],PuntoCardinal,ListaItems,Costo,ColocacionCargaPendiente],[[X,Y],PuntoCardinal,[[d,IdDeto,no]|ListaItems],CostoFinal,ColocacionCargaPendiente]):-
    estaEn([d,IdDeto,no],[X,Y]),
    not(member([d,IdDeto,no],ListaItems)),
    CostoFinal is Costo + 2.

%dejar_carga(+EstadoInicial,-EstadoFinal):
dejar_carga([[X,Y],PuntoCardinal,ListaItems,Costo,si],[[X,Y],PuntoCardinal,ListaItemsN,CostoFinal,no]):-
    member([c,IdCarga],ListaItems),
    delete(ListaItems, [c,IdCarga], ListaItemsN),
    ubicacionCarga([X,Y]),
    CostoFinal is Costo + 1.

%detonar(+EstadoInicial,-EstadoFinal):
detonar([[X,Y],PuntoCardinal,ListaItems,Costo,no],[[X,Y],PuntoCardinal,ListaItemsFinal,CostoFinal,no]):-
    sitioDetonacion([X,Y]),
    member([d,IdDeto,no],ListaItems),
    delete(ListaItems, [d,IdDeto,no], ListaItemsN),
    append(ListaItemsN,[d,IdDeto,si],ListaItemsFinal),
    CostoFinal is Costo + 1.
        

%mover_direccion_correspondiente(+PosInicial,-PosFinal,+PuntoCardinal):
mover_direccion_correspondiente([X,Y],[Xn,Yn],n):-
    Xn is X-1, Yn is Y.

mover_direccion_correspondiente([X,Y],[Xn,Yn],s):-
    Xn is X+1, Yn is Y.

mover_direccion_correspondiente([X,Y],[Xn,Yn],e):-
    Xn is X, Yn is Y+1.

mover_direccion_correspondiente([X,Y],[Xn,Yn],o):-
    Xn is X, Yn is Y-1.

%hay_obstaculos(+Pos):
hay_obstaculos(Pos):- 
    (estaEn([v,_,_],Pos); estaEn([p,_,_],Pos)).    

%tengo_llave(+ListaItems,+IdReja):
tengo_llave(ListaItems,IdReja):-
    member([l,IdLlave], ListaItems),
    abreReja([l,IdLlave],[r,IdReja]).

%costoCaminar(+Suelo,-Costo):
costoCaminar(firme,2).
costoCaminar(resbaladizo,3).

%costoRotar(Origen,Destino,Costo):
costoRotar(n,s,2).
costoRotar(s,n,2).
costoRotar(e,o,2).
costoRotar(o,e,2).
costoRotar(n,e,1).
costoRotar(n,o,1).
costoRotar(s,e,1).
costoRotar(s,o,1).
costoRotar(e,n,1).
costoRotar(e,s,1).
costoRotar(o,n,1).
costoRotar(o,s,1).