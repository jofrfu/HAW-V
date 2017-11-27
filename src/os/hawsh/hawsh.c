/*
 * Own HAW-Shell
 */

#include <stdio.h>
#include <string.h>
#include "functions.h"

#define MAX_LENGTH 255
#define DELIMITER " "

extern void huhuu();

void splitString(char* selection, char* fun, char* params) {
	int i = 0;
	char recent;
	recent = selection[i];
	while(recent != ' ' && recent != '\0') {
		if (recent == '\n') {
			recent = '\0';
			fun[i] = recent;
			break;
		}
		fun[i] = recent;
		i++;
		recent = selection[i];
	}
	i++;
	fun[i] = '\0';
	int j = 0;
	recent = selection[i];
	while (recent != '\0' && i < MAX_LENGTH) {
		if (recent == '\n') {
			recent = '\0';
		}
		params[j] = recent;
		i++;
		j++;
		recent = selection[i];
	}
}

void overwriteString(char* selection, char* fun, char* params) {
	for (int i = 0; i++; i < MAX_LENGTH) {
		selection[i] = ' ';
		fun[i] = ' ';
		params[i] = ' ';
	}
}


int main(int argc, char* argv[]) {
	// Eingelesener Befehl des Users
	char selection[MAX_LENGTH];
	char fun[MAX_LENGTH];
	char params[MAX_LENGTH];
	while (1) {
		overwriteString(selection, fun, params);	
		printf("Was willst du? - ");
		fflush(stdout);
		fgets(selection, MAX_LENGTH, stdin);
		splitString(selection, fun, params);
		checkCommand(fun, params);
	}
}
