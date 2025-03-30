#include <iostream>

class Node {
public:
    int data;
    Node* next;
    Node(int val) : data(val), next(nullptr) {}
};

class FIFO {
private:
    Node* head;
    Node* tail;
public:
    FIFO() : head(nullptr), tail(nullptr) {}
    
    void push(int item) {
        Node* newNode = new Node(item);
        if (!tail) {
            head = tail = newNode;
        } else {
            tail->next = newNode;
            tail = newNode;
        }
        std::cout << item << " ";
    }
    
    void pop() {
        if (!head) {
            std::cout << "FIFO is empty!" << std::endl;
            return;
        }
        Node* tmp = head;
        head = head->next;
        if (!head) {
            tail = nullptr;
        }
        std::cout << tmp->data << " ";
        delete tmp;
    }
};

class LIFO {
private:
    Node* top;
public:
    LIFO() : top(nullptr) {}
    
    void push(int item) {
        Node* newNode = new Node(item);
        newNode->next = top;
        top = newNode;
        std::cout << item << " ";
    }
    
    void pop() {
        if (!top) {
            std::cout << "LIFO is empty!" << std::endl;
            return;
        }
        Node* tmp = top;
        top = top->next;
        std::cout << tmp->data << " ";
        delete tmp;
    }
};

int main() {
    FIFO fifo;
    std::cout << "Pushing to FIFO: " << std::endl;
    for (int i = 1; i <= 50; i++) {
        fifo.push(i);
    }
    
    std::cout << std::endl << "Popping from FIFO: " << std::endl;
    for (int i = 1; i <= 50; i++) {
        fifo.pop();
    }
    
    LIFO lifo;
    std::cout << std::endl << "Pushing to LIFO: " << std::endl;
    for (int i = 1; i <= 50; i++) {
        lifo.push(i);
    }
    
    std::cout << std::endl << "Popping from LIFO: " << std::endl;
    for (int i = 1; i <= 50; i++) {
        lifo.pop();
    }
    
    std::cout << std::endl;
    return 0;
}
