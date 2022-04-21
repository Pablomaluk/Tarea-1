% definiendo grafo dirigido
camino(L1, L2) :- camino(L2, L1), lugar(L1), lugar(L2).
camino(L, L) :- lugar(L).

% si una persona esta en un lugar, entonces no es una ubicacion imposible
-imposibleUbi(P, L, T) :- personaEnLugar(P, L, T), persona(P), lugar(L), tiempo(T).
-personaEnLugar(P, L, T) :- imposibleUbi(P, L, T), persona(P), lugar(L), tiempo(T).

% cada ubicacion tiene capacidad 1
imposibleUbi(P1, L, T) :- personaEnLugar(P2, L, T), lugar(L), persona(P1), persona(P2), P1!=P2, tiempo(T).

% cada persona puede estar maximo en una ubicacion simultaneamente
imposibleUbi(P, L, T) :- personaEnLugar(P, LR, T), lugar(L), lugar(LR), L!=LR, tiempo(T).

% ubicaciones imposibles todas las que no se pueda llegar a tiempo
imposibleUbi(P, L1, T) :- personaEnLugar(P, L2, T+1), not camino(L1, L2), persona(P), lugar(L1), lugar(L2), tiempo(T), tiempo(T+1).
imposibleUbi(P, L1, T) :- personaEnLugar(P, L2, T-1), not camino(L1, L2), persona(P), lugar(L1), lugar(L2), tiempo(T), tiempo(T-1).


% si alguien miente es culpable
culpable(P1) :- afirmacionLugar(P1, P2, L, T), persona(P1), persona(P2), lugar(L), tiempo(T), imposibleUbi(P2, L, T).

% todas las personas distintas al culpable son no culpables
-culpable(P1) :- culpable(P2), persona(P1), persona(P2), P1!=P2.

% si persona no es culpable, entonces todas sus afirmaciones son ciertas
personaEnLugar(P, L, T) :- afirmacionLugar(PI, P, L, T), -culpable(PI).

% si alguien es culpable estuvo en el lugar del crimen
1 {personaEnLugar(P, L, T) : tiempo(T), T<TD} :- culpable(P), descubrimiento(L, TD), lugar(L), tiempo(TD).

% cada persona en exactamente 1 lugar en cada momento
1 {personaEnLugar(P, L, T) : lugar(L)} 1 :- persona(P), tiempo(T).


% no pueden mentir 2 personas sobre una misma ubicacion
personaEnLugar(P, L, T) :- afirmacionLugar(P1, P, L, T), afirmacionLugar(P2, P, L, T), P1 != P2, persona(P1), persona(P2).

% inocente no puede decir q persona esta en 2 lugares distintos al mismo tiempo
culpable(P) :- afirmacionLugar(P, PA, L1, T), afirmacionLugar(P, PA, L2, T), L1!=L2.

% 2 inocentes no pueden contradecirse
% afirman misma persona en distinto lugar
1{culpable(P1;P2)}1 :- afirmacionLugar(P1, P3, L1, T), afirmacionLugar(P2, P3, L2, T), L1!=L2.
% afirman mismo lugar con distinta persona
1{culpable(P1;P2)}1 :- afirmacionLugar(P1, P3, L, T), afirmacionLugar(P2, P4, L, T), P3!=P4.


% inocente no puede decir q hay 2 personas en 1 lugar
culpable(P) :- afirmacionLugar(P, P1, L, T), afirmacionLugar(P, P2, L, T), P1!=P2.

% sospechoso si pasa 3 veces por escena del crimen
sospechoso(P) :- 3{personaEnLugar(P, L, T) : tiempo(T), T<TC}, persona(P), lugar(L), descubrimiento(L, TC).

% minimizar sospechosos
#minimize{1, P: sospechoso(P)}.


#show culpable/1.
#show sospechoso/1.
#show personaEnLugar/3.



