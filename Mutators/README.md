# Mutator Operators

This folder contains themutation operators used to mutate the stateflow model.
The operators were implemented in the form of Insertion (I), Replace (R) or Delete (D) actions.

## Operators

### Relational Operator Replacement (R)
It replaces relational operators in a transition (e.g., <= to ==)

### Conditional Operator Replacement (R)
It replaces conditional operators in a transitions (e.g., && to ||)

### Mathematical Operator Replacement (R)
It replaces mathematical operators in a transition or state (e.g., + to -)

### Change of unit in the after (R)
It replaces the unit in an after function in a transition (e.g., from msec to sec)

### Numerical Replacement Operator in Transition (R)
It replaces numerical values in transition (e.g., from 5 to 1)

### Numerical Replacement Operator in State (R)
It replaces numerical values in states (e.g., from 5 to 1)

### Transition Destination Replacement (R)
It changes the destination state of a transition

### Transition Root Replacement (R)
It changes the root state of a transition

### Initial Transition Change (R)
It changes the initial transition from state

### Action State Replacment (R) (Not implemented?)

### Delete State (D)
It delates a state from the stateflow chart.

### Delete Transition (D)
It delates a transition from the stateflow chart.

### Delete Variable from a State (D)
It delates a variable from a state.

### Delete Condition from a Transition (D)
It delates a condition from a transition (e.g., A==5 && B<3 -> A==5).

### Insert Mathematical Operator (I)
It inserts a mathematical operator in a state

### Variable Insertion In State (I)
It inserts a new variable in a state

### Insert New Condition (I)
It inserts a new condition in a transition (e.g., from A==5 -> A==5 && B>=8)
