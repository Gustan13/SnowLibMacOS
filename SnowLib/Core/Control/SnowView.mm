#include "SnowView.h"

@implementation SnowView

- (BOOL)acceptsFirstResponder {
    return YES;
}

//- (void)setInputManager:(Input *)input {
//    self->input = input;
//}

//- (void)interpretKeyEvents:(NSArray<NSEvent *> *)eventArray {
//    for (int i = 0; i < eventArray.count; i++) {
//        printf("%c\n", eventArray[i].keyCode);
//    }
//}

- (void)keyDown:(NSEvent *)event {
    int key;
    Input* input = Input::getInstance();
    
    if (event.type == NSEventTypeKeyDown) {
        
        key = (int)event.keyCode;
        
        if (input->pressedKeys[key]) {
            if (input->justPressedKeys[key] == true) {
                input->justPressedKeys[key] = false;
            }
        } else {
            input->pressedKeys[key] = true;
            input->justPressedKeys[key] = true;
            input->justReleasedKeys[key] = false;
        }
    }
}

- (void)keyUp:(NSEvent *)event {
    int key;
    Input* input = Input::getInstance();
    
    if (event.type == NSEventTypeKeyUp) {
        key = (int)event.keyCode;
        if (input->justReleasedKeys[key]) {
            input->justReleasedKeys[key] = false;
        } else {
            input->pressedKeys[key] = false;
            input->justPressedKeys[key] = false;
            input->justReleasedKeys[key] = true;
        }
    }
}

- (void)mouseMoved:(NSEvent *)event {
    Input* input = Input::getInstance();
    
    if (event.type == NSEventTypeMouseMoved) {
        
        input->mousePosition.x = NSEvent.mouseLocation.x;
        input->mousePosition.y = NSEvent.mouseLocation.y;
        
        input->mouseDelta.x = event.deltaX;
        input->mouseDelta.y = event.deltaY;
    }
}

- (void)mouseUp:(NSEvent *)event {
    Input* input = Input::getInstance();
    input->leftMouseState = false;
}

- (void)mouseDown:(NSEvent *)event {
    Input* input = Input::getInstance();
    input->leftMouseState = true;
}

- (void)rightMouseUp:(NSEvent *)event {
    Input* input = Input::getInstance();
    input->rightMouseState = false;
}

- (void)rightMouseDown:(NSEvent *)event {
    Input* input = Input::getInstance();
    input->rightMouseState = true;
}

@end
