// Init game
r1 = 1; // Shape
r4  = 19; // Counter
r5 = 0; // Score
_wshp(r1);
r1 = (r1 == 1) ? 2 : 1;

while (true) {
    if (inputReg[gameAction] == down) {
        moveDown();
    }

    if (inputReg[gameAction] == left) {
        moveLeft();
    }

    if (inputReg[gameAction] == right) {
        moveDown();
    }


    // If full, clear row and update score
    if (rowStatusReg[r4] == 1) {
        _clrl(r4);
        r5 = r5 + 1;
    }

    // Send row to graphics module
    _sndrow(r4);

    // Update timer
    if (r4 == 0) {
        r4 = 19;
    } else {
        r4 = r4 - 1;
    }

}


moveDown() {
    
    // If already at the bottom just write new shape
    if (inputReg[ypos] == 0) {
        _wshp(r1);
        r1 = (r1 == 1) ? 2 : 1;

    // If not, check if can move down
    } else {
        r2 = _getrow(inputReg[ypos - 1]);
        if (inputReg[shapeType] == 1) { // Line

            // Can't move down
            if (r2[inputReg[xpos]]) {
                _wshp(r1);
                r1 = (r1 == 1) ? 2 : 1;

            // Can move down
            } else {
                _movshpd();
            }
        } else { // Square

            // Can't move down
            if (r2[inputReg[xpos]] || r2[inputReg[xpos] + 1]) {
                _wshp(r1);
                r1 = (r1 == 1) ? 2 : 1;

            // Can move down
            } else {
                _movshpd();
            }
        }
    }
}

moveLeft() {
    if (inputReg[xpos] != 0) {
        if (inputReg[shapeType] == 1) { // Line
    
            // Determines if something is blocking to the left
            r3 = 0;
            r2 = _getrow(inputReg[ypos]);
            r3 = r3 | r2[inputReg[xpos] - 1];
            r2 = _getrow(inputReg[ypos] + 1);
            r3 = r3 | r2[inputReg[xpos] - 1];
            r2 = _getrow(inputReg[ypos] + 2);
            r3 = r3 | r2[inputReg[xpos] - 1];
            r2 = _getrow(inputReg[ypos] + 3);
            r3 = r3 | r2[inputReg[xpos] - 1];

                // If not, move
            if (r3 == 0) {
                _movshpl();
            }

        } else { // Square

            // Determines if something is blocking to the left
            r3 = 0;
            r2 = _getrow(inputReg[ypos]);
            r3 = r3 | r2[inputReg[xpos] - 1];
            r2 = _getrow(inputReg[ypos] + 1);
            r3 = r3 | r2[inputReg[xpos] - 1];

            // If not, move
            if (r3 == 0) {
                _movshpl();
            }
        }
    }
}

moveRight() {
    if (inputReg[shapeType == 1]) { // Line

        // Not on edge of board
        if (inputReg[xpos] != 19) {
                
            // Determines if something is blocking to the right
            r3 = 0;
            r2 = _getrow(inputReg[ypos]);
            r3 = r3 | r2[inputReg[xpos] + 1];
            r2 = _getrow(inputReg[ypos] + 1);
            r3 = r3 | r2[inputReg[xpos] + 1];
            r2 = _getrow(inputReg[ypos] + 2);
            r3 = r3 | r2[inputReg[xpos] + 1];
            r2 = _getrow(inputReg[ypos] + 3);
            r3 = r3 | r2[inputReg[xpos] + 1];

            // If not, move
            if (r3 == 0) {
                _movshpr();
            }
        }
    } else { // Square

        // Not on edge of board
        if (inputReg[xpos] != 18) {

            // Determines if something is blocking to the right
            r3 = 0;
            r2 = _getrow(inputReg[ypos]);
            r3 = r3 | r2[inputReg[xpos] + 2];
            r2 = _getrow(inputReg[ypos] + 1);
            r3 = r3 | r2[inputReg[xpos] + 2];

            // If not, move
            if (r3 == 0) {
                _movshpr();
            }
        }
    }
}
