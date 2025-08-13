#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/wait.h>
#include <fcntl.h>
#include <signal.h>
#include <errno.h>

#define MAX_LINE 1024
#define MAX_ARGS 128

void lsh_loop();
char **lsh_parse_line(char *line, int *is_background);
int lsh_execute(char **args, int is_background);
int lsh_execute_command(char **args, int in_fd, int out_fd, int err_fd, int is_background);
int lsh_handle_builtins(char **args);
void sigchld_handler();
void sigint_handler();

// Zmienna globalna do obsługi `Ctrl+C`
volatile sig_atomic_t foreground_process = 0;

// Obsługa SIGCHLD - usuwanie procesów zombie
void sigchld_handler() {
    while (waitpid(-1, NULL, WNOHANG) > 0);
}

// Obsługa SIGINT - przerywa tylko aktywny proces
void sigint_handler() {
    if (foreground_process != 0) {
        kill(foreground_process, SIGINT);
    }
}

// Funkcja parsująca linie na argumenty
char **lsh_parse_line(char *line, int *is_background) {
    int bufsize = MAX_ARGS, position = 0;
    char **tokens = malloc(bufsize * sizeof(char *));
    char *token;

    if (!tokens) {
        fprintf(stderr, "lsh: allocation error\n");
        exit(EXIT_FAILURE);
    }

    token = strtok(line, " \t\r\n");
    while (token != NULL) {
        if (strcmp(token, "&") == 0) {
            *is_background = 1; // Proces w tle
            break;
        }

        tokens[position++] = token;

        if (position >= bufsize) {
            bufsize += MAX_ARGS;
            tokens = realloc(tokens, bufsize * sizeof(char *));
            if (!tokens) {
                fprintf(stderr, "lsh: allocation error\n");
                exit(EXIT_FAILURE);
            }
        }

        token = strtok(NULL, " \t\r\n");
    }
    tokens[position] = NULL;
    return tokens;
}

// Obsługa wbudowanych komend (np. cd, exit)
int lsh_handle_builtins(char **args) {
    if (args[0] == NULL) {
        return 1;
    }
    if (strcmp(args[0], "exit") == 0) {
        exit(0);
    } else if (strcmp(args[0], "cd") == 0) {
        if (args[1] == NULL) {
            fprintf(stderr, "lsh: expected argument to \"cd\"\n");
        } else if (chdir(args[1]) != 0) {
            perror("lsh");
        }
        return 1;
    }
    return 0;
}

// Wykonanie pojedynczej komendy z uwzględnieniem przekierowań i procesów w tle
int lsh_execute_command(char **args, int in_fd, int out_fd, int err_fd, int is_background) {
    pid_t pid;
    int status;

    pid = fork();
    if (pid == 0) {
        // Proces potomny
        if (in_fd != STDIN_FILENO) {
            dup2(in_fd, STDIN_FILENO);
            close(in_fd);
        }
        if (out_fd != STDOUT_FILENO) {
            dup2(out_fd, STDOUT_FILENO);
            close(out_fd);
        }
        if (err_fd != STDERR_FILENO) {
            dup2(err_fd, STDERR_FILENO);
            close(err_fd);
        }
        if (execvp(args[0], args) == -1) {
            perror("lsh");
        }
        exit(EXIT_FAILURE);
    } else if (pid < 0) {
        // Błąd forkowania
        perror("lsh");
    } else {
        if (is_background) {
            // Proces w tle - nie czekaj na zakończenie
            printf("[Proces w tle uruchomiony] PID: %d\n", pid);
        } else {
            // Proces pierwszoplanowy
            foreground_process = pid;
            waitpid(pid, &status, 0);
            foreground_process = 0;
        }
    }

    return 1;
}

// Wykonanie komendy z obsługą potoków i przekierowań
int lsh_execute(char **args, int is_background) {
    int in_fd = STDIN_FILENO;
    int out_fd = STDOUT_FILENO;
    int err_fd = STDERR_FILENO;

    char *cmd[MAX_ARGS];
    int cmd_index = 0;

    for (int i = 0; args[i] != NULL; i++) {
        if (strcmp(args[i], "|") == 0) {
            // Potoki
            int pipe_fd[2];
            pipe(pipe_fd);

            cmd[cmd_index] = NULL;
            lsh_execute_command(cmd, in_fd, pipe_fd[1], err_fd, 0);

            close(pipe_fd[1]);
            in_fd = pipe_fd[0];
            cmd_index = 0;
        } else if (strcmp(args[i], "<") == 0) {
            // Przekierowanie wejścia
            in_fd = open(args[++i], O_RDONLY);
            if (in_fd < 0) {
                perror("lsh");
                return 1;
            }
        } else if (strcmp(args[i], ">") == 0) {
            // Przekierowanie wyjścia
            out_fd = open(args[++i], O_WRONLY | O_CREAT | O_TRUNC, 0644);
            if (out_fd < 0) {
                perror("lsh");
                return 1;
            }
        } else if (strcmp(args[i], "2>") == 0) {
            // Przekierowanie wyjścia błędu
            err_fd = open(args[++i], O_WRONLY | O_CREAT | O_TRUNC, 0644);
            if (err_fd < 0) {
                perror("lsh");
                return 1;
            }
        } else {
            // Dodanie do aktualnej komendy
            cmd[cmd_index++] = args[i];
        }
    }

    cmd[cmd_index] = NULL;
    lsh_execute_command(cmd, in_fd, out_fd, err_fd, is_background);

    if (in_fd != STDIN_FILENO) close(in_fd);
    if (out_fd != STDOUT_FILENO) close(out_fd);
    if (err_fd != STDERR_FILENO) close(err_fd);

    return 1;
}

// Główna pętla powłoki
void lsh_loop() {
    char *line = NULL;
    char **args;
    size_t bufsize = 0;

    signal(SIGCHLD, sigchld_handler);
    signal(SIGINT, sigint_handler);

    while (1) {
        printf("lsh> ");
        if (getline(&line, &bufsize, stdin) == -1) {
            printf("\n");
            break;
        }

        int is_background = 0;
        args = lsh_parse_line(line, &is_background);

        if (!lsh_handle_builtins(args)) {
            lsh_execute(args, is_background);
        }

        free(args);
    }

    free(line);
}

// Funkcja główna
int main() {
    lsh_loop();
    return 0;
}
