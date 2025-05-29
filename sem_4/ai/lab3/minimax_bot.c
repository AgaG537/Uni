/****************************
Agnieszka Głuszkiewicz
Bot using the Minimax algorithm with Alpha-Beta pruning
2025-05-29
****************************/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <arpa/inet.h>
#include <stdbool.h>
#include <limits.h>
#include <time.h>
#include <gsl/gsl_rng.h>
#include <gsl/gsl_randist.h>

#include "./board.h"

// Global for GSL random number generator
gsl_rng *generator = NULL;

// Global variable to store the desired search depth
int MAX_SEARCH_DEPTH;

// --- Heuristic Evaluation Function ---
 /**
 * @brief Evaluates the current board state for the given player.
 * A higher score means a better position for the player.
 * A lower score means a worse position for the player.
 *
 * This function assesses the board from the perspective of 'evaluatingPlayer'.
 * The score is calculated as (Player's advantages) - (Opponent's advantages).
 *
 * Scoring Breakdown:
 *
 * 1. Immediate Win/Loss Detection:
 * - If 'evaluatingPlayer' has won (4-in-a-row): a very high positive value (100000).
 * - If 'evaluatingPlayer' has lost (3-in-a-row): a very high negative value (-100000).
 * - If the 'opponent' has won (4-in-a-row): a high negative value (-90000).
 * - If the 'opponent' has lost (3-in-a-row): a high positive value (90000).
 *
 * 2. Potential 4-in-a-row Lines:
 * - For each possible 4-in-a-row line:
 * - **Offensive Potential (for 'evaluatingPlayer'):**
 * - 3 player symbols + 1 empty: a significant score (550), representing a strong win opportunity.
 * - 2 player symbols + 2 empty: a moderate score (60).
 * - 1 player symbol + 3 empty: a small score (15).
 * - **Defensive Blocking (against 'opponent'):**
 * - 3 opponent symbols + 1 empty: a large negative score (-900), because it's an immediate opponent win threat.
 * - 2 opponent symbols + 2 empty: a moderate negative score (-50).
 * - 1 opponent symbol + 3 empty: a small negative score (-15).
 *
 * 3. Potential 3-in-a-row (Losing Lines):
 * - For each possible 3-in-a-row 'lose' line:
 * - **Avoiding Self-Loss:** 
 *   If 'evaluatingPlayer' has 2 pieces + 1 empty: a penalty of -30.
 * - **Forcing Opponent's Loss:** 
 *   If 'opponent' has 2 pieces + 1 empty: a bonus of +25.
 *
 * 4. Board Control Bonuses (Weighted by position):
 * If 'evaluatingPlayer' controls a cell, its value is added to the score.
 *       1   2   3   4   5
 *     -------------------
 *  1 |  0   2   5   2   0
 *  2 |  2  10  15  10   2
 *  3 |  5  15  20  15   5
 *  4 |  2  10  15  10   2
 *  5 |  0   2   5   2   0
 */
int evaluateBoard(int evaluatingPlayer) {
    int score = 0;
    int opponent = 3 - evaluatingPlayer;

    // Check for win/lose conditions first
    if (winCheck(evaluatingPlayer))
        return 100000;
    if (loseCheck(evaluatingPlayer))
        return -100000;
    if (winCheck(opponent))
        return -90000;
    if (loseCheck(opponent))
        return 90000;

    // Iterate through all possible winning lines (4-in-a-row)
    for (int i = 0; i < 28; i++) {
        int player_count = 0;
        int opponent_count = 0;
        int empty_count = 0;

        for (int j = 0; j < 4; j++) {
            int row = win[i][j][0];
            int col = win[i][j][1];
            if (board[row][col] == evaluatingPlayer) {
                player_count++;
            }
            else if (board[row][col] == opponent) {
                opponent_count++;
            }
            else {
                empty_count++;
            }
        }

        // Evaluate for evaluatingPlayer
        if (opponent_count == 0) {
            if (player_count == 3 && empty_count == 1)
                score += 550;
            else if (player_count == 2 && empty_count == 2)
                score += 60;
            else if (player_count == 1 && empty_count == 3)
                score += 15;
        }

        // Evaluate for opponent (blocking opportunities)
        if (player_count == 0) {
            if (opponent_count == 3 && empty_count == 1)
                score -= 900;
            else if (opponent_count == 2 && empty_count == 2)
                score -= 50;
            else if (opponent_count == 1 && empty_count == 3)
                score -= 15;
        }
    }

    // Iterate through all possible losing lines (3-in-a-row)
    for (int i = 0; i < 48; i++) {
        int player_count = 0;
        int opponent_count = 0;
        int empty_count = 0;

        for (int j = 0; j < 3; j++) {
            int row = lose[i][j][0];
            int col = lose[i][j][1];
            if (board[row][col] == evaluatingPlayer) {
                player_count++;
            }
            else if (board[row][col] == opponent) {
                opponent_count++;
            }
            else {
                empty_count++;
            }
        }

        // Evaluate for evaluatingPlayer (avoid self-lose)
        if (opponent_count == 0) {
            if (player_count == 2 && empty_count == 1)
                score -= 30;
        }

        // Evaluate for opponent (force opponent to lose)
        if (player_count == 0) {
            if (opponent_count == 2 && empty_count == 1)
                score += 25;
        }
    }   


    // Board Control Bonuses
    for (int row = 0; row < 5; row++) {
        for (int col = 0; col < 5; col++) {
            if (board[row][col] == evaluatingPlayer) {
                // Center (2,2)
                if (row == 2 && col == 2) {
                    score += 20;
                }
                // Neighbors of center (2,1; 1,2; 2,3; 3,2)
                else if ((row == 2 && (col == 1 || col == 3)) || ((row == 1 || row == 3) && col == 2)) {
                    score += 15;
                }
                // Other cells in the 3x3 middle grid (rows 1-3, columns 1-3)
                else if (row >= 1 && row <= 3 && col >= 1 && col <= 3) {
                    score += 10;
                }
                // Middle cells on the outer ring (0,2; 2,0; 4,2; 2,4)
                else if (((row == 0 || row == 4) && col == 2) || ((col == 0 || col == 4) && row == 2)) {
                    score += 5;
                }
                // Other cells on the outer ring (excluding corners and middle outer)
                else if ((row == 0 || row == 4 || col == 0 || col == 4) &&
                        !((row == 0 || row == 4) && (col == 0 || col == 4))) { // Exclude corners
                    score += 2;
                }
                // Corners (0,0; 0,4; 4,0; 4,4) - 0, no value added
            }
        }
    }

    return score;
}

// Minimax with Alpha-Beta Pruning
int minimax(int depth, int currentPlayer, int maximizingPlayer, int alpha, int beta) {
    if (depth == MAX_SEARCH_DEPTH || winCheck(currentPlayer) || loseCheck(currentPlayer)
        || winCheck(3 - currentPlayer) || loseCheck(3 - currentPlayer)) {
        return evaluateBoard(maximizingPlayer);
    }

    // Check if board is full
    bool board_full = true;
    for (int i = 0; i < 5; i++) {
        for (int j = 0; j < 5; j++) {
            if (board[i][j] == 0) {
                board_full = false;
                break;
            }
        }
        if (!board_full)
            break;
    }
    if (board_full) {
        return evaluateBoard(maximizingPlayer);
    }

    if (currentPlayer == maximizingPlayer) { // Maximizing player
        int maxEval = INT_MIN;
        for (int i = 0; i < 5; i++) {
            for (int j = 0; j < 5; j++) {
                if (board[i][j] == 0) {
                    board[i][j] = currentPlayer; // Make move
                    int eval = minimax(depth + 1, 3 - currentPlayer, maximizingPlayer, alpha, beta);
                    board[i][j] = 0; // Undo move

                    maxEval = (eval > maxEval) ? eval : maxEval;
                    alpha = (alpha > maxEval) ? alpha : maxEval;
                    if (beta <= alpha) {
                        break; // Beta cut-off
                    }
                }
            }
            if (beta <= alpha)
                break;
        }
        return maxEval;
    }
    else { // Minimizing player
        int minEval = INT_MAX;
        for (int i = 0; i < 5; i++) {
            for (int j = 0; j < 5; j++) {
                if (board[i][j] == 0) {
                    board[i][j] = currentPlayer; // Make move
                    int eval = minimax(depth + 1, 3 - currentPlayer, maximizingPlayer, alpha, beta);
                    board[i][j] = 0; // Undo move

                    minEval = (eval < minEval) ? eval : minEval;
                    beta = (beta < minEval) ? beta : minEval;
                    if (beta <= alpha) {
                        break; // Alpha cut-off
                    }
                }
            }
            if (beta <= alpha)
                break;
        }
        return minEval;
    }
}

int findBestMove(int player) {
    int bestMove = -1;
    int bestValue = INT_MIN;
    int opponent = 3 - player;

    // Moves with the same best value
    int possible_moves[25];
    int num_possible_moves = 0;

    for (int i = 0; i < 5; i++) {
        for (int j = 0; j < 5; j++) {
            if (board[i][j] == 0) {
                board[i][j] = player; // Make move

                if (winCheck(player)) {
                    board[i][j] = 0; // Undo move
                    return (i + 1) * 10 + (j + 1);
                }
                if (loseCheck(player)) {
                    board[i][j] = 0; // Undo move
                    continue;
                }

                if (loseCheck(opponent)) {
                    board[i][j] = 0; // Undo move
                    return (i + 1) * 10 + (j + 1);
                }

                int moveValue = minimax(0, opponent, player, INT_MIN, INT_MAX); // Start minimax from depth 0, for opponent's turn

                board[i][j] = 0; // Undo move

                if (moveValue > bestValue) {
                    bestValue = moveValue;
                    bestMove = (i + 1) * 10 + (j + 1);
                    num_possible_moves = 0;
                    possible_moves[num_possible_moves++] = bestMove;
                }
                else if (moveValue == bestValue) {
                    possible_moves[num_possible_moves++] = (i + 1) * 10 + (j + 1);
                }
            }
        }
    }

    if (num_possible_moves > 0) {
        // If multiple moves have the same best value, choose one randomly
        return possible_moves[gsl_rng_uniform_int(generator, num_possible_moves)];
    }
    else {
        // If no good move found, pick any empty cell
        for (int i = 0; i < 5; i++) {
            for (int j = 0; j < 5; j++) {
                if (board[i][j] == 0) {
                    return (i + 1) * 10 + (j + 1);
                }
            }
        }
    }
    return -1;
}

int main(int argc, char *argv[]) {
    int server_socket;
    struct sockaddr_in server_addr;
    char server_message[16], player_message[16];

    bool end_game;
    int player, msg, move;

    // Initialize GSL random number generator
    generator = gsl_rng_alloc(gsl_rng_mt19937);
    gsl_rng_set(generator, time(NULL));

    if (argc != 6) {
        printf("Wrong number of arguments\n");
        printf("Usage: ./my_minimax <server_ip> <server_port> <player_number> <nick> <search_depth>\n");
        return -1;
    }

    MAX_SEARCH_DEPTH = atoi(argv[5]);
    if (MAX_SEARCH_DEPTH < 1 || MAX_SEARCH_DEPTH > 10) {
        printf("Search depth must be between 1 and 10.\n");
        return -1;
    }

    // Create socket
    server_socket = socket(AF_INET, SOCK_STREAM, 0);
    if (server_socket < 0) {
        printf("Unable to create socket\n");
        return -1;
    }
    printf("Socket created successfully\n");

    // Set port and IP the same as server-side
    server_addr.sin_family = AF_INET;
    server_addr.sin_port = htons(atoi(argv[2]));
    server_addr.sin_addr.s_addr = inet_addr(argv[1]);

    // Send connection request to server
    if (connect(server_socket, (struct sockaddr *)&server_addr, sizeof(server_addr)) < 0) {
        printf("Unable to connect\n");
        return -1;
    }
    printf("Connected with server successfully\n");

    // Receive the server message (700)
    memset(server_message, '\0', sizeof(server_message));
    if (recv(server_socket, server_message, sizeof(server_message), 0) < 0) {
        printf("Error while receiving server's message\n");
        return -1;
    }
    printf("Server message: %s\n", server_message);

    memset(player_message, '\0', sizeof(player_message));
    snprintf(player_message, sizeof(player_message), "%s %s", argv[3], argv[4]);
    // Send player number and nick to server
    if (send(server_socket, player_message, strlen(player_message), 0) < 0) {
        printf("Unable to send message\n");
        return -1;
    }
    printf("Sent player info: %s\n", player_message);

    setBoard();
    end_game = false;
    sscanf(argv[3], "%d", &player);

    while (!end_game) {
        memset(server_message, '\0', sizeof(server_message));
        if (recv(server_socket, server_message, sizeof(server_message), 0) < 0) {
            printf("Error while receiving server's message\n");
            return -1;
        }
        printf("Server message: %s\n", server_message);
        sscanf(server_message, "%d", &msg);
        move = msg % 100;
        msg = msg / 100;

        if (move != 0) {
            setMove(move, 3 - player);
            printf("Opponent played %d.\n", move);
            printBoard();
        }

        if ((msg == 0) || (msg == 6)) {
            printf("It's your turn. Calculating best move...\n");
            move = findBestMove(player);
            printf("Minimax selected move: %d\n", move);

            // Validate and make the move on your local board
            if (!setMove(move, player))
            {
                printf("ERROR: Minimax selected an invalid move %d. This should not happen.\n", move);
                return -1;
            }
            printBoard();

            memset(player_message, '\0', sizeof(player_message));
            snprintf(player_message, sizeof(player_message), "%d", move);
            if (send(server_socket, player_message, strlen(player_message), 0) < 0)
            {
                printf("Unable to send message\n");
                return -1;
            }
            printf("Player %s sent move: %s\n", argv[4], player_message);
        }
        else { // Game over message
            end_game = true;
            switch (msg) {
                case 1:
                    printf("You won.\n");
                    break;
                case 2:
                    printf("You lost.\n");
                    break;
                case 3:
                    printf("Draw.\n");
                    break;
                case 4:
                    printf("You won. Opponent error.\n");
                    break;
                case 5:
                    printf("You lost. Your error.\n");
                    break;
            }
        }
    }

    // Clean up GSL generator
    gsl_rng_free(generator);
    // Close socket
    close(server_socket);

    return 0;
}