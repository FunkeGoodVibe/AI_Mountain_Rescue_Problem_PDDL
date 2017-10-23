(define (domain mountain-rescue)
(:requirements :typing :durative-actions :numeric-fluents)
(:types
person location vehicle - object
personToBeRescued rescuer paramedic - person
ambulance cableCar helicopter - vehicle
)
(:predicates   
(hasPetrolStation ?l - location)
(personAt ?p - person ?l - location)
(vehicleAt ?v - vehicle ?l - location)
(injured ?p - personToBeRescued)
(notInjured ?p - personToBeRescued)
(conscious ?p - personToBeRescued)
(notConscious ?p - personToBeRescued)
(onVehicle ?p - person ?v - vehicle)
(alive ?p - personToBeRescued)
(withR ?p - personToBeRescued ?r - rescuer)
(validForAmb ?l - location)
(validForHelicopter ?l - location)
(validForCC ?l - location)
(checked ?p - personToBeRescued)
)
(:functions
(passengers ?v - vehicle) - number
(capacity ?v - vehicle) - number
(distance ?from - location ?to - location) - number
(withRescuer ?res - rescuer) - number
(maxWithRescuer ?res - rescuer) - number
(fuelLeft ?v - vehicle) - number
(fuelMax ?v - vehicle) - number
(timeForVehicle ?v - vehicle ?from - location ?to - location) - number
(timeForRescuer ?r - rescuer ?from - location ?to - location) - number
)

 
(:durative-action disembarkFromVehicle
:parameters (?p - personToBeRescued ?v  - vehicle ?l - location )
:duration (= ?duration 5)
:condition (and (at start (vehicleAt ?v ?l))
				(at start (onVehicle ?p ?v)) )
:effect    (and (at start (decrease (passengers ?v) 1))
			  (at start (not (onVehicle ?p ?v)))
			  (at end (personAt ?p ?l) )
		  )
)
 
(:durative-action disembarkFromRescuer
:parameters (?p - personToBeRescued ?r - rescuer ?l - location)
:duration (= ?duration 4)
:condition (and  (at start (personAt ?r ?l))
				(at start (withR ?p ?r)))
:effect    (and  (at start (decrease (withRescuer ?r) 1))
				(at start (not (withR ?p ?r)))
				(at end (personAt ?p ?l)))
)

(:durative-action boardHelicopter
:parameters (?p - personToBeRescued ?h - helicopter ?l - location)
:duration (= ?duration 5)
:condition (and (at start (notConscious ?p))
				(at start (personAt ?p ?l))
				(at start (vehicleAt ?h ?l))
				(at start (< (passengers ?h) (capacity ?h))) )
:effect    (and (at start (increase (passengers ?h) 1))
				(at end (onVehicle ?p ?h))
				(at start (not (personAt ?p ?l))))
)

(:durative-action boardAmbulance
:parameters (?p - personToBeRescued ?a - ambulance ?l - location)
:duration (= ?duration 5)
:condition (and  (at start (checked ?p))
				(at start (personAt ?p ?l))
				(at start (vehicleAt ?a ?l))
				(at start ( < (passengers ?a) (capacity ?a))) )
:effect    (and  (at start (increase (passengers ?a) 1))
				(at end (onVehicle ?p ?a))
				(at start (not (personAt ?p ?l))))
)

(:durative-action checkPerson
:parameters (?p - personToBeRescued ?d - paramedic ?l - location)
:duration ( = ?duration 10)
:condition 	(and (at start (personAt ?p ?l))
		(at start (personAt ?d ?l)) )
:effect 	(at end (checked ?p))
)

(:durative-action boardCableCar
:parameters (?p - personToBeRescued ?cc - cableCar ?l - location)
:duration (= ?duration 2)
:condition (and (at start (conscious ?p))
				(at start (alive ?p))
				(at start (personAt ?p ?l))
				(at start (vehicleAt ?cc ?l))
				(at start (< (passengers ?cc) (capacity ?cc)))
				(at start (notInjured ?p)) )
:effect 	(and (at start (increase (passengers ?cc) 1))
				(at end (onVehicle ?p ?cc))
				(at start (not (personAt ?p ?l)) ))
)

(:durative-action secureUninjuredToRescuer
:parameters (?p - personToBeRescued ?r - rescuer ?l -location)
:duration (= ?duration 3)
:condition (and  (at start (notInjured ?p))
				(at start (personAt ?p ?l))
				(at start (personAt ?r ?l))
				(at start (< (withRescuer ?r) (maxWithRescuer ?r) )) )
:effect  (and  (at end  (withR ?p ?r))
			 (at start (not (personAt ?p ?l))) )
)

(:durative-action secureInjuredToRescuer
:parameters (?p - personToBeRescued ?r - rescuer ?l - location)
:duration (= ?duration 5)
:condition (and (at start (injured ?p))
				(at start (personAt ?p ?l))
				(at start (personAt ?r ?l))
				(at start (< (withRescuer ?r) (maxWithRescuer ?r) )) )
:effect 	(and (at end (withR ?p?r))
				(at start (not (personAt ?p ?l))) )
)

(:durative-action moveHelicopter
:parameters (?h - helicopter ?from - location ?to - location)
:duration (= ?duration (timeForVehicle ?h ?from ?to))
:condition (and (at start (vehicleAt ?h ?from))
				(at start (validForHelicopter ?to))
				(at start (>= (fuelLeft ?h) (distance?from ?to) )) )
:effect   (and (at end (vehicleAt ?h ?to))
				(at start (not (vehicleAt ?h ?from)))
				(at start (decrease (fuelLeft ?h) (distance?from ?to))) )
)

(:durative-action moveRescuer
:parameters (?r - rescuer ?from - location ?to - location)
:duration (= ?duration (timeForRescuer ?r ?from ?to) )
:condition (and  (at start (personAt ?r ?from)) )
:effect    (and (at end (personAt ?r ?to))
				(at start (not (personAt ?r ?from))) )
)

(:durative-action moveCableCar
:parameters (?cc - cableCar ?from - location ?to - location)
:duration (= ?duration (timeForVehicle ?cc ?from ?to))
:condition (and  (at start (vehicleAt ?cc ?from))
				(at start (validForCC ?to)) )
:effect   (and   (at end (vehicleAt ?cc ?to))
				(at start (not (vehicleAt ?cc ?from))) )
)

(:durative-action moveAmbulance
:parameters (?a - ambulance ?from - location ?to - location)
:duration (= ?duration (timeForVehicle ?a ?from ?to))
:condition (and  (at start (vehicleAt ?a ?from))
		(at start (validForAmb ?to))
		(at start (>= (fuelLeft ?a) (distance?from ?to) )) )
:effect (and 	(at end (vehicleAt ?a ?to))
		(at start (not (vehicleAt ?a ?from)))
		(at start (decrease (fuelLeft ?a) (distance?from ?to))) )
)

(:durative-action refuelAmbulance
:parameters (?a - ambulance ?l - location)
:duration (= ?duration 10)
:condition (and (at start (vehicleAt ?a ?l))
		(over all (vehicleAt ?a ?l))
		(at start (hasPetrolStation ?l)) )
:effect 		(at end (assign (fuelLeft ?a) (fuelMax ?a)) )
)

(:durative-action refuelHelicopter
:parameters (?h - helicopter ?l  - location)
:duration (= ?duration 10)
:condition (and (at start (vehicleAt ?h ?l))
	(over all (vehicleAt ?h ?l))
	(at start (hasPetrolStation ?l)) )
:effect (at end (assign (fuelLeft ?h) (fuelMax ?h)) )
)
)