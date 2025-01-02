#include <stdio.h>
#include <stdlib.h>

// Encrypts a 4-character password (2 letters and 2 numbers)
char* cudaCrypt(char* rawPassword) {
    static char newPassword[11]; // Static array to store the encrypted password, returned to the caller

    // Apply transformations to each character of the rawPassword
    newPassword[0] = rawPassword[0] + 3; // Transform 1st letter
    newPassword[1] = rawPassword[0] - 2; // Transform 1st letter
    newPassword[2] = rawPassword[0] + 1; // Transform 1st letter
    newPassword[3] = rawPassword[1] + 1; // Transform 2nd letter
    newPassword[4] = rawPassword[1] - 2; // Transform 2nd letter
    newPassword[5] = rawPassword[1] - 3; // Transform 2nd letter
    newPassword[6] = rawPassword[2] + 1; // Transform 1st number
    newPassword[7] = rawPassword[2] - 2; // Transform 1st number
    newPassword[8] = rawPassword[3] + 4; // Transform 2nd number
    newPassword[9] = rawPassword[3] - 3; // Transform 2nd number
    newPassword[10] = '\0';              // Null-terminate the string

    // Ensure transformed characters stay within valid ranges
    for (int i = 0; i < 10; i++) {
        if (i >= 0 && i < 6) { // First 6 characters are letters
            if (newPassword[i] > 122) { // Exceeds 'z'
                newPassword[i] = (newPassword[i] - 122) + 97; // Wrap around to 'a'
            } else if (newPassword[i] < 97) { // Below 'a'
                newPassword[i] = (97 - newPassword[i]) + 97; // Wrap around from 'z'
            }
        } else { // Last 4 characters are numbers
            if (newPassword[i] > 57) { // Exceeds '9'
                newPassword[i] = (newPassword[i] - 57) + 48; // Wrap around to '0'
            } else if (newPassword[i] < 48) { // Below '0'
                newPassword[i] = (48 - newPassword[i]) + 48; // Wrap around from '9'
            }
        }
    }

    return newPassword; // Return the encrypted password
}

void main() {
    // Allocate memory for the input password
    char* passInput = malloc(sizeof(char) * 4);

    // Initialize the input password (hardcoded in this case)
    passInput = "hp93";

    // Allocate memory for the encrypted password
    char* newPasswordFromMethod = malloc(sizeof(char) * 11);

    // Call the cudaCrypt function to encrypt the input password
    newPasswordFromMethod = cudaCrypt(passInput);

    // Print the encrypted password
    printf("%s\n", newPasswordFromMethod);

    // Free allocated memory (missing in your code, but important in real implementations)
    free(passInput);
    free(newPasswordFromMethod);
}
