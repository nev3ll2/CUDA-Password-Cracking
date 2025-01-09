# Comparison of Regular Encryption Program and CUDA-based Encryption-Decryption Program

This README provides a detailed explanation of two programs for password encryption and decryption:
1. **The Regular Encryption Program (CPU-based)**
2. **The CUDA-based Encryption-Decryption Program (GPU-based)**

It includes what these programs are, how they work, their advantages and disadvantages, and instructions for compiling and running them. Additionally, it explains key methods and variables in each program that make them function effectively.

---

## 1. Regular Encryption Program (CPU-based)

### Description
This is a simple C program that performs encryption of a 4-character password. The password consists of two letters followed by two numbers (e.g., `hp93`). The encryption process transforms each character in the password based on a specific mathematical formula.

### Functionality
- The program takes a 4-character password as input.
- Each character undergoes transformations:
  - Letters are modified using addition and subtraction to produce three derived characters for each letter.
  - Numbers are similarly transformed into two derived characters each.
- The encrypted password is returned as a 10-character string.

### Key Methods and Variables
1. **`cudaCrypt(char* rawPassword)`**:
   - This function performs the encryption by applying transformations to each character in the input password.
   - Variables:
     - `newPassword`: A static array to store the encrypted 10-character password.
     - Transformation logic ensures valid ASCII ranges for letters (`a-z`) and numbers (`0-9`).
2. **Input Handling**:
   - A hardcoded password (e.g., `"hp93"`) is used for simplicity.
3. **Main Method**:
   - Calls the `cudaCrypt` function and prints the encrypted password.
   - Memory for input and output strings is dynamically allocated but lacks proper usage (e.g., overwriting allocated pointers).

### Advantages
1. **Simplicity**: Easy to understand and implement.
2. **Low Hardware Requirements**: Runs on any system with a standard CPU.
3. **No Parallelism Complexity**: Sequential execution avoids the need for managing threads or synchronization.

### Disadvantages
1. **Performance**: Slow for large-scale encryption tasks as it runs sequentially.
2. **No Decryption Support**: The program only supports encryption.

### Compilation and Execution
```bash
# Compile the program
gcc -o regular_encrypt regular_encrypt.c

# Run the program
./regular_encrypt
```

---

## 2. CUDA-based Encryption-Decryption Program (GPU-based)

### Description
This program extends the functionality of the regular encryption program by leveraging NVIDIA's CUDA framework to enable parallel processing on a GPU. In addition to encryption, this program also implements decryption to retrieve the original password from the encrypted one. The work is divided across multiple GPU threads and blocks to accelerate the computations.

### Functionality
- **Encryption**: Similar to the regular program, the password is encrypted into a 10-character string using parallel transformations.
- **Decryption**: The encrypted 10-character string is decrypted back into the original 4-character password using parallel GPU threads.
- **Validation**: The decrypted password is compared with the original input to ensure correctness.

### Key Methods and Variables
1. **`encryptKernel`**:
   - A CUDA kernel that performs encryption transformations in parallel.
   - Each thread handles a specific part of the transformation logic for a given character.
   - Memory transfer occurs between host and device using `cudaMemcpy`.

2. **`decryptKernel`**:
   - A CUDA kernel that reverses the encryption logic to decrypt the password.
   - Each thread is responsible for determining the original character from its transformations.

3. **Validation**:
   - After decryption, the original password and decrypted password are compared.
   - The result determines whether the decryption was successful.

4. **Main Method**:
   - Inputs:
     - Password from the user.
     - CUDA grid and block configuration (number of blocks and threads).
   - Steps:
     - Transfers data to the GPU, calls `encryptKernel`, retrieves encrypted data.
     - Displays encrypted password.
     - Initiates decryption using `decryptKernel` and retrieves the result.
     - Compares decrypted password with the original and displays success or failure.

5. **Variables**:
   - `passwordDevice`, `encryptedPasswordDevice`, `decryptedPasswordDevice`: Pointers to device memory.
   - `finalDecryptedPassword`: Holds the final decrypted password after retrieving it from the GPU.

### Advantages
1. **Performance**: Significantly faster for large-scale encryption and decryption tasks due to parallel processing.
2. **Support for Decryption**: Enables retrieval of the original password.
3. **Scalability**: Can handle a large number of passwords efficiently by leveraging GPU capabilities.

### Disadvantages
1. **Complexity**: More difficult to understand and implement due to parallel programming concepts.
2. **Hardware Requirements**: Requires an NVIDIA GPU and CUDA toolkit.
3. **Setup Overhead**: Users need to manage thread-block configurations and ensure proper memory handling between host and device.

### Compilation and Execution
#### Prerequisites
- An NVIDIA GPU with CUDA support.
- CUDA Toolkit installed on your system.

#### Compilation
```bash
# Compile the CUDA program
nvcc -o cuda_encrypt_decrypt cuda_encrypt_decrypt.cu
```

#### Execution
```bash
# Run the program
./cuda_encrypt_decrypt
```

---

## Key Differences
| Feature                     | Regular Encryption Program            | CUDA-based Encryption-Decryption Program |
|-----------------------------|----------------------------------------|-------------------------------------------|
| **Platform**                | CPU                                   | GPU                                       |
| **Parallelism**             | No                                    | Yes                                       |
| **Encryption**              | Supported                             | Supported                                 |
| **Decryption**              | Not Supported                         | Supported                                 |
| **Performance**             | Slower for large inputs               | Faster for large inputs                   |
| **Hardware Requirements**   | Standard CPU                          | NVIDIA GPU + CUDA Toolkit                 |
| **Complexity**              | Low                                   | High                                      |

---

## Conclusion
The Regular Encryption Program is a good choice for small-scale tasks and environments where simplicity and minimal hardware requirements are priorities. However, for high-performance applications, the CUDA-based program provides a powerful solution that takes advantage of GPU parallelism for both encryption and decryption.

Choose the program based on your specific needs, balancing ease of use against performance and scalability.

## License
This project is private and under the ownership of Neville Abolo

