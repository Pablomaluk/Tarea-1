time(1..bound).


rangeZ(0..1).

action(up).
action(down).
action(left).
action(right).
action(wait).
action(pick).

% Para cada instante de tiempo T, cada robot R puede ejecutar una única acción de las posibles:
1 {exec(R,A,T) : action(A)} 1 :- robot(R), time(T+1).

% Cada accion tiene consecuencias sobre la posicion del robot
robotOn(R,X,Y+1,T+1) :- exec(R,up,T),   robotOn(R,X,Y,T), time(T+1).
robotOn(R,X,Y-1,T+1) :- exec(R,down,T), robotOn(R,X,Y,T), time(T+1).
robotOn(R,X-1,Y,T+1) :- exec(R,left,T), robotOn(R,X,Y,T), time(T+1).
robotOn(R,X+1,Y,T+1) :- exec(R,right,T),robotOn(R,X,Y,T), time(T+1).
robotOn(R,X,Y,T+1)   :- exec(R,wait,T), robotOn(R,X,Y,T), time(T+1).
robotOn(R,X,Y,T+1)   :- exec(R,pick,T), robotOn(R,X,Y,T), time(T+1).


% Se descartan los modelos en los que un robot haya ejecutado una acción que lo sacaría del mapa:
:- robotOn(R,X,Y,T), not rangeX(X).
:- robotOn(R,X,Y,T), not rangeY(Y).

% Se descartan los modelos en los que un robot haya ejecutado una acción que lo haga chocar:
:- robotOn(R,X,Y,T), obstacle(X,Y).

% Se descartan los modelos donde, luego de ejecutar una acción, dos robots queden en el mismo lugar:
:- robotOn(R1,X,Y,T), robotOn(R2,X,Y,T), R1 != R2.

% Se descartan los modelos donde, luego de ejecutar una acción, dos robots se cruzan.
:- exec(R1,right,T), exec(R2,left,T), robotOn(R1,X,Y,T), robotOn(R2,X+1,Y,T), rangeX(X), rangeX(X+1), robot(R1), robot(R2).
:- exec(R1,up,T), exec(R2,down,T), robotOn(R1,X,Y,T), robotOn(R2,X,Y+1,T), rangeY(Y), rangeY(Y+1), robot(R1), robot(R2).

% Cada caja debe estar en exactamente 1 lugar
1{boxOn(B,X,Y,Z,T) : rangeX(X), rangeY(Y), rangeZ(Z)}1 :- box(B), time(T).
% Cada lugar puede tener maximo 1 caja
:- boxOn(B1,X,Y,Z1,T), boxOn(B2,X,Y,Z2,T), box(B1), box(B2), B1!=B2, rangeZ(Z1), rangeZ(Z2), time(T).


% posiciones son adyacentes si hay diferencia de 1 en 1 coordenada
adyacent(X1,Y1,X2,Y2) :- X1 = X2+1, Y1=Y2, rangeX(X1), rangeX(X2), rangeY(Y1), rangeY(Y2).
adyacent(X1,Y1,X2,Y2) :- X1 = X2, Y1=Y2+1, rangeX(X1), rangeX(X2), rangeY(Y1), rangeY(Y2).
adyacent(X1,Y1,X2,Y2) :- adyacent(X2,Y2,X1,Y1).

% Se guarda como que robot y caja estan adyacentes si estan en posiciones adyacentes
boxAdyacent(R,B,T) :- robotOn(R,XR,YR,T), boxOn(B,XB,YB,0,T), adyacent(XR,YR,XB,YB), robot(R), box(B), time(T+1).

% Robot esta moviendo caja en T+1 si la recoge en T
move(R,B,T+1) :- exec(R,pick,T), boxAdyacent(R,B,T), time(T+1).

% Robot sigue moviendo caja en T+1 si la estaba moviendo en T
move(R,B,T+1) :- move(R,B,T), robot(R), box(B), time(T+1).

% Robot no puede mover 2 cajas simultaneamente
:- move(R,B1,T), move(R,B2,T), robot(R), box(B1), box(B2), B1 != B2.

% 2 robot no pueden mover 1 caja simultaneamente

:- move(R1,B,T), move(R2,B,T), robot(R1), robot(R2), box(B), R1 != R2.

% Caja se mantiene en posicion de robot que la mueve
boxOn(B,X,Y,1,T) :- move(R,B,T), robotOn(R,X,Y,T), robot(R), box(B), time(T).

% Caja se mantiene en posicion si ningun robot la mueve
boxOn(B,X,Y,0,T+1) :- boxOn(B,X,Y,0,T), 0{move(R,B,T+1) : robot(R)}0, box(B), time(T+1).

% Robot no puede mover caja sin antes recogerla
:- move(R,B,T+1), not exec(R,pick,T), not move(R,B,T).

% Caja no puede estar en posicion de robot si este no la esta moviendo
:- boxOn(B,X,Y,Z,T), robotOn(R,X,Y,T), not move(R,B,T), time(T), box(B), robot(R), rangeZ(Z).



% IMPLEMENTACION DE ROBOTS PROCRASTINADORES

% Definicion de caja en la meta
boxGoal(B,T) :- boxOn(B,X,Y,Z,T), goal(X,Y), box(B).

% Descartar modelos donde cajas no terminan en la meta
:- not boxGoal(B, bound), box(B).

% Maximizar tiempo donde las cajas estan en la meta: maximiza tiempos donde las cajas y robots estan en la meta, ya que ambos estan pegados.
#maximize{2, B,T: boxGoal(B,T)}.

#show rangeX/1.
#show rangeY/1.
#show robotOn/4.
#show boxOn/5.
#show obstacle/2.
#show goal/2.
#show boxAdyacent/3.
#show exec/3.
#show move/3.


