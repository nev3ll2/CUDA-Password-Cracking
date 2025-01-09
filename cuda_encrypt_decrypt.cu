#include <stdio.h>
#include <stdlib.h>
#include <cuda_runtime.h>
#include <ctype.h>  // For isalpha() and isdigit()

// Kernel to encrypt a 4-character password
__global__ void encryptPasswordKernel(const char *rawPassword, char *newPassword) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x; // Global thread index

    if (idx == 0) newPassword[0] = rawPassword[0] + 3; // Transform 1st letter
    if (idx == 1) newPassword[1] = rawPassword[0] - 2; // Transform 1st letter
    if (idx == 2) newPassword[2] = rawPassword[0] + 1; // Transform 1st letter
    if (idx == 3) newPassword[3] = rawPassword[1] + 1; // Transform 2nd letter
    if (idx == 4) newPassword[4] = rawPassword[1] - 2; // Transform 2nd letter
    if (idx == 5) newPassword[5] = rawPassword[1] - 3; // Transform 2nd letter
    if (idx == 6) newPassword[6] = rawPassword[2] + 1; // Transform 1st number
    if (idx == 7) newPassword[7] = rawPassword[2] - 2; // Transform 1st number
    if (idx == 8) newPassword[8] = rawPassword[3] + 4; // Transform 2nd number
    if (idx == 9) newPassword[9] = rawPassword[3] - 3; // Transform 2nd number

    if (idx < 10) {
        // Wrapping logic for letters and numbers
        if (idx < 6) { // First 6 characters are letters
            if (newPassword[idx] > 'z') {
                newPassword[idx] = 'a' + (newPassword[idx] - 'z' - 1);
            } else if (newPassword[idx] < 'a') {
                newPassword[idx] = 'z' - ('a' - newPassword[idx] - 1);
            }
        } else { // Last 4 characters are numbers
            if (newPassword[idx] > '9') {
                newPassword[idx] = '0' + (newPassword[idx] - '9' - 1);
            } else if (newPassword[idx] < '0') {
                newPassword[idx] = '9' - ('0' - newPassword[idx] - 1);
            }
        }
    }

    if (idx == 10) newPassword[10] = '\0'; // Null-terminate the string
}

// Kernel to decrypt a 10-character password back to the original 4-character password
__global__ void decryptPasswordKernel(const char *encryptedPassword, char *decryptedPassword) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x; // Global thread index

    if (idx == 0) decryptedPassword[0] = encryptedPassword[0] - 3; // Reverse 1st letter
    if (idx == 1) decryptedPassword[1] = encryptedPassword[1] + 2; // Reverse 1st letter
    if (idx == 2) decryptedPassword[2] = encryptedPassword[2] - 1; // Reverse 1st letter
    if (idx == 3) decryptedPassword[3] = encryptedPassword[3] - 1; // Reverse 2nd letter
    if (idx == 4) decryptedPassword[4] = encryptedPassword[4] + 2; // Reverse 2nd letter
    if (idx == 5) decryptedPassword[5] = encryptedPassword[5] + 3; // Reverse 2nd letter
    if (idx == 6) decryptedPassword[6] = encryptedPassword[6] - 1; // Reverse 1st number
    if (idx == 7) decryptedPassword[7] = encryptedPassword[7] + 2; // Reverse 1st number
    if (idx == 8) decryptedPassword[8] = encryptedPassword[8] - 4; // Reverse 2nd number
    if (idx == 9) decryptedPassword[9] = encryptedPassword[9] + 3; // Reverse 2nd number

    // Wrapping logic for letters and numbers
    if (idx < 6) { // First 6 characters are letters
        if (decryptedPassword[idx] > 'z') {
            decryptedPassword[idx] = 'a' + (decryptedPassword[idx] - 'z' - 1);
        } else if (decryptedPassword[idx] < 'a') {
            decryptedPassword[idx] = 'z' - ('a' - decryptedPassword[idx] - 1);
        }
    } else { // Last 4 characters are numbers
        if (decryptedPassword[idx] > '9') {
            decryptedPassword[idx] = '0' + (decryptedPassword[idx] - '9' - 1);
        } else if (decryptedPassword[idx] < '0') {
            decryptedPassword[idx] = '9' - ('0' - decryptedPassword[idx] - 1);
        }
    }

    if (idx == 10) decryptedPassword[10] = '\0'; // Null-terminate the string
}

// Function to validate the password format
int validatePassword(const char *password) {
    // Check the length
    if (strlen(password) != 4) return 0;

    // Check if first two characters are letters (a-z, A-Z)
    if (!isalpha(password[0]) || !isalpha(password[1])) return 0;

    // Check if last two characters are digits (0-9)
    if (!isdigit(password[2]) || !isdigit(password[3])) return 0;

    return 1; // Valid password format
}

int main() {
    // Variables for user input
    char rawPasswordHost[5]; // Password must be 4 characters + null terminator
    int blocksPerGrid, threadsPerBlock;

    // Get password input from the user with validation
    while (1) {
        printf("Enter a 4-character password (2 letters followed by 2 digits): ");
        scanf("%4s", rawPasswordHost);
        
        // Validate the password
        if (validatePassword(rawPasswordHost)) {
            break;
        } else {
            printf("Invalid password format! Please enter a valid password (2 letters followed by 2 digits).\n");
        }
    }

    // Get CUDA configuration input from the user
    printf("Enter the number of blocks per grid: ");
    scanf("%d", &blocksPerGrid);

    printf("Enter the number of threads per block: ");
    scanf("%d", &threadsPerBlock);

    // Host and device memory for the encrypted and decrypted passwords
    char newPasswordHost[11]; // Host memory to store encrypted password
    char decryptedPasswordHost[11]; // Host memory to store decrypted password (10 characters + null terminator)
    char *rawPasswordDevice, *newPasswordDevice, *decryptedPasswordDevice;

    // Allocate device memory
    cudaMalloc((void **)&rawPasswordDevice, sizeof(char) * 5);
    cudaMalloc((void **)&newPasswordDevice, sizeof(char) * 11);
    cudaMalloc((void **)&decryptedPasswordDevice, sizeof(char) * 11);

    // Copy the raw password to device memory
    cudaMemcpy(rawPasswordDevice, rawPasswordHost, sizeof(char) * 5, cudaMemcpyHostToDevice);

    // Launch the kernel for encryption
    encryptPasswordKernel<<<blocksPerGrid, threadsPerBlock>>>(rawPasswordDevice, newPasswordDevice);

    // Copy the encrypted password back to host memory
    cudaMemcpy(newPasswordHost, newPasswordDevice, sizeof(char) * 11, cudaMemcpyDeviceToHost);

    // Print the encrypted password
    printf("Encrypted password: %s\n", newPasswordHost);

    // Notify user that decryption is starting
    printf("Now decrypting the encrypted password...\n");

    // Launch the kernel for decryption
    decryptPasswordKernel<<<blocksPerGrid, threadsPerBlock>>>(newPasswordDevice, decryptedPasswordDevice);

    // Copy the decrypted password back to host memory
    cudaMemcpy(decryptedPasswordHost, decryptedPasswordDevice, sizeof(char) * 11, cudaMemcpyDeviceToHost);

    // Extract the original 4-character password from the decrypted string
    char finalDecryptedPassword[5]; // 4 characters + null terminator
    finalDecryptedPassword[0] = decryptedPasswordHost[0];  // 1st letter from index 0
    finalDecryptedPassword[1] = decryptedPasswordHost[3];  // 2nd letter from index 3
    finalDecryptedPassword[2] = decryptedPasswordHost[6];  // 1st number from index 6
    finalDecryptedPassword[3] = decryptedPasswordHost[8];  // 2nd number from index 8
    finalDecryptedPassword[4] = '\0';

    // Print the decrypted password (corrected)
    printf("Decrypted password: %s\n", finalDecryptedPassword);

    // Compare decrypted password with the original one
    if (strcmp(finalDecryptedPassword, rawPasswordHost) == 0) {
        printf("The decrypted password matches the original password.\n");
    } else {
        printf("The decrypted password does not match the original password. Could not crack the password.\n");
    }

    // Free device memory
    cudaFree(rawPasswordDevice);
    cudaFree(newPasswordDevice);
    cudaFree(decryptedPasswordDevice);

    return 0;
}
