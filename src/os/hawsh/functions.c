/*
 * Functions for Own HAW-Shell
 */

#include <stdio.h>
#include <string.h>
#include "functions.h"


void printVersion() {
	printf("HAW-Shell Version: 1.0\n");
}

void printHelp() {
	printf("No help for you!\n");
}

void echo(char* message) {
	printf("%s\n", message);
}

void printExit() {
	printf("Nowhere to return!\n");
}

void printUnrecognized(char* select) {
	printf("Unrecognized command %s!\n", select);
}

int checkCommand(char* select, char* params) {
	if (strcmp(select, "exit") == 0) {
		printExit();
	} else if (strcmp(select, "version") == 0) {
		printVersion();
	} else if (strcmp(select, "echo") == 0) {
		echo(params);
	} else if (strcmp(select, "exit") == 0) {
		printExit();
	} else if (strcmp(select, "help") == 0) {
		printHelp();
	} else {
		printUnrecognized(select);
	}
	return 0;
}
