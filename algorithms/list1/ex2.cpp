#include <iostream>
#include <random>

class Node {
public:
    int data;
    Node* next;
    Node(int val) : data(val), next(nullptr) {}
};

class CyclicList {
public:
    Node* head;
    int size;

    CyclicList() : head(nullptr), size(0) {}
    
    void insert(int value) {
        Node* newNode = new Node(value);
        if (!head) {
            head = newNode;
            newNode->next = newNode;
        } else {
            newNode->next = head->next;
            head->next = newNode;
        }
        size++;
    }

    void merge(CyclicList& list2) {
        if (!list2.head) {
            return;
        }

        Node* tmp = head->next;
        head->next = list2.head->next;
        list2.head->next = tmp;
        
        size += list2.size;
        list2.head = nullptr;
        list2.size = 0;
    }

    int search(int value) {
        if (!head) {
            return 0;
        }
        int comparisons = 0;
        Node* current = head;
        do {
            comparisons++;
            if (current->data == value){
                return comparisons;
            }
            current = current->next;
        } while (current != head);
        return comparisons;
    }

    void print() {
        if (!head) {
            std::cout << "List is empty\n";
            return;
        }
        Node* tmp = head;
        do {
            std::cout << tmp->data << " ";
            tmp = tmp->next;
        } while (tmp != head);
        std::cout << std::endl;
    }
};

int main() {
    std::random_device rd;
    std::mt19937 rng(rd());
    std::uniform_int_distribution<int> dist1(10, 99);
    std::uniform_int_distribution<int> dist2(0, 100000);
    std::uniform_int_distribution<int> index_dist(0, 9999);

    CyclicList list1, list2;
    for (int i = 0; i < 10; i++) {
        list1.insert(dist1(rng));
        list2.insert(dist1(rng));
    }

    std::cout << "List 1: ";
    list1.print();

    std::cout << "List 2: ";
    list2.print();

    list1.merge(list2);
    std::cout << "Merged list: ";
    list1.print();


    int T[10000];
    CyclicList list;
    
    for (int i = 0; i < 10000; i++) {
        T[i] = dist2(rng);
        list.insert(T[i]);
    }
    
    int totalComparisons = 0;
    for (int i = 0; i < 1000; i++) {
        int index = index_dist(rng);
        totalComparisons += list.search(T[index]);
    }
    std::cout << "Average cost (elements from the list): " << totalComparisons / 1000.0 << std::endl;
    
    totalComparisons = 0;
    for (int i = 0; i < 1000; i++) {
        int randomValue = dist2(rng);
        totalComparisons += list.search(randomValue);
    }
    std::cout << "Average cost (random elements): " << totalComparisons / 1000.0 << std::endl;
    
    return 0;
}
