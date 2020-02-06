# Collatz-Sequence-on-Arduino

While taking CSC 230, course for computer architecture, its assignments built on each other and resulted in a Collatz Sequence counter running on Arduino. Experienced programming in Assembly and at the end compared it with C.

# Collatz Sequence

From famous unsolved problem, it proceeds as follows:

1. Pick any starting point.
2. Let this be n.
3. If n is even, next number is n/2; else, next number is 3*n+1.
4. Go back to 2.

Collatz Conjecure states that this will, for any starting point, always reach 1 at some point. This has been verified for at least all numbers < 10^12.

Here, we make a counter so that chosen a number, it will proceed to count iterations to reach 1 and show each number of sequence.

# Stage 1: Get Next Number

In this assignment we wrote code to get next 2 byte number in Collatz Sequence, when given a 2 byte number. This gets us familiar with our setup, Arduino, Atmel Studio and Assembly.

# Stage 2: Functions and Buttons

In this assignment we integrate buttons into our routine and use functions to write more scalable code. The Aim is to imagine Pascal's Triangle internally and have cursor moving through it. Current value of cursor is shown as the last 6 bytes of the number on 6 LEDs. Buttons are used to move cursor.

# Stage 3: Collatz Counter (Assembly)

We use all our knowledge of button, Assembly, LCD and Timers to conjure up a Collatz Counter. It uses text on LCD as user interface and takes inputs from buttons. The initial value can only be 3 digit but while counting it can show upto 6 digits for Collatz Sequence number and upto 3 digit for counter. The speed can be adjusted in real time.

# Stage 4: Collatz Counter (C)

Make ditto same Collatz Counter with C. Just goes to show the difference between Assembly and C. Also, some internal logic of C is understood in converting the code.
